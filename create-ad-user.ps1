
# Read these as input
FNAME="Frodo"
LNAME="Baggy Pants"
GRADY="1234"
EMAIL=$FNAME[0]$LNAME$GRADY[2]$GRADY[3]
# Maybe options:
# -ChangePasswordAtLogon $true
# -AccountPassword SecureString
# TODO:
# OUs
# Groups
# Student vs Teacher logic branches

New-ADUser -HomeDrive "T:" -HomeDirectory "\\ehps-fs3\student\$GRADY\$LNAME$FNAME" -UserPrincipalName "$EMAIL@ehps.com" -GivenName $FNAME -Surname $LNAME -EmailAddress "$EMAIL@ehps.k12.mt.us" -ScriptPath "logon.bat"