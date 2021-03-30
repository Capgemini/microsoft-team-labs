Summary: A lab to create more advanced SpecFlow scenarios using custom step bindings.
URL: /CodeLabs/
Category: Automated Testing
Environment: Web
Status: Draft
Feedback Link: 
Analytics Account:
Authors: Zoe Dawson and Matthew Hoy

# Introduction


# Extending Steps with EasyRepro


# Data Setup - Getting the Context


## Introduction

The Capgemini Bindings do not currently have a way to access the Dynamics OrganisationServiceContext, so this section will show a way to retrieve it.


## Installing Dynamics NuGet Packages

Navigate to the NuGet packages for the solution and add the following: 


```
Microsoft.CrmSdk.XrmTooling.CoreAssembly
Microsoft.CrmSdk.CoreAssemblies
```


These packages provide access to the required SDK classes to connect to and update data in a Dynamics instance.


## Helper Class

As it is possible that a number of different Steps files will require access to the Dynamics context, it is useful to put this logic in a helper file that can be accessed by all step files. Create an Extensions folder in the project root and add a ContextHelper.cs file to the folder.

![alt_text](/.attachments/advanced-scenarios/image1.png "image_tooltip")


Next, add `: PowerAppsStepDefiner `after the class name in the file to inherit from the Capgemini Bindings class.

This class will initially require two methods, one that returns a ServiceClient based on standard user credentials, and one that returns a ServiceClient in the context of an application user, which uses a clientid and secret.

