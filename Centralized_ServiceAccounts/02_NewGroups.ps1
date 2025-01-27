$CMDB_Apps = Get-RbData -TaskName './CMDB_Apps' -DataSetName 'CMDB_CI_APPL' -Property 'managed_by.user_name','managed_by_group.name','name'
$NewApps = $CMDB_Apps | Select name
$GroupList = @()
$DefaultRoles = @('Standard User', 'Advanced User', 'Administrator')

Foreach($NewApp in $NewApps){
    [string]$PreNewAppName = $NewApp.Name
    $NewAppName = $PreNewAppName -replace '[^a-zA-Z0-9]', ''

    ForEach($DefaultRole in $DefaultRoles){
        $Extension = $DefaultRole.Substring(0,5)
        $NextGroup = "APP-$NewAppName-$Extension"
        New-ADGroup -Name $NextGroup -SamAccountName $NextGroup -GroupCategory Security -GroupScope Global -Path "OU=MyGroups,DC=genericco,DC=com" -Description "$NewAppName" -OtherAttributes @{'Info'="$DefaultRole"}
    
        $obj = New-Object -TypeName PSObject
        $obj | Add-Member -MemberType NoteProperty -Name AppName -Value "$NewAppName"
        $obj | Add-Member -MemberType NoteProperty -Name DefaultRole -Value "$DefaultRole"
        $obj | Add-Member -MemberType NoteProperty -Name GroupName -value "$NextGroup"

        $GroupList += $obj
    }
    Break
}

$GroupList
