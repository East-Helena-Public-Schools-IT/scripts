
# Read these as input
$FNAME=$null
$LNAME=$null
$GRADY=$null
# Calculate these later
$EMAIL=$null
$IS_TEACHER=$null
$HOME_PATH=$null
$GROUPS = @()
$OU=$null
$CHANGE_PASSWORD_AT_LOGON=$null

function Set-GradYear() {
    Write-Host "Enter Graduation Year. If this is a teacher, just press enter."
    $script:GRADY = Read-Host "YYYY"

    if ($GRADY.Length -eq 0) {
        Write-Host "Creating Teacher..."
        $script:IS_TEACHER = $true
        return
    } else { $script:IS_TEACHER = $false }
    if ($GRADY.Length -ne 4) {
        Write-Host "Please use YYYY format."
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

Set-Name
Set-GradYear

$CNG_PASS_RESPONSE = Read-host "Should user change password at next logon? [y/N]"
if ($CNG_PASS_RESPONSE -match "(y|Y)") { $script:CHANGE_PASSWORD_AT_LOGON=$true }
else { $script:CHANGE_PASSWORD_AT_LOGON=$false }

if ($IS_TEACHER) {
    # Teacher
    $script:EMAIL=$FNAME[0]+$LNAME
    $script:HOME_PATH="\\ehps-fs3\teachers\$FNAME $LNAME"
    $script:GROUPS += "Teacher" 
    $script:GROUPS += "PSO_Teachers" 
    $script:GROUPS += "GCDS_StandardStaff" 
    $script:OU = "OU=Teachers"
} else {
    # Student
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
}
# TODO this name cannot be longer than 20 char combined when going in the -Name field. Shorted then
$CONCAT_NAME=$($LNAME+$FNAME) -replace '[^a-zA-Z0-9\.]', ''

New-ADUser -HomeDrive "T:" `
    -HomeDirectory $HOME_PATH  `
    -UserPrincipalName "$EMAIL@ehps.com" `
    -GivenName $FNAME `
    -Surname $LNAME `
    -Name $CONCAT_NAME `
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