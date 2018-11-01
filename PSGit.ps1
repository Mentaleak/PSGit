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
function Get-GitRepo()
{
     param(
     #Example: C:\Scripts\
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

#Example:
#Get-GitRepo -LocalPath "C:\Scripts\" -RemoteRepo "https://github.com/Mentaleak/PSGit"

function Push-GitCommit()
{
     param(
     #Example: C:\Scripts\
     [string]$ProjectPath=((Get-Item -Path ".\").FullName),
     [string]$message=""
     )

    if(!(Test-Path $ProjectPath))
    {
    New-Item -ItemType Directory -Force -Path $ProjectPath
    }
    if($message -eq ""){
        $message=get-gitComment
    }
    git add *
    git commit -m $comment
    git push
}

#private-
function get-gitMessage(){
 param(
     #Example: C:\Scripts\
     [Parameter(mandatory=$true)][string]$ProjectPath
     )

    if(!(Test-Path $ProjectPath))
    {
    New-Item -ItemType Directory -Force -Path $ProjectPath
    }

git add -N *
git diff
}


$ta=$test.split("`n")

$message=""
$lastindex = 0
foreach($diff in $ta.where{$_.Contains("diff --git")})
{
  if( $ta[$ta.IndexOf($diff) + 1].contains("new file")){
    $comment+=" Added "+ $diff.Substring($diff.IndexOf("b/")+2,($diff.Length - $diff.IndexOf("b/")-2))

  }else {
  
   $comment+=" Modified "+ $diff.Substring($diff.IndexOf("b/")+2,($diff.Length - $diff.IndexOf("b/")-2))
  
  }


}
$comment












{
    $diffs=@()
    $indexlist+= $ta.IndexOf($diff)
    $diffs = @($ta[$lastindex..$($ta.IndexOf($diff))])
    if($ta.IndexOf($diff) -ne 0)
    {

    $mod=New-Object -TypeName psobject -Property @{
        
    }
        $diffs = @($ta[$lastindex..$($ta.IndexOf($diff))])
    }
    $lastindex = $ta.IndexOf($diff)
}
