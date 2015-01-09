function Show-LastOutput
{
    param()

    $lo = Get-LastOutput
    if (-not $lo) { return } 


    $controls = New-Object Collections.Arraylist
    $objects = New-Object Collections.Arraylist
    $brushes= New-Object Collections.Arraylist

    foreach ($i in $lo) {
        if ($i -is [Windows.UIElement]) {
            $null = $controls.Add($i)
        } elseif ($i -is [Windows.Media.Brush]) {
            $null = $brushes.Add($i)
        } else {
            $asXaml = try {
                [Windows.Markup.XamlReader]::Parse($i)
            } catch {

            }

            if ($asXaml) {
                if ($asXaml -is [Windows.UIElement]) {
                    $null = $controls.Add($asXaml)
                } elseif ($i -is [Windows.Media.Brush]) {
                    $null = $brushes.Add($asXaml)
                } else {
                    $null = $objects.Add($i)
                }
                
            } else {
                $null = $objects.Add($i)
            }
            
        }
    }

    $outputPanel = ""
    
    if ($controls) {
        $outputPanel += foreach ($c in $controls) {
            "[Windows.Markup.XamlReader]::Parse(@'
$($c | Out-Xaml)
'@)
"
        }
        
    }

    if ($borders) {
        $outputPanel += foreach ($c in $borders) {
            "[Windows.Markup.XamlReader]::Parse(@'
<Border>
    <Border.Background>
$($c | Out-Xaml)
    </Border.Background>
</Border>
'@)"
        }
    }

    if ($objects) {
        $outputPanel += 
@"
`$wb = New-WebBrowser 

`$wb.NavigateToString(@'
$(
$global:response = New-Object Net.HttpWebResponse
$global:request = New-Object Net.HttpWebRequest
$objects | Out-Html | New-WebPage -UseJQueryUI -JQueryUITheme Start -JavaScript @'
function noError(){return true;}
window.onerror = noError;
'@
$global:response = $null
$global:request = $null
)
'@)
`$wb.Document.Window | Add-EventHandler -EventName Error -Handler { `$_.Handled = `$true}
`$wb
"@        
    }

    $screenscript = [ScriptBlock]::Create(@"
New-UniformGrid -Columns 1 -Children {
    $($outputPanel -join ([Environment]::NewLine))
}
"@)

    $null = Add-Icicle -Screen $screenscript -Name "Show-LastOutput" -Force 
} 
