function Update-Sql
{
    <#
    .Synopsis
        Updates a SQL table
    .Description
        Inserts new content into a SQL table, or updates the existing contents of a SQL table
    #>
    param(
    # The name of the SQL table
    [Parameter(Mandatory=$true)]
    [string]$TableName,

    # The Input Object
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [PSObject]
    $InputObject,

    # A List of Properties to add to the database.  If omitted, all properties will be added (except those excluded with -ExcludeProperty)
    
    [string[]]
    $Property,

    # A List of Properties to exclude from the database.  If omitted, all properties (or the properties specified with the -Property parameter) will be added
    
    [string[]]
    $ExcludeProperty,
    
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    $RowKey,
    
    [ValidateSet('Guid', 'Hex', 'SmallHex', 'Sequential', 'Named', 'Parameter')]
    [string]$KeyType  = 'Named',

    # A lookup table containing SQL data types
    [Hashtable[]]
    $ColumnType,


    # A lookup table containing the real SQL column names for an object
    [Hashtable[]]
    $ColumnAlias,

    # If set, will force the creation of a table.
    # If omitted, an error will be thrown if the table does not exist.
    [Switch]
    $Force,

    # The connection string or a setting containing the connection string.  
    [Parameter(Mandatory=$true)]
    [String]
    $ConnectionStringOrSetting
    )


    begin {
        
        $params = @{} + $psboundparameters
        if ($ConnectionStringOrSetting.Contains("=")) {
            $ConnectionString =  $ConnectionStringOrSetting    
        } else {
            $ConnectionString = Get-SecureSetting -Name $ConnectionStringOrSetting -ValueOnly        
    
        }
        if (-not $ConnectionString) {
            throw "No Connection String"
            return
        }
        $sqlConnection = New-Object Data.SqlClient.SqlConnection "$connectionString"
        $sqlConnection.Open()

        $lastKnownRowCount = 0
        
        $propertyMatches = @{}
        foreach ($p in $Property) {
            if ($p) {
                $propertyMatches.$p =  $p
            }
        }

        $excludeMatches = @{}
        foreach ($p in $excludeMatches) {
            if ($p) {
                $excludeMatches.$p =  $p
            }
        }

        #region Common Parameters & Procedures
        
        # This is a set of parameters used to get the column metadata
        $GetColumnMetaData = @{
            FromTable="INFORMATION_SCHEMA.COLUMNS"
            Where= "TABLE_NAME = '$tableName'" 
            Property="Column_Name", "Data_Type"            
            ConnectionStringOrSetting=$ConnectionString
        }
        
        $GetPropertyNamesAndTypes = {
            param($object)

            $propTypes = New-Object Collections.ArrayList
            $propValues = New-Object Collections.ArrayList
            
                foreach ($prop in $object.psobject.properties) {
                    if (-not $prop) { continue } 
                    if ($propertyMatches.Count -and -not $propertyMatches[$prop]) {
                        continue
                    } 

                    if ($ExcludeProperty.Count -and $ExcludeProperty -contains $prop.Name) {
                        continue
                    }
                    # $prop.Name
                    if ($prop.Name -eq 'RowError' -or $prop.Name -eq 'RowState' -or $prop.Name -eq 'Table' -or $prop.Name -eq 'ItemArray'-or $prop.Name -eq 'HasErrors') {
                        continue
                    }
                    
                    $sqlType = if ($columnType -and $columnType[$prop.Name]) {
                        $columnType[$prop.Name]
                    } elseif ($prop.Value) {
                        if ($prop.Value -is [String]) {
                            "varchar(max)"                            
                        } elseif ($prop.Value -as [Byte]) {
                            "tinyint"
                        } elseif ($prop.Value -as [Int16]) {
                            "smallint"
                        } elseif ($prop.Value -as [Int]) {
                            "int"
                        } elseif ($Prop.Value -as [Double]) {
                            "float"
                        } elseif ($prop.Value -as [Long]) {
                            "bigint"
                        } elseif ($prop.Value -as [DateTime]) {
                            "datetime"
                        } else {
                            "varchar(max)"
                        }

                    } else {
                        "varchar(max)"
                    }

                    $columnName = if ($ColumnAlias -and $ColumnAlias[$prop.Name]) {
                        $ColumnAlias[$prop.Name]
                    } else {
                        $prop.Name
                    }



                    
                    New-Object PSObject -Property @{
                        Name=$columnName 
                        Value = $prop.Value
                        SqlType = $sqlType
                    }
                }


            New-Object PSObject -Property @{
                Name="pstypename"
                Value = $object.pstypenames -join '|'
                SqlType = $sqlType
            }
        }

        #endregion Common Parameters & Procedures

        $columnsInfo = 
            Select-SQL @GetColumnMetaData
        
        if (-not $columnsInfo) {
            # Table Doesn't Exist Yet, mark it for creation 
            if (-not $Force) {
                Write-Error "$tableName does not exist"
            }    
                    
        }
        $Local:DoNotRetry = $false
    }

 
    process {                
        # If there are no columns, and -Force  is not set
        if (-not $columnsInfo -and -not $force) {
            
            return
        }

        $objectSqlInfo = & $GetPropertyNamesAndTypes $inputObject 
        $byName = $objectSqlInfo | 
            Group-Object Name -AsHashTable

        if ($columnsInfo -and $force) {
            
        }

        # There are no columns, create the table
        if (-not $columnsInfo -and (-not $Local:DoNotRetry)) {
             
            Add-SqlTable -KeyType $keyType -TableName $TableName -Column (
                $objectSqlInfo | 
                    Where-Object { $_.Name -ne 'RowKey' } | 
                    Select-Object -ExpandProperty Name
            ) -DataType (
                $objectSqlInfo | 
                    Where-Object { $_.Name -ne 'RowKey' } | 
                    Select-Object -ExpandProperty SqlType
            ) -ConnectionStringOrSetting $ConnectionStringOrSetting
            

            $columnsInfo = 
                Select-SQL @GetColumnMetaData
        
        }

        # If there's still no columns info the table could not be created, and we should bounce
        if (-not $columnsInfo) {
            $Local:DoNotRetry = $true
            return

        }
        $updated = $false

        if ($psboundparameters.RowKey) {
            $updated = $false
            $sqlExists = "SELECT RowKey FROM $TableName WHERE RowKey='$RowKey'"
            $sqlAdapter= New-Object "Data.SqlClient.SqlDataAdapter" ($sqlExists, $sqlConnection)
            $sqlAdapter.SelectCommand.CommandTimeout = 0
            $dataSet = New-Object Data.DataSet
            $rowcount = try {
                    $sqlAdapter.Fill($dataSet)
                    $count = $lastKnownRowCount
            } catch {
                $ex = $_
            }

            if ($rowCount) {
                $updated = $true


                # Value Supplied, SQL UPDATE
                $sqlUpdate = 
                "UPDATE $TABLEName 
SET $(($objectSqlInfo | 
    Where-Object { $_.Name -ne 'RowKey'} | 
    Foreach-Object { '"' + $_.Name + '"=' + "'$($_.Value)'" }) -join ", ") WHERE RowKey='$RowKey'"
    
                Write-Verbose $SqlUpdate
                $sqlAdapter= New-Object "Data.SqlClient.SqlDataAdapter" ($sqlUpdate , $sqlConnection)
                $sqlAdapter.SelectCommand.CommandTimeout = 0
                $dataSet = New-Object Data.DataSet
                $rowCount = try {            
                    $sqlAdapter.Fill($dataSet)
                    $count = $lastKnownRowCount
                } catch {
                    Write-Error $_
                }
            }


        
        } 
        # Value Not supplied, generate a rowkey
        if (! $updated) {
            
            $row = 
                if ($psBoundParameters.RowKey -and -not $updated) {
                    $psBoundParameters.RowKey
                } elseif ($KeyType -eq 'GUID') {
                    {[GUID]::NewGuid()}
                } elseif ($KeyType -eq 'Hex') {
                    {"{0:x}" -f (Get-Random)}
                } elseif ($KeyType -eq 'SmallHex') {
                    {"{0:x}" -f ([int](Get-Random -Maximum 512kb))}
                } elseif ($KeyType -eq 'Sequential') {
                    if ($row -ne $null -and $row -as [Uint32]) {
                        $row + 1  
                    } else {                    
                        Select-SQL -FromTable $TableName -Property "COUNT(*)" -ConnectionStringOrSetting $ConnectionString | 
                            Select-Object -ExpandProperty Column1                    
                    }
                }
            $insertColumns = ($objectSqlInfo | 
                Where-Object { $_.Name -ne 'RowKey'} | 
                Select-Object -ExpandProperty Name) -join "`", `""
            $sqlInsert = 
                "INSERT INTO $TABLEName (`"RowKey`", `"$insertColumns`") VALUES ('$Row','$((
                    $objectSqlInfo | 
                    Where-Object { $_.Name -ne 'RowKey' } | 
                    Foreach-Object { "$($_.Value)".Replace("'", "''") }) -join "', '")')"
            Write-Verbose $sqlInsert

            $sqlAdapter= New-Object "Data.SqlClient.SqlDataAdapter" ($sqlInsert, $sqlConnection)
            $sqlAdapter.SelectCommand.CommandTimeout = 0
            $dataSet = New-Object Data.DataSet
            $rowCount = try {            
                $sqlAdapter.Fill($dataSet)
                $lastKnownRowCount = $row
            } catch {
                if ($_.Exception.InnerException.Message -like "*invalid column name*") {
                    $columnName  = ($_.Exception.InnerException.Message -split "'")[1]
                    $sqlAlter=  "ALTER TABLE $TableName ADD $ColumnName varchar(max)"
                    $sqlAdapter= New-Object "Data.SqlClient.SqlDataAdapter" ($sqlAlter, $sqlConnection)
                    $sqlAdapter.SelectCommand.CommandTimeout = 0
                    $dataSet = New-Object Data.DataSet
                    $n = $sqlAdapter.Fill($dataSet)
                    $sqlAdapter= New-Object "Data.SqlClient.SqlDataAdapter" ($sqlInsert, $sqlConnection)
                    $sqlAdapter.SelectCommand.CommandTimeout = 0
                    $dataSet = New-Object Data.DataSet
                    $n = $sqlAdapter.Fill($dataSet)
                } else {
                    Write-Error $_
                }
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