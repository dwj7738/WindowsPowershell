$inputfilepath = "C:\Test\in\"
$pathprocessed = "C:\Test\processed\"
$server = "c:\Test\server\"

function create{
	if ((Test-Path $inputfilepath) -ne $true) {mkdir $inputfilepath}
	for ($i=0;$i -le 50; $i++) {
		$date = Get-Date -Format "MMddyy_hhmmss"
		$part1 = "XmlData_"
		$end = "FFF_Rotech#xcbl-v3_5#Order.xml"
		$filename = $part1 + $date + $end
		Write-Output $filename > ($inputfilepath + $filename)
		Start-Sleep -Seconds 1
		$filename
		}
}
function test {
$files = Get-ChildItem $inputfilepath -name
foreach ($file in $files) {
$dir = $file.substring(8,6)
$from = $inputfilepath +$file
$to = $pathprocessed + $dir +"\"
if ((Test-Path $to) -ne $true) {
	mkdir $to
	}
$to = $to + $file 
if ((test-path $to) -ne $true){Copy-Item  $from $to }
if ((Test-Path $server) -ne $true) {mkdir $server}
Move-Item $from $server

}
}