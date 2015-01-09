$moduleRoot = "$home\documents\windowspowershell\modules\pipeworks"
# Get-Module Pipeworks | Split-Path

$walkthruFormatAction =  {
    $name = $_.Name
    $walkthru = Get-Walkthru -Text $_.Description                    
    New-Region -ItemType walkthru -AsWidget -Style @{
        'text-align' = 'left'
    } -Layer @{ 
        $Name = Write-WalkthruHTML -WalkThru $walkthru -StepByStep
    }   
}


$colorizedScriptBlockAction = {
    if ($request -and $response) {
        Write-ScriptHTML -Text $_
    } else {
        $_
    }
}


$personAction = {
    $person = $_

    if ($request -and $response) 
    {
        $name = $person.Name
    
        $nameLink = $name 
        if ($person.Url) {
            $nameLink = "<a href='$($person.Url)'>$name</a>"
        }

        $itsMe = if ($session -and ($person.UserID -eq $session["User"].UserID -and $person.UserEmail -eq $session["User"].UserEmail)) {
            $true
        } else {
            $false
        }           

            
        $imageAndDescription = ""

        $imageAndDescription += 
            if ($person.Image) {
                "<img src='$($person.Image)' style='border:0' />"
            } elseif ($person.FacebookId -and $person.FacebookAccessToken) {
                # They may not have an image, but they have a Facebook ID and access token, so show their facebook photo
                "<img src='http://graph.facebook.com/$($person.FacebookId)/picture?type=large' style='border:0' border='0' />"
            } elseif ($person.LiveID -and $person.LiveIDAccessToken) {
                # They have a liveID, so show their liveID
                "<img src='https://apis.live.net/v5.0/$($person.LiveId)/picture' style='border:0' border='0'/>"
            }
        $imageAndDescription += 
            if ($person.Description -and $person.Description -like "*<*") {
                $person.Description 
            } elseif ($person.Description) {
                ConvertFrom-Markdown $person.Description 
            } else {
                ""
            }

        if ($person.Age) {
            $age  = $person.Age -as [int]
        } elseif ($person.Birthday -as [DateTime]) {
            $daysOld = ((Get-date) - ($person.Birthday -as [Datetime])).Days
            $age = [Math]::Floor($daysOld / 365)
            
        }


        $billMe = if ($itsMe -and $person.Balance -and ($person.Balance -as [Double] -gt 1) -and $serviceUrl) {
            $payUpUrl =  if ($serviceUrl.ToString().Contains("?")) {
                "$serviceUrl" + "&settle=true"
            } else {
                "$serviceUrl" + "?settle=true"
            }
            New-Region -LayerId "SettlePersonalAccountBalanceFor$($person.UserID)" -AsPopdown -LayerUrl @{"Account Balance -  $($Person.Balance)."= $payUpUrl}  -Layer @{"Account Balance -  $($Person.Balance)."="Please take care of your bill when you can"} -Style @{"font-size"="xx-small";"float" = "right"}  
        } else { 
            ""
        }

        

        $imageAndDescription += 
            if ($age) {
                if ($person.Gender) {
                    "<BR/>$age | $($person.Gender)"
                } else {
                    "<BR/>$age"
                }
            } else {
                ""
            } 

        $imageAndDescription +=
            if ($person.Location -and $person.Location.Name) {
                "<BR/>" + $($person.Location.Name)
            }

        $imageAndDescription +=
            if ($person.LastLogin -and $person.Location.Name) {
                "<BR/>" + $($person.Location.Name)
            }

        $AdditionalContent = ""

        $AdditionalContent += 
            if ($person.Bio) {
                "<BR/>" + $person.Bio + ("<BR/>" * 3)
            }

        $CloseMailLink = if ($person.Email -or $person.UserEmail) {
            "</a>"
        } else {
            ""
        }

        $openMailLink = if ($person.UserEmail) {
            "<a href='mailto:$($person.UserEmail)'>"
        } elseif ($person.Email) {
            "<a href='mailto:$($person.Email)'>"
        } else {
            ""
        }

        "<h3 style='float:left'>
        $NameLink
        </h3>
        <div style='clear:both'> </div>
        <div style='float:right'>
        $($BillMe)
        </div>
        
        <hr/>
        <br/>
        <div style='clear:both'> </div>
        <div style='float:right;text-align:center'>
            $OpenMailLink $imageAndDescription $CloseMailLink
        </div>
        <div>
            $AdditionalContent
        </div>"
    
    } else {
        
        Write-Host $person.Name 
    }
    

    
             

                


}

