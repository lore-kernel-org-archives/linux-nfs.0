From: M A Young <m.a.young@durham.ac.uk>
Subject: NFS client fcntl locks going missing on FC6
Date: Fri, 23 Feb 2007 23:16:08 +0000 (GMT)
Message-ID: <Pine.LNX.4.58.0702232223170.24593@vega3.dur.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HKjeN-0006t9-57
	for nfs@lists.sourceforge.net; Fri, 23 Feb 2007 15:16:29 -0800
Received: from hermes1.dur.ac.uk ([129.234.8.20])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HKjeO-00050I-OE
	for nfs@lists.sourceforge.net; Fri, 23 Feb 2007 15:16:29 -0800
Received: from smtphost4.dur.ac.uk (smtphost4.dur.ac.uk [129.234.4.18])
	by hermes1.dur.ac.uk (8.13.8/8.13.7) with ESMTP id l1NNGAXr009082
	for <nfs@lists.sourceforge.net>; Fri, 23 Feb 2007 23:16:14 GMT
Received: from vega3.dur.ac.uk (vega3.dur.ac.uk [129.234.4.206])
	by smtphost4.dur.ac.uk (8.13.7/8.11.7) with ESMTP id l1NNG9Af026415
	(using TLSv1/SSLv3 with cipher DHE-RSA-AES256-SHA (256 bits) verified
	NO) for <nfs@lists.sourceforge.net>; Fri, 23 Feb 2007 23:16:09 GMT
Received: from vega3.dur.ac.uk (localhost [127.0.0.1])
	by vega3.dur.ac.uk (8.13.8/8.11.1) with ESMTP id l1NNG9cZ025741
	for <nfs@lists.sourceforge.net>; Fri, 23 Feb 2007 23:16:09 GMT
Received: from localhost (dcl0may@localhost)
	by vega3.dur.ac.uk (8.13.8/8.13.8/Submit) with ESMTP id l1NNG8DI025738
	for <nfs@lists.sourceforge.net>; Fri, 23 Feb 2007 23:16:09 GMT
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

We have been having problems of files getting mysteriously locked on a
linux NFS client to a Netapp NFS server (most recently with the
kernel-2.6.19-1.2911.fc6 package, and ONTAP 7.0.5), and after some
investigation it seems that the problem is that the linux box is getting a
lock but not recording it, with the result that the lock is never removed
from the NetApp server. I reported this in RedHat's bugzilla
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=229469
and haven't heard anything from them, but it is possible that it is more
general than just a RedHat issue.
I have found a way to reproduce the locks being left on the server which
seems to occur when an attempt to lock a file is cancelled and a second
attempt to lock the file immediately afterwards succeeds, which results in
the server locking the file but not the client, and thus the lock never
being removed from the server.
My test program to reproduce the bug is attached to the RedHat bug report
at https://bugzilla.redhat.com/bugzilla/attachment.cgi?id=148693 which can
be done by running the program twice concurrently from an NFS mount.
Is this a known bug and is it easy to fix?

	Michael Young

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
