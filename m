From: Christopher Huhn <C.Huhn@gsi.de>
Subject: /etc/eports and CNAME
Date: Wed, 03 Dec 2003 09:26:12 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FCD9E24.8020404@gsi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARSLd-00040S-9z
	for nfs@lists.sourceforge.net; Wed, 03 Dec 2003 00:27:01 -0800
Received: from lxmta2.gsi.de ([140.181.67.43])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARSLc-0004My-R1
	for nfs@lists.sourceforge.net; Wed, 03 Dec 2003 00:27:01 -0800
Received: from localhost (localhost [127.0.0.1])
	by lxmta2.gsi.de (Postfix) with ESMTP id 092A619272A
	for <nfs@lists.sourceforge.net>; Wed,  3 Dec 2003 09:26:39 +0100 (CET)
Received: from lxmta2.gsi.de ([127.0.0.1])
	by localhost (lxmta2 [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 03506-48 for <nfs@lists.sourceforge.net>;
	Wed, 3 Dec 2003 09:26:35 +0100 (CET)
Received: from gsi.de (lxg0815.gsi.de [140.181.70.60])
	by lxmta2.gsi.de (Postfix) with ESMTP id A6FAE192728
	for <nfs@lists.sourceforge.net>; Wed,  3 Dec 2003 09:26:14 +0100 (CET)
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
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

Hi,

I have a quite silly question:

I have a host with a DNS A record "realname" and an alias (CNAME) "xyz0123".

A /etc/exports like:

/mountpoint   xyz*

does not export to "realname" by default.

Is there a possibility to get this working?

Regards,

    Christopher



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
