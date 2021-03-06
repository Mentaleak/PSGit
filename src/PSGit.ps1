<# 
 .SYNOPSIS 
 Creates New Git Repo

.DESCRIPTION 
Creates New Git Repo on Github

.PARAMETER ModuleName 
 string Parameter_Name=Name is a mandatory parameter of type String, The name of the new repo

.EXAMPLE 
  New-GitRepo PSGit
  Makes a new repo called PSGit

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

<# 
 .SYNOPSIS 
 Returns User Repos

.DESCRIPTION 
 Gets data for the users repos

.EXAMPLE 
  get-GitRepos
  Gets all repos of users

.NOTES 
 Author: Mentaleak 

#> 
function get-GitRepos () {
	return Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers (Test-GitAuth)
}

<# 
 .SYNOPSIS 
 gets repo data for a given repo

.DESCRIPTION 
 gets repo data for a given repo

.PARAMETER ProjectPath
 ProjectPath is a string containing the path to the local repo, else it will use current path

.EXAMPLE 
  get-GitRepo
  Gets all repo data for the repo you are currently in

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

<# 
 .SYNOPSIS 
Gets Collaborator data for a given Repo

.DESCRIPTION 
Gets Collaborator data for a given Repo

.PARAMETER FullName
FullName is a string containing the full name of the repo EX: "Mentaleak\PSGit"

.EXAMPLE 
  get-GitRepoCollaboratorsData "Mentaleak\PSGit"
  Gets Collaborator data for Repo Mentaleak\PSGit

.NOTES 
 Author: Mentaleak 

#> 
function get-GitRepoCollaboratorsData () {
	param(
		#Example: Mentaleak\PSGit
		[string]$FullName
	)
	return Invoke-RestMethod -Uri "https://api.github.com/repos/$($FullName)/collaborators" -Headers (Test-GitAuth)
}

<# 
 .SYNOPSIS 
Gets Contributor data for a given Repo

.DESCRIPTION 
Gets Contributor data for a given Repo

.PARAMETER FullName
FullName is a string containing the full name of the repo EX: "Mentaleak\PSGit"

.EXAMPLE 
  get-GitRepoContributorsData "Mentaleak\PSGit"
  Gets Contributor data for Repo Mentaleak\PSGit

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

<# 
 .SYNOPSIS 
Gets Contributor stats for a given Repo

.DESCRIPTION 
Gets Contributor stats for a given Repo
Likely a better choice than get-GitRepoContributorsData for everything

.PARAMETER FullName
FullName is a string containing the full name of the repo EX: "Mentaleak\PSGit"

.EXAMPLE 
  get-GitRepoContributorsStats "Mentaleak\PSGit"
  Gets Contributor stats for Repo Mentaleak\PSGit

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

<# 
 .SYNOPSIS 
Checks to see if the user is authenticated

.DESCRIPTION 
Checks to see if the user is authenticated

.PARAMETER nobreak
 If nobreak the script won't break all when failing to connect

.EXAMPLE 
Test-GitAuth
returns true if user is authenticated

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

<# 
 .SYNOPSIS 
Creates a Basic auth value and returns it as a header 

.DESCRIPTION 
Creates a Basic auth value using base64string and returns it as a header 

.PARAMETER user
The username

.PARAMETER upass
The password

.PARAMETER cred
A credential object containing username and password (More secure, in local memory)

.NOTES 
 Author: Mentaleak 
 Private

#> 
function Get-GitAuthHeader () {
	param(
		[string]$user,
		[string]$pass,
		[pscredential]$cred
	)
	if ($cred)
	{
		$user = $cred.UserName
		$basicAuthValue = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($user):$([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($($cred.Password))))")))"
	}
	elseif ($user -and $pass)
	{
		$pair = "${user}:${pass}"
		$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
		$base64 = [System.Convert]::ToBase64String($bytes)
		$basicAuthValue = "Basic $base64"
	}
	else {
		throw [System.InvalidOperationException]"Please Provide either (-cred) or (-user and -pass)"
	}
	$headers = @{ Authorization = $basicAuthValue }
	return $headers
}

<# 

.SYNOPSIS 
Creates a connection to github

.DESCRIPTION 
Creates a connection to github, sets web security to handle api calls, sets global headers for use elsewhere
Will use better credentials stored github Credentials "GithubBasicAuth" if they exist in local keystore

