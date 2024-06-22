$Properties = @(
'SamAccountName'
'UserPrincipalName'
'DisplayName'
'EmployeeID'
'EmployeeNumber'
'physicalDeliveryOfficeName'
'Department'
'Title'
'l'
'st'
)

Get-ADUser -Filter {enabled -eq $true} -SearchBase "OU=MyUsers,DC=genericco,DC=com" -Properties $Properties | Select $Properties
