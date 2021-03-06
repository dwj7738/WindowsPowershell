[System.Reflection.Assembly]::LoadWithPartialName(”System.Web") `
| Out-Null


function Publish-Tweet([string] $TweetText, [string] $Username, [string] $Password)
{ 
[System.Net.ServicePointManager]::Expect100Continue = $false
  $request = [System.Net.WebRequest]::Create("http://twitter.com/statuses/update.xml")
  $request.Credentials = new-object System.Net.NetworkCredential($Username, $Password)
  $request.Method = "POST"
  $request.ContentType = "application/x-www-form-urlencoded" 
  write-progress "Tweeting" "Posting status update" -cu $tweetText

  $formdata = [System.Text.Encoding]::UTF8.GetBytes( "status="  + $tweetText  )
  $requestStream = $request.GetRequestStream()
    $requestStream.Write($formdata, 0, $formdata.Length)
  $requestStream.Close()
  $response = $request.GetResponse()

  write-host $response.statuscode 
  $reader = new-object System.IO.StreamReader($response.GetResponseStream())
     $reader.ReadToEnd()
  $reader.Close()
}


Function Get-TwitterSearch { 
 Param($searchTerm="PowerShell", [switch]$Deep) 
 if ($WebClient -eq $null) {$Global:WebClient=new-object System.Net.WebClient  }
 $searchTerm="PowerShell" 
 $results=[xml]($webClient.DownloadString("http://search.twitter.com/search.rss?rpp=100&page=1&q=$SearchTerm").replace("item","RssItem"))
#lang:      restricts tweets to the given language, given by an ISO 639-1 code
#rpp:       Results per page, (max 100) 
#page:      the page number (starting at 1) to return, up to a max of roughly 1500 results (based on rpp * page)
#since_id:  returns tweets with status ids greater than the given id.
#geocode:   returns tweets by users located within a given radius of the given latitude/longitude, where the user's location is taken from their Twitter profile. The parameter value is specified by "latitide,longitude,radius", where radius units must be specified as either "mi" (miles) or "km" (kilometers). Ex: http://search.twitter.com/search.atom?geocode=40.757929%2C-73.985506%2C25km. Note that you cannot use the near operator via the API to geocode arbitrary locations; however you can use this geocode parameter to search near geocodes directly.
#show_user: when "true", adds "<user>:" to the beginning of the tweet. This is useful for readers that do not display Atom's author field. The default is "false".
 $Searchitems=$results.rss.channel.RssItem 
 if ($Deep) { $MaxID= $results.rss.channel.refresh_url.split("=")[-1]
              2..16 | foreach { $Searchitems += ([xml]($webClient.DownloadString("http://search.twitter.com/search.rss?rpp=100&max_id=$maxID;&page=$_&q=$SearchTerm").replace("item","RssItem"))).rss.channel.RssItem} }
 $SearchItems 
} 
 #Get-twitterSeach "PowerShell" -Deep | select @{Name="Author"; expression={$_.link.split("/")[3] }}, 
 #                                     @{name="Id"; expression={$_.link.split("/")[-1] }}, Title, pubdate #[date]::parseexact($_.pubdate,"formatString")


Function Get-TwitterFriend { 
 param ($username, $password, $ID)
 if ($WebClient -eq $null) {$Global:WebClient=new-object System.Net.WebClient  }
 $WebClient.Credentials = (New-Object System.Net.NetworkCredential -argumentList $username, $password)
 $page = 1
 $Friends = @()
 if ($ID) {$URL="http://twitter.com/statuses/friends/$ID.xml?page="}
 else     {$URL="http://twitter.com/statuses/friends.xml?page="}
 do {  $Friends += (([xml]($WebClient.DownloadString($url+$Page))).users.user   )
                     # Returns the  user's friends, with current status inline, in the order they were added as friends. 
                     # If ID is specified, returns another user's friends
                     #id:    Optional.  The ID or screen name of the user for whom to request a list of friends.
                     #page:  Optional. Retrieves the next 100 friends. 

		$Page ++
	} while ($Friends.count -eq ($page * 100) )
 $Friends
}
#Get-TwitterFriend $userName $password | select name,screen_Name,url,id   


Function Get-TwitterFollower { 
 param ($username, $password, $ID)
 if ($WebClient -eq $null) {$Global:WebClient=new-object System.Net.WebClient  }
 $WebClient.Credentials = (New-Object System.Net.NetworkCredential -argumentList $username, $password)
 $page = 1
 $followers = @()
 if ($ID) {$URL="http://twitter.com/statuses/followers/$ID.xml?page="}
 else     {$URL="http://twitter.com/statuses/followers.xml?page="}
 do {  $followers += (([xml]($WebClient.DownloadString($url+$Page))).users.user   )
                     # Returns the  user's followers, with current status inline, in the order they joined twitter
                     # If ID is specified, returns another user's followers
                     #id:    Optional.  The ID or screen name of the user for whom to request a list of friends.
                     #page:  Optional. Retrieves the next 100 friends. 

		$Page ++
	} while ($followers.count -eq ($page * 100) )
 $followers
}

Function Get-TwitterReply { 
 param ($username, $password, $Page=1)
 if ($WebClient -eq $null) {$Global:WebClient=new-object System.Net.WebClient  }
 $WebClient.Credentials = (New-Object System.Net.NetworkCredential -argumentList $username, $password)
 ([xml]$webClient.DownloadString("http://twitter.com/statuses/replies.xml?page=$Page")  ).statuses.status 
 # Returns the 20 most recent @replies for the authenticating user.
 #page:  Optional. Retrieves the 20 next most recent replies
 #since.  Optional.  Narrows the returned results to just those replies created after the specified HTTP-formatted date, up to 24 hours old.
 #since_id.  Optional.  Returns only statuses with an ID greater than (that is, more recent than) the specified ID.  Ex: http://twitter.com/statuses/replies.xml?since_id=12345
}
#Get-TwitterReply | ft @{label="Screen_Name"; expression={$_.user.Screen_Name}}, Source, Created_at , in_reply_to_status_id, text  -a -wrap 


Function Get-TwitterTimeLine { 
 param ($username, $password, $Page=1)
 if ($WebClient -eq $null) {$Global:WebClient=new-object System.Net.WebClient  }
 $WebClient.Credentials = (New-Object System.Net.NetworkCredential -argumentList $username, $password)
 ([xml]$WebClient.DownloadString("http://twitter.com/statuses/friends_timeline.xml?page=$Page")  ).statuses.status
 # Returns the 20 most recent statuses posted by the authenticating user and that user's friends. This is the equivalent of /home on the Web. 
 #count:    Optional.  Specifies the number of statuses to retrieve. (Max 200.) 
 #since:    Optional.  Narrows the returned results to just those statuses crea ted after the specified HTTP-formatted date, up to 24 hours old. 
 #since_id: Optional.  Returns only statuses with an ID greater than the specified ID.   
 #page.     Optional. 
}
# Get-TwitterTimeline $name $password  | ft @{label="Screen_Name"; expression={$_.user.Screen_Name}}, Source, Created_at , text  -a -wrap


Function Get-TwitterPublicTimeLine { 
 if ($WebClient -eq $null) {$Global:WebClient=new-object System.Net.WebClient  }
 [xml]($webclient.DownloadString("http://twitter.com/statuses/Public_timeline.xml")  ).statuses.status
 # Returns the 20 most recent statuses from non-protected users who have set a custom user icon.  Does not require authentication.  Note that the public timeline is cached for 60 seconds so requesting it more often than that is a waste of resources.
}
#Get-TwitterPublicTimeLine  | ft @{label="Screen_Name"; expression={$_.user.Screen_Name}}, Source, Created_at , in_reply_to_status_id, text  -a -wrap  
 
Function Get-TwitterUserTimeLine { 
 param ($ID)
 if ($WebClient -eq $null) {$Global:WebClient=new-object System.Net.WebClient  }
 ([xml]$webClient.DownloadString("http://twitter.com/statuses/user_timeline/$ID.xml")  ).statuses.status 
 # Returns the 20 most recent statuses posted from the authenticating user. It's also possible to request another user's timeline via the id parameter 
 #id:       Optional. 
 #count:    Optional.  Specifies the number of statuses to retrieve. Max 200.  
 #since:    Optional.  Narrows the returned results to just those statuses created after the specified HTTP-formatted date, up to 24 hours old. 
 #since_id: Optional.  Returns only statuses with an ID greater than (that is, more recent than) the specified ID.   
 #page:     Optional. 
}
#getTwittedUserTimeLine -ID jonhoneyball | ft @{label="Screen_Name"; expression={$_.user.Screen_Name}}, Source, Created_at , in_reply_to_status_id, text  -a -wrap 

# Returns a single status, specified by the id parameter below.  The status's author will be returned inline.
#id:  Required.  The numerical ID of the status you're trying to retrieve.  

#Get-Tweet 1196649130  | ft @{label="Screen_Name"; expression={$_.user.Screen_Name}}, Source, Created_at , in_reply_to_status_id, text  -a -wrap 


Function Get-TinyURL { 
 param ( $PostLink )
 if ($WebClient -eq $null) {$Global:WebClient=new-object System.Net.WebClient  }
 $webClient.DownloadString("http://tinyurl.com/api-create.php?url="  + [System.Web.HttpUtility]::UrlEncode($postlink)) 
}



Filter Add-TwitterFriend
{Param ([string] $ID, [string] $Username, [string] $Password)
 [System.Net.ServicePointManager]::Expect100Continue = $false
  if ($id -eq $null) {$id=$_}
  $request = [System.Net.WebRequest]::Create("http://twitter.com/friendships/create/$ID.xml")
  $request.Credentials = new-object System.Net.NetworkCredential($Username, $Password)
  $request.Method = "POST"
  $request.ContentType = "application/x-www-form-urlencoded" 
  write-progress "Tweeting" "Adding Friend" -cu $ID

  $formdata = [System.Text.Encoding]::UTF8.GetBytes( 'follow=true'  )
  $requestStream = $request.GetRequestStream()
    $requestStream.Write($formdata, 0, $formdata.Length)
  $requestStream.Close()
  $response = $request.GetResponse()

  write-host $response.statuscode 
  $reader = new-object System.IO.StreamReader($response.GetResponseStream())
     $reader.ReadToEnd()
  $reader.Close()
  $id=$null
}



#Pasted from <http://devcentral.f5.com/weblogs/Joe/archive/2008/12/30/introducing-poshtweet---the-powershell-twitter-script-library.aspx> 


function Get-TwitterList()
{   $wc = new-object system.net.webclient
    $site = $wc.DownloadString('http://www.mindofroot.com/powershell-twitterers/')
	
	$previous = @()
	$site =  $site.substring( $site.IndexOf('<div class="entrybody">'))
	$site = $site.substring($site.IndexOf('<ul>'))
	
	[xml]$doc = $site.substring(0,($site.IndexOf('</ul>') + 5))	
	$results = $doc.ul.li | select @{name='Name';Expression={$_.a.'#text'}},
                               @{name='TwitterURL';Expression={$_.a.href}},
                               @{name='UserName';Expression=
                                {$_.a.href -replace 'http://twitter.com/'}}
	$results[1..($results.count-1)]
}



# SIG # Begin signature block
# MIINGAYJKoZIhvcNAQcCoIINCTCCDQUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOeRMBlWYFdGCk3gMgfDJ0gK1
# hpCgggpaMIIFIjCCBAqgAwIBAgIQAupQIxjzGlMFoE+9rHncOTANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE0MDcxNzAwMDAwMFoXDTE1MDcy
# MjEyMDAwMFowaTELMAkGA1UEBhMCQ0ExCzAJBgNVBAgTAk9OMREwDwYDVQQHEwhI
# YW1pbHRvbjEcMBoGA1UEChMTRGF2aWQgV2F5bmUgSm9obnNvbjEcMBoGA1UEAxMT
# RGF2aWQgV2F5bmUgSm9obnNvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAM3+T+61MoGxUHnoK0b2GgO17e0sW8ugwAH966Z1JIzQvXFa707SZvTJgmra
# ZsCn9fU+i9KhC0nUpA4hAv/b1MCeqGq1O0f3ffiwsxhTG3Z4J8mEl5eSdcRgeb+1
# jaKI3oHkbX+zxqOLSaRSQPn3XygMAfrcD/QI4vsx8o2lTUsPJEy2c0z57e1VzWlq
# KHqo18lVxDq/YF+fKCAJL57zjXSBPPmb/sNj8VgoxXS6EUAC5c3tb+CJfNP2U9vV
# oy5YeUP9bNwq2aXkW0+xZIipbJonZwN+bIsbgCC5eb2aqapBgJrgds8cw8WKiZvy
# Zx2qT7hy9HT+LUOI0l0K0w31dF8CAwEAAaOCAbswggG3MB8GA1UdIwQYMBaAFFrE
# uXsqCqOl6nEDwGD5LfZldQ5YMB0GA1UdDgQWBBTnMIKoGnZIswBx8nuJckJGsFDU
# lDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAw
# bjA1oDOgMYYvaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1j
# cy1nMS5jcmwwNaAzoDGGL2h0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFz
# c3VyZWQtY3MtZzEuY3JsMEIGA1UdIAQ7MDkwNwYJYIZIAYb9bAMBMCowKAYIKwYB
# BQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwgYQGCCsGAQUFBwEB
# BHgwdjAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME4GCCsG
# AQUFBzAChkJodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEy
# QXNzdXJlZElEQ29kZVNpZ25pbmdDQS5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG
# 9w0BAQsFAAOCAQEAVlkBmOEKRw2O66aloy9tNoQNIWz3AduGBfnf9gvyRFvSuKm0
# Zq3A6lRej8FPxC5Kbwswxtl2L/pjyrlYzUs+XuYe9Ua9YMIdhbyjUol4Z46jhOrO
# TDl18txaoNpGE9JXo8SLZHibwz97H3+paRm16aygM5R3uQ0xSQ1NFqDJ53YRvOqT
# 60/tF9E8zNx4hOH1lw1CDPu0K3nL2PusLUVzCpwNunQzGoZfVtlnV2x4EgXyZ9G1
# x4odcYZwKpkWPKA4bWAG+Img5+dgGEOqoUHh4jm2IKijm1jz7BRcJUMAwa2Qcbc2
# ttQbSj/7xZXL470VG3WjLWNWkRaRQAkzOajhpTCCBTAwggQYoAMCAQICEAQJGBtf
# 1btmdVNDtW+VUAgwDQYJKoZIhvcNAQELBQAwZTELMAkGA1UEBhMCVVMxFTATBgNV
# BAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIG
# A1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTEzMTAyMjEyMDAw
# MFoXDTI4MTAyMjEyMDAwMFowcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGln
# aUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUgU2lnbmluZyBDQTCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAPjTsxx/DhGvZ3cH0wsxSRnP0PtFmbE620T1
# f+Wondsy13Hqdp0FLreP+pJDwKX5idQ3Gde2qvCchqXYJawOeSg6funRZ9PG+ykn
# x9N7I5TkkSOWkHeC+aGEI2YSVDNQdLEoJrskacLCUvIUZ4qJRdQtoaPpiCwgla4c
# SocI3wz14k1gGL6qxLKucDFmM3E+rHCiq85/6XzLkqHlOzEcz+ryCuRXu0q16XTm
# K/5sy350OTYNkO/ktU6kqepqCquE86xnTrXE94zRICUj6whkPlKWwfIPEvTFjg/B
# ougsUfdzvL2FsWKDc0GCB+Q4i2pzINAPZHM8np+mM6n9Gd8lk9ECAwEAAaOCAc0w
# ggHJMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQM
# MAoGCCsGAQUFBwMDMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDov
# L29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5k
# aWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8E
# ejB4MDqgOKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1
# cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsME8GA1UdIARIMEYwOAYKYIZIAYb9
# bAACBDAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BT
# MAoGCGCGSAGG/WwDMB0GA1UdDgQWBBRaxLl7KgqjpepxA8Bg+S32ZXUOWDAfBgNV
# HSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzANBgkqhkiG9w0BAQsFAAOCAQEA
# PuwNWiSz8yLRFcgsfCUpdqgdXRwtOhrE7zBh134LYP3DPQ/Er4v97yrfIFU3sOH2
# 0ZJ1D1G0bqWOWuJeJIFOEKTuP3GOYw4TS63XX0R58zYUBor3nEZOXP+QsRsHDpEV
# +7qvtVHCjSSuJMbHJyqhKSgaOnEoAjwukaPAJRHinBRHoXpoaK+bp1wgXNlxsQyP
# u6j4xRJon89Ay0BEpRPw5mQMJQhCMrI2iiQC/i9yfhzXSUWW6Fkd6fp0ZGuy62ZD
# 2rOwjNXpDd32ASDOmTFjPQgaGLOBm0/GkxAG/AeB+ova+YJJ92JuoVP6EpQYhS6S
# kepobEQysmah5xikmmRR7zGCAigwggIkAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# MTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcg
# Q0ECEALqUCMY8xpTBaBPvax53DkwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwx
# CjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGC
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFPFoVEXRHOEJ+a1p
# 0SmOvXcXI0mfMA0GCSqGSIb3DQEBAQUABIIBAMz8BeXIIJB0pb7krZCL1Phaimzt
# jzKCoCsqjjViBX9jEJ+QRVEXTHL14hwLnNDZTD5NwW02gwNnYW9WD1LsHOGD3HVd
# R8Ajuw+Uhu2tT6ptZcOrv2c8EAwzXrf7KIit/loRstsMbPXSWB9YYVhUW2jAHBfN
# rsEu1J3c1OOXMWW7VhLOa810u+EeSnSSgZ62UNBw40e7mGLUpl6rKY7sSjSIV8DC
# xHnXL9rl+1AlRwSQOwluzhqzB1siZG5MCOXhRf7jz+DkcjHJBchUqN80mvb/1nhv
# swZ1Kpj2PkZgBoGrhwwTsxsCgMBZtfs9Iv5VzHBGlYbifVpbmGhah8V/JT4=
# SIG # End signature block
