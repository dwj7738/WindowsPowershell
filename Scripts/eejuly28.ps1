#region functions

function install_roles {
Write-host ('Installing Roles')
#{d:.\setup.com /mode:install /roles:mb,ht,ca,mt
#Set-service NetTcpPortSharing -startuptype automatic
}

function install_prereq {
    Write-Host('Installing Prerequesites')
    #Import-Module servermanager
    #add-WindowsFeature file-services,web-webserver,net-framework,Web-Basic-Auth,Web-Windows-Auth,`
    #    Web-Digest-Auth,Web-Client-Auth,Web-Filtering,Web-Stat-Compression,Web-Dyn-Compression,`
    #	Web-Mgmt-Console,Web-Metabase,Web-WMI,Web-Lgcy-Mgmt-Console,RSAT,RPC-over-HTTP-Proxy,WAS -Restart
  
    }

function my-certreq {
param(
    [Parameter(Mandatory=$true)]
    $servername
    )
#New-ExchangeCertificate -generaterequest -subjectname "dc=com,dc=company,dc=line,cn=server.company.com" '
# -domainname server.company.com, server, autodiscover.company.com, webmail, webmail.line.stenanet.com, '
#   webmail.stenaline.com -PrivateKeyExportable $true
Write-Host("Requesting Certificate for $servername")
}	

function mycert-import {
param(
    [Parameter(Mandatory=$true)]
    $servername 
    )
Write-Host ("Importing Certificate for $servername")
}
#endregion


cls
write-host('1. install prerequesites')
write-host('2. install roles')
write-host('3. certificate request')
write-host('4. import cert')
Write-Host('0. Exit')
while ($true){
$value = Read-Host "Input your selection (0-4)"
switch ($value)
{
	"0"{ exit }
	"1" { install_prereq  }
	"2" {	install_roles }
	"3" {	my-certreq    }
	"4" { $servername = $null
            mycert-import   
            }
default { exit }
	}
}

