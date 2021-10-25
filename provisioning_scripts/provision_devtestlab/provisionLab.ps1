Param(
    # Azure subscription ID associated with the Dev/Test lab instance.
    [ValidateNotNullOrEmpty()]
    [string]
    $SubscriptionId,

    #Name for the new resource group where the lab will be created 
    [ValidateNotNullOrEmpty()]
    [string]
    $ResourceGroupName,

    #Location for the resource group to be created. e.g. West US 
    [ValidateNotNullOrEmpty()]
    [string]
    $ResourceGroupLocation,

    #The name of the lab to be provisioned.
    [ValidateNotNullOrEmpty()]
    [string]
    $LabName,

    # The location to a CSV containing a row per VM. Columns include: vmPrefix, vmUsername, vmPassword 
    [ValidateNotNullOrEmpty()]
    [string]
    $ConfigCsvLocation,

    # The user name of the azure account. Optional - user is prompted for credentials if not included
    [string]
    $AzureUsername,

    # The password of the azure account. Optional - user is prompted for credentials if not included
    [string]
    $AzurePassword
)

# ====
# Script Functions
# ====

function InstallRequiredModules {
    if(-not (Get-Module -ListAvailable Az.*)) {
        Install-Module -Name PowerShellGet -Force
        Install-Module -Name Az -Repository PSGallery -Force -AllowClobber
    }
}

function ProvisionLab {
    param(
        [string] $ResourceGroupName,
        [string] $LabName
    )

    $deploymentName = "DeployTestLab_" + (New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds;
    New-AzResourceGroupDeployment -Name $deploymentName `
        -Force `
        -ResourceGroupName $ResourceGroupName `
        -TemplateFile "$PSScriptRoot\devtestlab-lab-template\devtestlab-lab-arm.json" `
        -TemplateParameterFile "$PSScriptRoot\devtestlab-lab-template\devtestlab-lab-arm.parameters.json" `
        -labName $LabName
}

function ProvisionLabVirtualMachines {
    param(
        [string] $ResourceGroupName,
        [string] $LabName,
        $ConfigCsv
    )

    $vmDeploymentName = "DeployTestLabVm_" + (New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds
    $multipleVmInformation = ConvertCsvObjectToVmInformationList -VmConfigurationCsv $ConfigCsv

    # This is performed as a job as provisioning VMs takes a long time
    New-AzResourceGroupDeployment -Name $vmDeploymentName `
        -ResourceGroupName $ResourceGroupName `
        -Force `
        -TemplateFile "$PSScriptRoot\devtestlab-vm-template\devtestlab-multiple-vm-arm.json" `
        -TemplateParameterFile "$PSScriptRoot\devtestlab-vm-template\devtestlab-multiple-vm-arm.parameters.json" `
        -multipleVmInformation $multipleVmInformation `
        -labName $LabName
}

function ConvertCsvObjectToVmInformationList {
    param(
        $VmConfigurationCsv
    )

    $multipleVmInformation = New-Object -TypeName System.Collections.Generic.List[VmInformation]
    foreach($configItem in $VmConfigurationCsv) {
        $currentVmInfo = New-Object -TypeName VmInformation
        $currentVmInfo.vmName = $configItem.vmName
        $currentVmInfo.vmUserName = $configItem.vmUserName
        $currentVmInfo.vmPassword = $configItem.vmPassword
        $multipleVmInformation.Add($currentVmInfo)
    }

    return $multipleVmInformation
}

class VmInformation {
    [string] $vmName
    [string] $vmUserName
    [string] $vmPassword
}

# ====
# Main Logic
# ====
$ErrorActionPreference = "stop"

# Install Required modules
InstallRequiredModules

# Get the CSV input
$configCsv = Import-Csv -Path $ConfigCsvLocation -Header 'vmName', 'vmUserName', 'vmPassword'

# === Login to Azure
Write-Host "Login to azure..."
if($PSBoundParameters.ContainsKey('AzureUsername') -And $PSBoundParameters.ContainsKey('AzurePassword')) {
    $azureSecurePassword = ConvertTo-SecureString -String $AzurePassword -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($AzureUsername, $azureSecurePassword)
    Connect-AzAccount -Credential $Credential -Subscription $SubscriptionId
}
else {
    Connect-AzAccount -SubscriptionId $SubscriptionId
}

# === Deploy Resource Group
Write-Host "Creating resource group..."
New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Force

# === Deploy Azure Dev Test Lab
Write-Host "Creating Azure Dev Test Lab..."
ProvisionLab -ResourceGroupName $ResourceGroupName -LabName $LabName

# === Deploy Azure Virtual Machines for each user to the test labs subscription
Write-Host "Creating Azure Dev Test Lab Virtual Machines..."
ProvisionLabVirtualMachines -ResourceGroupName $ResourceGroupName -LabName $LabName -ConfigCsv $configCsv

Write-Host "Finished Provisioning Azure Dev Test Lab Environment"