$wolframAlphaResultAction = {
    if ($request -and $response) {
        $item = $_
        $podHtml = 
            $_.psobject.properties |             
                ForEach-Object {
                    if ('Pods','OutputXml','InputInterpretation', 'PSComputerName', 'RunspaceId' -contains $_.Name) {
                        return
                    }
                    
                    "$($_.Name)<br/>
                    <blockquote>
                        $($_.Value | Out-HTML)
                    </blockquote>"                    
                }
        "
        $($item.InputInterpretation)
        <blockquote>
            $podHtml    
        </blockquote>
        "    
    } else {
        Write-Host "Input :" $_.InputInterpretation
        
        $_.psobject.properties |             
            ForEach-Object {
                if ('Pods','OutputXml','InputInterpretation', 'PSComputerName', 'RunspaceId' -contains $_.Name) {
                    return
                }
                $displayName = $_.Name
                Write-Host $displayName
                $content = $_.Value | Out-String    
                $newContent = $content -split "[$([Environment]::NewLine)]" |
                    Where-Object { $_ } |
                    ForEach-Object { 
                        "    " + $_
                    }
                Write-Host ($newContent -join ([Environment]::NewLine))
            }
    }
    $null
}

$exampleAction = {
    "<h3 class=`'ui-widget-header`' itemprop=`'name`'>$($_.Name)</h3>    
    <div itemprop='description'>
    $($sb = [ScriptBlock]::Create($_.Description); Write-ScriptHTML -Text $sb)
    </div>"
}

$classAction = {
    $item = $_
    
    $itemHtml = @"
<h1 class="page-title">     
    <a href='$($item.Url)' class='shouldbelink' itemprop='name'>$($item.Name)</a>
</h1>
"@
    if ($item.Description) {
        $itemHtml += @"
<span itemprop='description'>
    $($item.Description)
</span>
"@        
    }
          
    
    $itemHtml += @"
<style>

    table.definition-table
    {
        margin: 1em 0 0 0;
        border: 1px solid #98A0A6;
    }
    .definition-table th
    {
        text-align: left;
        background: #C7CBCE;
        padding-left: 5px;
    }
    .definition-table td
    {
        padding: 0 5px 2px 5px;
        margin: 0;
        vertical-align: top;
    }
    .definition-table td p
    {
        padding: 0 0 .6em 0;
        margin: 0;
    }
    .definition-table td ul
    {
        padding-top: 0;
        margin-top: 0;
    }
    .definition-table tr.alt
    {
        background: #E9EAEB;
    }
    .h .space
    {
        width: 20px
    }
    .h .bar
    {
        background-color: #000;
        width: 1px
    }
    .h .tc
    {
        text-indent: -21px;
        padding-left: 21px
    }
</style>
<table cellspacing="3" class="definition-table SchemaContent" >
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
        </tr>
    </thead>
"@


    $itemClassId = if ($item.Url) {
        $item.Url
    } else {
        $item.Name
    }
    $classHierarchy  =@($item.ParentClass) + $itemClassId
    foreach ($parentClass in $classHierarchy) {
        if (-not $parentClass) { continue }
        
        
        $declaringTypeString = 
            if ($parentClass.Url) {
                if ($parentClass.Url -like "*http*") {
                    "<a href='$($parentClass.Url)'>$(([uri]$ParentClass.Url).Segments[-1])</a>"
                } else {
                    "<a href='$($ParentClass.Url)'>$($ParentClass.Url)</a>"
                }
                
            } elseif ($parentClass.Name) {
                "$($ParentClass.Name)"
            } elseif ($parentClass -like "*http*") {
                "<a href='$($parentClass)'>$(([uri]$ParentClass).Segments[-1])</a>"
            } else {
                $parentClass
            }
            
        $itemHtml += $item.Property |
            Where-Object { 
                $_.DeclaringType -and (
                    $_.DeclaringType -eq $parentClass -or
                    $_.DeclaringType -eq $parentClass.Url -or
                    $_.DeclaringType -eq $parentClass.Name
                )                 
            } |
            ForEach-Object -Begin {                
@"

    <thead class="supertype"><tr>
        <th class="supertype-name" colspan="3">
            Properties from $declaringTypeString</th>
        </tr>
    </thead>
    <tbody class="supertype">
"@                
            } -Process {
                $property = $_
                
                $typeChunk = 
                    if ($property.PropertyType -like "http://*") {
                        
                        "<a href='$($property.PropertyType)' itemprop='PropertyType'>$(([uri]$property.PropertyType).Segments[-1])</a>"   
                    } elseif ($property.PropertyType -is [string]) {
                        
                        "$($property.PropertyType)
                        <meta style='display:none' itemprop='PropertyType' content='Text' />
                        "
                        
                    } else {
                        "Text
                        <meta style='display:none' itemprop='PropertyType' content='Text' />
                        "
                    }
                @"
    <tr itemscope='' itemprop='Property' itemtype='http://shouldbeonschema.org/Property'>
        <th class="prop-nam" scope="row">
            <code itemprop='Name'>$($property.Name)</code>
        </th>
        <td class="prop-ect">
            $typeChunk
        </td>
        <td class="prop-desc" itemprop='Description'>
            $($property.Description)
        </td>
    </tr> 
"@
            } -End {
@"
    </tbody>
"@
            }
            
            
        
    }
    $itemHtml += @"    
</table>
"@



    "
<div itemscope='' itemtype='http://shouldbeonschema.org/Class' style='margin:0;padding:0'>
    $itemHtml
</div>
    " 
} 

