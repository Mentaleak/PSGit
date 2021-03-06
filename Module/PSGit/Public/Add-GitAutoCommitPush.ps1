<# 
 .SYNOPSIS 
 Creates automated commits and pushes them 

.DESCRIPTION 
 Creates automated commits and pushes them, looks at the files and the differences and comments the commit for each file rather than entire repo with a brief overview of changes made 

.PARAMETER fixes 
 string Parameter_fixes=either one number or array of numbers that coincide with issue #'s in github. Will close issues marking them as being solved by this push 

.PARAMETER force 
 string Parameter_force=Will ignore git sync status and overwrite the remote repo 

.PARAMETER ProjectPath 
 string Parameter_ProjectPath=Path to the git project you would like to add commits and pushes to.
If Blank it will use the active powershell ISE File this was run from 

.EXAMPLE 
 Add-GitAutoCommitPush -ProjectPath Will commit changes to the project that the active file in ISE belongs to. 

.NOTES 
 Author: Mentaleak 

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
