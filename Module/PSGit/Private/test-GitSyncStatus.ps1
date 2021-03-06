<# 
 .SYNOPSIS 
 Checks to see if the current project is sync'd with remote repo 

.DESCRIPTION 
 checks to see if the current project is sync'd with remote repo
returns bool 

.PARAMETER ProjectPath 
 string Parameter_ProjectPath=ProjectPath is a parameter of type string. Path to the git project you would like to add commits and pushes to.
If Blank it will use the current directory 

.NOTES 
 Author: Mentaleak 

#> 
function test-GitSyncStatus () {
 
	param(
		#Example: C:\Scripts\
		[string]$ProjectPath = ((Get-Item -Path ".\").FullName)
	)
	Set-Location $ProjectPath
	$gitStatus = (git status).split("`n").where{ ($_.Contains("diverged")) }
	if ($gitStatus) {
		return $false
	}
	return $true
}