Create a method in the ContextHelper class that returns a CrmServiceClient based on the below code outline. As this class inherits from PowerAppStepDefiner, its methods will have access to helpful methods within the TestConfig class. Use the [SDK documentation](https://docs.microsoft.com/en-us/powerapps/developer/data-platform/xrm-tooling/use-connection-strings-xrm-tooling-connect) to help you.


```
public static CrmServiceClient GetServiceClient(UserConfiguration user)
        {
return new CrmServiceClient($"Replace this text with the required values to create a connection.");
        }
```


Below is a sample connection string, though this will be different across different environment configurations, such as those using IFD.


```
return new CrmServiceClient($"Url={TestConfig.GetTestUrl()}; Username={user.Username}; Password={user.Password}; AuthType=Office365; RequireNewInstance=true");
```


The next method to create for this class should return a CrmServiceClient for an application user, using a clientid and secret in the connection string rather than a username and password. Using what you have learned from the above method, create a new method based on the below code outline, using a connection string for an application user. Remember to utilise the TestConfig class.


```
public static CrmServiceClient GetServiceClient()
{
    ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
 
    return new CrmServiceClient($"Replace this text with the required values to create a connection");
}
```


Below is a sample connection string for an application user.


```
return new CrmServiceClient($"Url={TestConfig.GetTestUrl()}; ClientId={TestConfig.ApplicationUser.ClientId}; ClientSecret={TestConfig.ApplicationUser.ClientSecret}; AuthType=ClientSecret; RequireNewInstance=true");
```


This concludes the basic functionality required for this class, though there may be other methods that would be useful to add, such as creating a ServiceClient based on a given string containing a username rather than requiring creation of a UserConfiguration object. An example of this is given below.


```
public static CrmServiceClient GetServiceClient(string user)
{
    return GetServiceClient(TestConfig.GetUser(user));
}
```


To use the ServiceClient in a Steps class and retrieve the context from it, wrap any API operations in the below using statements.


```
using (var svc = ContextHelper.GetServiceClient(TestConfig.GetUser("<user alias here>")))
using (var context = new OrganizationServiceContext(svc))
```


It is important to remember that any records created here will not be cleaned up as part of the Capgemini Bindings after test cleanup functionality.


# Data Setup - CRM Context Practice


## Exercise - Using the CRM Context

Next we will be practicing using the CRM Context to set up data required for tests. In this scenario, we will be deactivating a contact as part of a Given step and validating that it appears in the “Inactive Contacts” view. In a real world scenario, data setup would be far more complex, involving updating multiple records to advance in the business process in order to reach the precondition for the user story.

First, create a SpecFlow Step Definition file named “DataSetupSteps.cs” in the Steps folder of the project. Delete the auto generated steps and write a new Given step method declaration based on the following: 


```
Given a contact has been deactivated
```


Within this method, use the TestDriver class to retrieve the EntityReference of the ‘a contact’ entity, then use the ServiceClient to execute a SetStateRequest to deactivate the contact. Use the SDK Documentation to help you.


```
[Given("a contact has been deactivated")]
public void GivenContactIsDeactivated()
{
    var contact = TestDriver.GetTestRecordReference("a contact");
    using (var svc = ContextHelper.GetServiceClient(TestConfig.GetUser("a basic user")))
    using (var context = new OrganizationServiceContext(svc))
    {
        var updateStatus = new SetStateRequest()
        {
            EntityMoniker = contact,
            State = new OptionSetValue(1),
            Status = new OptionSetValue(2),
        };
 
        context.Execute(updateStatus);
        context.SaveChanges();
    }
}
```


Once the step has been created, it can now be used in scenarios. Create a new scenario in the ContactManagement feature file named “Basic user validates inactive contacts view” based on the below user story.


```
Given I log into the app as a basic user
And I create a contact
And the contact has been deactivated
When I navigate to the Contacts subarea
And I select the Inactive Contacts view
Then I can see the contact
```


Below is a sample scenario for the above user story:


```
Scenario: Basic user validates inactive contacts view
	Given I am logged in to the 'UI Test App' app as 'a basic user'
	And I have created 'a contact'
	And a contact has been deactivated
	When I open the sub area 'Contacts' under the 'Organisation Details' area
	And I switch to the 'Inactive Contacts' view in the grid
	Then the grid contains 'a contact'
```


Now update this step to work for any alias passed to the step. Below is a sample of how this could be implemented.


```
[Given("'(.*)' has been deactivated")]
public void GivenContactIsDeactivated(string recordAlias)
{
    var recordRef = TestDriver.GetTestRecordReference(recordAlias);
    using (var svc = ContextHelper.GetServiceClient(TestConfig.GetUser("a basic user")))
    using (var context = new OrganizationServiceContext(svc))
    {
        var updateStatus = new SetStateRequest()
        {
            EntityMoniker = recordRef,
            State = new OptionSetValue(1),
            Status = new OptionSetValue(2),
        };
 
        context.Execute(updateStatus);
        context.SaveChanges();
    }
}
```



# Writing Custom Steps

When using SpecFlow on a project, it is expected that you will be able to write custom steps to expand on those of EasyRepro and the Capgemini Bindings. At the time of writing, there are some areas of the Dynamics UI that are not compatible with EasyRepro, such as editable grids and certain dialog boxes. In this section you will be required to write custom steps that interact with these UI elements.


# Writing Custom Steps - Using XPath


## Introduction

One of the most common ways to interact with elements on the web page as part of SpecFlow testing is using XPath. XPath is a syntax that is used to navigate through and retrieve elements in an XML document.


## Finding the XPath of an Element

An easy way to find the XPath of an element is by opening Chrome Developer Tools, right clicking a HTML element and clicking “Copy XPath”. This XPath can then be used in the Chrome Console to return this specific element, by using the following function:


```
$x("<Paste XPath here")
```


To execute this XPath in C#, the following method is used:


```
Driver.FindElement(By.XPath($"Paste XPath here"));
```


This is helpful for finding elements that are not accessible as part of the XrmApp EasyRepro object. For more information on XPath, see [here](https://www.w3schools.com/xml/xpath_intro.asp).


# Writing Custom Steps - Exercise 1 - XPath

In this exercise we will be validating the title shown on the out of the box Contact Delete Confirmation dialog.

Write a custom step in a new Steps file, which asserts that the dialog text is equal to “Contact Delete Confirmation”.

Then add a scenario using this step called “Basic user deletes a contact”. Please note that the “I select the ‘Delete’ command” should be used instead of the “I delete the record”, as the latter does not trigger the dialog to appear.


## Sample Answer

Below is a sample step and scenario for the above exercise.


```
[Then("a dialog is displayed with a title of '(.*)'")]
public void ThenADialogIsDisplayedWithTitle(string title)
{
    var actual = Driver.FindElement(By.XPath("//h1[@id='dialogTitleText']"));
    actual.Should().Be(title);
}
```



```
Scenario: Basic user deletes a contact
	Given I am logged in to the 'UI Test App' app as 'a basic user'
	And I have created 'a contact'
	And I have opened 'a contact'
	When I select the 'Delete' command
	Then a dialog is displayed with a title of 'Contact Delete Confirmation'
```

