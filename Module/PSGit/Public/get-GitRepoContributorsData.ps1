<# 
 .SYNOPSIS 
 Gets Contributor data for a given Repo 

.DESCRIPTION 
 Gets Contributor data for a given Repo 

.PARAMETER FullName 
 string Parameter_FullName=FullName is a string containing the full name of the repo EX: "Mentaleak\PSGit" 

.EXAMPLE 
 get-GitRepoContributorsData "Mentaleak\PSGit" Gets Contributor data for Repo Mentaleak\PSGit 

.NOTES 
 Author: Mentaleak 

#> 
function get-GitRepoContributorsData () {
 
	param(
		#Example: Mentaleak\PSGit
		[string]$FullName
	)
	return Invoke-RestMethod -Uri "https://api.github.com/repos/$($FullName)/stats/contributors" -Headers (Test-GitAuth)
}
