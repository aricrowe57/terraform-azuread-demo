$GroupObjectId = "bad14d28-85ba-4960-a27f-e57cdb16325b"

Install-Module AzureADPreview -Force

Install-Module AzureAD -Force

#Connect-AzureAD

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
