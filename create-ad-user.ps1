
# Read these as input
$FNAME=$null
$LNAME=$null
$GRADY=$null
# Calculate these later
$EMAIL=$null
$IS_TEACHER=$null
$HOME_PATH=$null
$GROUPS = @()
# Maybe options:
# -ChangePasswordAtLogon $true
# -AccountPassword SecureString
# TODO:
# OUs

function Set-GradYear() {
    Write-Output "Enter Graduation Year. If this is a teacher, just press enter."
    $script:GRADY = Read-Host "YYYY"

    if ($GRADY.Length -eq 0) {
        Write-Output "Creating Teacher..."
        $script:IS_TEACHER = $true
        return
    } else { $script:IS_TEACHER = $false }
    if ($GRADY.Length -gt 4 -or $GRADY.Length -lt 4) {
        Write-Output "Please use YYYY format."
        Set-GradYear
    }
}

function Set-Name() {
    Write-Output "Enter Name:"
    $script:FNAME = Read-Host "First Name"
    $script:LNAME = Read-Host "Last Name"
    if ($LNAME.Length -eq 0 -or $FNAME.Length -eq 0) {
        Write-Output "One of the names was empty, try again."
        Set-Name
    }
}

Set-Name
Set-GradYear

if ($IS_TEACHER) {
    # Teacher
    $script:EMAIL=$FNAME[0]+$LNAME
    $script:HOME_PATH="\\ehps-fs3\teachers\$FNAME $LNAME"
    $script:GROUPS += "Teacher" 
    $script:GROUPS += "PSO_Teachers" 
    $script:GROUPS += "GCDS_StandardStaff" 
} else {
    # Student
    $script:EMAIL=$FNAME[0]+$LNAME+$GRADY[2]+$GRADY[3]
    $script:HOME_PATH="\\ehps-fs3\student\$GRADY\$LNAME$FNAME"
    $script:GROUPS += "Students"

    # Calculate student's year
    get-date -f yyyy
    # only if 4+
    $STUDENT_GROUPS += "GCDS_StandardStudent"
}

New-ADUser -HomeDrive "T:" `
    -HomeDirectory $HOME_PATH  `
    -UserPrincipalName "$EMAIL@ehps.com" `
    -GivenName $FNAME `
    -Surname $LNAME `
    -EmailAddress "$EMAIL@ehps.k12.mt.us" `
    -ScriptPath "logon.bat" `
    -Path "OU=,DC=ehps,DC=com" `
    -PassThru |
    ForEach-Object {
        ForEach ($G in $GROUPS) {
            Add-ADGroupMember -Identity $G -Members $_
        }
    }
