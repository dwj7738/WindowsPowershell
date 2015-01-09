function Add-Text{
<#
        .Synopsis
         Adds a User Defined String to the Second Line of a File and then writes it to another file
         
        .Example
         Add-String string infile outfile
         
         
       
        .Example
         Start-Countdown -Seconds 10 -ProgressBar
         
         This method will display a progress bar on screen without clearing.
                 
        .Link
         http://www.vtesseract.com/
        .Description
====================================================================
Author(s):              David Johnson
File:                   Add-Text.ps1
Date:                   2012-04-27
Revision:               1.0
References:             
 
====================================================================
Disclaimer: This script is written as best effort and provides no
warranty expressed or implied. Please contact the author(s) if you
have questions about this script before running or modifying
====================================================================
#>
$additionaltext = $args[0]
$infile = $args[1]
$outfile = $args[2]

Write-Host "Infile=" $args[1] 
Write-Host "Outfile=" $args[1] 
Write-Host "Text to be added:" $args[0]


$reader = [System.IO.File]::OpenText($infile)
$writer = [System.Io.File]::CreateText($outfile)
$linecounter = 1
try {
    for(;;) {
        $line = $reader.ReadLine()
        if ($line -eq $null) { break }
        # process the line
       if ($linecounter -eq 2) { $writer.WriteLine($additionaltext) }
       $writer.WriteLine($line)
       $linecounter = $linecounter + 1
       }
}
finally {
    $reader.Close()
    $writer.Close()

}
Get-Content $outfile 
}





