<# 
 .SYNOPSIS 
 Creates New Git Repo 

.DESCRIPTION 
 Creates New Git Repo on Github 

.PARAMETER name 
 string Parameter_name=name is a mandatory parameter of type string 

.EXAMPLE 
 New-GitRepo PSGit Makes a new repo called PSGit 

.NOTES 
 Author: Mentaleak 

#> 
function New-GitRepo () {
 
	param(
		[Parameter(mandatory = $true)] [string]$name
	)

	$postparams = "{`"name`":`"$($name)`"}"

	return Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers (Test-GitAuth) -Method POST -Body $postparams
}
