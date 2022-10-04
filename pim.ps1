$GroupObjectId = "bad14d28-85ba-4960-a27f-e57cdb16325b"
$UserObjectId = "5c102dd0-6f07-475e-9ab9-b58034e46631" 
$RoleDefinitionId = "d4ddc0e6-3bc9-4a1c-9da3-6e880e1a9a76"

Import-Module AzureADPreview -Force

Connect-AzureAD

Add-AzureADMSPrivilegedResource -ProviderId "aadGroups" -ExternalId $GroupObjectId

$schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
$schedule.Type = "Once"
$schedule.StartDateTime = "2022-10-02T20:49:11.770Z"
$schedule.endDateTime = "2022-12-31T20:49:11.770Z"

$RoleDefinitions = @( Get-AzureADMSPrivilegedRoleDefinition -ProviderId "aadGroups" -ResourceId $GroupObjectId );

try {
    Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadGroups -Schedule $schedule -ResourceId $GroupObjectId -RoleDefinitionId $RoleDefinitionId -SubjectId $UserObjectId -AssignmentState "Eligible" -Type "AdminAdd"
}
catch {
    Write-Host $_
}