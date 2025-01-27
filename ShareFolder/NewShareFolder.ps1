#By default the dequeued item(s) contains only the data that was added to the queue.
#To include the entire READIMessage in the dequeued item(s),
#check the "Provide full ReadiMessage" option under the "General" tab.

#$READIQItem     #the first dequeued item

   $READIQItems | foreach-object {
        $_      #a dequeued item
        $PreProposedName = $_.pre_proposed_name
        Try{
        # specify root folder
        $RootFolder = "C:\NAS"

        # Check for and create new folder
        $DirItems = Get-ChildItem -Path "$RootFolder"
        $ExistingFolders = $DirItems.Name
        $LongProposedName = $PreProposedName -replace '[^a-zA-Z0-9]', '_'

        # Foldername cannot exceed 40 characters
        If($LongProposedName.Length -gt 40){
            $ProposedName = $LongProposedName.Substring(0,40)
        }
        Else{
            $ProposedName = $LongProposedName
        }

        # Foldername cannont already exist
        If($ProposedName -in $ExistingFolders){
            $ValidChar = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
            $UniversalID = $null
            $Counter = 0

            Do{
                $RandomChar = Get-Random -Minimum 0 -Maximum $ValidChar.Length
                $UniversalID += $ValidChar[$RandomChar]
                $Counter++
            }
            Until($Counter -ge 3)

            $Append = $UniversalID

            $FolderName = $ProposedName + "-DUP-" + $Append
        }
        Else{
            $FolderName = $ProposedName
        }

        $CreateDirResult = New-Item -Path "$RootFolder" -Name "$FolderName" -ItemType "directory"

        $NewDirName = $CreateDirResult.Name

        # Create AD Groups and set ACL
        $DefaultRoles = @('RO', 'RW')

        ForEach($DefaultRole in $DefaultRoles){

            switch ( $DefaultRole )
            {
                "RO" { $Permission = "ReadAndExecute" }
                "RW" { $Permission = "Modify" }
            }

            $NextGroup = "SHR-NAS_" + "$NewDirName" + "-$DefaultRole"
            New-ADGroup -Name $NextGroup -SamAccountName $NextGroup -GroupCategory Security -GroupScope Global -Path "OU=MyGroups,DC=genericco,DC=com" -Description "$RootFolder\$NewDirName" -OtherAttributes @{'Info'="$Permission permissions on $RootFolder\$NewDirName"}
            
            # Configure ACL
            $Acl = Get-Acl -Path "$RootFolder\$NewDirName"
            $Acl.SetAccessRuleProtection($False, $False)
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("genericco.com\$NextGroup","$Permission","ContainerInherit, ObjectInherit","None","Allow")
            $Acl.AddAccessRule($AccessRule)
            $Acl | Set-Acl "$RootFolder\$NewDirName"

        }

        $NewDirName
        
        }
        Catch{
            $_
        }

   }
