[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#public
function New-GitRepo(){
   param(
     #Example: C:\Scripts\
     [Parameter(mandatory=$true)][string]$name
    )

$postparams= "{`"name`":`"$($name)`"}"

return Invoke-RestMethod -uri "https://api.github.com/user/repos" -Headers (Test-GitAuth) -Method POST -Body $postparams
}

#public
function get-GitRepos(){
    return Invoke-RestMethod -uri "https://api.github.com/user/repos" -Headers (Test-GitAuth)
}

#private 
function Test-GitAuth(){

if($Global:GitAuth){
return $Global:GitAuth

}
Write-Host "Please run Connect-Github first"
break all

}


#private
function Get-GitAuthHeader(){
     param(
     [string]$user,
     [string]$pass,
     [PSCredential]$cred
     )
     if($cred)
     {
        $user=$cred.UserName
        $basicAuthValue = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($user):$([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($($cred.Password))))")))"
     }
     elseif($user -and $pass)
     {
     $pair = "${user}:${pass}"
     $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
     $base64 = [System.Convert]::ToBase64String($bytes)
     $basicAuthValue = "Basic $base64"
     }
     else{
     throw [System.InvalidOperationException] "Please Provide either (-cred) or (-user and -pass)"
     }
     $headers = @{ Authorization = $basicAuthValue}
     return $headers
}


function Connect-github(){
    $tmpheader = Get-GitAuthHeader -cred (get-credential)
     try{$userdata=Invoke-RestMethod -uri "https://api.github.com/user" -Headers $tmpheader}
     Catch{
     throw [System.UnauthorizedAccessException] "$((($_.ErrorDetails.Message) | ConvertFrom-Json).message)"
     break all
     }
     Write-Host "Connection Successful"
     Write-Host "Login: $($userdata.Login)"
     Write-Host "URL: $($userdata.html_url)"
     $global:GitAuth = $tmpheader
}

# Binds folder to github
# requires git
function Get-GitRepo(){
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

function Add-GitAutoCommitPush(){
     param(
     #Example: C:\Scripts\
     [string]$ProjectPath=((Get-Item -Path ".\").FullName)
     )


      #  if(!(Test-Path $ProjectPath))
       # {
       #  New-Item -ItemType Directory -Force -Path $ProjectPath
       # }
        

     if(test-GitLocal -ProjectPath $ProjectPath){

      if(test-GitRemote -ProjectPath $ProjectPath){

            #get diff list, including new files
            git add -N *
            $difflist = (git diff).split("`n")


            #look at each file add and commit file with changes
                foreach($diff in $difflist.where{$_.Contains("diff --git")})
                {
                    $fileName=$diff.Substring($diff.IndexOf("b/")+2,($diff.Length - $diff.IndexOf("b/")-2))
                    $diffdata = (git diff $fileName).split("`n")
                    $functionlist = get-functions $fileName
    
                    $mods = $diffdata | where {($_[0] -eq "+" -or $_[0] -eq "-") -and ($_ -match "[a-zA-Z0-9]") }
                    $ChangedFunctions=[string]@()
                    foreach($mod in $mods){ 
                        foreach($fn in $functionlist){
                            if($fn.definition.contains($mod.Substring(1,$mod.length -1 ))){
                                $ChangedFunctions+= "$($fn.name)"
                            }
                        }
                    }
                    $ChangedFunctions=$ChangedFunctions |sort | get-unique

                  if( $difflist[$difflist.IndexOf($diff) + 1].contains("new file")){
                     $Message=" Added "+ $fileName
     
                  }else {
                     $Message=" Modified "+ $fileName
  
                  }
                  $description= "Changed functions: `n" + $ChangedFunctions -join ","
                  git add $fileName
                  git commit -m "$Message" -m "$description"
                }
            try {git push} catch { return $_ }

            }
    }
}

#private
function test-GitLocal(){
    param(
         #Example: C:\Scripts\
         [string]$ProjectPath=((Get-Item -Path ".\").FullName)
         )
        if((Test-Path "$($ProjectPath)\.git"))
        {
        return $true
        }
        else
        {
        throw [System.IO.FileNotFoundException] "NO .git Folder present"
        return $false
        }

}

#private
function test-GitRemote(){
    param(
             #Example: C:\Scripts\
             [string]$ProjectPath=((Get-Item -Path ".\").FullName)
             )
    $repos = get-GitRepos
    $config = (get-content "$($ProjectPath)\.git\config").split("`n")
    $urls = ($config | Where-Object {$_ -like "*url = *"})
    $giturl = ($urls | Where-Object {$_ -like "*github*"}).split("=").Trim()[1].Replace(".git", "")
    
    
    if($repos.html_url.Contains($giturl)){
    return $true
    
    }
    throw [System.UriFormatException] "The repo $($giturl) Does not exsist"
    break all
    


}
   
#returns functions from file
function Get-functions(){
    param(
       [Parameter(mandatory=$true)][string]$filePath
       )
        $file=get-childitem $filePath
        $oldarray= Get-ChildItem function:\
        import-module $($file.FullName)
        $newarray= Get-ChildItem function:\
        $functions=($newarray | where {$oldarray -notcontains $_})
        Remove-Module $($file.BaseName)
        return $functions
}