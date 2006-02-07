From: Daniel Bramkamp <bramkamp@team-datentechnik.de>
Subject: RE: Permission denied
Date: Tue, 07 Feb 2006 14:04:08 +0100
Message-ID: <20060207140408.nhfp0qhukggs84ck@linux-smb.molly>
References: <011401c62bdc$f8f03890$0700a8c0@muelleimer>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-15;
	format="flowed"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F6SW4-0003gl-HV
	for nfs@lists.sourceforge.net; Tue, 07 Feb 2006 05:04:20 -0800
Received: from natblindhugh.rzone.de ([81.169.145.175])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F6SW3-0007SV-9O
	for nfs@lists.sourceforge.net; Tue, 07 Feb 2006 05:04:20 -0800
Received: from linux-smb.molly ([85.8.92.16])
	by post.webmailer.de (8.13.1/8.13.1) with ESMTP id k17D4AMo020353
	for <nfs@lists.sourceforge.net>; Tue, 7 Feb 2006 14:04:11 +0100 (MET)
Received: from localhost (localhost [127.0.0.1])
	by linux-smb.molly (Postfix) with ESMTP id C565A450CF
	for <nfs@lists.sourceforge.net>; Tue,  7 Feb 2006 14:04:08 +0100 (CET)
Received: from linux-smb.molly ([127.0.0.1])
 by localhost (linux-smb.molly [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 20248-19 for <nfs@lists.sourceforge.net>;
 Tue,  7 Feb 2006 14:04:08 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <011401c62bdc$f8f03890$0700a8c0@muelleimer>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Quoting Tradebit Service <info@tradebit.com>:

>
>> great, however, sometimes access to files and directories
>> stored on the server is denied for a certain user account. I
>> am not sure if it affects other users as well - only heard
>> complaints from that particular user so far.
>
> daniel,

Hi Ralf,

thanks for your reply.

> just a wild guess: did you compare the user IDs in /etc/shadow
> on both systems?

sorry, I should have added this to my orginal post. The user accounts 
are managed via LDAP. UIDs start at 10000 and they do not overlap with 
system accounts. Also, when the problem arises, access to all NFS 
shares is denied, not just a single directory or file.

-- 
Daniel Bramkamp

team! datentechnik GmbH & Co.KG
Werner von Siemens Stra=DFe 12a
49124 Georgsmarienh=FCtte
Tel.: 05401-8226-0
Fax : 05401-8226-20
eMail: bramkamp@team-datentechnik.de


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
