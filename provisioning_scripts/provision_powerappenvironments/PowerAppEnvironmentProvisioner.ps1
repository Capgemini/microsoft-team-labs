param (
	[Parameter(mandatory=$true)]
	[string]$AdminUsername,
	[Parameter(mandatory=$true)]
	[string]$AdminPassword,
	[Parameter(mandatory=$true)]
	[string]$NewUserPassword
)
$ErrorActionPreference = 'Stop'
$DynamicsCRMAppId = "00000007-0000-0000-c000-000000000000"
$DynamicsCRMUserImpersonationResourceAccessId = "78ce3f0f-a1ce-49c2-8cde-64b5c0896db4"
$Environments = @("Dev", "Master", "CI")

function Install-RequiredModules {
	Write-Host "`r`nInstalling Modules"
	if((Get-InstalledModule -Name Microsoft.PowerApps.Administration.PowerShell -ErrorAction SilentlyContinue) -eq $null)
	{
		Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Force
	}
	if((Get-InstalledModule -Name AzureAD -ErrorAction SilentlyContinue) -eq $null)
	{
		Install-Module -Name AzureAD -Force
	}
	Write-Host "Modules Installed"
}

function Connect-ToAzureAD {
	param(
		[Parameter(mandatory=$true)]
		[string]$username, 
		[Parameter(mandatory=$true)]
		[string]$password
	)
	$secureAdminPassword = ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force
	$credential = New-Object System.Management.Automation.PSCredential($username, $secureAdminPassword)
	$connect = Connect-AzureAD -Credential $credential
	Write-Host "Connected to Azure"
	
	return $connect
}

function New-AppRegistrationForApplicationUser {
	Write-Host "`r`nCreating App Registration..."
	$ResourceAccessObjects = New-Object "System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]"
	$ResourceAccessObjects.Add([Microsoft.Open.AzureAD.Model.ResourceAccess]@{
		Id = $DynamicsCRMUserImpersonationResourceAccessId;
		Type = "Scope";
	})

	$RequiredResourceAccess = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
	$RequiredResourceAccess.ResourceAppId = $DynamicsCRMAppId
	$RequiredResourceAccess.ResourceAccess = $ResourceAccessObjects

	$newAppReg = New-AzureADApplication -DisplayName "Labs Azure DevOps" -RequiredResourceAccess $RequiredResourceAccess
	Write-Host "Created App Registration"
	
	$newAppRegSecret = New-AzureADApplicationPasswordCredential -ObjectId $newAppReg.ObjectId -CustomKeyIdentifier "Secret"
	
	$newServicePrincipal = New-AzureADServicePrincipal -AppId $newAppReg.AppId
	Write-Host "Created Service Principal"
	
	$dataverseServicePrincipal = Get-AzureADServicePrincipal -Filter "AppId eq '$DynamicsCRMAppId'"
	
	$body = @{
		clientId = $newServicePrincipal.ObjectId;
		consentType = "AllPrincipals";
		principalId = $null;
		resourceId = $dataverseServicePrincipal.ObjectId;
		scope = "user_impersonation";
		expiryTime = (Get-Date).AddDays(365).ToString("s");
	}
	
	$token = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens['AccessToken'].AccessToken
	Invoke-RestMethod -Uri "https://graph.windows.net/myorganization/oauth2PermissionGrants?api-version=1.6" -Headers @{ Authorization = "Bearer $token" } -Method POST -Body ($body | ConvertTo-Json) -ContentType "application/json"
	
	return @{
		AppRegistration = $newAppReg;
		ServicePrincipal = $newServicePrincipal;
		Secret = $newAppRegSecret
	}
}

