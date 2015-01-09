function Publish-AzureService
{
    <#
    .Synopsis
        Publishes one or more modules as azure services
    .Description
        Publishes one or more modules as azure services, according to the DomainSchematic found in the Pipeworks manifest
    .Example
        Get-Module Pipeworks | 
            Publish-AzureService
    .Link
        Out-AzureService
    #>
    [OutputType([IO.FileInfo])]
    param(
    # The name of the module
    [ValidateScript({
        if ($psVersionTable.psVersion -lt '3.0') {
            if (-not (Get-Module $_)) {
                throw "Module $_ must be loaded"            
            }
        }        
        return $true
    })]        
    [Parameter(Mandatory=$true,Position=0,ParameterSetName='LoadedModule',ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
    [Alias('Module')]
    [string[]]
    $Name,
    
    # The VMSize of the deployment
    [ValidateSet('ExtraSmall','Small','Medium', 'Large', 'Extra-Large', 'XS', 'XL', 'S', 'M', 'L')]
    [string]
    $VMSize = 'ExtraSmall',
    
    # The name of the deployment   
    [string]
    $DeploymentName = 'MyPipeworksService',
    
    # If set, deletes local deployments after packaging.
    [Switch]
    $CleanupAfterDeployment,
    
    # The instance count
    [Uint32]
    $InstanceCount = 1,

    [Switch]
    $AsJob,

    [Switch]
    $Wait

    )
    
    begin {
        $progId = Get-Random
        $serviceDirectories = @()
        $azureServiceDefinition = New-AzureServiceDefinition -ServiceName $DeploymentName |
            Add-AzureRole -RoleName $DeploymentName -VMSize $vmSize
        $moduleNAmes = @()

        $jobs = @()
    }
    
    process {
        $moduleNAmes  += $name                        
    }
    
    end {
        $c = 0 
        foreach ($moduleName in $moduleNames) {
            if ($psVersionTable.PSVersion -ge '3.0') {
                $myModulePath = $env:PSModulePath -split ";" | Select-Object -First 1
                $moduleRoot = Join-Path $myModulePath $moduleName
            } else {
                $RealModule = Get-Module $moduleName
                $moduleList = @($RealModule.RequiredModules | 
                        Select-Object -ExpandProperty Name) + $realModule.Name

                $perc  =($c / $moduleNames.Count) * 100
                $c++
                Write-Progress "Publishing Modules" "$moduleName" -PercentComplete $perc -Id $progId 
                $module = Get-Module $moduleName
                if ($module.Path -like "*.ps1") {
                    continue
                }
                $moduleRoot = $module | Split-Path | Select-Object -First 1 
                
            }
            $manifestPath = "$moduleRoot\$($modulename).pipeworks.psd1"
            $pipeworksManifestPath = Join-Path $moduleRoot "$($moduleName).Pipeworks.psd1"
            
            
            $pipeworksManifest = 
                if (Test-Path $pipeworksManifestPath) {
                    try {                     
                        & ([ScriptBlock]::Create(
                            "data -SupportedCommand Add-Member, New-WebPage, New-Region, Write-CSS, Write-Ajax, Out-Html, Write-Link { $(
                                [ScriptBlock]::Create([IO.File]::ReadAllText($pipeworksManifestPath))                    
                            )}"))            
                    } catch {
                        Write-Error "Could not read pipeworks manifest for $moduleName" 
                    }                                                
                }


            if (-not $pipeworksManifest) {
                Write-Error "No Pipeworks manifest found for $moduleName"
                continue
            }
            
            
            
            if (-not $pipeworksManifest.DomainSchematics) {
                Write-Error "Domain Schematics not found for $moduleName"
                continue
            }

            $moduleServiceParameters = @{
                Name = $moduleName
            }

            
            if ($pipeworksManifest.PublishDirectory) {
                $baseName = $pipeworksManifest.PublishDirectory
            } else {
                $baseName = "${env:SystemDrive}\inetpub\wwwroot\$moduleName" 
            }
            
            
            
            
            foreach ($domainSchematic in $pipeworksManifest.DomainSchematics.GetEnumerator()) {
                if ($pipeworksManifest.AllowDownload) {
                    $moduleServiceParameters.AllowDownload = $true
                }                                
                $domains = $domainSchematic.Key -split "\|" | ForEach-Object { $_.Trim() }
                $schematics = $domainSchematic.Value
                
                if ($schematics -ne "Default") {
                    $moduleServiceParameters.OutputDirectory = "$baseName.$($schematics -join '.')"
                    $moduleServiceParameters.UseSchematic = $schematics                
                } else {
                    $moduleServiceParameters.OutputDirectory = "$baseName"
                    $moduleServiceParameters.Remove('UseSchematic')
                }                


                

                
                if ($AsJob) {
                    if ($psVersionTable.PSVersion -ge '3.0') {
                        $convertScript = "
Import-Module Pipeworks
Import-Module $ModuleName
"
                    } else {
                        $convertScript = "
Import-Module Pipeworks
Import-Module '$($moduleList -join "','")';"
                    }
                    
                $convertScript  += "
`$ModuleServiceParameters = "
                $convertScript  += $moduleServiceParameters | Write-PowerShellHashtable
                $convertScript  += "
ConvertTo-ModuleService @moduleServiceParameters -Force"
                
                    $convertScript = [ScriptBlock]::Create($convertScript)
                    Write-Progress "Launching Jobs" "$modulename"
                    $jobs += Start-Job -Name $moduleName -ScriptBlock $convertScript
                } else {
                    
                    ConvertTo-ModuleService @moduleServiceParameters -Force
                }
                


                $serviceDirectories += $moduleServiceParameters.OutputDirectory 
                $azureServiceDefinition = $azureServiceDefinition | 
                    Add-AzureWebSite -SiteName "$($moduleName).$($schematics -join '.')" -PhysicalDirectory $moduleServiceParameters.OutputDirectory -HostHeader $domains
            }   
            
            
            if ($pipeworksManifest.DomainCommands) {
                foreach ($domainCommands in $pipeworksManifest.DomainCommands.GetEnumerator()) {
                    $domains = $domainCommands.Key -split "\|" | ForEach-Object { $_.Trim() }
                    $cmdName = $domainCommands.Value
                    
                    $moduleServiceParameters.StartOnCommand = $cmdName
                    $moduleServiceParameters.OutputDirectory = "$baseName.$($cmdName)"
                    ConvertTo-ModuleService @moduleServiceParameters -Force
                    $serviceDirectories += $moduleServiceParameters.OutputDirectory 
                    $azureServiceDefinition = $azureServiceDefinition | 
                        Add-AzureWebSite -SiteName "$($moduleName).$($cmdName)" -PhysicalDirectory $moduleServiceParameters.OutputDirectory -HostHeader $domains
                }
            }
        }
        
                
        if ((-not $asJob) -or ($AsJob -and $Wait)) {

            $Activity = "Build $DeploymentName"
            $runningJobs = $jobs | 
                Where-Object { $_.State -eq "Running" }
        
            while ($runningJobs) {
                $runningJobs = @($jobs | 
                    Where-Object { $_.State -eq "Running" })
                $jobs | Wait-Job -Timeout 1 | Out-Null
                $jobs | 
                    Receive-Job             

                $percent = 100 - ($runningJobs.Count * 100 / $jobs.Count)
            
                Write-Progress "Waiting for $Activity to Complete" "$($Jobs.COunt - $runningJobs.Count) out of $($Jobs.Count) Completed" -PercentComplete $percent
            
                    
            }

            Write-Progress "Creating Deployment Package" "$DeploymentName" -Id $progId -PercentComplete 100
            if ($serviceDirectories) {
                $azureServiceDefinition |
                    Out-AzureService -OutputPath "$home\Documents\$DeploymentName" -InstanceCount $InstanceCount
            }
        
        
            if ($CleanupAfterDeployment) {
                foreach ($s in $serviceDirectories) {
                    Remove-Item -Path $s -Recurse -Force
                }
            } else {
                Write-Progress "Creating Deployment Package" "$DeploymentName" -Id $progId -Completed
            }

        }
                
        
        
        
    }
} 
