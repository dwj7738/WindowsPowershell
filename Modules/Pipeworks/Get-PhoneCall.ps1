function Get-PhoneCall
{
    <#
    .Synopsis
        Gets information about phone calls
    .Description
        Gets information about phone calls sent to or from any Twilio Number
    .Example
        Get-PhoneCall
    #>
    param(   
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('Sid')] 
    [string]
    $CallSid, 

    # The Twilio credential 
    [Management.Automation.PSCredential]
    $Credential,
    
        
    # A setting storing the credential
    [Parameter(ValueFromPipelineByPropertyName=$true)]   
    [string]
    $Setting = "TwilioAccountDefault",
    
    [Switch]$IncludeRecording,
    
    [Switch]$IncludeTranscript

    )
    
    process {
        if (-not $Credential -and $Setting) {
            $userName = Get-WebConfigurationSetting -Setting "${Setting}_UserName"
            $password = Get-WebConfigurationSetting -Setting "${Setting}_Password"
            
            if ($userName -and $password) {
                $password = Get-WebConfigurationSetting -Setting "${Setting}_Password" |
                    ConvertTo-SecureString -AsPlainText -Force           
                $credential  = New-Object Management.Automation.PSCredential $username, $password 
            } elseif ((Get-SecureSetting -Name "$Setting" -ValueOnly | Select-Object -First 1)) {
                $credential = (Get-SecureSetting -Name "$Setting" -ValueOnly | Select-Object -First 1)
            }
            
            
        }
        if (-not $Credential) {
            Write-Error "No Twilio Credential provided.  Use -Credential or Add-SecureSetting TwilioAccountDefault -Credential (Get-Credential) first"               
            return
        }


        
        $getWebParams = @{
            WebCredential=$Credential
            Url="https://api.twilio.com/2010-04-01/Accounts/$($Credential.GetNetworkCredential().Username.Trim())/Calls"           
            AsXml =$true            
        }
        
        if ($callSid) {
            $getWebParams.Url = 
                "https://api.twilio.com/2010-04-01/Accounts/$($Credential.GetNetworkCredential().Username.Trim())/Calls/$CallSid"           
        }         
        
        Get-Web @getwebParams -Verbose |            
            Select-Object -ExpandProperty TwilioResponse | 
            Select-Object -ExpandProperty Calls | 
            Select-Object -ExpandProperty Call |
            ForEach-Object {
                $_.pstypenames.clear()
                $_.pstypenames.add('Twilio.PhoneCall')
                $_
                
                
            }
              
    }       
} 
 

 
 
