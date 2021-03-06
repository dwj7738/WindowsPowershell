@{
    # The Domain Schematics Describe How The Package Will be deployed to Azure.  
    DomainSchematics = @{
        # Each key in domain schematics is one or more domains, separated by an |
        "powershellise.com | www.powershellise.com" = "Default"        
    }


    # Always allows download, even if -AllowDownload is now specified.
    AllowDownload = $true


    # By specifying a FaceBook AppId, it becomes a Facebook Appilication
    Facebook = @{
        AppId = "119161064898429"
    }    
    
    # The WebCommand section describes how various commands in the module will convert into web services.
    WebCommand = @{
        "Get-PowerShellIcicle" = @{
            FriendlyName = "Find Cool Icicles"
            HideParameter = "All", "Select", "ExcludeTableInfo", "MyPowerShellIcicle", 'UserId'
        }
        "Get-PowerShellLink" = @{
            FriendlyName = "Read PowerShell Articles"
            HideParameter = "All", "Select", "ExcludeTableInfo", "MyPowerShellArticle", 'UserId'
        }

        "Get-PowerShellVideo" = @{
            FriendlyName = "Watch PowerShell Videos"
            HideParameter = "All", "Select", "ExcludeTableInfo", "MyPowerShellVideo", 'UserId'
        }
        "Get-PowerShellWalkthru" = @{
            FriendlyName = "Show Step-by-Step Walkthrus"
            HideParameter = "All", "Select", "ExcludeTableInfo", "MyPowerShellWalkthru", 'UserId'
        }
        "Add-PowerShellLink"  = @{
            
            FriendlyName = "Share an Article"
            IfLoggedInAs = '*'
        }
        "Add-PowerShellIcicle"  = @{
            
            FriendlyName = "Share an Icicle"
            IfLoggedInAs = '*'
        }
        "Add-PowerShellVideo"  = @{
            FriendlyName = "Share a Video"
            IfLoggedInAs = '*'
        }
        "Add-PowerShellWalkthru"  = @{            
            FriendlyName = "Share an Walkthru"
            IfLoggedInAs = '*'
        }        
    }

    # The command order indicates how each item will be displayed on the front page.
    CommandOrder = "Get-PowerShellLink", 
        "Get-PowerShellVideo", 
        "Get-PowerShellIcicle",
        "Get-PowerShellWalkthru",
        "Add-PowerShellLink",
        "Add-PowerShellVideo", 
        "Add-PowerShellWalkthru", 
        "Add-PowerShellIcicle"

    # These settings will be propagated into the site
    SecureSettings = "AzureStorageAccountName", "AzureStorageAccountKey"

    # The UserTable indicates how individuals' logon data will be stored
    UserTable = @{
        Name = "IsePackUsers"
        Partition = "Users"
        StorageAccountSetting = "AzureStorageAccountName"
        StorageKeySetting = "AzureStorageAccountKey"
    }

    # By providing an Analytics ID, Google Analytics trackers are added to each page
    AnalyticsID  = "UA-24591838-33"
    
    # By providing a Google Site Verification, Google Webmaster Tools Recognizes the Site
    GoogleSiteVerification = "mGN_qDeFWMscbG868RTnaxX_tc-fN3PQZy9zU-CSHTM"

    # By providing a Bing Validation Key, the site is verified with Bing Webmaster Tools
    BingValidationKey = "7B94933EC8C374B455E8263FCD4FE5EF"
    
    # Indicates that every page should use JQueryUI, and a custom theme
    UseJQueryUI = $true
    JQueryUITheme = 'Custom'

    Style = @{
        body = @{
            "font-family" = '"Lucida Grande" , "Lucida Sans Unicode" , Verdana, Tahoma, Arial, sans-serif'            
            'color' = '#012456'
            'background' = '#FFFFFF'
        }
        'a' = @{
            'color' = '#012456'            
            'letter-spacing' = 'normal'
        }
        'a:hover' = @{
            'text-decoration' ='none'
            'letter-spacing' = '1.2px'
        }
    }
} 
