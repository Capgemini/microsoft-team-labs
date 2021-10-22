# DevTestLab creator tool
The following tool can be used to create an azure devtestlabs instance with virtual machines.

## Run Steps
1. You will need to firstly create a csv file which contains the information about the VMs you wish to create in your lab environment. 
The CSV file will need to be comma delimited in the format "vmName (This has to be under 15 characters), vmUserName, vmPassword". An example is the "examplemachines.csv" file contained in the project.
2. The next step is to run the "provisionLab.ps1" script as an administrator specifying arguments for SubscriptionId, ResourceGroupName, ResourceGroupLocation, LabName and ConfigCsvLocation. Note. If you prefer to use the older AzureRm powershell module there is also a script called "provisionLabAzureRm.ps1".
An example of calling the script with the required arguments is:
    ```
    .\provisionLab.ps1 -SubscriptionId 0fbe9ddf-04bf-4b96-bdc6-032844dfaa9c -ResourceGroupName "rg-capgemini-devtestlab" -ResourceGroupLocation "UK South" -LabName "examplelab001" -ConfigCsvLocation ".\example_machines.csv" 
    ```
    As a note the first time the script is run if you do not currently have the Az powershell module installed it will take quite a while to install so be patient.

3. Once the script has started running if you have not included -AzureUsername and -AzurePassword as part of the parameters you will be prompted to enter credentials for the azure account that has admin access to the previously specified subscription.
4. The script should then attempt to provision the lab and VMs. This will take some time so be patient.
5. You can check the progress of the VM's being created by navigating to the created lab in the azure portal.
6. When the machines are ready you should be able to remote desktop in to them using the local credentials provided in the CSV. 
The fully qualified domain name for the machines should be in the format '{vmname}.{resourcegrouplocation}.cloudapp.azure.com' e.g. caplabvma02.uksouth.cloudapp.azure.com. You can download a preconfigured rdp file by navigating to the provisioned VM in azure and clicking the connect button.
7. When the lab is no longer needed it's advised to delete the resources. This can be done from the azure portal or by running the "deleteResourceGroup.ps1" script. if running from the portal you may need to remove the locks on the resource group.

## Virtual Machine configured in the ARM template
The arm template that is used to generate the virtual machines currently provisions a windows 10 base image with the following software:
- Visual Studio 2019
- Visual Studio Code
- Chrome

If you wish to provision the VMs with additional software you will need to update the artifacts in the "devtestlab-multiple-vm-arm" arm template.

## Additional Configuration
As well as configuring some aspects through the script parameters, You can also perform more advanced configuration by editing the azure resource manager templates and parameters specified in the "devtestlab-lab-template" and "devtestlab-vm-template" folders.