# Pull in new group data
$NewGroupsData = Get-RbData -TaskName './NewGroups' -DataSetName 'NewGroups'
#$NewGroups = [string]$NewGroupsData.CBStringContent
#$NewGroups
ForEach($NewGroup in $NewGroupsData){
        $Group = $NewGroup.GroupName
        $NewGroupList += $Group + ","
}
$NewGroupsLong = $NewGroupList.Substring(0,$NewGroupList.Length-1)

# New-ServiceNowSession -url $Connectid.ServiceNowUrl -Credential $ConnectIds['dev221285'].Credentials
$BaseURL = $Connectid.ServiceNowUrl
$Creds = $ConnectIds['dev221285'].Credentials
$User = $Creds.GetNetworkCredential().Username
$Pass = $Creds.GetNetworkCredential().Password
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $User, $Pass)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')

# Specify endpoint uri
$uri = "$BaseURL/api/now/table/sc_task"

# Specify HTTP method
$method = "post"

#SN Ticket Information
$ASSIGNMENT_GROUP = 'Identity and Access Management'
$SHORT_DESCRIPTION = 'New Application SSO'
$DESCRIPTION = 'Please configure SSO access for this new application.'
$COMMENTS = "<p>New SSO application identified, please configure SSO.<br>New Groups: $NewGroupsLong</p>"

# Specify request body
$body = "{`"opened_by`":`"readibots.service`",`"correlation_id`":`"created_from_module`",`"assignment_group`":`"$ASSIGNMENT_GROUP`",`"state`":`"1`",`"short_description`":`"$SHORT_DESCRIPTION`",`"description`":`"$DESCRIPTION`",`"work_notes`":`"[code]$COMMENTS[/code]`"}"

# Send HTTP request
$response = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri -Body $body

# note ticket number
$response.RawContent
$Ticket = $response.result.number
$Ticket
