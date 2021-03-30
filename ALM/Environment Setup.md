Summary: A lab to setup the Power Platform environments and Azure DevOps.
URL: /CodeLabs/
Category: ALM
Environment: Web
Status: Draft
Feedback Link: 
Analytics Account:
Authors: Tom Ashworth and Luke Philips
Id: alm-environment-setup

# Environment Setup

##Introduction
### What you'll build & learn
This lab gives you a hands-on walkthrough to setup several Power Platform environments for use with development hub. You will:
- use the power platform admin centre to create 3 environments (development, extract and continuous integration)
- use Azure Active Directory to create an application user
- register the new user across the 3 power platform environments with System Administrator rights

### Prerequisites
- Dynamics 365 admin, Global admin, or Power Platform admin to a PowerApps tenant
   - Dynamics 365 Admin or Power Platform Admin to create instances
   - Global Admin is only required if you want to configure Exchange integration and approve email accounts
- Azure DevOps organisation created with a project created
- Preferably you will **request your account have Project collection administrator access** in Azure DevOps but as most Azure DevOps instances are hosted by clients they are sometimes reluctant to grant you this permission. This permission is required to enable you to install the required third-party extensions to Azure DevOps that are consumed by our tooling. If you struggle getting these permissions **at a minimum you will need Project administrator access** for an Azure DevOps project so you can request the extensions to be installed by a Project collection administrator.
<br>
Project collection administrator access is required to install the following tools without approval, if not possible then Project administrator will allow you to request these tools be installed to an Azure DevOps organisation:
   - [Power Platform Build Tools](https://marketplace.visualstudio.com/items?itemName=microsoft-IsvExpTools.PowerPlatform-BuildTools)
   - [Sarif Viewer Build Tab](https://marketplace.visualstudio.com/items?itemName=sariftools.sarif-viewer-build-tab)

## Request additional tools for Azure DevOps
**Important:** Only required if you only have Project administrator access to Azure DevOps

Open [Power Platform Build Tools](https://marketplace.visualstudio.com/items?itemName=microsoft-IsvExpTools.PowerPlatform-BuildTools)

Select **Get it free**

![MicrosoftTeams-image (8).png](/../.attachments/MicrosoftTeams-image%20(8)-fbf9c5b5-c9b5-4441-bef1-22cd5d5aa941.png)

You'll then be prompted to **Select an Azure DevOps organization**. Select your Azure DevOps organisation and select **Request**

![MicrosoftTeams-image (9).png](/../.attachments/MicrosoftTeams-image%20(9)-e5996451-c431-4439-86e5-fadafa1320fa.png)

Repeat this step for [Sarif Viewer Build Tab](https://marketplace.visualstudio.com/items?itemName=sariftools.sarif-viewer-build-tab)


## Create environments
Open up the ['Power Platform admin center'](https://admin.powerplatform.microsoft.com/) as an admin (Dynamics 365 admin, Global admin, or Power Platform admin).

If not automatically re-directed, navigate to **Environments** in the left-hand pane

Click **New**
<IMG  src="https://docs.microsoft.com/en-us/power-platform/admin/media/new-environment.png"  alt="Create new environment"/>
You will then be prompted to enter the following details

| Field | Value |
|--|--|
| Name | <Project name>Development e.g. ALMDevelopment |
| Type | Sandbox |
| Region | United Kingdom - Default |
| Purpose | _Include project name and reason for creating the environment e.g. ALM for MACE_ |
| Create a database for this environment | Yes |

Select **Next** to move onto next set of fields
<IMG  src="https://docs.microsoft.com/en-us/power-platform/admin/media/new-environment-page1.png"  alt="Create new environment settings"/>

| Field | Value |
|--|--|
| Language | English |
| URL | <project name><environment name> e.g. MACEALMDevelopment |
| Currency | GBP (£) |
| Enable Dynamics 365 Apps | _Project dependent but for lab leave as **No**_ |
| Deploy sample apps and data | No |
| Security group | Not applicable |
<IMG  src="https://docs.microsoft.com/en-us/power-platform/admin/media/new-environment-page2-enable-apps.png"  alt="Create new environment settings"/>

Select **Save**
Repeat steps above for the below two environments swapping out the details as necessary:
| Field | Value |
|--|--|
| Name | <Project name>Master e.g. ALMMaster |

| Field | Value |
|--|--|
| Name | <Project name>CI e.g. ALMCI|

**Important:** note down the **URLs of all environments** created into a text tool such as notepad as these will be used later on in the lab.

## Register a new Azure application
### Why?
The application in Azure Active Directory gives our development tooling, primarily Azure DevOps and Development Hub, the ability to talk to Dynamics 365. It enables:
- Development Hub to extract and import solutions across environments
- Allows to call Microsoft's Solution checker for the Power Platform in an Azure DevOps build to verify the quality of a solution

### Setup
Navigate to [Azure Active Directory](https://aad.portal.azure.com/)

From the left panel, choose **Azure Active Directory** > **App registrations**

Choose **+ New registration**

![MicrosoftTeams-image (6).png](/../.attachments/MicrosoftTeams-image%20(6)-66ad8683-81d7-4af6-9a1b-4610b66e889c.png)

In the **Register an application form** provide a name for your app such as **DevOps User**, select **Accounts in this organizational directory only**, and choose **Register**. A redirect URI is not needed for this walkthrough and the provided sample code.

<IMG  src="https://docs.microsoft.com/en-us/powerapps/developer/data-platform/media/s2s-app-registration-started.png"  alt="Register an application form"/>

On the **Overview** page, select **API permissions**

Choose **+ Add a permission**
![MicrosoftTeams-image (7).png](/../.attachments/MicrosoftTeams-image%20(7)-2b48a06c-02e5-4a5e-99ee-8220079cb641.png)

In the **Microsoft APIs** tab, **choose Dynamics CRM**

In the **Request API permission** form, select **Delegated permissions**, check **user_impersonation**, and select **Add permissions**

<IMG  src="https://docs.microsoft.com/en-us/powerapps/developer/data-platform/media/s2s-api-permission-started.png"  alt="Setting API permissions"/>

On the **API permissions** page select **Grant admin consent for "org-name"** and when prompted choose **Yes**

<IMG  src="https://docs.microsoft.com/en-us/powerapps/developer/data-platform/media/s2s-api-permission-completed.png"  alt="Granting API permissions"/>

Important: Select **Overview** in the navigation panel, record the **Display name**, **Application (client) ID**, and **Directory (tenant) ID** values of the app registration. You will use these later in the lab.

![MicrosoftTeams-image (4).png](/../.attachments/MicrosoftTeams-image%20(4)-594fccc7-a353-406b-b0d9-388233c5ccdd.png)

In the navigation panel, select **Certificates & secrets**

Below **Client secrets**, choose **+ New client secret** to create a secret

In the form, enter a description and select **Add**. 

**Important:** Record the secret string. You will not be able to view the secret again once you leave the current screen.


## Application user creation
Open the **[Maker Portal](https://make.powerapps.com/)**. 

Select the current environment (in the screenshot this is 'CSD - PP - Development') in the banner on the top right-hand side of the page and choose your Dataverse environment

![image.png](/../.attachments/image-ededabb0-f107-454b-b1f2-ac4c5a282d5f.png)

Once you're in the right environment, choose the **cog icon for Settings** and select **Advanced settings**

![image.png](/../.attachments/image-93467f1b-2eac-4a1c-9f74-b4f764dd2286.png)

Navigate to **Settings** > **Security** > **Users**.

Change the view filter to **Application Users** by selecting **Enabled Users** and choosing **Application Users**

![image.png](/../.attachments/image-dcc98e54-7a2a-4e0b-a701-4b3270daaca8.png)

Select **+ New**.

![image.png](/../.attachments/image-7a12ce98-721b-4856-95ae-edd9075553b9.png)

Change the Dynamics form by selecting **User** and choosing **Application User**
![image.png](/../.attachments/image-c470dd4b-f6ed-43bb-bb37-d6cc46380f38.png)

In the **Application ID** field, enter the **Application ID (Client ID)** of the app you registered earlier in Azure Active Directory which you also copied to a notepad and select **SAVE**
<IMG  src="https://docs.microsoft.com/en-us/powerapps/developer/data-platform/media/s2s-new-appuser1.png"  alt="New app user"/>

After selecting **SAVE**, if all goes well, the **User Name**, **Application ID URI**, **Azure AD Object Id**, **Full Name**, and **Primary Email** fields will auto-populate with correct values

![image.png](/../.attachments/image-ac89d4ae-3604-4869-a638-5fdaaac9f661.png)

Before exiting the user form, choose **MANAGE ROLES** and assign the System Administrator security role.

![image.png](/../.attachments/image-8dfe7b73-e27d-4f24-98fa-5e9afc226ae3.png)

Click **OK**

Repeat the this (Application user creation) step for the other two Power Platform environments you created earlier on:

- <Project name>Master
- <Project name>CI
