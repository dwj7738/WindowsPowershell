###########################################################################
#
# NAME: 
#
# AUTHOR:  David Johnson
#
# COMMENT: 
#
# VERSION HISTORY:
# 1.0 27-Sep-2012 - Initial release
#
###########################################################################
$os = Get-WmiObject –class win32_operatingsystem
$os.Description
$os.Description = "David Johnson's Windows 8 Computer"
$os.put()