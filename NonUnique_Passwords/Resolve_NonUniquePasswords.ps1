# Install-Module DSInternals

$domain = "DC=genericco,DC=com"
$Hashes = Get-ADReplAccount -All -Server $env:computername -NamingContext $Domain | Select SamAccountName, DistinguishedName, @{Name="NT_Hash";Expression={ [System.BitConverter]::ToString($_.NTHash).Replace("-","") } }, @{Name="LM_Hash";Expression={ [System.BitConverter]::ToString($_.LMHash).Replace("-","") } }
$Hashes

# Users with duplicate passwords
$NonUniqueNT_Hash = $Hashes | Select DistinguishedName, NT_Hash | Group-Object NT_Hash | Where-Object Count -ge 2 | Select -ExpandProperty Group | Select DistinguishedName
$NonUniqueNT_Hash

# Force password change on next login
ForEach($Hash in $NonUniqueNT_Hash){
    $User = $Hash.DistinguishedName
    Set-Aduser $User -ChangePasswordAtLogon $true
}
