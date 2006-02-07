From: Daniel Bramkamp <bramkamp@team-datentechnik.de>
Subject: Permission denied
Date: Tue, 07 Feb 2006 12:34:48 +0100
Message-ID: <20060207123448.pqv165xvwosgk0g8@linux-smb.molly>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-15;
	format="flowed"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F6R7Z-0005Yc-Sc
	for nfs@lists.sourceforge.net; Tue, 07 Feb 2006 03:34:57 -0800
Received: from natfrord.rzone.de ([81.169.145.161])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F6R7Y-0007Ol-CX
	for nfs@lists.sourceforge.net; Tue, 07 Feb 2006 03:34:57 -0800
Received: from linux-smb.molly ([85.8.92.16])
	by post.webmailer.de (8.13.1/8.13.1) with ESMTP id k17BYoTm024187
	for <nfs@lists.sourceforge.net>; Tue, 7 Feb 2006 12:34:52 +0100 (MET)
Received: from localhost (localhost [127.0.0.1])
	by linux-smb.molly (Postfix) with ESMTP id 2F45544F00
	for <nfs@lists.sourceforge.net>; Tue,  7 Feb 2006 12:34:49 +0100 (CET)
Received: from linux-smb.molly ([127.0.0.1])
 by localhost (linux-smb.molly [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 26011-04 for <nfs@lists.sourceforge.net>;
 Tue,  7 Feb 2006 12:34:48 +0100 (CET)
To: nfs@lists.sourceforge.net
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

Hi list,

I am experiencing some issues with a NFS server running on Linux Kernel 
2.4.26 with nfs-utils-1.0.6 installed. Basically it works great, 
however, sometimes access to files and directories stored on the server 
is denied for a certain user account. I am not sure if it affects other 
users as well - only heard complaints from that particular user so far. 
This happens very infrequently. They mainly use KDE's Konqueror to 
access the NFS shares but the problem affects Gnome's Nautilus and the 
KDE konsole as well. Any ideas what could cause this weird behaviour ?

TIA
-- 
Daniel Bramkamp


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
