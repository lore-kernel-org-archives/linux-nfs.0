From: Mark Hemment <markhe@veritas.com>
Subject: Lock client list while detaching locks
Date: Thu, 31 Jul 2003 20:18:13 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0307312014470.1062-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from brooklyn-bridge.emea.veritas.com ([62.172.234.2] helo=localhost.localdomain)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19iIvp-0000bR-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Jul 2003 12:17:46 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

  Patch against 2.4.21-pre9.

Mark

diff -urN linux-2.4.21-pre9/fs/nfsd/export.c nlmdetach/fs/nfsd/export.c
--- linux-2.4.21-pre9/fs/nfsd/export.c	2003-07-31 20:49:28.000000000 +0100
+++ nlmdetach/fs/nfsd/export.c	2003-07-31 21:08:56.000000000 +0100
@@ -903,8 +903,10 @@
 {
 	struct svc_client	*clp;

+	exp_readlock();
 	for (clp = clients; clp; clp = clp->cl_next)
 		nfsd_lockd_unexport(clp);
+	exp_unlock();
 }

 /*



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