$jobPostingView = Write-FormatView -TypeName "http://schema.org/JobPosting" -Action {
    $item = $_
    $jobTitle = if ($item.Name) {
        $item.Name
    } elseif ($item.Title) {
        $item.Title
    }
    $description = if ($item.Description -like "*<*") {
        # Treat as HTML
        $item.Description
    } elseif ($item.Description) {
        # Treat as markdown
        
        ConvertFrom-Markdown $item.Description
    } else {
        ""
    }
    
    $responsibilities =if ($item.responsibilities) {
        "
        <h3>Roles & Responsibilities</h3>
        <blockquote>
            $($item.Responsibilities.Replace("`n", "<BR/>"))
        </blockquote>        
        "
        
    } else {
        ""
    }
    
    $experienceRequirements =if ($item.experienceRequirements) {
        "
        <h3>Experience Required</h3>
        <blockquote>
            $(ConvertFrom-Markdown $item.experienceRequirements.Replace("`n", "<BR/>"))
        </blockquote>        
        "
        
    } else {
        ""
    }
    
    $educationRequirement =if ($item.educationRequirements) {
        "
        <h3>Education Required</h3>
        <blockquote>
            $(ConvertFrom-Markdown $item.educationRequirements.Replace("`n", "<BR/>"))
        </blockquote>        
        "
        
    } else {
        ""
    }
    
    $qualifications =if ($item.qualifications) {
        "
        <h3>Special Qualifications</h3>
        <blockquote>
            $(ConvertFrom-Markdown $item.qualifications.Replace("`n", "<BR/>"))
        </blockquote>        
        "
        
    } else {
        ""
    }
    
    $skills =if ($item.Skills) {
        "
        <h3>Skills</h3>
        <blockquote>
            $(ConvertFrom-Markdown $item.skills.Replace("`n", "<BR/>"))
        </blockquote>        
        "
        
    } else {
        ""
    }
    
    $locationAndOrg =if ($item.JobLocation -or $item.HiringOrganization) {
        "$($item.JobLocation) $(if ($item.HiringOrganization) { "for $($item.HiringOrganization)" })"
    }
    
    
    
    $ApplyButton  = if ($item.ApplyToEmail) {
        "<div style='float:right'>$(
            Write-Link -Button -Caption "Apply" -Url "mailto:$($item.ApplyToEmail)?subject=$jobtitle"
        )</div>
        <div style='clear:both'></div>"
    } else {
        ""
    } 
    
    if ($item.Url) {
        $jobTitle = "<a href='$($item.Url)'>$jobTitle</a>"        
    }
    
    $jobId = if ($item.RowKey) {
        "<div style='float:right;text-size:x-small'>JobId: $($item.RowKey)</div>
        <div style='clear:both'>
        </div>"
    } else {
        ""
    }
    
    "<h2>$jobTitle</h2>
    $locationAndOrg
    <blockquote>
    $description
    </blockquote>
    $responsibilities    
    $experienceRequirements
    $skills    
    $qualifications    
    $educationRequirements
    $ApplyButton           
    $JobId
    "
}

