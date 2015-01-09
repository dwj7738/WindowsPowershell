function Start-PSNode
{
    <#
    .Synopsis
        Starts a lightweight local server
    .Description
        Starts a lightweight local server that uses the HttpListener class to create a simple server.  
        
        This server is unlike the Pipeworks in ASP.NET in many interesting ways:
        
        - Unlike Pipeworks within ASP.NET which lets each user have their own runspace, PSNode puts all users in the same runspace.  
        This makes it faster, and means all people connected share a lot of the same information (for better and worse).  
        Additionally, this runspace does not contain any modules, but can load any modules you have.
        - Unlike Pipeworks within ASP.NET, which runs in an Application Pool as the context of that restricted user, PSNode is always running as you and under and administrative account.
        This means a lot.  On the good side, it means you can do things ASP.NET cannot, like popping up a window on the desktop.  On the darker side, it means that if you allow arbitrary code execution in what you put up on PSNode, you have an endpoint that can do anything to a box in the context of the current user.
        - Unlike Pipeworks within ASP.NET, PSNode runs in any .exe
        This also means a lot.  
        PSNode may run within any process, and, because it is running in a process, certain components that require a permission associated with an interactive process will execute in PSNode and not in Pipeworks under ASP.NET    
    
    
        PSNode was inspired by a presentation from Bruce Payette at the PowerShell Deep Dive @ TEC2011 in Frankfurt, Germany
    .Example
        Start-PSNode -Server http://localhost:9090 -Command {
            "Hello World"
        }
    .Example
        Start-PSNode -Server http://localhost:9092/ -AuthenticationType IntegratedWindowsAuthentication -Command {
            "Hello $($User.Identity.Name)"
        }    
    #>
    [OutputType([Management.Automation.Job])]    
    param(
    # The server url, ie. http://localhost:9090/
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$Server,
    
    # The command to run within the server
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]   
    [ScriptBlock]$Command,
    
    # The authentication type
    [Net.AuthenticationSchemes]
    $AuthenticationType = "Anonymous", 
    
    # If set, will not return
    [Switch]$DoNotReturn    
    )

    begin {
        $ll = @()
        $lc  = @()
        $definePSNode = {
        Add-Type -IgnoreWarnings @'
using System;
using System.Collections.Generic;
using System.Text;
using System.Net;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Threading;
using System.Security.Principal;

public class PSNode
{
    RunspacePool Pool
    {
        get
        {
            if (_pool == null)
            {
                _pool = RunspaceFactory.CreateRunspacePool();
                _pool.ThreadOptions = PSThreadOptions.ReuseThread;
                _pool.ApartmentState = System.Threading.ApartmentState.STA;
                _pool.Open();
            }
            return _pool;
        }
    }
    RunspacePool _pool;
    ScriptBlock action;
    
    private PSNode(ScriptBlock command)
    {
        WindowsIdentity current = System.Security.Principal.WindowsIdentity.GetCurrent();
        WindowsPrincipal principal = new WindowsPrincipal(current);
        if (!principal.IsInRole(WindowsBuiltInRole.Administrator))
        {
            throw new UnauthorizedAccessException();
        }

        this.action = command;        
    }
    
    
        
    public static AsyncCallback GetCallback(ScriptBlock action)
    {
        PSNode instance = new PSNode(action);
        
        return new AsyncCallback(instance.ListenerCallback);
    }

    public void ListenerCallback(IAsyncResult result)
    {
        try
        {
            HttpListener listener = (HttpListener)result.AsyncState;

            // Call EndGetContext to complete the asynchronous operation.        
            HttpListenerContext context = listener.EndGetContext(result);
            HttpListenerRequest request = context.Request;

            // Obtain a response object.
            HttpListenerResponse response = context.Response;

            string responseString = "";
            using (
                PowerShell command = PowerShell.Create()
                                            .AddScript(action.ToString(), false)
                                                .AddArgument(request)
                                                    .AddArgument(response)
                                                        .AddArgument(context)
                                                            .AddArgument(context.User)
            )
            {
                command.RunspacePool = Pool;
                
                int offset = 0;

                try
                {
                    foreach (PSObject psObject in command.Invoke<PSObject>())
                    {
                        if (psObject.BaseObject == null) { continue; }
                        byte[] buffer = System.Text.Encoding.UTF8.GetBytes(psObject.ToString());
                        response.OutputStream.Write(buffer, offset, buffer.Length);
                        offset += buffer.Length;
                    }
                    foreach (ErrorRecord error in command.Streams.Error)
                    {
                        byte[] buffer = System.Text.Encoding.UTF8.GetBytes("<span style='color:red'>"  + error.Exception.Message  + " at "  + error.InvocationInfo.PositionMessage + "</span>");
                        response.OutputStream.Write(buffer, offset, buffer.Length);
                        offset += buffer.Length;
                    }
                }
                catch (Exception ex)
                {
                    byte[] buffer = System.Text.Encoding.UTF8.GetBytes(ex.Message);
                    response.StatusCode = 500;
                    response.OutputStream.Write(buffer, offset, buffer.Length);
                    offset += buffer.Length;
                }
                finally
                {
                    response.Close();
                }
            }
        }
        catch (Exception e)
        {
        }
    }


}
'@    
        }
    }

    process {
        
        $listenerLocation = $server
        if ($listenerLocation -notlike "*/") {
            $listenerLocation += "/"
        }
        $ListenerCommand = $command
        
        $ll += $listenerLocation
        $lc += $listenerCommand
    } 

    end {
        $StartTime  =Get-Date
          
         
        
             
        
        $node = for ($i = 0; $i -lt $ll.Count; $i++) {
            $listenerLocation = $ll[$i]
            $listenerCommand = $lc[$i]
            
            Start-Job -InitializationScript $definePSNode -ArgumentList $listenerLocation, $ListenerCommand, $AuthenticationType -Name $listenerLocation -ScriptBlock {
                param($listenerLocation, $listenerCommand, $AuthenticationType) 
                
                # Create a listener and add the prefixes.
                $listener = New-Object System.Net.HttpListener
                $listener.AuthenticationSchemes =$AuthenticationType
                $listener.Prefixes.Add($ListenerLocation);

                # Start the listener to begin listening for requests.
                $listener.Start();
                $callBack = [PSNode]::GetCallback(
                    [ScriptBLock]::create('param($request, $response, $context, $user)
                    if ("$($request.QueryString)") {        
                        $query = ([uri]$request.RawUrl -split "/")[-1]                
                        $query.TrimStart("?") -split "&" |
                            ForEach-Object -Begin {
                                $requestParams = @{}
                            } -Process { 
                                $key, $value = $_ -split "="
                                $requestParams[[Web.HttpUtility]::UrlDecode($key)] = [Web.HttpUtility]::UrlDecode($value)
                            } -End {
                                $request | 
                                    Add-Member NoteProperty Params $RequestParams -Force 
                            }                                
                    }
                ' + $ListenerCommand)) 

                if (-not $callback) { return } 

                while (1)
                {
                    $result = $listener.BeginGetContext($callback, $listener);    
                    $null = $result.AsyncWaitHandle.WaitOne();    
                }

                $listener.Close()            
            }
        }
         
        
        if ($DoNotReturn) {
            do {
                Write-Progress "Pipeworks PSNode Running on $ListenerLocation" "Since $StartTime" 
                $node | Receive-Job
                Start-Sleep -Seconds 1 
            } while(1)
            return   
        }        
        
        
        $node
        

    }

} 
