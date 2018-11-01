function New-GitRepo(){
    param(
        [Parameter(mandatory=$true)][string]$token,
        [Parameter(mandatory=$true)][string]$name
    )
    # https://github.com/settings/tokens/new
# curl https://api.github.com/user/repos?access_token=$token -d '{"name":"$name"}'

}

$crd
function New-GitToken() {
     param(
     [string]$user,
     [string]$pass,
     [PSCredential]$cred
     )
     if($cred)
     {

     }
     elseif($user -and $pass)
     {


     }
     else{
     throw [System.IO.FileNotFoundException] "Please Provide either (-cred) or (-user and -pass)"
     }


$pair = "${user}:${pass}"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
#$headers = @{ Authorization = $basicAuthValue}
$postparams = @{scopes = "repo";note = "ZPSMODULE" }
#Invoke-WebRequest -uri "https://api.github.com/authorizations" -Headers $headers -Method POST -body $postparams
return $basicAuthValue
#curl -u '$username'  -d '{"scopes":["repo"],"note":"ZPSMODULE"}' https://api.github.com/authorizations
#Curl -u does not exsist in powershell we will have to find a way to do this with invoke-webrequest
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$gitToken=New-GitToken
$headers = @{ Authorization = $gitToken}
$postparams = @{scopes = "repo";note = "ZPSMODULE" }
$connection = Invoke-WebRequest -Uri https://api.github.com -Headers $headers





# Binds folder to github
# requires git
function New-RepoConnection()
{
     param(
     #Example: C:\Scripts\project1
     [Parameter(mandatory=$true)][string]$LocalPath,
     #Example: https://github.com/{USERNAME}/{REPO}
     [Parameter(mandatory=$true)][string]$RemoteRepo
     )
    if(!(Test-Path $LocalPath))
    {
    New-Item -ItemType Directory -Force -Path $LocalPath
    }
    cd $LocalPath
    git clone $RemoteRepo
}

New-RepoConnection -LocalPath "\\dutchess\support\Power Shell Scripts\Other" -RemoteRepo "https://github.com/Mentaleak/PSGit"

