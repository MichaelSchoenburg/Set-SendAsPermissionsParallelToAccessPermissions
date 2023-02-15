Clear-Host
$Mbxs = Get-Mailbox
foreach ($mbx in $Mbxs) {
    if ( ( $ReadPerms = ( Get-MailboxPermission -Identity $mbx.Alias ).where( { ( $_.User -ne "NT AUTHORITY\SELF" ) -and ( $_.User -notlike "admin*" ) } ) ).Count -gt 0 ) {
        Write-Host -ForegroundColor Cyan "Processing $( $mbx.PrimarySmtpAddress )..."
        $SendPerms = Get-RecipientPermission -Identity $mbx.Alias
        foreach ($readPerm in $ReadPerms.User) {
            if ( $SendPerms.Trustee -notcontains $readPerm ) {
                Write-Host -ForegroundColor Yellow "Missing send as permission for $( $readPerm ). Adding permission..."
                Add-RecipientPermission -Identity $mbx -Trustee $readPerm -AccessRights SendAs -Confirm:$false
            }
        }
    } else {
        Write-Host -ForegroundColor Cyan "Skipping $( $mbx.PrimarySmtpAddress )..."
    }
}
