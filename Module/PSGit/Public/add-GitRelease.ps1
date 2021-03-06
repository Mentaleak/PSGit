<# 
 .SYNOPSIS 
 adds releases 

.DESCRIPTION 
 adds releases to a given repo 

.PARAMETER body 
 string Parameter_body=body is a string containing the details of the release 

.PARAMETER Name 
 string Parameter_Name=Name is a string containing the name of the release 

.PARAMETER preRelease 
 string Parameter_preRelease=preRelease is a switch if you want to say WERE IN BETA! 

.PARAMETER RepoFullName 
 string Parameter_RepoFullName=REQUIRED
RepoFullName is a string containing the full name of the repo EX: "Mentaleak\PSGit" 

.PARAMETER TagName 
 string Parameter_TagName=REQUIRED
TagName is a string containing the Tagname for the release 

.EXAMPLE 
 TODO Up for grabs: Submit a pull request! 

.NOTES 
 Author: Mentaleak 

#> 
function add-GitRelease () {
 
	param(
		#Example: Mentaleak\PSGit
		[Parameter(mandatory = $true)] [string]$RepoFullName,
		[Parameter(mandatory = $true)] [string]$TagName,
		[string]$Name = $TagName,
		[string]$body = $TagName,
		[switch]$preRelease
	)

	if ($preRelease) {
		$preRe = "true"
	} else { $preRe = "false" }

	$postparams = "{`"tag_name`":`"$($TagName)`", 
                    `"name`":`"$($Name)`", `
                    `"body`":`"$($body)`", `
                    `"prerelease`":$($preRe)}"

	$postparams = convertto-json (ConvertFrom-Json $postparams)

	return Invoke-RestMethod -Uri "https://api.github.com/repos/$($RepoFullName)/releases" -Headers (Test-GitAuth) -Method POST -Body $postparams
}
