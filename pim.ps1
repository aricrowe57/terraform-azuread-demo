#$GroupObjectId = "bad14d28-85ba-4960-a27f-e57cdb16325b"

$GroupObjectId = $args[2]

Install-Module AzureADPreview -Force

Import-Module AzureADPreview -Force

$password = ConvertTo-SecureString $args[1] -AsPlainText -Force

$Cred = New-Object System.Management.Automation.PSCredential ($args[0], $password)

Connect-AzureAD -Credential $Cred

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
