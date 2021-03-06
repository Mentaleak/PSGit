<# 
 .SYNOPSIS 
 Add issues for the given project 

.DESCRIPTION 
 add issues for the repo 

.PARAMETER Assignees 
 string Parameter_Assignees=Assignees is an array: users to asign the issue to 

.PARAMETER body 
 string Parameter_body=REQUIRED
Body is a string: Body of the issue 

.PARAMETER Labels 
 string Parameter_Labels=Labels is an array: Labels to asign the issue to 

.PARAMETER Milestone 
 string Parameter_Milestone=Milestone is a string: Milestone of the issue 

.PARAMETER RepoFullName 
 string Parameter_RepoFullName=REQUIRED
RepoFullName is a string containing the full name of the repo EX: "Mentaleak\PSGit" 

.PARAMETER title 
 string Parameter_title=REQUIRED
title is a string: title of the issue 

.EXAMPLE 
 TODO Up for grabs: submit a pull request 

.NOTES 
 Author: Mentaleak 

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
