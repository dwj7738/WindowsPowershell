@{
    Name = 'Hello World'
    PSTypeName = 'http://shouldbeonschema.org/Topic'
    Content = (
                    ConvertFrom-Markdown @"
A Hello World in Pipeworks is just like a Hello World in PowerShell:  just put 'Hello world' in quotes, and pipe it into Out-HTML
"@
                ) + (
                Write-ScriptHTML @'
"Hello World" |
    Out-HTML
'@)
}