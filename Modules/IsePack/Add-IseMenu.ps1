function Add-IseMenu {
    <#
    .Synopsis
        Helper function to add menus to the ISE
    .Description
        Makes adding menus to the Windows PowerShell Integrated Scripting Environment (ISE)
        easier.  Add-IseMenu accepts a hashtable of menus.  
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
        Add-IseMenu -Name "Get" @{
            "Process" = { Get-Process } 
            "Service" = { Get-Service } 
            "Hotfix" = {Get-Hotfix}
        }
    .Example
        Add-IseMenu -Name "Verb" @{
            Get = @{
                Process = { Get-Process }
                Service = { Get-Service } 
                Hotfix = { Get-Hotfix } 
            }
            Import = @{
                Module = { Import-Module } 
            }
        }
    .Example
        Add-IseMenu -Name "Favorites" @{
            "Edit Profile" = { psedit $profile } | 
                Add-Member NoteProperty ShortcutKey "CTRL + E" -PassThru
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
        $Root,
        # If PassThru is set, the menu items will be outputted to the pipeline        
        [switch]$PassThru,
        # If Merge is set, menu items will be merged with existing menus rather than
        # recreating the entire menu.
        [switch]$Merge        
    )
    
    process {
        Set-StrictMode -Off
        if ($psCmdlet.ParameterSetName -eq 'MenuFile') {
            $resolvedPsPath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($MenuFile)
            $Menu = . $MenuFile
        }
        if (-not $psise) { return }
        if (-not $root) { 
            $root = $psise.CustomMenu
            if (-not $root) {
                $root = $psise.CurrentPowerShellTab.AddOnsMenu
            }
            if (-not $root) {
                $root = $psise.CustomMenu
            }    
        }
        $iseMenu = $root.Submenus | Where-Object {
            $_.DisplayName -eq $name
        }
        if (-not $iseMenu) {
            $iseMenu = $root.Submenus.Add($name, $null, $null)
        }
        if (-not $merge) {
            $iseMenu.Submenus.Clear()
        }
        if (-not $doNotSort) {
            $menuItems = $menu.GetEnumerator() | 
                Sort-Object Key
        } else {
            $menuItems = $menu.GetEnumerator()            
        }
        $menuItems | 
            ForEach-Object {
                $itemName = $_.Key
                switch ($_.Value) {
                    { $_ -is [Hashtable] } {
                        # Nested menu, recurse
                        $subMenu = $iseMenu.SubMenus.Add($itemName, $null, $null)
                        Add-IseMenu -Name $itemName $_ -root $iseMenu -passThru:$passThru
                    }
                    { $_.ShortcutKey } {
                        $scriptBlock= [ScriptBlock]::Create($_)
                        $m = $iseMenu.Submenus.Add($itemName, $scriptBlock, $_.ShortcutKey)
                        if ($passThru) { $m }
                    }
                    default {
                        $scriptBlock= [ScriptBlock]::Create($_)
                        $m= $iseMenu.Submenus.Add($itemName, $scriptBlock, $null)
                        if ($passThru) { $m }
                    }                 
                }
            }
    }
    

}
# SIG # Begin signature block
# MIINGAYJKoZIhvcNAQcCoIINCTCCDQUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/aS2xhVC4GkOS3VashDJoWLK
# oBGgggpaMIIFIjCCBAqgAwIBAgIQAupQIxjzGlMFoE+9rHncOTANBgkqhkiG9w0B
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
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFFZDxzjQcXCTdwpl
# dGPUYDKFp2q8MA0GCSqGSIb3DQEBAQUABIIBAGNpCPsfHku7b8aa+3m1z5Tlm5V/
# HNuBf9DIthzAdY+VEi/GYjqlUga2ZIvbQKx3U1TOsO6ZO5sSK+sBYHbQBBs7iy91
# r/H1OsaQSLQlR1Y4VJfwn0GUEZKH9YWPe+AupBxlnLs+rh/fjrys8RhcDiFz9v3U
# gcnOdwQAhM7R0d7wXCoD4WFpwa6iDpDCgTow7ttmL1iOk5yfO8XtoXSA4cqCZMFj
# v7sg/x8HQPjuaMjBnn2HJCjKxBZxKP9CVD3jStvEifl0p3TwsWRNtwxvS3GnOXUo
# yovcKkjSDnaMKjLVk/t9M53v7Hdylo+vEBbyfopVFePpq8di0q7/Iso1Yi4=
# SIG # End signature block
