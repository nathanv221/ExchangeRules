$ruleName = "ASCII Chars Only"
$ruleHtml = "<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 align=left width=`"100%`" style='width:100.0%;mso-cellspacing:0cm;mso-yfti-tbllook:1184; mso-table-lspace:2.25pt;mso-table-rspace:2.25pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-left:left;mso-padding-alt:0cm 0cm 0cm 0cm'>  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'><td style='background:#910A19;padding:5.25pt 1.5pt 5.25pt 1.5pt'></td><td width=`"100%`" style='width:100.0%;background:#FDF2F4;padding:5.25pt 3.75pt 5.25pt 11.25pt; word-wrap:break-word' cellpadding=`"7px 5px 7px 15px`" color=`"#212121`"><div><p class=MsoNormal style='mso-element:frame;mso-element-frame-hspace:2.25pt; mso-element-wrap:around;mso-element-anchor-vertical:paragraph;mso-element-anchor-horizontal: column;mso-height-rule:exactly'><span style='font-size:9.0pt;font-family: `"Segoe UI`",sans-serif;mso-fareast-font-family:`"Times New Roman`";color:#212121'> The origin of this email contains non-English characters.  This is common among scammers pretending to be someone else.  Unless you expect the sender to be speaking a language other than English, please do not click links or open attachments. <o:p></o:p></span></p></div></td></tr></table>"
$unacceptablechars = "(\wn--)|([^^[a-zA-Z0-9-_+\.]+@[a-zA-Z0-9-]+\.[a-zA-Z\.]+$\s])"
 

foreach($user in Get-Content C:\Scripts\admins.txt){
    Connect-ExchangeOnline -UserPrincipalName $user -ShowProgress $true
    Write-Host "Getting the Exchange Online cmdlets" -ForegroundColor Yellow
    $rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName}

    if (!$rule) {
        Write-Host "Rule not found, creating rule" -ForegroundColor Green
        New-TransportRule -Name $ruleName -Priority 0 -ApplyHtmlDisclaimerLocation "Prepend" `
        -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $unacceptablechars -ApplyHtmlDisclaimerText $ruleHtml
    }
    else {
        Write-Host "Rule found, updating rule" -ForegroundColor Green
        Set-TransportRule -Identity $ruleName -Priority 0 -FromScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Prepend" `
        -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $unacceptablechars -ApplyHtmlDisclaimerText $ruleHtml
    }
    Disconnect-ExchangeOnline -Confirm:$false
}