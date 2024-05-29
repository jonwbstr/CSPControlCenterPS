$cred = $(Get-Content $PSScriptRoot\postman_environment.json|convertfrom-json).values|Group-Object key -AsHashTable
$BaseURI = $cred.apiUrl.value

<#
.SYNOPSIS
This cmdlet creates a PowerShell connection to the CSP Control Center.
.DESCRIPTION
Use this command to create a connection to the CSP Control Center. Connecting is required before running other commands.
.EXAMPLE
Get-C3AccessToken -Credential $(Get-Credential)
#>
function Get-C3AccessToken($Credential)
{
	$Params = @{
		ErrorAction = "Stop"
		URI = "https://login.microsoftonline.com/$($cred.TenantId.value)/oauth2/token"
		Body = @{
			grant_type="client_credentials";
			client_id=$cred.client_id.value;
			client_secret=$cred.client_secret.value
			scope=$cred.scope.value;
			resource=$cred.resource.value
		}
		Method = 'POST'
	}

	try {
		$accesstoken = Invoke-RestMethod @Params
		$script:Headers = @{Authorization = "Bearer " + $accesstoken.access_token}
		Write-Host "C3 Access Token refreshed"
	}
	catch {
		Write-Host "Unable to obtain C3 Access Token.`n$_" -ForegroundColor Red -BackgroundColor Black
	}
}
Export-ModuleMember -Function 'Get-C3AccessToken'

<#
.SYNOPSIS
This cmdlet returns a list of billing periods.
.DESCRIPTION
Use this command to get a list of billing periods. Used in combination with the Get-C3Invoices command.
.EXAMPLE
Get-C3BillingPeriods
#>
Function Get-C3BillingPeriods
{
	$Params = @{
		ErrorAction = "Stop"
		URI = "$BaseURI/api/BillingPeriods"
		Headers = $script:Headers
		Method = 'GET'
	}

	try {
		$results = Invoke-RestMethod @Params
		$results.Data
	}
	catch {
		Write-Host "Request Failed.`n$_" -ForegroundColor Red -BackgroundColor Black
	}
}
Export-ModuleMember -Function 'Get-C3BillingPeriods'

<#
.SYNOPSIS
This cmdlet returns a list of invoice line items.
.DESCRIPTION
Use this command to retreive a list of invoice line items for all or a specific customer.
.PARAMETER BillingPeriodId
The list of Billing Periods is available from Get-C3BillingPeriods
.PARAMETER TenantIDs
Comma 
.EXAMPLE
Get-C3Invoices
# This command returns all invoices for the most recent billing period
.EXAMPLE
Get-C3Invoices -BillingPeriodId $(Get-C3BillingPeriods)[2].id -TenantIds "00000000-0000-0000-0000-000000000000","00000000-0000-0000-0000-000000000000"
# This command returns all invoices for the two specified customers for a specific billing period.
#>
Function Get-C3Invoices($BillingPeriodId,$TenantIDs)
{
	$Params = @{
		ErrorAction = "Stop"
		URI = "$BaseURI/api/invoices/Download/v3/billingperiods/$BillingPeriodId"
		Headers = $script:Headers
		Method = 'POST'
		ContentType = 'application/json'
	}

	if($TenantIds) {
		$Params += @{Body = @{TenantIds=$TenantIDs}|ConvertTo-Json}
	}

	try {
		$results = Invoke-RestMethod @Params
		$results.Data
	}
	catch {
		Write-Host "Request Failed.`n$_" -ForegroundColor Red -BackgroundColor Black
	}
}
Export-ModuleMember -Function 'Get-C3Invoices'