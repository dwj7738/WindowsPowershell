function Add-PowerGUIMenu {
    <#
    .Synopsis
        Helper function to add menus to the PowerGUI Script Editor
    .Description
        Makes adding menus to the PowerGUI Script Editor
        easier.  Add-PowerGUIMenu accepts a hashtable of menus.  
        Each key is the name of the menu.
            Keys are automatically alphabetized, unless the 
        Each value can be one of three things:
            - A Script Block
                Selecting the menu item will run the script block
            - A Hashtable
                The value will be used to create a nested menu
            - A Script Block with a note property of ShortcutKey
                Selecting the menu item will run the script block.
                The ShortcutKey will be used to assign a shortcut key to the item
    .Example
        Add-PowerGuiMenu -Name "Get" @{
            "Process" = { Get-Process } 
            "Service" = { Get-Service } 
            "Hotfix" = {Get-Hotfix}
        }
    .Example
        Add-PowerGuiMenu -Name "Verb" @{
            Get = @{
                Process = { Get-Process }
                Service = { Get-Service } 
                Hotfix = { Get-Hotfix } 
            }
            Import = @{
                Module = { Import-Module } 
            }
        }
    #>
    [CmdletBinding(DefaultParameterSetName='AddMenuItem')] 
    param(
        #The name of the menu to create 
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String]
        $Name,
        # The contents of the menu
        [Parameter(Mandatory=$true,
                Position=0,
                ValueFromPipelineByPropertyName=$true,
                ParameterSetName='AddMenuItem')]
        [Hashtable]$Menu,
        
        # The Menu File
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName='MenuFile')]
        [Alias('Fullname')]
        [string]
		$MenuFile,
		
        # The root of the menu.  This is used automatically by Add-IseMenu when it 
        # creates nested menus.
        [Parameter(ParameterSetName='AddMenuItem')]
		[PSObject]
        $Root,
        # If PassThru is set, the menu items will be outputted to the pipeline        
        [switch]$PassThru,
        # If Merge is set, menu items will be merged with existing menus rather than
        # recreating the entire menu.
        [switch]$Merge,        
		
		# If DoNotSort is set, menu items will not be sorted alphabetically
		[switch]$doNotSort
    )
    

    begin {
    	$pgSE= [Quest.PowerGUI.SDK.ScriptEditorFactory]::CurrentInstance
		Set-StrictMode -Off
		$myCommandName = $MyInvocation.InvocationName
		
	}
	
	process {
        if ($psCmdlet.ParameterSetName -eq 'MenuFile') {
            $resolvedPsPath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($MenuFile)
            $Menu = & $MenuFile
        }
		$menuPointer = $null
		if (-not $Root) {
			# The "root" is actually a list of menu names that lead to the current item
			$existingMenu = $pgSE.Menus | Where-Object { $_.Command.FullName -eq "Menu.${Name}" }
			if ($existingMenu) {
				 if (-not $Merge) 
				 {
					$existingMenu.Items.Clear()
				 }
				 $menuPointer = $existingMenu 
			} else {
				$menuPointer = New-Object Quest.PowerGUI.SDK.MenuCommand "Menu","$Name" -Property @{
					Text = $Name.Replace("_", "&")
				}
				$pgSE.Menus.Add($menuPointer)
			}
		} else {
			if ($Root -is [string] -and $newMenu) {
				$Root = $newMenu
			}
			$menuPointer = $Root 
			<#
			$currentItem = $null
			for ($i = 0; $i -lt $Root.Count; $i++) {
				if ($i -eq 0) {
					# First case, root is the menu
					$currentItem = $pgSE.Menus | Where-Object { $_.Command.FullName  -eq $Root[$i] }					
				} else {
					$currentItem = $currentItem.Items | Where-Object { $_.Command.FullName -eq $Root[$i] } 
				}				
				if (-not $currentItem) { break }
			}
			if ($currentItem) {
				$menuPointer = $currentItem
			}
			#>
			
		}
		
		    
	    $menuItems = $Menu.GetEnumerator()
		if (-not $doNotSort) {
        	$menuItems = $menu.GetEnumerator() | 
            	Sort-Object Key
    	} else {
        	$menuItems = $menu.GetEnumerator()            
    	}
		foreach ($menuItem in $menuItems) {
            switch ($menuItem.Value) {
                { $_ -is [Hashtable] } {
                    # Nested menu, recurse
					$newMenu = New-Object Quest.PowerGUI.SDK.MenuCommand "Menu","$($menuItem.Key)" -Property @{
						Text = $menuItem.Key.Replace("_", "&")
					}                    					
					$r = $root + "Menu.$($MenuItem.Key)"
                    Add-PowerGUIMenu -Name $menuItem.Key -Menu:$_ -root $newMenu -merge:$merge -passThru:$passThru
					
					if (-not $Root) { 
						$pgSE.Menus.Item("Menu.${Name}").Items.Add($newMenu)
					} else {
						$menuPointer.Items.Add($newMenu)
					}	
					break
				}
				default {		
					
					$scriptBlock= [ScriptBlock]::Create(					
					"
					[Quest.PowerGUI.SDK.ScriptEditorFactory]::CurrentInstance.Execute({$_},`$true)					
					"															
					)
					# To correctly add and remove command entries, they have to be unique.
					# To uniquify them, make the command the full path to the object
					# by peeking up the callstack and finding out the names of the parent menus
					# Nifty trick, right?									
					$restOfName = @(Get-PSCallStack | 
						Where-Object { $_.InvocationInfo.InvocatioName -eq $myCommand } |
						Select-Object -ExpandProperty InvocationInfo | 
						ForEach-Object { $_.BoundParameters.Name } |
						Where-Object { $_ })
						
					$restOfName += $menuItem.Key
						
					
					$ofs = "."				
					$fullname = "Menu.${restOfName}"
					$itemCommand = New-Object Quest.PowerGUI.SDK.ItemCommand "Menu","$restOfName" -Property @{
						Text = $menuItem.Key.Replace("_", "&")
						ScriptBlock = $scriptBlock
					}
					$oldCommands = $pgSE.Commands | 
						Where-Object { $_.FullName -eq $fullname }
						
					if ($oldCommands) {
						foreach ($cmd in $oldCommands) {
							$null = $pgSE.Commands.Remove($cmd)
						}
					}
										
					if ($_.ShortcutKey) {
						# Add a shortcut key
						$saferKey = $_.ShortcutKey.Replace("ALT", "Alt").Replace("CONTROL", "Control").Replace("SHIFT", "Shift").Replace("LEFT","Left").Replace("RIGHT", "Right")
						$itemCommand.AddShortcut($saferKey)							
					}
					if ($_.Image) {
						# Add an image
						# Expand the image string.  By doing this here it enables the menu to use $psScriptRoot
						# which lets images be stored within a module
						$expandedImageString = $ExecutionContext.InvokeCommand.ExpandString($_.Image)
						$existsAndValidPAth = Resolve-Path $expandedImageString -ErrorAction SilentlyContinue
						$realItem= Get-Item $existsAndValidPAth 
						if ($existsAndValidPAth ) {
							$image = [Drawing.Image]::FromFile($realItem.Fullname)
							if ($image) {
								$itemCommand.Image = $image
							}
						}
					}					
										
					$null = $pgSE.Commands.Add($itemCommand)
					if (-not $Root) { 
						$pgSE.Menus.Item("Menu.${Name}").Items.Add($itemCommand)
					} else {
						$MenuPointer.Items.Add($itemCommand)
					}

					
															
					if ($passThru) { $itemCommand }
				}								
            }
		}
	}
}
# SIG # Begin signature block
# MIINGAYJKoZIhvcNAQcCoIINCTCCDQUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlbNeNvTkUa4sQgMOpVxOzplj
# ZwigggpaMIIFIjCCBAqgAwIBAgIQAupQIxjzGlMFoE+9rHncOTANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE0MDcxNzAwMDAwMFoXDTE1MDcy
# MjEyMDAwMFowaTELMAkGA1UEBhMCQ0ExCzAJBgNVBAgTAk9OMREwDwYDVQQHEwhI
# YW1pbHRvbjEcMBoGA1UEChMTRGF2aWQgV2F5bmUgSm9obnNvbjEcMBoGA1UEAxMT
# RGF2aWQgV2F5bmUgSm9obnNvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAM3+T+61MoGxUHnoK0b2GgO17e0sW8ugwAH966Z1JIzQvXFa707SZvTJgmra
# ZsCn9fU+i9KhC0nUpA4hAv/b1MCeqGq1O0f3ffiwsxhTG3Z4J8mEl5eSdcRgeb+1
# jaKI3oHkbX+zxqOLSaRSQPn3XygMAfrcD/QI4vsx8o2lTUsPJEy2c0z57e1VzWlq
# KHqo18lVxDq/YF+fKCAJL57zjXSBPPmb/sNj8VgoxXS6EUAC5c3tb+CJfNP2U9vV
# oy5YeUP9bNwq2aXkW0+xZIipbJonZwN+bIsbgCC5eb2aqapBgJrgds8cw8WKiZvy
# Zx2qT7hy9HT+LUOI0l0K0w31dF8CAwEAAaOCAbswggG3MB8GA1UdIwQYMBaAFFrE
# uXsqCqOl6nEDwGD5LfZldQ5YMB0GA1UdDgQWBBTnMIKoGnZIswBx8nuJckJGsFDU
# lDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAw
# bjA1oDOgMYYvaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1j
# cy1nMS5jcmwwNaAzoDGGL2h0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFz
# c3VyZWQtY3MtZzEuY3JsMEIGA1UdIAQ7MDkwNwYJYIZIAYb9bAMBMCowKAYIKwYB
# BQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwgYQGCCsGAQUFBwEB
# BHgwdjAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME4GCCsG
# AQUFBzAChkJodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEy
# QXNzdXJlZElEQ29kZVNpZ25pbmdDQS5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG
# 9w0BAQsFAAOCAQEAVlkBmOEKRw2O66aloy9tNoQNIWz3AduGBfnf9gvyRFvSuKm0
# Zq3A6lRej8FPxC5Kbwswxtl2L/pjyrlYzUs+XuYe9Ua9YMIdhbyjUol4Z46jhOrO
# TDl18txaoNpGE9JXo8SLZHibwz97H3+paRm16aygM5R3uQ0xSQ1NFqDJ53YRvOqT
# 60/tF9E8zNx4hOH1lw1CDPu0K3nL2PusLUVzCpwNunQzGoZfVtlnV2x4EgXyZ9G1
# x4odcYZwKpkWPKA4bWAG+Img5+dgGEOqoUHh4jm2IKijm1jz7BRcJUMAwa2Qcbc2
# ttQbSj/7xZXL470VG3WjLWNWkRaRQAkzOajhpTCCBTAwggQYoAMCAQICEAQJGBtf
# 1btmdVNDtW+VUAgwDQYJKoZIhvcNAQELBQAwZTELMAkGA1UEBhMCVVMxFTATBgNV
# BAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIG
# A1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTEzMTAyMjEyMDAw
# MFoXDTI4MTAyMjEyMDAwMFowcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGln
# aUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUgU2lnbmluZyBDQTCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAPjTsxx/DhGvZ3cH0wsxSRnP0PtFmbE620T1
# f+Wondsy13Hqdp0FLreP+pJDwKX5idQ3Gde2qvCchqXYJawOeSg6funRZ9PG+ykn
# x9N7I5TkkSOWkHeC+aGEI2YSVDNQdLEoJrskacLCUvIUZ4qJRdQtoaPpiCwgla4c
# SocI3wz14k1gGL6qxLKucDFmM3E+rHCiq85/6XzLkqHlOzEcz+ryCuRXu0q16XTm
# K/5sy350OTYNkO/ktU6kqepqCquE86xnTrXE94zRICUj6whkPlKWwfIPEvTFjg/B
# ougsUfdzvL2FsWKDc0GCB+Q4i2pzINAPZHM8np+mM6n9Gd8lk9ECAwEAAaOCAc0w
# ggHJMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQM
# MAoGCCsGAQUFBwMDMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDov
# L29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5k
# aWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8E
# ejB4MDqgOKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1
# cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsME8GA1UdIARIMEYwOAYKYIZIAYb9
# bAACBDAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BT
# MAoGCGCGSAGG/WwDMB0GA1UdDgQWBBRaxLl7KgqjpepxA8Bg+S32ZXUOWDAfBgNV
# HSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzANBgkqhkiG9w0BAQsFAAOCAQEA
# PuwNWiSz8yLRFcgsfCUpdqgdXRwtOhrE7zBh134LYP3DPQ/Er4v97yrfIFU3sOH2
# 0ZJ1D1G0bqWOWuJeJIFOEKTuP3GOYw4TS63XX0R58zYUBor3nEZOXP+QsRsHDpEV
# +7qvtVHCjSSuJMbHJyqhKSgaOnEoAjwukaPAJRHinBRHoXpoaK+bp1wgXNlxsQyP
# u6j4xRJon89Ay0BEpRPw5mQMJQhCMrI2iiQC/i9yfhzXSUWW6Fkd6fp0ZGuy62ZD
# 2rOwjNXpDd32ASDOmTFjPQgaGLOBm0/GkxAG/AeB+ova+YJJ92JuoVP6EpQYhS6S
# kepobEQysmah5xikmmRR7zGCAigwggIkAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# MTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcg
# Q0ECEALqUCMY8xpTBaBPvax53DkwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwx
# CjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGC
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFGkuaxhcvet8SU1Q
# FAOCXABL01CJMA0GCSqGSIb3DQEBAQUABIIBAFFXmmAl3qx2ISFZoq90Rk0nYCjU
# 25+4SqDB1JdDr4Z8l0VxoPawl8EOS4LfMt0XlIDuv0ERMDArBD0KAXd4smXLMdbI
# JJX/5LGUBxCVQWUV+Z3iYwRHuJo9xLKZeeKoLp4NPD/lq7QcjvIztVb+Qar/DuPD
# yUmUPrU1GvyfYZpZktOvKq8mDKHMmQeTm0qFiXftJ3aaLNgtxyuwSdXHqdXssQ9W
# 76yrp1vD7YfIQOf2nKXU6JW51/jvlvYc9LjPkoyhFgCRJ2dOkDRnTaugAt7xyvnR
# Yl2xmYV0ZkUlZktLs2futUFY1m9VWoyaIYMgCdhktxW746qZJvf366rT48o=
# SIG # End signature block
