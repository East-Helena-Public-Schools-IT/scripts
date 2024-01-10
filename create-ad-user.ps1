
# Read these as input
$FNAME=$null
$LNAME=$null
$GRADY=$null
# Calculate these later
$EMAIL=$null
$HOME_PATH=$null
$GROUPS = @()
$OU=$null
$CHANGE_PASSWORD_AT_LOGON=$null
$DESCRIPTION=""

function Set-GradYear() {
    Write-Host "Enter Graduation Year."
    $script:GRADY = Read-Host "YYYY"

    if ($GRADY.Length -ne 4) {
        Write-Host "Invalid format '$GRADY' Please use YYYY format."
        Set-GradYear
    }
}

function Set-Name() {
    $script:FNAME = Read-Host "First Name"
    $script:LNAME = Read-Host "Last Name"
    if ($LNAME.Length -eq 0 -or $FNAME.Length -eq 0) {
        Write-Host "One of the names was empty, try again."
        Set-Name
    }
}

function Set-Description() {
    Write-Host "What would you like the user's description to be?"
    $script:DESCRIPTION = Read-Host "Description"
}

function Get-AccountType() {
    Write-Host "Select what type of user you would like to create:
1) Teacher
2) Student
3) Non-Teaching Staff
"
    $ACCOUNTTYPE = Read-Host "Choice"
    Set-Name

    if ($ACCOUNTTYPE -match "1") {
        # Teacher
        $script:EMAIL=$FNAME[0]+$LNAME
        $script:HOME_PATH="\\ehps-fs3\teachers\$FNAME $LNAME"
        $script:GROUPS += "Teacher" 
        $script:GROUPS += "PSO_Teachers" 
        $script:GROUPS += "GCDS_StandardStaff" 
        $script:OU = "OU=Teachers"
        Set-Description
    }
    elseif ($ACCOUNTTYPE -match "2") {
        # Student
        Set-GradYear
        $script:EMAIL=$FNAME[0]+$LNAME+$GRADY[2]+$GRADY[3]
        $script:HOME_PATH="\\ehps-fs3\student\$GRADY\$LNAME$FNAME"
        $script:GROUPS += "Students"

        $YEAR=$null
        # Calculate school year
        if ([int]$(get-date -f MM) -gt 6) { $script:YEAR = $([int]$(get-date -f yyyy))+1 }
        else { $script:YEAR = get-date -f yyyy }

        # If student is > 3rd grade
        if ([int]$YEAR-[int]$GRADY+12 -gt 3) { $script:GROUPS += "GCDS_StandardStudent" }

        # This is a dumb way to do this, but it requires "less" boiler-plate than checking every date range
        $YTG = [int]$GRADY-[int]$YEAR
        $SCHOOLS = @("EHHS",   "EHHS",   "EHHS",  "EHHS",
                     "EVMS",   "EVMS",   "EVMS", 
                     "Radley", "Radley", "Radley",
                     "PPE",    "PPE",
                     "Eastgate", "Eastgate")
        $script:OU = "OU=$GRADY,OU=$($SCHOOLS[[int]$YTG]),OU=Students"
        $script:DESCRIPTION=$GRADY
    }
    elseif ($ACCOUNTTYPE -match "3") {
        # Non-teaching staff
        $script:EMAIL=$FNAME[0]+$LNAME
        $script:HOME_PATH="\\ehps-fs3\student\Classified Staff\"
        $script:GROUPS += "PSO_SupportStaff" 
        $script:GROUPS += "GCDS_StandardStaff" 
        $script:OU = "OU=Support Staff"
        Set-Description
    }
    else {
        Write-Host "Invalid option '$ACCOUNTTYPE'"
        Get-AccountType
    }
}

Get-AccountType

$CNG_PASS_RESPONSE = Read-host "Should user change password at next logon? [y/N]"
if ($CNG_PASS_RESPONSE -match "(y|Y)") { $script:CHANGE_PASSWORD_AT_LOGON=$true }
else { $script:CHANGE_PASSWORD_AT_LOGON=$false }

$tmpsam = $($EMAIL -replace '[^a-zA-Z0-9\.]', '')

New-ADUser -HomeDrive "T:" `
    -HomeDirectory $HOME_PATH  `
    -UserPrincipalName "$EMAIL@ehps.com" `
    -sAMAccountName $(if ($tmpsam.Length -gt 20) { $tmpsam.Substring(0, 20) } else { $tmpsam }) `
    -GivenName $FNAME `
    -Surname $LNAME `
    -Name $("$FNAME $LNAME" -replace '[^a-zA-Z0-9\. ]', '') `
    -Description $DESCRIPTION `
    -EmailAddress "$EMAIL@ehps.k12.mt.us" `
    -ScriptPath "logon.bat" `
    -Path "$OU,DC=ehps,DC=com" `
    -Enabled $true `
    -ChangePasswordAtLogon $CHANGE_PASSWORD_AT_LOGON `
    -AccountPassword (Read-Host -AsSecureString "Password") `
    -PassThru |
    ForEach-Object {
        ForEach ($G in $GROUPS) {
            Add-ADGroupMember -Identity $G -Members $_
        }
    }

Write-Host "Done, you need to do any changes to the password manually."