$moduleRoot = Get-Module Pipeworks | Split-Path 

New-Canvas -Background White -Width 300 -Height 70 -Children { 
New-Border -Left 10 -Child {
    Show-Logo "PowerShell" -Font 'Euphemia' -Size 28 -OutputUI 
}
New-Border -Left 146 -Top 26 -Child {
    Show-Logo "Pipeworks" -Font 'Arial Rounded MT' -Size 27 -OutputUI 
}

} | Save-Screenshot -outputPath $moduleRoot\Assets\Pipeworks_Logo.png 

Show-Logo "PowerShell" -Font 'Euphemia' -Size 28 -OutputUI | 
    Save-Screenshot -outputPath $moduleRoot\Assets\Pipeworks_Logo_Firstword.png 

Show-Logo "Pipeworks" -Font 'Arial Rounded MT' -Size 27 -OutputUI  | 
    Save-Screenshot -outputPath $moduleRoot\Assets\Pipeworks_Logo_SecondWord.png 
