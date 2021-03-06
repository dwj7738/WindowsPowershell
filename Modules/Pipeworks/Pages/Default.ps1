if (-not $connectTheClouds) {
    $connectTheClouds = . {
       ConvertFrom-Markdown @"
Cloud Services are cool and complimentary.  PowerShell Pipeworks includes tools to work with several different cloud services, such as Azure, Amazon Web Services, and Office365, and Wolfram|Alpha.

"@
    "<p style='text-align:center'>Learn some more about what happens when you join windows and web</p>"
        New-Region -AsLeftSidebarMenu -SidebarWidth 33 -LayerID ConnectTheClouds -Style @{
            "font-size" = "small"
        } -Layer @{
            "Using Azure Table Storage" = ConvertFrom-Markdown @'
Azure Table Storage provides incredibly cheap NoSQL storage.   PowerShell Pipeworks provides many commands to interact with Azure Table Storage.  The primary ones you will use are:

* Search-AzureTable
* Get-AzureTable
* Set-AzureTable
* Update-AzureTable

To see some of Table Storage in Action, check out [the Azure Table Storage Demo](Module.ashx?Walkthru=Using Azure Table Storage in Pipeworks)
'@
            "Publishing Services to Azure" = (ConvertFrom-Markdown "
One of the amazing things about Azure is the capability to host hundreds of sites within a single deployment.  PowerShell Pipeworks provides a way to do this elegantly.  If you use the DomainSchematics section of a Pipeworks Manifest, you can specify as many different domains and subdomains as you'd like when building a site.  When you use provide multiple modules to the command Publish-AzureService, it creates a deployment package containing all of them.


The Start-Automating deployement is one of the more elegant examples of this.  This generates an Azure deployment package with over 40 modules on 80 different subdomains:
") + (Write-ScriptHtml -Text {
    Import-Module Pipeworks -Force
Import-Module ShowUI -Force

$modules = 'AutoBrowse',
    'CodeCraft',
    'DemoPowershell',
    'Discovery',
    'EZOut',
    'Formulaic',
    'Get-Letterhead',
    'Get-Random',
    'Heatmap',
    'Monitis',
    'MoreLunches',
    'New-Popquiz',
    'Patchy',
    'Pipeworks',
    'PingMe',
    'Pinglings',
    'PSImageTools',
    'PSRss',
    'PSSystemTools',
    'PSUserTools',
    'RoughDraft',
    'ScriptCop',
    'ScriptCoverage',
    'SecureSettings',
    'Share-Script',
    'ShouldBeOnSchema.org',
    'ShowUI',
    'ShowSensor',
    'Show-Powershell',
    'Start-Automating',
    'Start-LearningPowerShell',
    'Start-Scripting',
    'Streamline',
    'TaskScheduler',
    'Test-Student',
    'Update-Web',
    'Unlock-Achievement',
    'WmiSpy',
    'XBPS',
    'PowershellPack'

    
Import-Module $modules -Force -PassThru |
    Publish-AzureService -DeploymentName StartAutomatingDeployment -VMSize Small

Import-Module Pipeworks -Force

})
            "Sandboxing with Amazon Web Services" = "
While Azure is Amazing for Hosting Hundreds of Sites in their finished form, Amazon is Awesome when you just need a single box, or want complete control over that box.   If you have installed the Amazon C# SDK, you can also use functions in PowerShell Pipeworks to manipulate EC2 instances.  This can be great for building a developer sandbox, or providing a temporary machine for testing or training.  The demo below shows how to bring up an EC2 instance
" + (Write-scripthtml -text {
# This creates a new Server2008R2 image, and waits for it to be ready.  The wait may take a while.
Add-EC2 -Name "TestServer2008R2" -ImageId ami-0cb76d65 -PassThru |
    Wait-EC2 
    
# Once it's up, this will retrieve the instance password for the image.  
# If you're providing the machine a part of a service, you could email this out.
Get-EC2 -Name "TestServer2008R2" |
    Get-EC2InstancePassword 
   
# You can use the Enable-EC2Remoting command to enable PowerShell remoting on the machine
Get-EC2 -Name "TestServer2008R2"  | Enable-EC2Remoting -PowerShell -Echo


# At this point we can run commands
Get-EC2 -Name "TestServer2008R2" | 
    Invoke-EC2 -ScriptBlock { "hello world"} 
 
# And we can also connect via RDP
Get-EC2 -Name "TestServer2008R2"  |
    Connect-EC2            
})
            "Emailing with Office365" = "Managing communication with customers is a key part of any web application.  PowerShell Pipeworks includes commands to let you send email or appointments via any Exchange server, including Office365.  It also includes commands that allow you to read email, so you can automatically respond to actions sent via email or take data in an email and use it within your application."
            "Texting with Twilio" = (ConvertFrom-Markdown "Customers communicate in many mediums.  You can text with [Twilio](http://twilio.com) from PowerShell Pipeworks in a quick one-liner:" ) + (
    Write-ScriptHTML -Text {        
        Send-TextMessage -To "1-206-555-5555" -From "1-206-555-5555" -Body "Texting - 1, 2, 3."
    }
)  
            "The Wonders of Wolfram|Alpha" = (ConvertFrom-Markdown "
Wolfram|Alpha is a knowledge search engine.  PowerShell Pipeworks provides a command, Search-WolframAlpha, which you can use to find out incredibly precise information about almost anything.  Here's a quick example of getting price performance comparisons for a stock
") + (
    Write-ScriptHTML -Text {        
        Search-WolframAlpha -For "MSFT" -ApiKeySetting WolframAlphaApiKey | 
            Select-Object -ExpandProperty "Performance Comparisons"
    }
)        
        } -Order "Using Azure Table Storage", "Publishing Services to Azure", "Sandboxing with Amazon Web Services", "Emailing with Office365", "Texting with Twilio", "The Wonders of Wolfram|Alpha"
    }    
}

