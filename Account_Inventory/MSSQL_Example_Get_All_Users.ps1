$Results = Invoke-Sqlcmd "Select * From [General].[dbo].[Employee] Where ([JobEnd] is null or [JobEnd] > DateAdd(year,-2,GetDate()))"
$Results
