New-task | 
    Add-TaskTrigger -DayOfWeek Monday, Wednesday, Friday -WeeksInterval 2 -At "3:00 PM" |
    Add-TaskAction -Script { Get-Process | Out-GridView } |
    Register-ScheduledTask TestTask