.PARAMETER ManualCred
switch, Will prompt user for credentials

.Example
Connect-github
Connects to github

.NOTES 
 Author: Mentaleak 

#> 
function Connect-github () {
	param(
		[switch]$ManualCred = $false
	)
	set-WebSecurity_PSTool
	if ($ManualCred) {
		$bcred = (Get-Credential -Title "Github" -Description "Enter GitHub Credentials")
		if ($bcred) { Set-Credential -Credential $bcred -Target "GithubBasicAuth" -Description "GitHub Credentials" }
		$cred = ((Find-Credential | Where-Object Target -Match "GithubBasicAuth")[0])
	} else {
		$cred = ((Find-Credential | Where-Object Target -Match "GithubBasicAuth")[0])
		if (!($cred)) {
			$bcred = (Get-Credential -Title "Github" -Description "Enter GitHub Credentials")
			if ($bcred) { Set-Credential -Credential $bcred -Target "GithubBasicAuth" -Description "GitHub Credentials" }
			$cred = ((Find-Credential | Where-Object Target -Match "GithubBasicAuth")[0])
		}
	}

	$tmpheader = Get-GitAuthHeader -cred ($cred)
	try { $userdata = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $tmpheader }
	catch {
		throw [System.UnauthorizedAccessException]"$((($_.ErrorDetails.Message) | ConvertFrom-Json).message)"
		break all
	}
	Write-Host "Connection Successful"
	Write-Host "Login: $($userdata.Login)"
	Write-Host "URL: $($userdata.html_url)"
	$global:GitAuth = $tmpheader
}

<# 

.SYNOPSIS 
Copies a remote repo to a local one 

.DESCRIPTION 
Copies a remote repo to a local one, makes new directory with name in remote repo
uses git clone to local path

.PARAMETER LocalPath
Folder to make a new local repo with same name as remote repo in C:\Scripts\

.PARAMETER RemoteRepo
Url of repo https://github.com/{USERNAME}/{REPO}

.Example
Copy-GitRepo -RemoteRepo "https://github.com/Mentaleak/PSGit" -localPath C:\Scripts\
clones repo to C:\Scripts\PSGit

.NOTES 
 Author: Mentaleak 

#> 
function Copy-GitRepo () {
	param(
		#Example: C:\Scripts\
		[Parameter(mandatory = $true)] [string]$LocalPath,
		#Example: https://github.com/{USERNAME}/{REPO}
		[Parameter(mandatory = $true)] [string]$RemoteRepo
	)
	if (!(Test-Path $LocalPath))
	{
		New-Item -ItemType Directory -Force -Path $LocalPath
	}
	Set-Location $LocalPath
	git clone $RemoteRepo
}

<# 
 .SYNOPSIS 
 Creates automated commits and pushes them

.DESCRIPTION 
 Creates automated commits and pushes them, looks at the files and the differences and comments the commit for each file rather than entire repo with a brief overview of changes made

.PARAMETER ProjectPath
Path to the git project you would like to add commits and pushes to.
If Blank it will use the active powershell ISE File this was run from

.PARAMETER fixes
either one number or array of numbers that coincide with issue #'s in github. Will close issues marking them as being solved by this push

.PARAMETER force 
Will ignore git sync status and overwrite the remote repo

.EXAMPLE 
 Add-GitAutoCommitPush -ProjectPath
 Will commit changes to the project that the active file in ISE belongs to.

.NOTES 
 Author: Mentaleak 

.LINK
 https://i.imgur.com/XFQLB.jpg

