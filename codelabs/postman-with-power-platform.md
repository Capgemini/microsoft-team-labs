id: postman-with-power-platform
summary: A lab to learn the learn how to use Postman with Power Platform Web API.
categories: Web API Tools,
environment: Web
status: Draft
authors: Ahmet Oztourk

# Using Postman with Power Platform

## Introduction

The aim of this lab is that you will learn how to configure Postman to be used with Power Platform Web API. Postman is one of the most popular third-party tools that can be used to authenticate to Microsoft Dataverse instances and to create and send Web API requests and view responses.

### Prerequisites
- Power Apps Dataverse instance that you can connect to. You can find more information around creating environments in - [Environment Setup Codelab](https://capgemini.github.io/microsoft-team-labs/codelabs/alm-environment-setup/index.html?index=..%2F..%2Fmicrosoft-team-labs%2F#2)
- Azure Application User - You can find more information in how to register an application user in [Environment Setup Codelab](https://capgemini.github.io/microsoft-team-labs/codelabs/alm-environment-setup/index.html?index=..%2F..%2Fmicrosoft-team-labs%2F#4)
- [Download and install the Postman desktop application (Windows 64-bit)](https://www.postman.com/downloads/)

Some links you might find useful through out this lab:

- [Postman](https://www.postman.com/)
- [Power Platform Web API](https://docs.microsoft.com/en-us/powerapps/developer/data-platform/webapi/perform-operations-web-api)

## What is Postman?

Postman is an API client that makes it easy for developers to create, test and share API requests. It allows users to create and save HTTP/s requests and it allows users to read their responses as well. Postman allows you to either create an account for free or continue to use the app without an account.

There are few features to point out about Postman before we continue with the rest of this lab. 

### API Client

Postman API Client is the main tool which enabled users to easily to define API requests. It automatically detects the language of response and format the text inside the body to make any inspection easy. The client also includes built-in support for authentication protocals like OAuth 1.2/2.0 and many more. 
API Client allows you to organize requests into collections to help organize the requests for reuse so you dont have to waste time building everything from scratch. 

### Environment and Variables in Postman

An environment in Postman is a set of key-value pair variables called 'Environment Variables' that you can reference and use in your requests. When you create an environment inside Postman, any chan**ge to value of the key-value pairs will reflect in the requests so that we do not need to update the requests.
Multiple environments can be created in Postman and each environment can have their own set of variables created. Variables created inside of an environment are 'Local Scope Variables' and they will only work inside the environment they were created in. However Global variables can be created in Postman as well and they do not belong to any specific environment. 

### Workspaces  

Postman Workspaces help you organize your API work and share with others. You will need to create a Postman Account to be able to use workspaces. In this lab we will be using Personal Workspace and they are degisned for individual work. They contain all the tools required to work with APIs and you can access them between different Postman instances.

### Postman Navigation

![image.png](.attachments/postman-with-power-platform/image1.png)

### 1 - Side Bar Section
This box is where you can find environments, history, collections and apis.

### 2 - Request Builder Section
This box is where you can build requests and select which environment to use.

### 3 - Response Section
This box shows the response from the server that you receive after executing a particular request.

## Setup Postman Environment
Once you downloaded and installed postman, you will now need to sign up to a free postman account in order for you to be able to create a workspace and environment for this lab.

Launch Postman once it is installed and you will get the screen below to create a free account

![image.png](.attachments/postman-with-power-platform/image2.png)

Go ahead and click Create Free Account and simply follow the steps by providing an email address and a password

When asked to **Create your own team**, please click on **Continue Without a Team** button as shown below

![image.png](.attachments/postman-with-power-platform/image3.png)

You should now on the screen below

![image.png](.attachments/postman-with-power-platform/image4.png)

To access your **'Private Workspace'** please click on **Workspaces** on the toolbar and select **My Workspace** from the dropdown

![image.png](.attachments/postman-with-power-platform/image5.png)

Once you selected **'My Workspace'** , you should now see the screen below where you can start to create an environment and adding variables

![image.png](.attachments/postman-with-power-platform/image6.png)

### Create A Postman Environment

Click on **Environments** from the left Side Bar Section and then click on **+ Create New Environment** as shown below

![image.png](.attachments/postman-with-power-platform/image7.png)

And give your environment a meaningful name. Once environment has been created, you will see your environment as shown below and now you are ready to add in local variables to your environment

![image.png](.attachments/postman-with-power-platform/image8.png)

## How to connect Postman to Power Platform

There is a set of variables required by Postman in order to authenticate to Power Platform using OAuth2.0. These variables are;

**Variable Name**                  **Value**
url                                 Power App instance url https://<add your instance url>.crm11.dynamics.com
clientid                            Application Registration Client Id created in pre-requisites
version                             9.1
webapiurl                           {{url}}/api/data/v{{version}}/
callback                            https://callbackurl
authurl                             https://login.microsoftonline.com/common/oauth2/authorize?resource={{url}}
clientsecret                        Application Registration Client Secret created in pre-requisites

Once you created these in your environment then it should look as shown below

![image.png](.attachments/postman-with-power-platform/image9.png)