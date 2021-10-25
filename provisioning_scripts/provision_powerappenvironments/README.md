# PowerApps Environments Provisioner

This provisioner will set up Dev, Master and CI Trial instances within a Office 365 Developer Program subscription.

## Set up a Office 365 Developer Program Subscription

1. Navigate to https://developer.microsoft.com/en-us/microsoft-365/dev-program
2. Click 'Join Now'
3. Sign in with your Capgemini credentials and enter any information requested
4. After filling out the infomration, you should be taken to the Office 365 Developer Program subscription profile page
5. Click 'Set Up E5 Subscription'
6. On the dialog that appears, you'll need to enter the following information. 
  - **IMPORTANT**: Please ensure you save these details as you'll need them shortly
  - Username: e.g. luke.benting
  - Domain: e.g. lukebentingcsd
  - Password
7. After confirming the dialog, you'll be asked to enter your mobile phone number for security, and will be text a code to enter
8. Navigate to https://powerapps.microsoft.com/
9. Click 'Start free'
10. Sign in with the credentials entered in step 6
11. You may be asked to confirm your phone number again

## Running the provisioner

1. Download the PowerAppsEnvironmentProvisioner.ps1 file onto a location on your machine
2. Open the location in Explorer, right click the file and click 'Properties', if there is a button with text 'Unblock' click it, otherwise Cancel
3. Open a Powershell window as Administrator
4. cd to the location of the file
5. Paste the following command replacing the <> blocks with the information from earlier
```
	.\PowerAppEnvironmentProvisioner.ps1 -AdminUsername "<Username including domain>" -AdminPassword "<Password>" -NewUserPassword "<Password to be used for new trial accounts>"
```
6. The script should run without further input, when complete, a summary of accounts and new environments created will be given, which can be copied out for reference.
7. Login to https://admin.powerplatform.com using the credentials from Step 6 from the previous section and verify the three new environments have been created successfully.

## Known Issues

- Ocassionally, after the environments have been provisioned, their State will show as 'Failed', this appears to be incorrect, as the environments themselves are fine, and the status will eventually change to 'Ready' without any further intervention.