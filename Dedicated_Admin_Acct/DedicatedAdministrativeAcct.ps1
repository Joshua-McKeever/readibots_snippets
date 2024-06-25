$PrivilegeGroups = "Enterprise Admins", "Domain Admins", "Administrators", "Schema Admins"

ForEach($PrivilegeGroup in $PrivilegeGroups){
    $P_GroupDN = (Get-ADGroup $PrivilegeGroup).DistinguishedName

    $LDAP = "(&(!(userAccountControl:1.2.840.113556.1.4.803:=2))(objectClass=user)((memberof=$P_GroupDN)))"

    $PrivilegeUsers = Get-ADUser -LDAPFilter $LDAP -Properties employeeType | Where-Object employeeType -NE "Administrator" | Select SamAccountName, DistinguishedName

    # If there are non-administrator accounts in one of the privilege group, remove them from the privilege group
    If($PrivilegeUsers){ Remove-ADGroupMember -Identity "$P_GroupDN" -Members $PrivilegeUsers }

}