function Add-LicensedADUsers {
	param(
		[Parameter(mandatory=$true)]
		[string]$password,
		[Parameter(mandatory=$true)]
		[string]$domain
	)
	$TrialLicense = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
	$TrialLicense.SkuId = [System.guid]::New("dcb1a3ae-b33f-4487-846a-a640262fadf4")
	$DeveloperLicense = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
	$DeveloperLicense.SkuId = [System.guid]::New("c42b9cae-ea4f-4ab7-9717-81576235ccac")
	$Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
	$Licenses.AddLicenses = @($TrialLicense, $DeveloperLicense)

	$NewUserPasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
	$NewUserPasswordProfile.Password = $password
	$NewUserPasswordProfile.EnforceChangePasswordPolicy = $False
	$NewUserPasswordProfile.ForceChangePasswordNextLogin = $False

	Write-Host "`r`nCreating Users..."
	foreach($Environment in $Environments)
	{
		$NewUserUsername = $Environment + "User"
		$NewUserUPN = $NewUserUsername + "@" + $domain
		if((Get-AzureADUser -Filter "userPrincipalName eq '$NewUserUPN'") -eq $null)
		{
			$NewUser = New-AzureADUser -DisplayName $NewUserUsername -PasswordProfile $NewUserPasswordProfile -UserPrincipalName $NewUserUPN -AccountEnabled $true -MailNickName $NewUserUsername -UsageLocation "GB" -PasswordPolicies "DisablePasswordExpiration"
			Set-AzureADUserLicense -ObjectId $NewUser.ObjectId -AssignedLicenses $Licenses
			Write-Host "$NewUserUPN Created."
		}
		else
		{
			Write-Host "$NewUserUPN Already Exists."
		}
	}
}

function New-TrialEnvironmentsForUsers {
	param(
		[Parameter(mandatory=$true)]
		[string]$userPassword,
		[Parameter(mandatory=$true)]
		[string]$domain,
		[Parameter(mandatory=$true)]
		[string]$servicePrincipalObjectId
	)	
	$secureNewUserPassword = ConvertTo-SecureString -String $userPassword -AsPlainText -Force
	
	$results = @()
	Write-Host "`r`nCreating Environments..."
	foreach($Environment in $Environments)
	{
		$EnvironmentUsername = $Environment + "User"
		$EnvironmentUPN = $EnvironmentUsername + "@" + $domain
		Add-PowerAppsAccount -Endpoint "prod" -Username $EnvironmentUPN -Password $secureNewUserPassword
		$NewEnvironment = New-AdminPowerAppEnvironment -DisplayName $Environment -Location unitedkingdom -EnvironmentSku Trial -CurrencyName GBP -ProvisionDatabase
		if($NewEnvironment.Error -ne $null) 
		{
			$results += [PSCustomObject]@{
				EnvironmentName = $Environment;
				EnvironmentUrl = "";
				UserUPN = $EnvironmentUPN;
				UserPassword = $userPassword;
				Status = "Failed";
			}
			Write-Host $NewEnvironment.Error
		}
		else 
		{
			$EnvironmentName = $NewEnvironment.DisplayName.Substring(($NewEnvironment.DisplayName.IndexOf("(") + 1), ($NewEnvironment.DisplayName.Length - $NewEnvironment.DisplayName.IndexOf("(") - 2))
			$results += [PSCustomObject]@{
				EnvironmentName = $Environment;
				EnvironmentUrl = ($EnvironmentName + ".crm11.dynamics.com");
				UserUPN = $EnvironmentUPN;
				UserPassword = $userPassword;
				Status = "Success";
			}
			Write-Host ("`r`n" + $NewEnvironment.DisplayName + " Created.")
		}
	}
	
	return $results
}

$DomainName = $AdminUsername.Substring($AdminUsername.IndexOf("@") + 1)

Install-RequiredModules

$Connection = Connect-ToAzureAD -username $AdminUsername -password $AdminPassword
$AppRegDetails = New-AppRegistrationForApplicationUser
Add-LicensedADUsers -password $NewUserPassword -domain $DomainName

Write-Host "`r`nWaiting for new users to sync through..."
Start-Sleep -Seconds 30

$EnvironmentResults = New-TrialEnvironmentsForUsers -userPassword $NewUserPassword -domain $DomainName -servicePrincipalObjectId $AppRegDetails.AppRegistration.ObjectId

Write-Host "`r`nSummary:"
Write-Host "Environments:"
$EnvironmentResults | Format-Table
Write-Host "`r`nService Connection Details for ADO:"
Write-Host ("Tenant Id: " + $Connection.TenantId)
Write-Host ("Application Id: " + $AppRegDetails.AppRegistration.ObjectId)
Write-Host ("Client Secret of Application ID: " + $AppRegDetails.Secret.Value)#>