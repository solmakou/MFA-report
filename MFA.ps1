#MFA - Requires MSOnline module as well as a connection to AAD (Connect-MsolService)
    #Get them users that are licensed and not guests.
    $ExportFile = "c:\temp\MFAUsers.csv"
    $Users = Get-MsolUser -all -EnabledFilter EnabledOnly | 
        Where-Object { $_.UserType -ne "Guest" -and $_.IsLicensed -eq $true}
    #Start that report
    $Report = [System.Collections.Generic.List[Object]]::new()

    ForEach ($User in $Users){
        #find them variables
        $MFAMethodType = $User.StrongAuthenticationMethods.MethodType
        $DefaultMFAMethod = ($User.StrongAuthenticationMethods | 
            where-object {$User.StrongAuthenticationMethods.IsDefault -eq "True"}).MethodType
        $MFAState = $User.StrongAuthenticationRequirements.State
        $MFAEmail = $User.StrongAuthenticationUserDetails.Email
        $MFAPhoneNumber = $User.StrongAuthenticationUserDetails.PhoneNumber
        $MFADeviceName = $User.StrongAuthenticationPhoneAppDetails.DeviceName
        $MFADeviceTag = $User.StrongAuthenticationPhoneAppDetails.DeviceTag
        $MFADeviceToken = $User.StrongAuthenticationPhoneAppDetails.DeviceToken
        $MFANotificationType = $User.StrongAuthenticationPhoneAppDetails.NotificationType
        $MFAPhoneAppVersion = $User.StrongAuthenticationPhoneAppDetails.PhoneAppVersion
        $MFAStatus = $User.StrongAuthenticationRequirements.State

        #Populate them variables for the report -join for fields with multiple results
        $ReportLine = [PSCustomObject] @{
            User = $User.UserPrincipalName
            MFAStatus = $MFAStatus
            Name = $User.DisplayName
            Office = $User.Office
            MFAEmail = $MFAEmail
            MFAUsed = $MFAEnforced
            MFAMethodType = $MFAMethodType -join ","
            MFAState = $MFAState
            MFAPhoneNumber = $MFAPhoneNumber
            MFADeviceName = $MFADeviceName -join ","
            MFADeviceTag = $MFADeviceTag -join ","
            MFADeviceToken = $MFADeviceToken -join ","
            MFANotificationType = $MFANotificationType -join ","
            MFAPhoneAppVersion = $MFAPhoneAppVersion -join ","
            DefaultMFAMethod = $DefaultMFAMethod -join ","
        }
        $Report.Add($ReportLine)
    }
    #export that csv
    $Report | 
        Select-Object Name, User, DefaultMFAMethod, MFAMethodType, MFAState, MFAPhoneNumber, Office, MFAStatus, MFADeviceName, MFAEmail, MFAUsed, MFADeviceTag, MFADeviceToken, MFANotificationType, MFAPhoneAppVersion | 
        Sort-Object Name | 
        Export-CSV -NoTypeInformation $ExportFile