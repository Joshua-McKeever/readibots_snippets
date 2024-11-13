$Creds = $ConnectIds['MongoDB'].Credentials
$Pass = $Creds.GetNetworkCredential().Password

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Access-Control-Request-Headers", "*")
$headers.Add("api-key", "$Pass")

$body = @"
{
      `"dataSource`": `"VPSlogs`",
      `"database`": `"SourceOfTruth`",
      `"collection`": `"Employee`"
  }
"@

$response = Invoke-RestMethod 'https://us-east-2.aws.data.mongodb-api.com/app/data-pvnjd/endpoint/data/v1/action/find' -Method 'POST' -Headers $headers -Body $body
$results = $response.documents | ConvertTo-Json | ConvertFrom-Json
$results
