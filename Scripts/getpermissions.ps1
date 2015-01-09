#Include only folders from the root path
Get-ChildItem "C:\"  | ?{ $_.PsIsContainer } | %{
  $Path = $_.FullName
$h = (Get-Acl $Path).Access | Select-Object @{n='Path';e={ $Path }}, IdentityReference, FileSystemRights } 
#Invoke-Expression C:\Permissions.html
$h