$moduleAction = {
    "<h3 class='ui-widget-header' itemprop='name'>$($_.Name)</h3>
    $(    
    if ($_.Description -and 
        $_.Description -ne $_.Name -and
        $_.Description -ne $_.ArticleText) {
        "<div class='Description' itemprop='Description' style='text-align:left'>$($_.Description)</div>"
    }
    "<br/>"
    if ($_.Url) {
        if (-not $_.ArticleText) {
            Write-Link -Button -Url $_.Url -Caption "<span class='ui-icon ui-icon-extlink'>
                </span>
                <br/>
                <span style='text-align:center'>
                Visit Website
                </span>"
            
        }
        "<meta style='display:none' content='$($_.Url)' itemprop='url' />"
    }
    if ($_.Author) {
        "<meta style='display:none' itemprop='author' content='$($_.Author)' />"
        if ($_.Author -like "@*") {
            "By $($_.Author) - $(Write-Link ('twitter:follow' + $_.Author))"
        } else {
            "By $($_.Author)"
        }
    }    
    if ($_.Image) {    
        Write-Link -Caption "<img border='0' src='$($_.Image)' />" -Simple -Url $_.Url
        "<meta style='display:none' content='$($_.Image)' itemprop='image'>"
    }
    if ($_.Image -or $_.Url) {
        '<br />'
    }
    )
    "
}


$topicAction = {
    $page = ""
    $item = $_
    $depth = 0
    $fullOriginalUrl  = $request.Url
    if ($context -and $context.Request.ServerVariables["HTTP_X_ORIGINAL_URL"]) {
    
        $originalUrl = $context.Request.ServerVariables["HTTP_X_ORIGINAL_URL"]

        $pathInfoUrl = $request.Url.ToString().Substring(0, $request.Url.ToString().LastIndexOf("/"))
                
            
            
        $pathInfoUrl = $pathInfoUrl.ToLower()
        $protocol = ($request['Server_Protocol'] -split '/')[0]  # Split out the protocol
        $serverName= $request['Server_Name']                     # And what it thinks it called the server

        $fullOriginalUrl = $protocol.ToLower() + "://" + $serverName + $request.Params["HTTP_X_ORIGINAL_URL"]
        
        $relativeUrl = $fullOriginalUrl.Replace("$pathInfoUrl", "")            
       
        if ($relativeUrl -like "*/*") {
            $depth = @($relativeUrl -split "/" -ne "").Count - 1
            if ($depth -eq 0) { $depth = 1 } 
        } else {
            $depth  = 0
        }
        
    }
    if ($item.Content) {
            
        $content = if (-not $item.Content.Contains(" ")) {
            # Treat compressed
            Expand-Data -CompressedData $item.Content
        } else {
            $item.Content
        }
        $content = if (-not $Content.Contains("<")) {
            # Treat as markdown
            ConvertFrom-Markdown -Markdown $content 
        } else {
            # Treat as HTML
            $content
        }
        $hasContent = $true
        $page += $content            
    }
        
                                        
        
    if ($item.Video) {
        $hasContent = $true
        $page += "<br/>$(Write-Link $item.Video)<br/><br/>" | New-Region -Style @{'text-align'='center'} 
        
    }
        
    if ($item.ItemId) {
        $hasContent = $true
        $part,$row = $item.ItemId -split ":"
        $page += Get-AzureTable -TableName $table -Partition $part -Row $row |
            ForEach-Object $unpackItem|
            Out-HTML -ItemType { 
                $_.pstypenames | Select-Object -Last 1                     
            } 
    }                
        
    
        
    if ($item.Related) {
        $hasContent = $true
        $page += 
            ((ConvertFrom-Markdown -Markdown $item.Related) -replace "\<a href", "<a class='RelatedLink' href") |
                New-Region -Style @{'text-align'='right';'padding'='10px'} 
        $page += @'
<script>
$('.RelatedLink').button()
</script>
'@            
        
    }
    if ($item.Next -or $item.Previous) {
        $hasContent = $true
        $previousChunk = 
            if ($item.Previous) {
            $previousCaption = "<span class='ui-icon ui-icon-seek-prev'>
                </span>
                <br/>
                <span style='text-align:center'>
                Last
                </span>"

                Write-Link -Caption $previousCaption -Url $item.Previous -Button
            } else {
                ""
            }
            
        $nextChunk = 
            if ($item.Next) {
                $nextCaption = "<span class='ui-icon ui-icon-seek-next'>
                    </span>
                    <br/>
                    <span style='text-align:center'>
                    Next
                    </span>"
                    Write-Link -Caption $nextCaption -Url $item.Next -Button
            } else {
                ""
            }
        $page+= "
<table style='width:100%'>
    <tr>
        <td style='50%;text-align:left'>
            $previousChunk
        </td>
        <td style='50%;text-align:right'>
            $nextChunk
        </td>
    <tr>
</table>"            
    }
    
    if ($item.Subtopic) {
    
    }
        

    if (-not $hasContent) {
        $page += $item | 
                Out-HTML -ItemType { $_.pstypenames | Select-Object -Last 1 } 
    }
    

    if ($pipeworksManifest.Facebook.AppId) {
        $page += "<div class='fb-like' data-send='true' data-width='450' data-show-faces='true'></div> <BR/>" + 
            "<div class='fb-comments' data-href='$fullOriginalUrl' data-num-posts='2' data-width='470'></div>"
                                
    }

    $page

}

