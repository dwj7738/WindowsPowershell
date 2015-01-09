function Expand-Zip
{
    <#
    .Synopsis
        Expands the contents of a Zip file
    .Description
        Expands the contents of a Zip file that was compressed with Out-Zip.
    .Example
        
    #>
    param(
    # The path of the zip file
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [Alias('Fullname', 'Filename', 'ZipFile')]
    [string]
    $ZipPath,

    # The output directory.  By default, this will be the name of the zip file.
    [string]
    $OutputPath
    )
    
    process {
        
        $fullPAth = "$($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ZipPath))"
        $file = Get-Item $fullPAth
        if (-not $fullpath) { return } 
        $package = [IO.Packaging.Package]::Open($fullpath, "Open", "Read")
        if (-not $package) { return } 
        $relationships = $package.GetRelationships()
        $parts = $package.GetParts()
        
        if (-not $outputPath) {
            $OutputPath = Join-Path $pwd $file.Name.Replace(".zip", "")

        }
        
        if (-not (Test-Path $OutputPath)) {
            $null = New-Item -ItemType Directory -path $OutputPath  -Force
        }
        $partCount = @($parts).Count
        $pc = 0
        

        $extractedParts = foreach ($p in $parts) {        
            
            $pStream = $p.GetStream("Open", "Read")
            $byteArray = New-Object Byte[] $pStream.Length
            $readCount = $pStream.Read($byteArray, 0, $pStream.Length)
            $file = New-Object PSObject -Property @{
                Uri = $p.Uri
                ContentType = $p.ContentType
                Content = $byteArray
            }

            $outputFileName = Join-Path (Resolve-path $OutputPath) $file.Uri

            $parentDir = $outputFileName | Split-Path 
            if (-not (Test-Path $parentDir)) {
                $null = New-Item -ItemType Directory -Path $parentDir -Force
            }

            
        
            #$partDict[$p.Uri] = "$strWrite"
            $pStream.Close()            
            $perc = $pc * 100 / $partCount
            $pc++
            Write-Progress "Extracting Files" "$($file.Uri.ToString().Replace("/", "\"))" -PercentComplete $perc
            [IO.File]::WriteAllBytes($outputFileName, $byteArray)
        }
        
        #$openXmlDocument.Parts = $extractedParts
        #$openXmlDocument.Relationships = $relationships
        #New-Object PSObject -Property $openXmlDocument
        
        $package.Close()
        
        return
                        
        $uri = New-Object Uri "/word/document.xml", ([UriKind]::Relative)
        $packagePart = $package.CreatePart($uri, "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml")
        
        $streamPart = New-Object IO.StreamWriter $packagePart.GetStream("Create","Write")
        (New-Object Xml.XmlDocument).Save($streamPart)
        $streamPart.Close()
        $package.Flush()
        
        $packagePart = $package.CreateRelationship($uri,
            "Internal",
            "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument",             
            "rId1")
    
        $package.Flush()
        $package.Close()
    }
    
}
 