if (-not $joinWindowsAndWeb) {
    $joinWindowsAndWeb = . {
       ConvertFrom-Markdown @"
Windows is the backbone of the computing industry.  Windows PowerShell has become the linga franca on Windows.  Since it's introduction in 2006, Windows PowerShell has seen rapid adoption within the enterprise and within the industry.   All major virtualization technologies support PowerShell, and the entire Microsoft enterprise IT product line is managed with PowerShell. 



PowerShell Pipeworks gives you the tools to mesh the amazing automation available together as part of a web application.
"@
    "<p style='text-align:center'>Learn some more about what happens when you join windows and web</p>"
        New-Region -AsLeftSidebarMenu -SidebarWidth 33 -LayerID JoinWindowsAndWeb -Style @{
            "font-size" = "small"
        } -Layer @{
            "Why Windows?" = (ConvertFrom-Markdown @'
We all know that Windows is the workhorse of the workplace.  Understanding why helps make the case for why you should build your web application on Windows.

To paraphrase the *Hitchhiker's Guide to the Galaxy*: Windows is big.  *Really* big.   




Windows has been expanding for over 20 years and, believe it or not, that expansion has been largely dictated by what large customers of Windows wanted.  This means that buried within Windows are literally millions of things you can do programatically.
 



In constrast, OsX has been expanding for about 10 years now, and that expansion is largely dictated by what small customers want.  Throughout OsX one encounters cases where it's possible to click but not script your way through and interaction.

 


While Linux has been expanding for roughly 40 years, it's been largely expanding based off of the needs of the developers working on individual parts.  This means that many parts overlap and do not usually play well together.




To get a simple idea of just how big Windows is, a box with nothing than Windows, Office, Reader, and Skype contains roughly:


* 3000 COM Objects
* 7000 WMI Classes
* 30000 .NET Classes



Put another way, Windows has 40,000 fairly well structured solutions right out of the box, not counting the tens of thousands of small C operations that you can do.   Since Apple and Linux have no mechanism for discoverying programmatic capabilites on a machine, there isn't even a way of knowning how large the gap is.



Not only are there so many solutions built into the box of Windows, there's an astounding amount of documentation about most of the capabilities of the operating system.  This means that there's a considerably higher chance of being able to actually write a complex application at all.
'@
)
            "Scripting with Superglue" = ConvertFrom-Markdown @'
Windows may have many possiblilties, but it's only within the past decade that it's been plausible to superglue them together.  Most scripting languages are not focused on OS integration as much as text manipulation.  Because of PowerShell's heavy emphasis on objects and Windows' wide world of classes, PowerShell is able to interact with many more components out of the box than any other scripting language on earth.  This is why writing PowerShell is sometimes called "Scripting with Superglue".  PowerShell Pipeworks enables you to glue together all of the things you can work with in PowerShell, and use them in a web application.  



Out of the box, PowerShell works wonderfully with:


* Anything from .NET
* Almost all COM Objects
* Anything from WMI
* Any .exe
* Any SOAP Web service (with New-WebServiceProxy)
* Any REST web service (with System.Net.Webclient)
* Low-Level windows Operations (via P/Invoke)



And if this wasn't enough, you can use the built in PowerShell cmdlet Add-Type to compile your way there.
'@            
            "Integrated Intranet" = ConvertFrom-Markdown @'
Another important reason why to use PowerShell Pipeworks is the degree to which it can let you have an integrated intranet.   
Since most web languages come from a linux background, making them work with windows is often like trying to fit a round peg into a square hole.  
Most enterprise IT applications need to do things like work with Active Directory, Exchange, or Sharepoint - Technologies PowerShell already works well with.  
You can use the -AsIntranetSite parameter on ConvertTo-ModuleService along with -AppPoolCredential to make any module available on your intranet as a certain user.            



PowerShell Pipeworks also includes a useful function to look up information from Active Directory:  Get-Person.  
'@            
            "The Power of PSNode" = ConvertFrom-Markdown @'
PowerShell Pipeworks normally runs inside of ASP.NET, but also includes an incredibly lightweight server called PSNode that opens up many more possibilities locally.


PSNode is designed to create high-throughoutput and low-impact local sites.  You can start a PSNode on the fly with Start-PSNode, or install it to run as the current user with Install-PSNode.



PSNode will run interactively in the session that launched it.  This means that by setting up specialized local PSNodes, you can do amazing things like remotely initiating activity on a PC.  This can turn any browser into a remote control for your machine. 
'@
        } -Order "Why Windows?", "Scripting with Superglue", "Integrated Intranet", "The Power of PSNode"
    }    
}

