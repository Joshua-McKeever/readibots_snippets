$NumberOfDays = -45
$StaleDate = (Get-Date).AddDays($NumberOfDays)
$SearchBase = "OU=MyUsers,DC=genericco,DC=com"
$DtD_OU = "OU=DisableToDelete,DC=genericco,DC=com"
$UpperLimit = 1

# identify stale user objects to disable and move
$data = Get-ADUser -Filter {enabled -eq $true} -SearchBase $SearchBase -Properties LastLogonDate, PasswordLastSet, whenCreated | Select SamAccountName, DistinguishedName, LastLogonDate, PasswordLastSet, whenCreated
$StaleUsers = $data | Where-Object LastLogonDate -LE $StaleDate | Where-Object PasswordLastSet -LE $StaleDate | Where-Object whenCreated -LE $StaleDate | Select SamAccountName, DistinguishedName -First $UpperLimit
$DisabledStaleUsers = @()

ForEach($StaleUser in $StaleUsers){

    $DN = $StaleUser.DistinguishedName
    $Sam = $StaleUser.SamAccountName

    Disable-ADAccount -Identity $DN
    Move-ADObject -Identity $DN -TargetPath $DtD_OU

    $obj1 = New-Object -TypeName PSObject
    $obj1 | Add-Member -MemberType NoteProperty -Name DistinguishedName -value "$DN"
    $obj1 | Add-Member -MemberType NoteProperty -Name SamAccountName -Value "$Sam"

    $DisabledStaleUsers += $obj1

}

$DisabledStaleUsers

# identify super stale user objects to delete
$SuperStaleUsers = Get-ADUser -Filter {enabled -eq $false -and whenChanged -le $StaleDate} -SearchBase $DtD_OU -Properties whenChanged | Select SamAccountName, DistinguishedName, whenChanged -First $UpperLimit

$DeletedStaleUsers = @()

ForEach($SuperStaleUser in $SuperStaleUsers){
    $SS_DN = $SuperStaleUser.DistinguishedName
    $SS_Sam = $SuperStaleUser.SamAccountName

    Remove-ADUser -Identity $SS_DN

    $obj2 = New-Object -TypeName PSObject
    $obj2 | Add-Member -MemberType NoteProperty -Name DistinguishedName -value "$SS_DN"
    $obj2 | Add-Member -MemberType NoteProperty -Name SamAccountName -Value "$SS_Sam"

    $DeletedStaleUsers += $obj2

}

$DeletedStaleUsers
