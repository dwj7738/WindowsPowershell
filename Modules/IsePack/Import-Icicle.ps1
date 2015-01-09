function Import-Icicle
{
    param(
    # The Icicle File
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
    [Alias('Fullname')]
    [string]
    $File, 

    [Switch]
    $Force,

    [Switch]
    $DoNotShow
    )

    process {
        
        try {
            $resolvedFile = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($File)
        } catch {
            $findError = $_
            $icicleExists = Get-Module | 
                Split-Path | 
                Join-Path -ChildPath { "Icicles" } | 
                Join-Path -ChildPath { "${file}.icicle.ps1" } | 
                Where-Object {
                    Test-Path $_
                }

            if ($icicleExists) {
                $resolvedFile = $icicleExists | Select-Object -Unique | Select-Object -First 1 
            } else {
                Write-Error $findError
                return
            }
        }
        if (-not $resolvedFile) { 
            # Ok, we really could not find the icicle, so bounce out             
            return 
        } 


        $fileContent = [IO.File]::ReadAllText($resolvedFile) 

        $fileScriptBlock = [ScriptBlock]::Create($fileContent)
        if (-not $fileScriptBlock) { return}


        $resultTable = & $fileScriptBlock
       
        if (-not $resultTable) { return }
        
        if ($resultTable -isnot [Object[]] -and
            $resultTable -isnot [Hashtable]) {
            return
        }


        foreach ($rt in $resultTable) {
            if ($rt -isnot [Hashtable]) { continue }
            if (-not $rt.Name) { $rt.Name = (Get-Item "$resolvedFile").Name.Replace(".icicle.ps1", "").Replace(".icicle", "")} 
            if ($DoNotShow) { $rt.DoNotShow = $DoNotShow } 
            $rt.Force = $Force


            Add-Icicle @rt

        }
    }
} 
