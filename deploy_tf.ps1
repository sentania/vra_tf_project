<#
.SYNOPSIS
    .
.DESCRIPTION
    This is a simple script (for a linux OS) that will apply a terraform template against a vRA 8 instance
    it is a very simple script and should be used as a learning example, not for production purposes.
.PARAMETER vRAUser
    The user to authenticate against vRA with.
.PARAMETER vRApassword
    The password to authenticate with.
.PARAMETER vRAdomain
    The vIDM domain to authencate against.  Leave it blank to authenticate against the system domain
.PARAMETER vRAServer
    The FQDN of the vRA Server.
.EXAMPLE
    ./deploy_tf_linux.ps1 -vraUser admin -vrapassword password -vradomain -vraserver vra8.lab.domain
.NOTES
    Author: Scott Bowe
    Email: scottb@sentania.net/sbowe@vmware.com
    Date:   March 5, 2020
#>

param (
    [Parameter(Mandatory=$true)][string]$vRAUser,
    [Parameter(Mandatory=$true)][string]$vRApassword,
    [Parameter(Mandatory=$true)][string]$vRAServer,
    [Parameter(Mandatory=$true)][string]$statePath

)


$loginurl="https://$vraserver/csp/gateway/am/api/login?access_token"
if ($vradomain.length -gt 1) {
    $body = "{ ""username"":""$vRAUser"",""password"":""$vRAPassword"",""domain"":""$vRADomain""}"    
} else {
    $body = "{ ""username"":""$vRAUser"",""password"":""$vRAPassword""}"
}

$resp = Invoke-RestMethod -Method POST -ContentType "application/json" -URI $loginurl -Body $body -skipcertificatecheck
#Write-Host "`n---------Refresh Token---------"
#$resp.refresh_token
#Write-Host "-------------------------------`n"

#Set ENV Variables for those wanting to use them for the Terraform Provider
$ENV:VRA_URL="https://$vRAServer"
$ENV:VRA_REFRESH_TOKEN=$resp.refresh_token
$refresh_token = $resp.refresh_token

$varfiles = Get-ChildItem -Path . -Filter *.tfvars
$tfstateFiles = get-childitem -path $statePath -Filter *.tfstate
if ( [environment]::OSVersion.Platform -eq 'Unix')
    {
        $path = '/usr/local/bin/terraform.12.26'
        Write-host "Linux system detected - setting path to: $path"
        
    }

    elseif ( [environment]::OSVersion.Platform -eq 'Win32NT')
    {
        $path = 'C:\utils\terraform.exe'
        Write-host "Windows system detected - setting path to: $path"
        
    }

    else {
        Write-host "Unable to determine operating system"
        break;
    }
$varfilesCount = $varfiles.count
Write-host "$varfilesCount var files found:"
foreach ($varfile in $varfiles)
{
    Write-host "$varfile.basename"
}    
foreach ($varfile in $varfiles)
{       
        
        Write-host "Applying terraform configuration"
        $basename = $varfile.BaseName
        $stateFilePath = "$statePath/$basename.tfstate"
        & $path --version
        & $path init
        & $path providers
        & $path plan -var-file="$varfile" -state="$stateFilePath" -var refresh_token="$refresh_token" -out "$statepath/$basename-maintain-plan"
        & $path apply -state="$stateFilePath" -input=false $statepath/$basename-maintain-plan
        #to ensure we can cleanly destory things in the future
        & $path plan -state="$stateFilePath" -destroy -var-file="$varfile" -var refresh_token="$refresh_token" -out $statepath/$basename-destroy-plan
}

foreach ($tfstateFile in $tfstateFiles)
{
    if ($tfstatefile | Where-Object {$varfiles.basename -notcontains $_.basename})
    {
        Write-host "Detected that clean up is needed $tfstatefile"
        $basename = $tfstatefile.BaseName
        & $path --version
        & $path init
        & $path providers
        & $path apply -input=false -auto-approve $statepath/$basename-destroy-plan
    }
}