Summary: A lab to learn the foundations of automated UI testing for Dynamics using Specflow and EasyRepro.
URL: /CodeLabs/
Category: Automated Testing
Environment: Web
Status: Draft
Feedback Link: 
Analytics Account:
Authors: Zoe Dawson and Matthew Hoy
id: Introduction


# Introduction

The aim of this lab and the subsequent labs that you will find a lot of the information you will need to get started with creating an automated test project using PowerApps SpecFlow Bindings along with some guidance on best practices and recommended approaches.

Some links you might find useful throughout these exercises are as follows:

Easyrepro: https://github.com/microsoft/EasyRepro
PowerApps Specflow Bindings: https://github.com/Capgemini/powerapps-specflow-bindings
Specflow: https://docs.specflow.org/en/latest/
Selenium: https://www.selenium.dev/documentation/en/

# What Is Automated Acceptance Testing?

Automated testing is a way of testing the functionality of software using an automation tool. It differs from manual testing in that in manual testing a human is responsible for working through a test case step by steps and recording the results. In automation testing the human is removed from the equation and the test automation software, such as Selenium, runs through a given suite of tests reporting on successes/failures. 

It is important at this point to distinguish automated acceptance testing from other types of test automation. With automated acceptance testing we are specifically looking at mimicking and automating the way in which a user interacts with the UI of your software. If you are looking at testing background data processes you should be using integration tests as a ui test will tell you nothing that the integration test wouldn’t be able to tell you much quicker.


## Why do we use automated acceptance testing?

Test automation allows for a large number of scenarios to be executed in a fairly short amount of time. It is much quicker to run a suite of regression tests, for example, with test automation software than it is for a human to work through a regression suite of manual tests. This short run time for a large number of tests allows for the test automation to be worked into a number of other processes such as pull requests, builds or releases to allow for code to be merged with confidence that the changes will not break anything. 


# What is EasyRepro?

EasyRepro is a library created and maintained by Microsoft to help facilitate easy automated ui testing of model driven Power Apps. This library aims to map typical user actions in a dynamics environment to selenium code to automate those actions. In this way you should be able to write automation tests using selenium that mimic typical users tasks quickly and efficiently with minimal extra code. 


# What is SpecFlow?

SpecFlow is a framework for automation tests that allows you to link code to plain text bindings to vastly improve the readability of your automation tests and allow them to be written by people with limited experience of development. 

For Example this code:


```
public static void WhenIEnterInTheField(string fieldValue, string fieldName, string fieldType, string fieldLocation)
        {
            if (fieldLocation == "field")
            {
                SetFieldValue(fieldName, fieldValue.ReplaceTemplatedText(), fieldType);
            }
            else
            {
                SetHeaderFieldValue(fieldName, fieldValue.ReplaceTemplatedText(), fieldType);
            }

            // Click to lose focus - So that business rules and other form events can occur
            Driver.FindElement(By.XPath("html")).Click();

            Driver.WaitForTransaction();
        }
```


Can be represented as:


```
@Regression
Scenario: Basic user views the contact forms
	When I enter 'John Doe' into the 'name' text field on the form
```


Which is much easier to understand for a layman than EntitySteps.WhenIEnterInTheField(“John Doe”, “name”, “text”, “field);

Specflow uses the Gherkin ‘Given-When-Then’ syntax for your bindings which allows for tests to be written in a way that mimics a user journey and should be broadly in line with your user stories. 


# What Is BDD?

BDD or Behaviour Driven Development is a way of working in which business analysts/functional consultants, developers and testers work collaboratively when defining requirements using simple, clear and easily understood common language to allow for everyone involved to have a clear understanding of how the system is expected to function. 

When requirements are written collaboratively in this way the user stories themselves act as a framework from which the automation tests can be built as each scenario in the user story should be a valid user scenario following the ‘Given-when-Then’ formula. 

An example of this might be a user story covering a user booking an appointment.


```
Story: Set Customer Checkup Call After Appointment

Given A customer service agent has scheduled an appointment with a customer
When The date of the appointment is set
Then The follow-up call date is scheduled for 2 days after the appointment
```


Could become the following test


```
Given I am logged in as "Customer Service Agent"
When I enter a date of "1/1/1970" into the "Appointment Date" field
Then The "Followup Call" field contains a value of "3/1/1970"
```


Here you can see how using this shared, behaviour driven approach to defining requirements has resulted in a clear and easy to understand user requirement that can be easily adapted into an automated test with minimal effort from the tester.

For more information on BDD and how we integrate this into our projects you can read the docuementation [here](https://capgeminiuk.visualstudio.com/Microsoft%20Community/_wiki/wikis/Microsoft-Community.wiki/839/Create-and-Sign-Off-Detailed-User-Stories).


# What is Power Apps Specflow Bindings?

The Capgemini Power Apps SpecFlow Bindings library is a helper library for Model Driven Power App test automation that takes the EasyRepro library of functions and uses SpecFlow to give you a step binding for each function. This Power Apps SpecFlow Bindings library currently has full step parity with EasyRepro. Further to this it also provides a number of useful tools to help you with automating your business requirements. An example of this would be the data creation steps using the dynamics api to consume and create dynamics data using json files.
