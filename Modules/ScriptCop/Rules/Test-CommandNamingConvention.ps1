function Test-CommandNamingConvention
{
    param(
    [Parameter(ParameterSetName='TestCommandInfo',Mandatory=$true,ValueFromPipeline=$true)]
    [Management.Automation.CommandInfo]
    $CommandInfo
    )
    
    begin {
        
        $standardVerbs = @{}
        Get-Verb | 
            ForEach-Object { $standardVerbs."$($_.Verb)" = $_ } 
    }
    
    process {    
        $commandName = $commandInfo.Name
        $verb, $noun, $rest = $commandName -split '-'
        if (-not $noun) {
            Write-Error "$CommandInfo does not follow the verb-noun naming convention.  
PowerShell commands should be named like:

StandardVerb-CustomNoun

To see all of the standard verbs, run 'Get-Verb'
"
            return
        }
        
        if ($rest) {
            Write-Error "$CommandInfo name contains an additional -, please rename the command"
            return
        }
        
        if (-not $standardVerbs.$verb) {
            Write-Error "$CommandInfo uses a non-standard verb, $Verb.  Please change it.  Use Get-Verb to see all verbs"
        }
        
        if ($commandName.IndexOfAny("#,(){}[]&/\`$^;:`"'<>|?@``*%+=~ ".ToCharArray()) -ne -1)
        {
            Write-Error "$commandInfo name contains invalid characters"
        }
        
    }
} 
