function Get-FtpFile {
	<#
		.SYNOPSIS
			Retrieves A file from an FTP Server

		.DESCRIPTION
			Using a Powershell Module this script retrievesa file from an ftp server

		.PARAMETER  Username
			The Username required to login to the ftp server
	
		.PARAMETER  Password
			The Password associated with the Username
		
		.PARAMETER  FtpServer
			The url for the Ftp server i.e. ftp:\\ftp.example.com
		
		.PARAMETER  Serverpath
			The path to the file on the ftp server
		
		.PARAMETER  LocalPath
			Where you want the file saved
		.PARAMETER  Password
			The Password associated with the Username
		.PARAMETER  Password
			The Password associated with the Username

		.EXAMPLE
			PS C:\> Get-FtpFile -username USERNAME -password PASSWORD -ftpserver ftp:\\ftp.example.com -serverpath /abc/ -localpath c:\temp -filename fileame.txt

		.EXAMPLE
			PS C:\> Get-FtpFile -username USERNAME -password PASSWORD -ftpserver ftp:\\ftp.example.com -filename fileame.txt

		.NOTES
			Additional information about the function go here.

		
#>	
	<#
param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 	[System.String] $username,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 	[System.String] $password,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 	[System.String] $ftpserver,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]  [System.String] $filename,
	[System.String] $serverpath,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]  [System.String] $localpath
	)
#>

Import-Module psftp
# get the module from http://gallery.technet.microsoft.com/scriptcenter/PowerShell-FTP-Client-db6fe0cb
#
# initiaize a few variables
#
$username = "USERNAME"
$password = "PASSWORD"
$FtpServer = "localhost"
$localpath = "C:\test\"
$filename = "117871293-Instagram-class-action-lawsuit.pdf"
$path = Test-Path $localpath
if ($path -eq $false) {
$("Path: " + $localpath + " Does NOT Exist. Returning...")
Return 4
}
#
# set credentials
#
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr
#
#connect to ftp server
#
Set-FTPConnection -Credentials $credentials -Server $FtpServer -UseBinary 
#
#  Test to see if the file exists by getting the file size by name.
#  If a -1 is Returned, the file does not exist.
try{
$remotefileSize = Get-FTPItemSize -Path $filename
}
catch{
$("Error Accessing the file.. Check that the File Exists..")
Return 5
}
$("The file exists and is " + $remotefileSize + " bytes in size")   
#
# transfer the file
#
Get-FTPChildItem -path $filename -Recurse | Get-FTPItem -localpath $localpath -RecreateFolders

#
# check recieved file is the same size as the remote filesize
#
$filesize = Get-childItem  -Path $localpath -Filter $filename
$localfilesize = $fileSize.length
if ($localfilesize -ne $remotefileSize) {
Write-Output("The Remote and Local Files don't have the same length")
Return 3
}
}