if (-not $updateDataNotDesigns) {
   $UpdateDataNotDesigns = . {
       ConvertFrom-Markdown @"
Windows PowerShell is a stronger language than many other scripting languages because it is focused on tasks and data.  Most scripting languages work at combining text, but almost everything you do in PowerShell produces objects.  This that I can stop trying to think of each page as a bunch of carefulled coded css, and start to update data and not designs.


"@

        "<p style='text-align:center'>To learn more, let's look at the way data-driven sites work in Pipeworks</p>" 
        
        New-Region -AsLeftSidebarMenu -SidebarWidth 33 -LayerID UpdateDataNotDesign -Style @{
            "font-size" = "small"
        }  @{
            "From Object To Output" = (ConvertFrom-Markdown -Markdown @'
In most cases, the process of building an application is turning messy objects into clean output.  Unfortunately, this often means that a lot of your experiences with technology are actually very different from how the technology works under the covers.  This means all sorts of pain in all sorts of ways, and it's one of the major problems that PowerShell sets out to solve as a language.




A core piece of this problem is what is called 'data loss'.  If you're plugging together several solutions, you need to communicate complex information from one solution to the next.  Unfortunately, in most cases in other web languages than PowerShell, a object is almost always only available in text.  This means tons of time has to be spent plugging two parts of a problem together, just because one of them went from Object to Output a little too early.




If want to make a good experience, and still keep all of your data intact so that you can reuse it in other projects, you need a way to "style" an object.  Luckily, PowerShell has this built in.
'@
)
            "An Object with a View" = (ConvertFrom-Markdown -Markdown @'
The Powershell View system lets you run custom code to output any object in PowerShell, and gives you a good enough default if no view exists.  Pipeworks does the same thing in HTML.   You can either allow Pipeworks to output all of the properties in an object into a simple table, or create a custom view for an object.  You can define multiple views for the same type, or define a view for a [duck type](http://en.wikipedia.org/wiki/Duck_typing) with any type name.


Pipeworks ships with a number of views for common HTML5 data types.  This quick example creates a new webpage from the [http://schema.org/VideoObject](http://schema.org/VideoObject) contained on the QuickStart video page on YouTube.
'@
) + (Write-ScriptHTML -Text {
Get-Web -Url http://www.youtube.com/watch?v=xPRC3EDR_GU -AsMicrodata -Itemtype http://schema.org/VideoObject |
    Out-Html |
    New-Webpage -Title "Quickstart Video" -UseJQueryUI -JQueryUITheme Blitzer
})

            "Help HTML5 Microdata" = (ConvertFrom-Markdown -Markdown @'
One of the cornerstones of HTML5 is something called Microdata.  It comes out of a very good point about the web as it is today:  Even though tons of the world's data is "online", it's almost impossible to extract.  PowerShell Pipeworks is the first framework that always produces HTML5 microdata, and it ships with views for most of the common base types on [Schema.org](http://schema.org).  It also ships with a function called Get-Web, which lets you slice and dice HTML in a variety of ways, including extracting Microdata.    Here are a few cool examples of extracting out Microdata in PowerShell Pipeworks:
'@
) + (Write-ScriptHTML -Text {
# Pull out the quickstart video from YouTube
Get-Web -Url http://www.youtube.com/watch?v=xPRC3EDR_GU -AsMicrodata -Itemtype http://schema.org/VideoObject


# Or information about the first movie in IMDB
Get-Web -Url "http://www.imdb.com/title/tt01/" -AsMicrodata -ItemType http://schema.org/Movie    

# Or the lastest post from my blog 
Get-Web -Url "http://blog.start-automating.com/" -asMicrodata -itemtype http://schema.org/BlogPosting

# Or a dinner recipe cooking instructions.
$url = "http://www.myrecipes.com/recipe/veal-and-artichoke-stew-with-avgolemono-10000000226585/"
Get-Web -Url $url  -AsMicrodata -ItemType http://data-vocabulary.org/Recipe
}) + (ConvertFrom-Markdown @'
These few examples are just the tip of the iceberg.  As microdata is adopted, more and more sites will be easily aggregatable with Pipeworks, and, because these sites will also produce microdata, yet more sites can use the data you produce.   To learn more about how Microdata helps unlock the web, watch this excellent TED talk by Tim-Berners Lee:
'@)+ @'
<br/>
<object width="526" height="374">
<param name="movie" value="http://video.ted.com/assets/player/swf/EmbedPlayer.swf"></param>
<param name="allowFullScreen" value="true" />
<param name="allowScriptAccess" value="always"/>
<param name="wmode" value="transparent"></param>
<param name="bgColor" value="#ffffff"></param>
<param name="flashvars" value="vu=http://video.ted.com/talk/stream/2009/Blank/TimBernersLee_2009-320k.mp4&su=http://images.ted.com/images/ted/tedindex/embed-posters/TimBerners-Lee-2009.embed_thumbnail.jpg&vw=512&vh=288&ap=0&ti=484&lang=&introDuration=15330&adDuration=4000&postAdDuration=830&adKeys=talk=tim_berners_lee_on_the_next_web;year=2009;theme=what_s_next_in_tech;event=TED2009;tag=business;tag=communication;tag=design;tag=invention;tag=technology;tag=web;&preAdTag=tconf.ted/embed;tile=1;sz=512x288;" />
<embed src="http://video.ted.com/assets/player/swf/EmbedPlayer.swf" pluginspace="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" wmode="transparent" bgColor="#ffffff" width="526" height="374" allowFullScreen="true" allowScriptAccess="always" flashvars="vu=http://video.ted.com/talk/stream/2009/Blank/TimBernersLee_2009-320k.mp4&su=http://images.ted.com/images/ted/tedindex/embed-posters/TimBerners-Lee-2009.embed_thumbnail.jpg&vw=512&vh=288&ap=0&ti=484&lang=&introDuration=15330&adDuration=4000&postAdDuration=830&adKeys=talk=tim_berners_lee_on_the_next_web;year=2009;theme=what_s_next_in_tech;event=TED2009;tag=business;tag=communication;tag=design;tag=invention;tag=technology;tag=web;&preAdTag=tconf.ted/embed;tile=1;sz=512x288;"></embed>
</object>
'@
            "Storing Stuff" = (ConvertFrom-Markdown @'
It would be impossible to build a data driven site without someplace to store the data, and so Pipeworks gives you tools to store stuff.  You can store objects in PowerShell in many different ways, and Pipeworks adds a few more powerful options:  The most effective ways to store data in Pipeworks are using Azure Table Storage (with Set-AzureTable and Update-AzureTable) or storing the data on disk with (with Export-PSData).

A Quick example of each is below:
'@) + (Write-ScriptHTML -Text {
# Takes the latest blog posting and stores it in a new row within the BlogPartition in the BlogBackup table
Get-Web -Url "http://blog.start-automating.com/" -asMicrodata -itemtype http://schema.org/BlogPosting |
    Set-AzureTable -TableName BlogBackup -PartitionKey BlogPartition -RowKey { [GUID]::NewGuid() } 

# Takes the latest blog posting and stores it locally in a .psd1 (PowerShell Data File)
Get-Web -Url "http://blog.start-automating.com/" -asMicrodata -itemtype http://schema.org/BlogPosting |
    Export-PSData .\Posts\Test.post.psd1 

})
            "From Scripts to Services" = (ConvertFrom-Markdown @'
Because modern web applications have to play nicely together, they are usually more than just pretty HTML.  Most modern web applications are build according to a [Service Oriented architecture](http://en.wikipedia.org/wiki/Service-oriented_architecture).   A Service Oriented Architecture lets you interact with your data via well-formulated web services, which makes it easy to plug solutions together.  



Service Oriented Architectures are normally very hard, but they are free in PowerShell Pipeworks.   In PowerShell Pipeworks, you convert PowerShell commands and modules into web services by using the commands ConvertTo-CommandService and ConvertTo-ModuleService.  This means that when you writing simple scripts, you're getting a service oriented architecture for free.
'@)
            "Starting with Schematics" = (ConvertFrom-Markdown "
Most applications are not a beautiful and unique snowflake.




In fact, once you've distilled an application down into pure data, it's easy to build a blueprint for how you'd like to build a type of site.  These are called Schematics.




Schematics give you an easy way to apply a set of capabilities to a site.  You can apply a schematic by using the -UseSchematic parameter in ConvertTo-ModuleService, like this:
") + (
Write-ScriptHTML -Text {
    ConvertTo-ModuleService -Name Start-Scripting -UseSchematic Blog
}) + (ConvertFrom-Markdown -Markdown @'
Or embed it within the Pipeworks Manifest in the DomainSchematics section
'@
) + (

Write-ScriptHTML -Text {
    @{
        "DomainSchematics" = @{
            "http://blog.start-automating.com | http://blog.startautomating.com" = "Blog"    
            "Start-Automating.com | StartAutomating.com | www.Start-Automating.com | www.StartAutomating.com" = "ObjectPage", "PartWiki"
        }
    }
})           
             

        } -Order "From Object to Output", "An Object with a View", "Help HTML5 Microdata", "Storing Stuff", "From Scripts to Services", "Starting with Schematics" 
        <#
       "Very Nice Views" = (
        #>
   }
}
if (-not $writeSitesInSeconds) {
    $writeSitesInSeconds  = . {
        (ConvertFrom-Markdown @"
Writing sites is tends to be a tedium of tweaking tags and jostling javascripting, but it doesn't have to be.  With PowerShell Pipeworks, you can write sites in a snap by using functions to facilitate more flexible frontend.




PowerShell Pipeworks provides a number of tools to help you write sites in a snap.  Let's take a look at a few examples: 
"@) + (New-Region -LayerId QuickSitesDemos -Style @{
    "font-size" = "small"
} -layer @{
    "A Simple Page" = New-Region -SidebarWidth 33 -AsTab -Style @{
        "font-size" = "small"
    } -ColumnCount 1 -LayerID PageExamples -Layer @{
            "Hello World" = (
                    ConvertFrom-Markdown @"
Setting up a simple page is usually anything but.
For every few lines of content, there are a dozen of tags.
Let's see how we can make a simple Breaking News page without breaking a sweat:
"@
                ) + (
                Write-ScriptHTML -Text {
                    New-Region -aspopout -Layer @{
                        "Hello World" = "Welcome to PowerShell Pipeworks.  It's time to Update-Web -with Powershell."
                    }-Style @{
                        "top" = "10%"
                        "margin-left" = "17%"
                        "margin-right" = "17%"
                        "text-align" = "center"
                        "font-size" = "xx-large"            
                    } |
                    New-WebPage -Title "Hello World" -UseJQueryUI -JQueryUITheme Blitzer 
                }
                )
            "Using Markdown" = (
        ConvertFrom-Markdown @'
It's also possible to make sites using [Markdown](http://daringfireball.net/projects/markdown/) with Pipeworks, which let's you use even less markup
'@
    ) + (
        Write-ScriptHTML -Text {
# A simple site using Markdown
ConvertFrom-Markdown -Markdown @'
# Use-Markdown in PowerShell Pipeworks
Did you know you could use [Markdown](http://daringfireball.net/projects/markdown/) in PowerShell Pipeworks?  
    ConvertFrom-Markdown @'
    # Hello World
    '@
'@ |
    New-WebPage -Title "Simple Markdown Example"
}
    )
        "The Joy of JQuery" = (
        ConvertFrom-Markdown @'
PowerShell Pipeworks makes extensive use of [JQuery](http://jquery.org) and [JQueryUI](http://jqueryui.com) so that you can built somewhat sleek sites in a few seconds.




A quick example is using the New-Region command to create a quick slideshow: 

'@
    ) + (
        Write-ScriptHTML -Text {
# A slideshow that switches every few seconds
New-Region -AsSlideShow -AutoSwitch "0:0:5" -Layer @{
    "About Latin" = "Latin is a language that has been on life support for roughly 1500 years.
It's a very good language to learn to help understand other languages"
    "Funny Factoids" = "Did you know?  A 'v' in Latin is pronounced like a 'w'.  Suddenly Veni Vidi Vici seems less macho."
    "Obligitory Sample Latin" = "Quidquid latine dictum sit altum sonatur.  Verba Volant, Scripta Manent."     
} |
    New-WebPage -Title "The Joy of JQueryUI in Pipeworks"
}
    ) + (ConvertFrom-Markdown @'
By using the [JQueryUI ThemeRoller](http://jqueryui.com/themeroller) and Pipeworks, you can set up a sleek site in a snap.
'@
    )
            
        }  
    
        
     
    "A Blog" = (
        ConvertFrom-Markdown @"
Basic blogs are a blast in PowerShell Pipeworks.


You can build a basic blog atop Azure by following these simple steps:
"@
    ) + (New-Region -AsTab -ColumnCount 1 -LayerID BlogSteps -Style @{
            "font-size" = "small"
    } -Layer @{
        "1. Get set up with Azure" = (ConvertFrom-Markdown @'
Sign up for an Azure account so you can publish your blog and store the articles online.  Once you've set up the account, create a storage account, copy your storage keys to the clipboard, open Powershell, and run:

- - -
'@) + (
    Write-ScriptHTML -Text {
# Set $myStorageAccount and $myStorageKey first
Import-Module Pipeworks 
Add-SecureSetting -Name AzureStorageAccountName -String $myStorageAccount
Add-SecureSetting -Name AzureStorageAccountKey -String $myStorageKey

Add-AzureTable -TableName MyBlog

}
) 
        "2. Write a Module For Your Blog" = (ConvertFrom-Markdown @'
Most web languages are fundamentally focused on single pages.  In PowerShell Pipeworks, you main mission is making a module with the right metadata, and then your site falls into place.  You do this by writing a module with some extra pieces of information.  The script below will create a MyBlog module
'@) + (Write-ScriptHtml -Text {

# Create the blog module directory if it doesn't exist
if (-not (Test-Path $home\Documents\WindowsPowerShell\Modules\MyBlog)) {
    New-Item -ItemType Directory -Path $home\Documents\WindowsPowerShell\Modules\MyBlog |
        Out-Null
}



# A PowerShell module has two core files, a manifest (.psd1) and a script module file (.psm1)

# This is the module manifest
# The module manifest has a lot of module metadata, including what script module file to use
{
    @{
        ModuleVersion = '1.0'
        ModuleToProcess = 'MyBlog.psm1'
    }
} |
    Set-Content $home\Documents\WindowsPowerShell\Modules\MyBlog.psd1
  


# This is the script module.  It declares commands and does module initialization.
{

param([Hashtable]$Options) 
# If you need to replace the .crud file, simply import the module with -ArgumentList @{Options= @{Clean=$true}}

if ($options.Clean) {
    Remove-Item "$psScriptRoot\Crud.ps1"
}
if (-not (Test-Path "$psScriptRoot\Crud.ps1")) {
    $crud = ""
    # Create a blog 
    $crud += Write-CRUD -Table MyAzureTable -Partition MyBlog -Schema http://schema.org/BlogPosting -Noun MyBlogPost
    $crud | 
        Set-Content "$psScriptRoot\Crud.ps1"
}

. $psScriptRoot\Crud.ps1 


} |
    Set-Content $home\Documents\WindowsPowerShell\Modules\MyBlog.psm1



# A Pipeworks module usually has one more file, the Pipeworks manifest.
# The Pipeworks Manifest contains settings used to publish your module.
# Any table in this file can be passed to a Schematic, 
# Schematics use these values in that table as a blueprint to build a site.
{

@{
    SecureSetting = 'AzureStorageAccountName', 'AzureStorageAccountKey'
    UseJQueryUI = $true
    # To make your blog a beautiful and unique snowflake, go to 
    # http://jqueryui.com/themeroller, create a custom theme, 
    # download it, put it in the directory, and rename this to custom
    JQueryUITheme = 'Redmond' 
    AnalyticsId = '' # add one if you want to
    
    # These are parameters to the Blog Schematic.  
    Blog = @{
        # The displayname and the partition in Azure Table Storage
        Name = "MyBlog"
        # A subtitle or description for the blog
        Description = "My Blog"
        # A link to the blog's front page.
        Link = "http://my.blog.com/"    
    }
    
    # The WebCommand section tells which commands within a module 
    # become web services.  The Keys are the name of the commands
    WebCommand = @{       
        "Get-MyBlogPost" = @{
            # The values are arguments to the function ConvertTo-CommandService
            RunOnline = $true
            RunWithoutInput = $true
        }
    }
    
    # The table section describes how the module works with table storage       
    Table = @{
        Name = 'MyAzureTable' # The name of the azure table
        StorageAccountSetting = 'AzureStorageAccountName'
        StorageKeySetting = 'AzureStorageAccountKey'
    }
    
    DomainSchematics = @{
        "my.blog.com | my.otherblogurl.com" = "Blog"
    } 
} 
    
} |
    Set-Content $home\Documents\WindowsPowerShell\Modules\MyBlog.pipeworks.psd1

}

)
        "3. Publish the Blog to Azure" = (ConvertFrom-Markdown @'
Once you've changed any settings you'd like run the script above, you'll have almost everything you'll need to publish the blog to Azure.  Make sure you install the Azure SDK and then go to the PowerShell prompt and run:
'@) + (Write-ScriptHTML -Text {
Import-Module Pipeworks, MyBlog
Add-MyBlogPost -Name "My First Blog Post" -DatePublished ( Get-Date) -ArticleBody @'
Memory is a selection  of images, some elusive, others printed indelibly upon the brain.
'@
Publish-AzureService -Name MyBlog 

}) + (ConvertFrom-Markdown @'
This will import your blog, create a first post, and create a deployment package to push the blog to azure.  
Simply upload the deployment package to the Azure management platform and you're all done.
'@)         
        "4. Start Writing" = "That's it.   If you need to add any new posts, user the Add-MyBlogPost command to do it." 
    }) 
    "A Gallery" = (ConvertFrom-Markdown @"
Galleries are ways to show sets of items and search them with simple RESTful URLs.  Galleries provide this experience around any type of content.  They allow the content for the Gallery to be either local or remote.
"@) + (New-Region -AsTab -ColumnCount 1 -LayerID GallerySteps -Style @{
            "font-size" = "small"
    } -Layer @{
        "1. Making your Module" = (ConvertFrom-Markdown @'
Just as with the blog, you need to make a small PowerShell module for your gallery:
'@) + (Write-ScriptHTML -Text {
# The module itself is very sparse:
{
@{
    ModuleVersion = '1.0'
    # Pipeworks is a useful module to require for most galleries, 
    # because contains the views for many common Microdata types
    RequiredModules = 'Pipeworks'
}
} | Set-Content $home\Documents\WindowsPowerShell\Modules\MyGallery\MyGallery.psd1
# The module requires a pipeworks manifest to hold the parameters to the gallery
{

@{
    UseJQueryUI = $true
    # To make your blog a beautiful and unique snowflake, go to 
    # http://jqueryui.com/themeroller, create a custom theme, 
    # download it, put it in the directory, and rename this to custom
    JQueryUITheme = 'Redmond' 
    AnalyticsId = '' # add one if you want to
    
    # These are parameters to the Gallery Schematic.  
    Gallery = @{
        # A Gallery is made of one or more collections
        Collection = @{
            # The name of the collection is a list of any short 
            Name = "Videos", "Video", "V"
            # The directory the items can be found in
            Directory = "Videos"
            # The display name of the collection
            DisplayName = "Videos"
            # The property that the friendly URL will contain
            By = "Name"
        }
        # A subtitle or description for the blog
        DefaultCollection = "Videos"
    }
    
    DomainSchematics = @{
        "my.gallery.com | my.othergalleryurl.com" = "Gallery"
    } 
} 
} |
    Set-Content $home\Documents\WindowsPowershell\MyGallery\MyGallery.Pipeworks.psd1
}) 
        "2. Getting Stuff For your Gallery" = (ConvertFrom-Markdown @'
An empty gallery would be bad, so let's learn how to fill them up.   A Gallery is made p of a series of colletions.  Each collection can take it's input from a directory or from a table in Azure.




The code below takes a YouTube user, grabs all of their videos, and puts them into a All.Videos.psd1 file:
'@) + (Write-ScriptHtml -text {
    Get-Web -Url "http://www.youtube.com/user/StartAutomating/videos" -Tag "a" |
    Where-Object { $_.Xml.Href -like "/watch*" } |
    ForEach-Object {
        "http://youtube.com" + $_.Xml.Href  
    } | 
    Select-Object -Unique |
    Get-Web -Url { $_ } -ItemType http://schema.org/VideoObject |
    Export-PSData $home\Documents\WindowsPowershell\MyGallery\Videos\All.Videos.psd1         
})
        
        "3. Publishing the Gallery" = (ConvertFrom-Markdown @'
Once you've changed any settings you'd like run the gallery's manifest, you'll have almost everything you'll need to publish it to Azure.  Make sure you install the Azure SDK and then go to the PowerShell prompt and run:
'@) + (Write-ScriptHTML -Text {
Import-Module Pipeworks, MyGallery
Publish-AzureService -Name MyGallery
}) + (ConvertFrom-Markdown @'
This will import your gallery moduel and create a deployment package to push the blog to Azure.  
Simply upload the deployment package to the Azure management dashboard and you're all done.
'@)         
    })      
} -Order "A Simple Page", "A Blog", "A Gallery" -asLeftSidebarmenu )
    
    }
}

if (-not $innerRegion) {
    $innerRegion = 
        New-Region -Style @{
            "font-size" = "medium"
        } -AsSlideShow -AutoSwitch "0:0:10" -LayerID CoreMessages -Layer @{
            "Write Sites in a Snap" = $writeSitesInSeconds 
            "Update Data not Designs" = $UpdateDataNotDesigns 
            "Join Windows And Web" = "$joinWindowsAndWeb"
            "Connect the Clouds" = "$ConnectTheClouds"
        } -Order "Write Sites in a Snap", "Update Data not Designs", "Join Windows and Web", "Connect the Clouds"
}


"
<p style='text-align:center'>
    <img src='Assets/Pipeworks_Logo.png' style='border:0' />
</p>
<p style='font-size:xx-small;text-align:right'>
$(Write-Link -Url "http://update-web.com/" -Caption "Read Blog" -Button)$(Write-Link -Url "Module.ashx?-DownloadNow" -Caption "Download Now" -Button)
</p>
<p style='text-indent:20px'>
PowerShell Pipeworks is a Framework for making Sites and Services with Windows PowerShell. 
</p>
<p style='text-indent:10px;font-size:medium'>
It is designed to do for web development what PowerShell has done for IT development --  make it easy to build complex solutions out of simple parts.
</p>
<p style='text-indent:10px;font-size:medium'>
PowerShell Pipeworks is developed by <a href='http://start-automating.com'>Start-Automating</a> and is released freely into the Public Domain, with no license or warranty of any kind.  
</p>

<p style='text-align:center;font-size:medium'>
Learn more about PowerShell Pipeworks by clicking on any of the four core goals of PowerShell Pipeworks:
</p>


$innerRegion


" |
    New-Region -Style @{
        "Line-Height" = "102%"
        "Letter-Spacing" = ".06px"
        "Font-Size" = "Medium"
        "Margin-Left" = "17%"
        "Margin-Right" = "17%"        
        "Width" = "66%"
        "height" = "33%"
        "align" = "center" 
    } |
    
    New-WebPage -Title "PowerShell Pipeworks | Update-Web -with PowerShell" 

# SIG # Begin signature block
# MIINGAYJKoZIhvcNAQcCoIINCTCCDQUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMlfD0fpSZ23jLd//tEILpLf4
# MrGgggpaMIIFIjCCBAqgAwIBAgIQAupQIxjzGlMFoE+9rHncOTANBgkqhkiG9w0B
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
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFC/mnpjuj0KH7pwX
# RF0GYn980xIoMA0GCSqGSIb3DQEBAQUABIIBAErAuYZE6MhBHPUCagrIbbs2sjIJ
# Nf3Bw6hPFm80q2pSi2fxi0GjUVTNufheBrj9GcsgWxxMVhYorS75c1mSF8kFUWlk
# bWSGqE0VcXQryf/CIhWyWA1LM0RjnCuJTpW6R2myeJpZ+wvmpxJFI7e4WXAxUWXb
# j0pDYT/tiSXOQkgoX2c65bU6Gyq0ylAeKfEuy6yyvE2qI4cOgPsyNfE7R55Dg3IF
# F5TBA4fjyqPI/3E9X9gs8Fzfuu8MVndW8Bdyg3mwRatzsqJvkYL1rk8vdQV0Kx60
# 4mL7eUpKrOLqRozJMS82JYCCQdN+psneBcBaCk01758ecuEW2iMVAo57DnQ=
# SIG # End signature block
