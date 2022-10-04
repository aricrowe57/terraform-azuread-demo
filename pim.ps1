$connectionDetails = @{
    'TenantId'     = 'arispaidtesttenant.onmicrosoft.com'
    #'ClientId'     = 'cfb23b33-17f6-475c-b1b0-f3cfaeb5446a'
    'ClientId'     = $args[0]
    #'ClientSecret' = 'l-.8Q~q2Orut719vVN5Bk5PuU5BhzNNbiV7Xsdww' | ConvertTo-SecureString -AsPlainText -Force
    'ClientSecret' = $args[1] | ConvertTo-SecureString -AsPlainText -Force
}

Install-Module -Name MSAL.PS -Force

Import-Module -Name MSAL.PS -Force

$MsAccessToken = Get-MsalToken @connectionDetails

$GroupObjectId = "bad14d28-85ba-4960-a27f-e57cdb16325b"

Install-Module AzureADPreview -Force

Import-Module AzureADPreview -Force

Connect-AzureAD -MsAccessToken $MSAccessToken.AccessToken -TenantId "arispaidtesttenant.onmicrosoft.com" -AadAccessToken "x" -AccountId "x"

Add-AzureADMSPrivilegedResource -ProviderId "aadGroups" -ExternalId $GroupObjectId

$schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
$schedule.Type = "Once"
$schedule.StartDateTime = "2022-10-02T20:49:11.770Z"
$schedule.endDateTime = "2022-12-31T20:49:11.770Z"

$RoleDefinitions = @( Get-AzureADMSPrivilegedRoleDefinition -ProviderId "aadGroups" -ResourceId $GroupObjectId);

foreach($RoleDefinition in $RoleDefinitions){
    if ($RoleDefinition.DisplayName -eq "Member") {
        $RoleDefinitionId = $RoleDefinition.Id
    }
}

foreach($line in Get-Content .\owners.txt) {
    $UserObjectId = $line
    try {
        Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadGroups -Schedule $schedule -ResourceId $GroupObjectId -RoleDefinitionId $RoleDefinitionId -SubjectId $UserObjectId -AssignmentState "Eligible" -Type "AdminAdd"
    }
    catch {
        Write-Host $_
    }
} 
