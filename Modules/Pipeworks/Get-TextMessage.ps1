function Get-TextMessage
{
    <#
    .Synopsis
        Gets text messages
    .Description
        Get text messages sent to a Twilio number
    .Example
        Get-TextMessage
    .Link
        Twilio.com
    .Link
        Send-TextMessage
    #>

    param(    
    # The credential used to get the texts
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Management.Automation.PSCredential]
    $Credential,
    
    
    # A setting storing the credential
    [Parameter(ValueFromPipelineByPropertyName=$true)]   
    [string]
    $Setting = "TwilioAccountDefault"
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
            Url="https://api.twilio.com/2010-04-01/Accounts/$($Credential.GetNetworkCredential().Username.Trim())/SMS/Messages.xml"           
            AsXml =$true            
        }        
        Get-Web @getwebParams -Verbose |
            
            Select-Object -ExpandProperty TwilioResponse | 
            Select-Object -ExpandProperty SmsMessages | 
            Select-Object -ExpandProperty SMSMessage |
            ForEach-Object {
                $_.pstypenames.clear()
                $_.pstypenames.add('Twilio.TextMessage')
                $_
            }
              
    }       
}