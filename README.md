# C3 powershellwrapper
A powershell wrapper for Spektra CSP C3 platform

Copy CSPControlCenterPS and its content to %username%\Documents\WindowsPowerShell\Modules.

## Getting started
After requesting API access you will receive connection details. Save the details to "<module path>\postman_environment.json" then use Get-C3AccessToken to connect.

Full documetation is available at
https://docs.cspcontrolcenter.com/docs/apis

|Function name|Purpose|
|-|-|
|`Get-C3AccessToken`|Generate Acecss token|
|`Get-C3BillingPeriods`|Get Billing Periods|
|`Get-C3Invoices`|Get Invoice by billing period|