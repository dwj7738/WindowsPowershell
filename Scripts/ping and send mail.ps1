###########################################################################
#
# NAME: 
#
# AUTHOR:  David Johnson
#
# COMMENT: 
#
# VERSION HISTORY:
# 1.0 11-Sep-2012 - Initial release
#
###########################################################################
$servername = "s2k8r2e"
$from = "powershell@domain.com"
$to = "administrator@dowmain.com"
$r = Test-Connection -ComputerName $servername -Count 1 -Quiet -Source localhost -ErrorAction SilentlyContinue
if ( $r -eq $false){
	Write-Output ("Server $servername is Down")
	Send-MailMessage -From $from -To $to -Subject "Server Down" -Body "Server $servername is down"
	}
	else { 
	Write-Output ("Server $servername is UP") }