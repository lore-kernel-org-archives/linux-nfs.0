From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 2 - BKL is missing in once place in knfsd
Date: Mon, 28 Jul 2003 16:56:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19h1vW-0002qc-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19h1vh-0006wO-00
	for <nfs@lists.sourceforge.net>; Sun, 27 Jul 2003 23:56:22 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Mon, 28 Jul 2003 16:56:11 +1000
To: Marcelo Tosatti <marcelo@conectiva.com.br>
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


Knfsd still uses the BKL in many places, and the 
exp_*lock() routines for locking the export table depend on it.
However reading /proc/fs/nfs/exports uses those locks without 
first grabing the BKL.

This patch is reported to fix a hang that was being experienced on
an SMP nfs server on which /proc/fs/nfs/exports was being
read frequently.

(patch against 2.4.22-pre9)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-07-28 16:22:15.000000000 +1000
+++ ./fs/nfsd/export.c	2003-07-28 16:22:15.000000000 +1000
@@ -19,6 +19,7 @@
 #include <linux/stat.h>
 #include <linux/in.h>
 #include <linux/seq_file.h>
+#include <linux/smp_lock.h>
 
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
@@ -571,6 +572,7 @@ static void *e_start(struct seq_file *m,
 	svc_client *clp;
 	struct list_head *p;
 	
+	lock_kernel();
 	exp_readlock();
 	if (!n--)
 		return (void *)1;
@@ -622,6 +624,7 @@ static void *e_next(struct seq_file *m, 
 static void e_stop(struct seq_file *m, void *p)
 {
 	exp_unlock();
+	unlock_kernel();
 }
 
 struct flags {


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
