Write-Output "PowerShell Timer trigger function executed at:$(get-date)";
 
$ruleName = "Block HTML Files"
s#$replyText = "Your message was not delivered. This message appears to have harmful content. If you did not send it, change your password."
#$notifyText = "Hi,<br> Somebody has sent you a message that appears to be a scam. We have blocked the message from getting through due to its seemingly harmful nature. If this is a message that you are expecting, please contact us at helpdesk@itguys.net. Otherwise, just sit back and relax. <br> The message was sent by: %%From%% <br> Subject: %%Subject%% <br> sent at %%MessageDate%% <br> If you are getting too many of these notification messages, please let us know!"
$fileType = "html", "htm", "php"
$ruleHtml = "<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 align=left width=`"100%`" style='width:100.0%;mso-cellspacing:0cm;mso-yfti-tbllook:1184; mso-table-lspace:2.25pt;mso-table-rspace:2.25pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-left:left;mso-padding-alt:0cm 0cm 0cm 0cm'>  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'><td style='background:#E98214;padding:5.25pt 1.5pt 5.25pt 1.5pt'></td><td width=`"100%`" style='width:100.0%;background:#e98214;padding:5.25pt 3.75pt 5.25pt 11.25pt; word-wrap:break-word' cellpadding=`"7px 5px 7px 15px`" color=`"#212121`"><div><p class=MsoNormal style='mso-element:frame;mso-element-frame-hspace:2.25pt; mso-element-wrap:around;mso-element-anchor-vertical:paragraph;mso-element-anchor-horizontal: column;mso-height-rule:exactly'><span style='font-size:14.0pt;font-family: `"Segoe UI`",sans-serif;mso-fareast-font-family:`"Times New Roman`";color:#212121'>This message contains an attachment type that is often used for scams. Please do not click links or open attachments unless you recognize the source of this email and know the content is safe. <o:p></o:p></span></p></div></td></tr></table>"
$whitelist = "lists.trialsmith.com", "taylorbusinessproducts.com", "dconc.gov", "rhfs.com", "trialsmith.com"


foreach($user in Get-Content C:\Scripts\admins.txt){

    Connect-ExchangeOnline -UserPrincipalName $user -ShowProgress $true

    Write-Output "Getting the Exchange Online cmdlets"

    $rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName}
    #$displayNames = (Get-Mailbox -ResultSize Unlimited).DisplayName

    if (!$rule) {
        Write-Output "Rule not found, creating rule"
        New-TransportRule -Name $ruleName -Priority 1 -FromScope "NotInOrganization" -AttachmentExtensionMatchesWords $fileType -ApplyHtmlDisclaimerLocation "Prepend" `
            -blindcopyto "noreply@itguys.net" -ApplyHtmlDisclaimerText $ruleHtml -ExceptIfRecipientDomainIs $whitelist
    }
    else {
        Write-Output "Rule found, updating rule"
        remove-transportrule -Identity $ruleName -Confirm:$false
        New-TransportRule -Name $ruleName -Priority 1 -FromScope "NotInOrganization" -AttachmentExtensionMatchesWords $fileType -ApplyHtmlDisclaimerLocation "Prepend" `
        -blindcopyto "noreply@itguys.net" -ApplyHtmlDisclaimerText $ruleHtml -ExceptIfRecipientDomainIs $whitelist
    }
    Disconnect-ExchangeOnline -Confirm:$false
}

