function Select-SQL
{
    <#
    .Synopsis
        Select SQL data
    .Description
        Select data from a SQL databsae
    .Example
        Select-Sql -FromTable ATable -Property Name, Day, Month, Year -Where "Year = 2005" -ConnectionSetting SqlAzureConnectionString
    .Example
        Select-Sql -FromTable INFORMATION_SCHEMA.TABLES -ConnectionSetting SqlAzureConnectionString -Property Table_Name -verbose
    .Link
        Add-SqlTable
    #>
    param(
    # The table containing SQL results
    [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
    [Alias('Table','From')]
    [string]$FromTable,

    # If set, will only return unique values.  This corresponds to the DISTINCT SQL qualifier.
    [Alias('Unique')]
    [Switch]$Distinct,

    # The properties to pull from SQL. If not set, all properties (*) will be returned
    [string[]]$Property,


    # The sort order of the returned objects
    [Alias('First')]
    [Uint32]$Top,

    # The sort order of the returned objects
    [Alias('Sort')]
    [string[]]$OrderBy,

    # If set, sorted items will be returned in descending order.  By default, if items are sorted, they will be in ascending order.
    [Switch]$Descending,

    # The where clause.
    [string]$Where,

    # A connection string or setting.
    [Parameter()]
    [Alias('ConnectionString', 'ConnectionSetting')]
    [string]$ConnectionStringOrSetting
    )

    begin {
        Set-StrictMode -Off
        $ConnectionString  = ""
        if ($script:CurrentConnectionString -and -not $ConnectionStringOrSetting) {
            $ConnectionString = $script:CurrentConnectionString
        }
        if ($ConnectionStringOrSetting -notlike "*;*") {
            if ($ConnectionStringOrSetting) {
                $ConnectionString = Get-SecureSetting -Name $ConnectionStringOrSetting -ValueOnly    
            }            
        } else {
            $ConnectionString =  $ConnectionStringOrSetting
        }
        if (-not $ConnectionString) {
            throw "No Connection String"
            return
        }
        if (-not $script:CurrentConnectionString) {
             $script:CurrentConnectionString = $ConnectionString
        }
        $sqlConnection = New-Object Data.SqlClient.SqlConnection "$connectionString"
        $sqlConnection.Open()
    }

    process {
        if (-not $Property) {
            $property = "*"
        }

        if ($Property -eq '*') {
            $propString = '*' 
        } else {
            if ($Property -like "*(*)*") {
                $propString = "$($Property -join ',')"
            } else {
                $propString = "`"$($Property -join '","')`""
            }
        }
        
        $sqlStatement = "SELECT $(if ($Top) { "TOP $Top" } ) $(if ($Distinct) { 'DISTINCT ' }) $propString FROM $FromTable $(if ($Where) { "WHERE $where"}) $(if ($OrderBy) { "ORDER BY $($orderBy -join ',') $(if ($Descending) { 'DESC'})"})".TrimEnd("\").TrimEnd("/")
        Write-Verbose "$sqlStatement"
        $sqlAdapter= New-Object "Data.SqlClient.SqlDataAdapter" ($sqlStatement, $sqlConnection)
        $sqlAdapter.SelectCommand.CommandTimeout = 0
        $dataSet = New-Object Data.DataSet
        $rowCount = $sqlAdapter.Fill($dataSet)

        
        foreach ($t in $dataSet.Tables) {
            
            foreach ($r in $t.Rows) {
                $r.pstypenames.clear()
                if ($r.pstypename) {                    
                    foreach ($tn in ($r.pstypename -split "\|")) {
                        $r.pstypenames.add($tn)
                    }
                }
                
                $r
                
            }
        }

        
    }

    end {
         
        if ($sqlConnection) {
            $sqlConnection.Close()
            $sqlConnection.Dispose()
        }
        
    }
}
 