#> 
function Add-GitAutoCommitPush () {
	param(
		#Example: C:\Scripts\
		[string]$ProjectPath = ((Get-ChildItem ($psISE.CurrentFile.FullPath)).Directory.FullName),
		$fixes = $null,
		[switch]$force
	)

	#Write-Host "Test Local"
	if (test-GitLocal -ProjectPath $ProjectPath) {
		#Write-Host "Test remote"
		if (test-GitRemote -ProjectPath $ProjectPath) {
			#check branch divergence
			if ((test-GitSyncStatus -ProjectPath $ProjectPath) -or $force) {

				Set-Location $ProjectPath
				#get diff list, including new files

				#set config user
				#Write-Host "getuserdata"
				$gituser = get-gituserdata
				git config --global user.name "$($gituser.UserData.login)"
				if ($gituser.UserEmail) {
					git config --global user.email "$($gituser.UserEmail.email)"
				}
				#Write-Host "Get Diff"
				$gitStatus = (git status).split("`n")
				git add -N *
				$difflist = (git diff 2>$null)
				#Write-Host "Compare Diff $difflist"
				if ($difflist) {
					$difflist = (git diff 2>$null).split("`n")
					Write-Host "$($difflist.Count) Differences Found"

					#look at each file add and commit file with changes
					foreach ($diff in $difflist.where{ ($_.Contains("diff --git")) -and !($_.Contains("(`"diff --git`")")) })
					{
						$fileName = $diff.Substring($diff.IndexOf("b/") + 2,($diff.Length - $diff.IndexOf("b/") - 2))
						$diffdata = (git diff $fileName 2>$null).split("`n")
						$functionlist = Get-functions_PSTool $fileName

						$mods = $diffdata | Where-Object { ($_[0] -eq "+" -or $_[0] -eq "-") -and ($_ -match "[a-zA-Z0-9]") }
						$ChangedFunctions = @()
						foreach ($mod in $mods) {
							foreach ($fn in $functionlist) {
								if ($fn.Definition.Contains($mod.Substring(1,$mod.Length - 1))) {
									$ChangedFunctions += "$($fn.name)"
								}
							}
						}
						$ChangedFunctions = $ChangedFunctions | sort | Get-Unique

						if ($difflist[$difflist.IndexOf($diff) + 1].Contains("new file")) {
							$Message = " Added " + $fileName

						} else {
							$Message = " Modified " + $fileName

						}
						if ($ChangedFunctions -ne $null)
						{
							$FunctionString = $ChangedFunctions -join "`n"
							$Description = "Changed functions: `n$($FunctionString)"
						}
						else
						{
							$description = "Content Modified"
						}
						if ($fixes -ne $null)
						{
							$fixes = $fixes | sort | Get-Unique
							$fixed = $fixes -join " and resolves #"
							$description += "`n This Commit Resolves #$($fixed)"
						}
						Write-Host "$fileName" -ForegroundColor Yellow
						Write-Host "$Message"
						Write-Host "$Description" -ForegroundColor Gray
						git add $fileName
						git commit -m "$Message" -m "$Description"
					}
					$DeletedFiles = ($gitStatus.where{ ($_.Contains("deleted:")) })
					if ($deletedFiles)
					{
						$DeletedFiles = $DeletedFiles.split(":")[1].Trim()
					}
					foreach ($deletedfile in $deletedfiles) {
						Write-Host "$deletedfile" -ForegroundColor red
						Write-Host "DELETED"
					}

					git push --force 2>$null

				}

			}
			else {
				Set-Location $ProjectPath
				git status
			}
		}
	}else{throw [System.IO.FileNotFoundException]"NO .git Folder present"}
}

<# 
 .SYNOPSIS 
Checks to see if the current project is sync'd with remote repo

.DESCRIPTION 
checks to see if the current project is sync'd with remote repo
returns bool

.PARAMETER ProjectPath
Path to the git project you would like to add commits and pushes to.
If Blank it will use the current directory

.NOTES 
 Author: Mentaleak 
 Private

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

<# 
 .SYNOPSIS 
Checks to see if the project path has a .git folder

.DESCRIPTION 
Checks to see if the project path has a .git folder

.PARAMETER ProjectPath
Path to the git project you would like to add commits and pushes to.
If Blank it will use the current directory

.NOTES 
 Author: Mentaleak 

#> 
function test-GitLocal () {
	param(
		#Example: C:\Scripts\
		[string]$ProjectPath = ((Get-Item -Path ".\").FullName)
	)
	if ((Test-Path "$($ProjectPath)\.git"))
	{
		return $true
	}
	else
	{
		return $false
		#throw [System.IO.FileNotFoundException]"NO .git Folder present"

	}
}

<# 
 .SYNOPSIS 
Checks to see if the remote project exists

.DESCRIPTION 
Checks to see if the remote project exists by using data found in the local .git folder
returns bool

.PARAMETER ProjectPath
Path to the git project you would like to add commits and pushes to.
If Blank it will use the current directory

.NOTES 
 Author: Mentaleak 

#> 
function test-GitRemote () {
	param(
		#Example: C:\Scripts\
		[string]$ProjectPath = ((Get-Item -Path ".\").FullName)
	)
	$repos = get-GitRepos
	$config = (Get-Content "$($ProjectPath)\.git\config").split("`n")
	$urls = ($config | Where-Object { $_ -like "*url = *" })
	$giturl = ($urls | Where-Object { $_ -like "*github*" }).split("=").Trim()[1].Replace(".git","")

	if ($repos.html_url.Contains($giturl)) {
		return $true

	}
	throw [System.UriFormatException]"The repo $($giturl) Does not exsist"
	break all
}

<# 
 .SYNOPSIS 
Don't programatically do this

.DESCRIPTION 
Do it manually

.PARAMETER Name 
We aren't going to do anything with this. Deal with it

.Example
STOP!

.NOTES 
 Author: Mentaleak 

#>
function remove-gitRepo () {
	param(
		[Parameter(mandatory = $true)] [string]$name
	)
	throw [System.NotSupportedException]"Somethings are just too powerful, Make your own mistakes, I'm not helping"
}

<# 
 .SYNOPSIS 
Gets the current users data

.DESCRIPTION 
Gets the current users data from github

.NOTES 
 Author: Mentaleak 

#> 
function get-gituserdata () {
	$userdata = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers (Test-GitAuth)
	$emailheader = @{ Scope = 'user:email' }
	$emailheader += (Test-GitAuth)
	try { $useremail = Invoke-RestMethod -Uri "https://api.github.com/user/emails" -Headers $emailheader }
	catch { $useremail = $null }
	$user = New-Object PSObject -Property @{
		UserData = $userdata
		UserEmail = $useremail
	}

	return $user
}

<# 
 .SYNOPSIS 
Git Pull but longer

.DESCRIPTION 
I dont know why this was made

.PARAMETER ProjectPath 
Path to the git project you would like to add commits and pushes to.
If Blank it will use the active powershell ISE File this was run from

.PARAMETER force 
Will ignore git sync status and overwrite the local repo

.Example
STOP!

.NOTES 
 Author: Mentaleak 

#>
function initialize-GitPull () {
	param(
		#Example: C:\Scripts\
		[string]$ProjectPath = ((Get-ChildItem ($psISE.CurrentFile.FullPath)).Directory.FullName),
		[switch]$force
	)


	#Write-Host "Test Local"
	if (test-GitLocal -ProjectPath $ProjectPath) {
		#Write-Host "Test remote"
		if (test-GitRemote -ProjectPath $ProjectPath) {
			#check branch divergence
			if ((test-GitSyncStatus -ProjectPath $ProjectPath) -or $force) {

				Set-Location $ProjectPath
				git pull

			}
		}
	}else{throw [System.IO.FileNotFoundException]"NO .git Folder present"}

}

<# 
 .SYNOPSIS 
Git issues for the given project

.DESCRIPTION 
Provides all issues for the repo

.PARAMETER FullName
FullName is a string containing the full name of the repo EX: "Mentaleak\PSGit"

.NOTES 
 Author: Mentaleak 

#>
function get-GitIssues () {
	param(
		#Example: Mentaleak\PSGit
		[Parameter(mandatory = $true)] [string]$FullName
	)
	$RepoIssues = Invoke-RestMethod -Uri "https://api.github.com/repos/$($FullName)/issues" -Headers (Test-GitAuth)
	return $RepoIssues
}

<# 
 .SYNOPSIS 
Add issues for the given project

.DESCRIPTION 
add issues for the repo

.PARAMETER RepoFullName
REQUIRED
RepoFullName is a string containing the full name of the repo EX: "Mentaleak\PSGit"

.PARAMETER title
REQUIRED
title is a string: title of the issue 

.PARAMETER body
REQUIRED
Body is a string: Body of the issue 

.PARAMETER Assignees
Assignees is an array: users to asign the issue to

.PARAMETER Labels
Labels is an array: Labels to asign the issue to

.PARAMETER Milestone
Milestone is a string: Milestone of the issue 

.NOTES 
 Author: Mentaleak 


.Example
 TODO Up for grabs: submit a pull request

#>
function add-GitIssue () {
	param(
		#Example: Mentaleak\PSGit
		[Parameter(mandatory = $true)] [string]$RepoFullName,
		[Parameter(mandatory = $true)] [string]$title,
		[Parameter(mandatory = $true)] [string]$body,
		[array]$Assignees,
		[array]$Labels,
		[string]$Milestone

	)
	#$postparams = "{`"title`":`"$($title)`",`"body`":`"$($body)`" }"
	$assigneesJSON = "[`"$($assignees -join "``", ``"")`"]"
	$labelsJSON = "[`"$($Labels -join "``", ``"")`"]"
	$postparams = "{`"title`":`"$($title)`", `
    `"body`":`"$($body)`""
	if ($Assignees) { $postparams += ",`"assignees`":$($assigneesJSON)" }
	if ($Labels) { $postparams += ",`"labels`":$($labelsJSON)" }
	if ($Milestone) { $postparams += ",`"milestone`":`"$($Milestone)`"" }
	$postparams += " }"
	$NewIssue = Invoke-RestMethod -Uri "https://api.github.com/repos/$($FullName)/issues" -Headers (Test-GitAuth) -Method Post -Body $postparams
	#write-host $postparams

}

<# 
 .SYNOPSIS 
Displays a list of issues via Show-PsGUI A great module....

.DESCRIPTION 
Mainly used for returning an array of solved issues when using add-GitAutoCommitPush -fixes
But feel free to use it how you like, its public do as you do.

.PARAMETER FullName
REQUIRED
FullName is a string containing the full name of the repo EX: "Mentaleak\PSGit"

.NOTES 
 Author: Mentaleak 

.Example
 add-GitAutoCommitPush -fixes (get-gitfixesUI "Mentaleak\PSGit")

#>
function get-gitfixesUI () {
	param(
		#Example: Mentaleak\PSGit
		[Parameter(mandatory = $true)] [string]$FullName
	)
	$gitissues = get-GitIssues $FullName | Sort-Object { [int]$_.number }
	$getfixobj = [pscustomobject]@{}
	foreach ($issue in $gitissues)
	{
		Add-Member -InputObject $getfixobj -MemberType NoteProperty -Name "$($issue.title) `#$($issue.number)" -Value $false
	}
	$fixedList = Show-Psgui $getfixobj
	if ($fixedList) {
		$fixes = ((Get-PSObjectParamTypes $fixedlist) | Where-Object { $_.Definition -match "TRUE" }).Name | ForEach-Object { $_.split("`#")[1] }
	}
	return $fixes
}

<# 
 .SYNOPSIS 
Gets all releases

.DESCRIPTION 
Gets releases on a given repo

.PARAMETER FullName
REQUIRED
FullName is a string containing the full name of the repo EX: "Mentaleak\PSGit"

.NOTES 
 Author: Mentaleak 

.Example
 get-GitReleases "Mentaleak\PSGit"

#>
function get-GitReleases () {
	param(
		[Parameter(mandatory = $true)] [string]$FullName
	)
	return Invoke-RestMethod -Uri "https://api.github.com/repos/$($fullname)/releases" -Headers (Test-GitAuth)
}

<# 
 .SYNOPSIS 
adds releases

.DESCRIPTION 
adds releases to a given repo

.PARAMETER RepoFullName
REQUIRED
RepoFullName is a string containing the full name of the repo EX: "Mentaleak\PSGit"

.PARAMETER TagName
REQUIRED
TagName is a string containing the Tagname for the release

.PARAMETER Name
Name is a string containing the name of the release

.PARAMETER body
body is a string containing the details of the release

.PARAMETER preRelease
preRelease is a switch if you want to say WERE IN BETA!

.NOTES 
 Author: Mentaleak 

.Example
 TODO Up for grabs: Submit a pull request!

#>
function add-GitRelease {
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

<#
function get-GitTeams () {}

function get-GitForks () {}

function get-GitHooks () {}

function get-GitEvents () {}

function get-GitSubscribers () {}

function get-GitLanguages () {}

function get-GitSubscription () {}

function get-GitAsignees () {}

function get-GitBranches () {}

function get-GitCommits () {}

function get-GitContent () {}

function get-GitMerges () {}

function get-GitPulls () {}

function get-GitDownloads () {}

function get-GitMilestones () {}

function get-GitNotifications () {}

function get-GitDeployments () {}
#>