From: "Gomez, Daniel" <dgomez@tigr.ORG>
Subject: RE: Setting up NFS on Windows
Date: Fri, 19 Aug 2005 13:41:36 -0400
Message-ID: <7F0AA25C9B1706448E8B73DFDD109B31017DEA9C@EXCHANGE.TIGR.ORG>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E6AsC-0002fe-Ry
	for nfs@lists.sourceforge.net; Fri, 19 Aug 2005 10:41:44 -0700
Received: from ranger.tigr.org ([192.207.234.252])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1E6AsB-0004e2-KA
	for nfs@lists.sourceforge.net; Fri, 19 Aug 2005 10:41:45 -0700
Received: from EXCHANGE.TIGR.ORG (exch1n [172.17.5.22])
	by ranger.tigr.org (8.13.0/8.13.0/Submit) with ESMTP id j7JHfakV024265
	for <nfs@lists.sourceforge.net>; Fri, 19 Aug 2005 13:41:36 -0400 (EDT)
To: <nfs@lists.sourceforge.net>
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


1. It is free.
Download Microsoft's SFU service
http://www.microsoft.com/technet/interopmigration/unix/sfu/sfu35int.mspx

2. somewhat - it's easier if you just use local passwd/group files.

I personally copied /etc/passwd /etc/group files from my linux
environment to my local windows box to make the UID mapping between our
unix environment and our windows environment. If you want something more
domain wide, either use the other mapping services as explained in SFU
OR expose your passwd/group file on say the netlogin domain shared
folder.

3. dunno aside from what's in the SFU software and on Microsoft's site.
Another useful config page.
http://www.microsoft.com/technet/interopmigration/unix/sfu/perfnfs.mspx


-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Vijaya Kishore
Idimadakala
Sent: Friday, August 19, 2005 12:44 PM
To: nfs@lists.sourceforge.net
Subject: [NFS] Setting up NFS on Windows


Hey All,

I have a few questions wrt installing NFS server on
Windows XP (Client=3D a board running Linux).

1. Is it Free?
2. Is it easy to install/use=20
3. are there any good tutorials on installation/usage?

Any help is greatly appreciated.

Thanks in advance and have a wonderful day,
Vijay



	=09
____________________________________________________
Start your day with Yahoo! - make it your home page=20
http://www.yahoo.com/r/hs=20
=20


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle
Practices Agile & Plan-Driven Development * Managing Projects & Teams *
Testing & QA Security * Process Improvement & Measurement *
http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