$mediaObjectAction = {
    $linkType = if ("http://schema.org/VideoObject" -eq @($_.pstypenames)[-1]) {
        "play"
    } else {
        "extlink"
    }
    
    $fromString = if ($_.Publisher) {
        $_.Publisher
    } elseif ($_.From) {
        $_.From
    } else {
        "$(($_.Url -as [Uri]).DnsSafeHost)".Replace("www.", "")
    }
    
    
    if ($fromString) {
        $fromString=  "- $fromString"
    }
    
    
    "<h3 class=`'ui-widget-header`' itemprop=`'name`'>$($_.Name) $fromString</h3>
    $(
    if ($_.Image) {
        "<p style='text-align:center'>" + (    
        Write-Link -Caption "<img border='0' style='min-width:320px;min-height:240px' src='$($_.Image)' />" -Url $_.Url) + "</p>"
        "<meta style='display:none' content='$($_.Image)' itemprop='image'>"
    } elseif ($_.ThumbnailUrl) {
        "<p style='text-align:center'>" + (
        Write-Link -Caption "<img border='0' style='min-width:320px;min-height:240px' src='$($_.ThumbnailUrl)' />" -Url $_.Url) + "</p>"
        "<meta style='display:none' content='$($_.ThumbnailUrl)' itemprop='image'>"
    } )
    $(if ($_.Url) {
        "<p style='text-align:center'>" + (Write-Link -Button -Simple -Url $_.Url -Caption "<span class='ui-icon ui-icon-$linkType'> </span>") + "</p>"
        "<meta style='display:none' content='$($_.Url)' itemprop='url'>"
    })    
    $(if ($_.Image -or $_.Url) {
        '<br />'
    })    
    $(if ($_.Description -and $_.Description -ne $_.Name) {
        "<div class='Description' itemprop='Description' style='text-align:left'>$($_.Description)</div>"
    }
    $(if ($pipeworksManifest.Facebook.AppId) {
        "<div class='fb-like' data-send='true' data-width='450' data-show-faces='true'></div> <BR/>" + 
            "<div class='fb-comments' data-href='$(if ($FullUrl) { $fullUrl } else { $request.Url  })' data-num-posts='2' data-width='470'></div>"
                                
    })

    )
        
    "} 
    
$articleAction = {
    # Calculate the depth of the virtual URL compared to the real page. 
    # This gets used to convert links to local resources, such as a custom JQuery theme
    $depth = 0
    if ($context -and $context.Request.ServerVariables["HTTP_X_ORIGINAL_URL"]) {
    
        $originalUrl = $context.Request.ServerVariables["HTTP_X_ORIGINAL_URL"]

        $pathInfoUrl = $request.Url.ToString().Substring(0, $request.Url.ToString().LastIndexOf("/"))
                
            
            
        $pathInfoUrl = $pathInfoUrl.ToLower()
        $protocol = ($request['Server_Protocol'] -split '/')[0]  # Split out the protocol
        $serverName= $request['Server_Name']                     # And what it thinks it called the server

        $fullOriginalUrl = $protocol.ToLower() + "://" + $serverName + $request.Params["HTTP_X_ORIGINAL_URL"]
        
        $relativeUrl = $fullOriginalUrl.Replace("$pathInfoUrl", "")            
       
        if ($relativeUrl -like "*/*") {
            $depth = @($relativeUrl -split "/" -ne "").Count - 1
            if ($depth -eq 0) { $depth = 1 } 
        } else {
            $depth  = 0
        }
        
    }
    
    
    "<h3 class='ui-widget-header' itemprop='name'>$($_.Name)</h3>
    $(
    if ($_.Url) {
        if (-not $_.ArticleText -or ($_.ArticleBody)) {
            Write-Link -Button -Url $_.Url -Caption "<span class='ui-icon ui-icon-extlink'>
                </span>
                <br/>
                <span style='text-align:center'>
                From $(
                    $urlHost=([uri]$_.Url).DnsSafeHost
                    if ($urlHost){
                        $urlHost.Replace('www.', '')
                    } else {
                        $_.Url
                    }
                )
                </span>"
            
        }
        "<meta style='display:none' content='$($_.Url)' itemprop='url' />"
    }
    if ($_.Author) {
        "<meta style='display:none' itemprop='author' content='$($_.Author)' />"
        if ($_.Author -like "@*") {
            "By $($_.Author) - $(Write-Link ('twitter:follow' + $_.Author))"
        } else {
            "By $($_.Author)"
        }
    }    
    if ($_.Image) {    
        Write-Link -Caption "<img border='0' src='$($_.Image)' />" -Simple -Url $_.Url
        "<meta style='display:none' content='$($_.Image)' itemprop='image'>"
    }
    if ($_.Image -or $_.Url) {
        '<br />'
    }
    if ($_.Description -and 
        $_.Description -ne $_.Name -and
        $_.Description -ne $_.ArticleText -and
        $_.Description -ne $_.ArticleBody) {
        "<div class='Description' itemprop='Description' style='text-align:left'>$($_.Description)</div>"
    }
    if ($_.ArticleBody -and $_.ArticleBody -ne $_.Name) {
        "<div class='ArticleBody' itemprop='ArticleBody' style='text-align:left'>$($_.ArticleBody)</div>"
    } elseif ($_.ArticleText -and $_.ArticleText -ne $_.Name) {
        "<div class='ArticleText' itemprop='ArticleText' style='text-align:left'>$($_.ArticleText)</div>"
    }
    
    if ((-not $_.Url) -and $pipeworksManifest.Blog.Name) {
        "<div style='text-align:right'>" + (
        Write-Link -Style @{'font-size'='xx-small'} -Button -Url "$('../' * $depth)?Post=$([Web.HttpUtility]::UrlEncode($_.Name))" -Caption "<span class='ui-icon ui-icon-extlink'>
        </span>
        <br/>
        <span style='text-align:center'>
        Permalink
        </span>") + "</div>" + "<meta style='display:none' itemprop='url' content='$('../' * $depth)?Post=$([Web.HttpUtility]::UrlEncode($_.Name))' />"        
    }    
    if ($pipeworksManifest.Facebook.AppId) {
        "<div class='fb-like' data-send='true' data-width='450' data-show-faces='true'></div> <BR/>" + 
            "<div class='fb-comments' data-href='$(if ($FullUrl) { $fullUrl } else { $request.Url  })' data-num-posts='2' data-width='470'></div>"
                                
    }
    
    
        
        
    
    
    

    )
    
    "    
        
    
}


$ContactPointAction= {
"
<h3 class='ui-widget-header' itemprop='name'>$($_.Name)</h3>
$(
if ($_.ContactType){
"<span itemprop='contactType' class='contactType'>$($_.ContactType)</span><br/>"
}
if ($_.Email){
"<a href='mailto:$($_.Email)' itemprop='email' class='contactEmail'>$($_.Email)</a><br/>"
}
if ($_.Telephone){
"Phone: <span itemprop='telephone' class='contactPhone'>$($_.Telephone)</span><br/>"
}
if ($_.FaxNumber){
"Phone: <span itemprop='telephone' class='contactPhone'>$($_.Telephone)</span><br/>"
}
)
"}


$eventAction = {
"
<div class='product'>
<h3 class='ui-widget-header' itemprop='name'>$($_.Name)</h3>
<p class='ProductDescription'>
$(if ($_.Image) { "<img class='product-image' src='$($_.Image)' align='right' />"})    
<span itemprop='description'>$($_.Description)</span>

</p>
$(
if ($_.Performers){
    if ($_.Performers -is [string]) {
        "<span itemprop='performers' class='eventPerformer'>$($_.Performers)</span><br/>"    
    } else {
        $_.Performers | Out-String -Width 1kb
    }
}
if ($_.Location){
    if ($_.Location -is [string]) {
        "<span itemprop='location' class='eventLocation'>$($_.Location)</span><br/>"    
    } else {
        $_.Location | Out-String -Width 1kb
    }
}
if ($_.StartDate){
    "<meta style='display:none' itemprop='startDate' content='$(([DateTime]$_.StartDate).ToString('r'))' />
    $($_.StartDate | Out-String)
    <br/>
    "    
}
if ($_.EndDate){
    "<meta style='display:none' itemprop='endDate' content='$(([DateTime]$_.EndDate).ToString('r'))' />
    $($_.EndDate | Out-String)
    <br/>
    "   
}
if ($_.Offers) {
    foreach ($o in $_.Offers) {
        $doubleO = $o -as [Double]        
        if ($doubleO) {
            "<span class='product-price' itemprop='offer'>${doubleO}</span>"
        } else {
            $o | Out-String
        }
    }        
}
if ($pipeworksManifest -and $PipeworksManifest.GoogleMerchantId) {
'<div role="button" alt="Add to cart" tabindex="0" class="googlecart-add-button">
</div>'
})
</div>"}

$amiFormatAction = {
    $obj = $_
    if ($obj.Name) { 
        Write-Host $obj.Name -NoNewline
        
    } else {
        Write-Host $obj.ImageLocation -NoNewline
    }

    Write-Host (" :$($obj.ImageId)")

    Write-Host ' ' 
    if ($obj.Description) {
        Write-Host $obj.Description
    }
    return $null    
}


$placeAction = {
    

    # A Place will display a header with the name of the place
    # it will display the address, telephone.
    # if latitude and longitude are available, 
    # it will display a Bing map, and if present, the mapSize parameter will determine resolution


    $canDisplayMap = $true
    $obj = $_
    if ($obj.Latitude -and $obj.longitude) {
        $displayMode = "AerialWithLabels"
        
        if ($obj.StreetAddress) {
            $displayMode = "Road"
        }                        
    }


    $lat = $obj.Latitude 
    $long = $obj.Longitude

    $displayName = if ($obj.Name) {        
        $obj.Name
    } elseif ($obj.StreetAddress -and $obj.Locality) {
        "$($obj.StreetAddress) $($obj.Locality)"
    } elseif ($obj.Latitude -and $obj.Longitude)  {
        "$($obj.Latitude)x$($obj.Longitude)"
    }
    if ($canDisplayMap )  { 
        $mapSize = if ($obj.MapSize) {
            $obj.MapSize
        } else {
            "420,315"
        }
        if ($lat -notlike "*.*" -or $long -notlike "*.*") {
            $zoomLevel = 7
        } else {
            $latp = @($lat.ToString().Split("."))[-1].Length
            $longp = @($long.ToString().Split("."))[-1].Length
            if ($latP -lt $longp)
            {
                $zoomLevel  = 7 + (1.5 * $latP)
            } else {
                $zoomLevel  = 7 + (1.5 * $longP)
            }
        }
        $mapId = "Map_" + $DisplayName.Replace(" ", "_").Replace(",", "_").Replace(".","_")
        $width,$height = $mapSize -split ","
        
        $address= 
            if ($obj.Address) {
                $obj.Address + "<BR/>"
            } else {
                ""
            }
        

        $telephone= 
            if ($obj.Telephone) {
                $obj.Telephone + "<BR/>"
            } else {
                ""
            }

        "<h4>$displayName</h4><div style='text-align:center'>
        
        $address
        $telephone




        
        <iframe width='$width' height='$height' frameborder='0' scrolling='no' marginheight='0' marginwidth='0' src='http://dev.virtualearth.net/embeddedMap/v1/ajax/${displayMode}?zoomLevel=$zoomLevel&center=${lat}_${long}&pushpins=${lat}_${long}' ></iframe></div>"
        
    } else {
        $obj | Select * | Out-HTML
    }
}




# This file is used to regenerate the formatting with the EZOut module.
$formatting = (Write-FormatView -TypeName http://schema.org/Place -Action $placeAction),
$jobPostingView,
(Write-FormatView -TypeName http://schema.org/Person -Action $personAction),
(Write-FormatView -TypeName Walkthru -Action $walkthruFormatAction),
(Write-FormatView -TypeName Module -Action $moduleAction),
(Write-FormatView -TypeName Example -Action $exampleAction),
(Write-FormatView -TypeName WolframAlphaResult -Action $wolframAlphaResultAction),
(Write-FormatView -TypeName http://schema.org/ContactPoint -Action $ContactPointAction),
(Write-FormatView -TypeName http://schema.org/Article -Action $articleAction),
(Write-FormatView -TypeName http://schema.org/BlogPosting -Action $articleAction),(
Write-FormatView -TypeName http://schema.org/VideoObject -Action $mediaObjectAction),(
Write-FormatView -TypeName http://schema.org/ImageObject -Action $mediaObjectAction),
(Write-FormatView -TypeName ColorizedScript -Action $colorizedScriptBlockAction),
(Write-FormatView -TypeName http://schema.org/Event -Action $EventAction),
(Write-FormatView -TypeName Amazon.EC2.Model.Image -Action $amiFormatAction),(
Write-FormatView -TypeName http://schema.org/MediaObject -Action $mediaObjectAction), (
Write-FormatView -TypeName http://shouldbeonschema.org/Class -Action $classAction), (
Write-FormatView -TypeName http://shouldbeonschema.org/Topic -Action $topicAction), (
Write-FormatView -TypeName http://schema.org/Product -Action {
$item = $_
"
<div class='product'>
    <h2 class=`'ui-widget-header`'>$(if ($_.Url) { "<a href='$($_.Url)' itemprop='url'>"})<span class='product-title' itemprop=`'name`'>$($_.Name)</span>
    $(if ($_.Url) { "</a>"})</h2>
    $(if ($_.Brand) {"<meta style='display:none' itemprop='brand' content=$($_.Brand)/>" })    
    $(if ($_.Manufacturer) {"by <span style='font-size:small' itemprop='manufacturer'>$($_.Manufacturer)</span> <br/>" })    
    <p class=`'ProductDescription`'>
    $(if ($_.Image) { "<img class='product-image' src='$($_.Image)' align='right' />"})    
    <span itemprop=`'description`' >$($_.Description)</span>
    
    </p>
    $(if ($_.Offers) {
        foreach ($o in $_.offers) {
            $doubleO = $o -as [Double]
            if ($doubleO) {
                $itemPrice= $doubleO                
                "<span class='product-price' itemprop='offer'>${doubleO}</span>"
            } else {
                $o | Out-String
            }
        }        
    }
    
    if ($itemPrice -and $pipeworksManifest -and $PipeworksManifest.PaypalEmail) {
        Write-Link -ItemName "$($item.Name)" -ItemPrice $itemPrice -PaypalEmail $PipeworksManifest.PaypalEmail
    }
    
    if ($itemPrice -and $pipeworksManifest -and $PipeworksManifest.AmazonPaymentsAccountId -and $PipeworksManifest.AmazonAccessKey ) {
        Write-Link -ItemName "$($item.Name)" -ItemPrice $itemPrice -AmazonPaymentsAccountId $PipeworksManifest.AmazonPaymentsAccountId -AmazonAccessKey $PipeworksManifest.AmazonAccessKey
    }
    if ($itemPrice -and $pipeworksManifest -and $PipeworksManifest.GoogleMerchantId) {
    '<div role="button" alt="Add to cart" tabindex="0" class="googlecart-add-button">
    </div>' + (Write-Link -ItemName "$($item.Name)" -ItemPrice $itemPrice -GoogleCheckoutMerchantId $PipeworksManifest.GoogleMerchantId)
    }
    
    if ($itemPrice) {
        '<br/>'
    }            
    
    
            
    )
</div>
"}) |
    Out-FormatData

$formatPath  = Join-Path $moduleRoot "Pipeworks.Format.ps1xml"
$formatting |
    Set-Content $formatPath  