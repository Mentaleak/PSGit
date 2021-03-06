<# 
 .SYNOPSIS 
 gets repo data for a given repo 

.DESCRIPTION 
 gets repo data for a given repo 

.PARAMETER ProjectPath 
 string Parameter_ProjectPath=ProjectPath is a string containing the path to the local repo, else it will use current path 

.EXAMPLE 
 get-GitRepo Gets all repo data for the repo you are currently in 

.NOTES 
 Author: Mentaleak 

#> 
function Get-GitRepo () {
 
	param(
		[string]$ProjectPath = ((Get-Item -Path ".\").FullName)
	)
	$repos = get-GitRepos
	$config = (Get-Content "$($ProjectPath)\.git\config").split("`n")
	$urls = ($config | Where-Object { $_ -like "*url = *" })
	$giturl = ($urls | Where-Object { $_ -like "*github*" }).split("=").Trim()[1].Replace(".git","")

	if ($repos.html_url.Contains($giturl)) {
		$RepoData = ($repos | Where-Object { $_.html_url.Contains($giturl) })
		Add-Member -InputObject $RepoData -MemberType NoteProperty -Name collaborators_data -Value (get-GitRepoCollaboratorsData -FullName "$($RepoData.full_name)")
		Add-Member -InputObject $RepoData -MemberType NoteProperty -Name contributors_data -Value (get-GitRepoContributorsData -FullName "$($RepoData.full_name)")
		Add-Member -InputObject $RepoData -MemberType NoteProperty -Name contributors_stats -Value (get-GitRepoContributorsStats -FullName "$($RepoData.full_name)")
		Add-Member -InputObject $RepoData -MemberType NoteProperty -Name issues_data -Value (get-GitIssues -FullName "$($RepoData.full_name)")
		return $RepoData
	}
	throw [System.UriFormatException]"The repo $($giturl) Does not exsist"
	break all
}
