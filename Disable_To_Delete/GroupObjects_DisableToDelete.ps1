# Update the variables to meet your business needs

$StaleDate = (Get-Date).AddDays(-3)
$SearchBase = "OU=MyGroups,DC=genericco,DC=com"
$DtD_OU = "OU=DisableToDelete,DC=genericco,DC=com"
$UpperLimit = 2
# identify stale AD groups, rename them, and move them

$data = Get-ADGroup -Filter * -SearchBase $SearchBase -Properties whenChanged, whenCreated | Select Name, DistinguishedName, whenChanged, whenCreated
$StaleGroups = $data | Where-Object whenChanged -LE $StaleDate | Select DistinguishedName, Name -First $UpperLimit
$RemediatedStaleGroups = @()
ForEach($StaleGroup in $StaleGroups){
    $DN = $StaleGroup.DistinguishedName
    $Name = $StaleGroup.Name
    $NewName = "Dtd$Name"
    Set-ADGroup -Identity "$DN" -SamAccountName "$NewName"
    Rename-ADObject -Identity "$DN" -NewName "$NewName"

    $NewDN = "CN=$NewName,$SearchBase"
    Move-ADObject -Identity "$NewDN" -TargetPath $DtD_OU


    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name NewName -value "$NewName"
    $obj | Add-Member -MemberType NoteProperty -Name OldDN -Value "$DN"

    $RemediatedStaleGroups += $obj

}

$RemediatedStaleGroups

# identify super stale AD groups, delete them
$DtD_Candidates = Get-ADGroup -Filter * -SearchBase $DtD_OU -Properties whenChanged, whenCreated | Select Name, DistinguishedName, whenChanged, whenCreated
$SuperStaleGroups = $DtD_Candidates | Where-Object whenChanged -LE $StaleDate | Select DistinguishedName, Name -First 1
$DeletedGroups = @()
ForEach($SuperStaleGroup in $SuperStaleGroups){
    $SS_DN = $SuperStaleGroup.DistinguishedName
    $SS_Name = $SuperStaleGroup.Name
    
    Remove-ADGroup -Identity $SS_DN -Confirm:$false
    
    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name DeletedName -value "$SS_Name"
    $obj | Add-Member -MemberType NoteProperty -Name DeletedDN -Value "$SS_DN"

    $DeletedGroups += $obj

}

$DeletedGroups
