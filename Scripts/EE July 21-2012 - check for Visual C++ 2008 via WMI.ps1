
$Computers = (Get-Content c:\ComputerList.txt)
ForEach ($Computer In $Computers){
	$installed = "IS NOT"
	if (
	(Get-WmiObject -ComputerName $Computer Win32_Product  -Filter "Name LIKE '%Visual C++ 2008%'")`
	-ne $null )	{ $installed = "IS" }
	Write-output ("$computer : Windows Visual C++ 2008 Redistributable $installed Installed")
}
	

