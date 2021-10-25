Param(
    # Azure subscription ID associated with the Dev/Test lab instance.
    [ValidateNotNullOrEmpty()]
    [string]
    $SubscriptionId,

    #Name for the new resource group where the lab will be created 
    [ValidateNotNullOrEmpty()]
    [string]
    $ResourceGroupName
)

$ErrorActionPreference = "stop"

# === Login to Azure
Login-AzureRmAccount -SubscriptionId $SubscriptionId

# === Remove the resource group locks
$resourceGrouplocks = Get-AzureRmResourceLock -ResourceGroupName $ResourceGroupName
foreach($lock in $resourceGrouplocks) {
    Remove-AzureRmResourceLock -LockId $lock.LockId
    Write-Host "Removed lock: " + $lock.Name
}

# === Delete the resource group
Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force