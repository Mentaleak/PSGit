<# 
 .SYNOPSIS 
 Gets Contributor stats for a given Repo 

.DESCRIPTION 
 Gets Contributor stats for a given Repo
Likely a better choice than get-GitRepoContributorsData for everything 

.PARAMETER FullName 
 string Parameter_FullName=FullName is a string containing the full name of the repo EX: "Mentaleak\PSGit" 

.EXAMPLE 
 get-GitRepoContributorsStats "Mentaleak\PSGit" Gets Contributor stats for Repo Mentaleak\PSGit 

.NOTES 
 Author: Mentaleak 

#> 
function get-GitRepoContributorsStats () {
 
	param(
		#Example: Mentaleak\PSGit
		[string]$FullName
	)
	$RepoContributors = Invoke-RestMethod -Uri "https://api.github.com/repos/$($FullName)/stats/contributors" -Headers (Test-GitAuth)
	$contributors = @()
	foreach ($author in $RepoContributors)
	{
		$sum_a = 0
		$sum_d = 0
		$sum_c = 0
		$author.weeks.a | ForEach-Object { $sum_a += $_ }
		$author.weeks.d | ForEach-Object { $sum_d += $_ }
		$author.weeks.c | ForEach-Object { $sum_c += $_ }
		#$authors+="`nContributor: $($author.author.login)      Adds: $sum_a    Deletes: $sum_d    Commits: $sum_c"
		$contributor = [pscustomobject]@{
			AuthorType = if ($($Fullname.split("/")[0]) -eq "$($author.author.login)") { "Owner" } else { "Contributor" }
			Author = $author.Author.login
			Changes = [int]$sum_a + [int]$sum_d
			Adds = $sum_a
			Deletes = $sum_d
			Commits = $sum_c
		}
		$contributors += $contributor
	}
	return $contributors | Sort-Object -Property changes -Descending
}
