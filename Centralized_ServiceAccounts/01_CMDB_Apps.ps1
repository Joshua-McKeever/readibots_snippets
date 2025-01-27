# query ServiceNow CMDB and get a list of application CI
# New-ServiceNowSession -url $Connectid.ServiceNowUrl -Credential $ConnectIds['dev221285'].Credentials
$BaseURL = $Connectid.ServiceNowUrl
$Creds = $ConnectIds['dev221285'].Credentials
$User = $Creds.GetNetworkCredential().Username
$Pass = $Creds.GetNetworkCredential().Password
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $User, $Pass)))

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')

$ReportURI = "$BaseURL/sys_report_template.do?CSV&jvar_report_id=b4cdacb397afb11041ba3b90f053afd6"
$Response = Invoke-RestMethod -Uri $ReportURI -Headers $Headers
$Rows = $Response | ConvertFrom-Csv
$Rows
