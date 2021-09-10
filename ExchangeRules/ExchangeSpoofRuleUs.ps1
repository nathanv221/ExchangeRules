Write-Output "PowerShell Timer trigger function executed at:$(get-date)";
 
$ruleName = "External Senders with matching Display Names"
$ruleHtml = "<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 align=left width=`"100%`" style='width:100.0%;mso-cellspacing:0cm;mso-yfti-tbllook:1184; mso-table-lspace:2.25pt;mso-table-rspace:2.25pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-left:left;mso-padding-alt:0cm 0cm 0cm 0cm'>  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'><td style='background:#d90f25;padding:5.25pt 1.5pt 5.25pt 1.5pt'></td><td width=`"100%`" style='width:100.0%;background:#d02040;padding:5.25pt 3.75pt 5.25pt 11.25pt; word-wrap:break-word' cellpadding=`"7px 5px 7px 15px`" color=`"#212121`"><div><p class=MsoNormal style='mso-element:frame;mso-element-frame-hspace:2.25pt; mso-element-wrap:around;mso-element-anchor-vertical:paragraph;mso-element-anchor-horizontal: column;mso-height-rule:exactly'><span style='font-size:14.0pt;font-family: `"Segoe UI`",sans-serif;mso-fareast-font-family:`"Times New Roman`";color:#212121'>This message was sent from outside the company by someone with a display name matching a user in your organization. Please do not click links or open attachments unless you recognize the source of this email and know the content is safe. <o:p></o:p></span></p></div></td></tr></table>"


foreach($user in Get-Content C:\Scripts\admins.txt){

    Connect-ExchangeOnline -UserPrincipalName $user -ShowProgress $true

    Write-Output "Getting the Exchange Online cmdlets"

    $rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName}
    $displayNames = (Get-Mailbox -ResultSize Unlimited | Where-Object{$_.DisplayName -ne 'info' -and $_.DisplayName -ne 'helpdesk' `
    -and $_.DisplayName -ne 'noreply' -and $_.DisplayName -ne 'no reply' -and $_.DisplayName -ne 'marketing' -and $_.DisplayName -ne 'intern' `
    -and $_.DisplayName -ne 'admin' -and $_.DisplayName -ne 'accounting' -and $_.DisplayName -ne 'bookkeeper' -and $_.DisplayName -ne 'book keeper'}).DisplayName

    if (!$rule) {
        Write-Output "Rule not found, creating rule"
        New-TransportRule -Name $ruleName -Priority 0 -FromScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Prepend" `
            -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $displayNames -ApplyHtmlDisclaimerText $ruleHtml
    }
    else {
        Write-Output "Rule found, updating rule"
        remove-transportrule -Identity $ruleName -Confirm:$false #yes, we have to remove the whole rule. simply setting won't remove names added to the common list
        New-TransportRule -Name $ruleName -Priority 0 -FromScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Prepend" `
            -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $displayNames -ApplyHtmlDisclaimerText $ruleHtml
    }
    Disconnect-ExchangeOnline -Confirm:$false
}
