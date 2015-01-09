function prompt {
    $lunchtime = Get-Date -Hour 19 -Minute 45
    $timespan = New-TimeSpan -End $lunchtime
    [Int]$minutes = $timespan.TotalMinutes
    switch ($minutes) {
        { $_ -lt 0 }   { $text = 'Lunch is over. {0}' }
        { $_ -lt 3 }   { $text = 'Prepare for lunch!  {0}' }
        default        { $text = '{1} minutes to go... {0}' }
    }

    'PS> '
    $Host.UI.RawUI.WindowTitle = $text -f (Get-Location), $minutes
    if ($minutes -lt 3) { [System.Console]::Beep() }
} 
