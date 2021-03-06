param([switch]$NoVersionCheck)

#Is module loaded; if not load
if ((Get-Module PSGit)){return}
    $psv = $PSVersionTable.PSVersion

    #verify PS Version
    if ($psv.Major -lt 5 -and !$NoVersionWarn) {
        Write-Warning ("PSGit is listed as requiring 5; you have version $($psv).`n" +
        "Visit Microsoft to download the latest Windows Management Framework `n" +
        "To suppress this warning, change your include to 'Import-Module PSGit -NoVersionCheck `$true'.")
        return
    }
. $PSScriptRoot\public\Add-GitAutoCommitPush.ps1
. $PSScriptRoot\public\add-GitIssue.ps1
. $PSScriptRoot\public\add-GitRelease.ps1
. $PSScriptRoot\public\Connect-github.ps1
. $PSScriptRoot\public\Copy-GitRepo.ps1
. $PSScriptRoot\public\get-gitfixesUI.ps1
. $PSScriptRoot\public\get-GitIssues.ps1
. $PSScriptRoot\public\get-GitReleases.ps1
. $PSScriptRoot\public\Get-GitRepo.ps1
. $PSScriptRoot\public\get-GitRepoCollaboratorsData.ps1
. $PSScriptRoot\public\get-GitRepoContributorsData.ps1
. $PSScriptRoot\public\get-GitRepoContributorsStats.ps1
. $PSScriptRoot\public\get-GitRepos.ps1
. $PSScriptRoot\public\get-gituserdata.ps1
. $PSScriptRoot\public\initialize-GitPull.ps1
. $PSScriptRoot\public\New-GitRepo.ps1
. $PSScriptRoot\public\remove-gitRepo.ps1
. $PSScriptRoot\public\Test-GitAuth.ps1
. $PSScriptRoot\public\test-GitLocal.ps1
. $PSScriptRoot\public\test-GitRemote.ps1
. $PSScriptRoot\private\Get-GitAuthHeader.ps1
. $PSScriptRoot\private\test-GitSyncStatus.ps1
Export-ModuleMember Add-GitAutoCommitPush
Export-ModuleMember add-GitIssue
Export-ModuleMember add-GitRelease
Export-ModuleMember Connect-github
Export-ModuleMember Copy-GitRepo
Export-ModuleMember Get-GitAuthHeader
Export-ModuleMember get-gitfixesUI
Export-ModuleMember get-GitIssues
Export-ModuleMember get-GitReleases
Export-ModuleMember Get-GitRepo
Export-ModuleMember get-GitRepoCollaboratorsData
Export-ModuleMember get-GitRepoContributorsData
Export-ModuleMember get-GitRepoContributorsStats
Export-ModuleMember get-GitRepos
Export-ModuleMember get-gituserdata
Export-ModuleMember initialize-GitPull
Export-ModuleMember New-GitRepo
Export-ModuleMember remove-gitRepo
Export-ModuleMember Test-GitAuth
Export-ModuleMember test-GitLocal
Export-ModuleMember test-GitRemote
Export-ModuleMember test-GitSyncStatus
