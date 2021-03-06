<# 
 .SYNOPSIS 
 Checks to see if the user is authenticated 

.DESCRIPTION 
 Checks to see if the user is authenticated 

.PARAMETER nobreak 
 string Parameter_nobreak=If nobreak the script won't break all when failing to connect 

.EXAMPLE 
 Test-GitAuth returns true if user is authenticated 

.NOTES 
 Author: Mentaleak 

#> 
function Test-GitAuth () {
 
	param(
		[switch]$nobreak
	)
	if ($Global:GitAuth) {
		return $Global:GitAuth

	}
	Write-Host "Please run Connect-Github first"
	Connect-github
	if ($Global:GitAuth) {
		return $Global:GitAuth

	}
	if (!$nobreak) {
		break all
	}
	else
	{
		return $false
	}
}
