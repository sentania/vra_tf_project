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
    [Parameter(Mandatory=$true)][string]$vRAServer

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
$tfstateFiles = get-childitem -path /var/lib/jenkins/terraform/vra_tf_project/ -Filter *.tfstate
foreach ($varfile in $varfiles)
{
    if ($tfstatefiles | Where-Object {$varfile.basename -contains $_.basename})
    {
        if ( [environment]::OSVersion.Platform -eq 'Unix')
        {
            $basename = $varfile.BaseName
            & /usr/local/bin/terraform.12.26 --version
            & /usr/local/bin/terraform.12.26 init
            & /usr/local/bin/terraform.12.26 providers
            & /usr/local/bin/terraform.12.26 plan -var-file="$varfile" -state="/var/lib/jenkins/terraform/vra_tf_project/$basename.tfstate" -var refresh_token="$refresh_token" -out "$basename-plan"
            & /usr/local/bin/terraform.12.26 apply -state="/var/lib/jenkins/terraform/vra_tf_project/$basename.tfstate" -input=false $basename-plan
        }

        elseif ( [environment]::OSVersion.Platform -eq 'Win32NT')
        {
            $basename = $varfile.BaseName
            & /usr/local/bin/terraform.12.26 --version
            & /usr/local/bin/terraform.12.26 init
            & /usr/local/bin/terraform.12.26 providers
            & /usr/local/bin/terraform.12.26 plan -var-file="$varfile" -state="/var/lib/jenkins/terraform/vra_tf_project/$basename.tfstate" -var refresh_token="$refresh_token" -out "$basename-plan"
            & /usr/local/bin/terraform.12.26 apply -state="/var/lib/jenkins/terraform/vra_tf_project/$basename.tfstate" -input=false $basename-plan
        }

        else {
            Write-host "Unable to determine operating system"
            break;
        }
    }
    elseif ($tfstatefiles | Where-Object {$varfile.basename -contains $_.basename})
    {
        {
            if ( [environment]::OSVersion.Platform -eq 'Unix')
            {
                $basename = $varfile.BaseName
                & /usr/local/bin/terraform.12.26 --version
                & /usr/local/bin/terraform.12.26 init
                & /usr/local/bin/terraform.12.26 providers
                & /usr/local/bin/terraform.12.26 plan -var-file="$varfile" -state="/var/lib/jenkins/terraform/vra_tf_project/$basename.tfstate" -var refresh_token="$refresh_token" -out "$basename-plan"
                & /usr/local/bin/terraform.12.26 destroy -state="/var/lib/jenkins/terraform/vra_tf_project/$basename.tfstate" -input=false $basename-plan
            }
    
            elseif ( [environment]::OSVersion.Platform -eq 'Win32NT')
            {
                $basename = $varfile.BaseName
                & /usr/local/bin/terraform.12.26 --version
                & /usr/local/bin/terraform.12.26 init
                & /usr/local/bin/terraform.12.26 providers
                & /usr/local/bin/terraform.12.26 plan -var-file="$varfile" -state="/var/lib/jenkins/terraform/vra_tf_project/$basename.tfstate" -var refresh_token="$refresh_token" -out "$basename-plan"
                & /usr/local/bin/terraform.12.26 destroy -state="/var/lib/jenkins/terraform/vra_tf_project/$basename.tfstate" -input=false $basename-plan
            }
    
            else {
                Write-host "Unable to determine operating system"
                break;
            }
        }
    }
}

foreach ($tfstateFile in $tfstateFiles)
{

}