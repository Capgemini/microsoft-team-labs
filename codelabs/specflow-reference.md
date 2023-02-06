id: specflow-reference
summary: A reference lab containing useful code examples to solve advanced SpecFlow problems.
categories: Automated_Testing, SpecFlow
environment: Web
status: Draft
authors: Zoe Dawson and Mike Andrews
tags: Intermediate

# Reference

## Working With Modal Forms

In this exercise we will be using selectors on objects which have already been selected, in order to work with modal forms which appear in Dynamics on top of other forms. Attempting to work with modal forms without first establishing their context causes issues with XPath incorrectly retrieving fields and components from the page behind the modal form.

Below is an example method for retrieving the context of a form. The IWebElement returned by this method can then be queried using XPath, which will only return child values of the modal form element.

```
public static IWebElement GetFormContext(IWebDriver webDriver)
        {
            webDriver.WaitUntilAvailable(By.XPath("//div[(contains(@aria-modal, 'true') and contains (@role, 'dialog')) or @data-id='GridRoot' or @data-id='editFormRoot']"), 10.Seconds());
            var modalForms = webDriver.FindElements(By.XPath("//div[contains(@aria-modal, 'true') and contains (@role, 'dialog')]"));
            if (modalForms.Count > 0)
            {
                return modalForms.Last();
            }
            else if (webDriver.TryFindElement(By.XPath("//div[@data-id='GridRoot']"), out var gridRoot))
            {
                return gridRoot;
            }
            else if (webDriver.TryFindElement(By.XPath("//div[@data-id='editFormRoot']"), out var editFormRoot))
            {
                return editFormRoot;
            }
            return null;
        }
 ```
 