From: Mark Hemment <markhe@veritas.com>
Subject: [PATCH] reply-cache - RC_DELAY
Date: Mon, 18 Aug 2003 14:16:49 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0308181412430.1203-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bay-bridge.veritas.com ([143.127.3.10] helo=mtvmime03.VERITAS.COM)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ojrW-0000eV-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Aug 2003 06:15:54 -0700
Received: from localhost.localdomain(markhe.wat.veritas.com[10.10.185.104]) (2011 bytes) by megami
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <markhe@veritas.com>)
	id <m19ojrQ-000088C@megami>
	for <nfs@lists.sourceforge.net>; Mon, 18 Aug 2003 06:15:48 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
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

  Do not update 'c_timestamp' for a "too fast" retransmit.  Otherwise, it
is possible we'll never re-send to a client which is constantly being
over-eager - or is this the idea?

  Also, protect against jiffies wrap.

Thanks,
Mark


diff -urNp linux-2.6.0-test3/fs/nfsd/nfscache.c linux-2.6.0-test3-nfsd-age/fs/nfsd/nfscache.c
--- linux-2.6.0-test3/fs/nfsd/nfscache.c	2003-08-09 05:42:23.000000000 +0100
+++ linux-2.6.0-test3-nfsd-age/fs/nfsd/nfscache.c	2020-08-18 13:46:31.033864560 +0100
@@ -252,13 +252,25 @@ nfsd_cache_lookup(struct svc_rqst *rqstp

 found_entry:
 	/* We found a matching entry which is either in progress or done. */
-	age = jiffies - rp->c_timestamp;
+
+	/* careful of wrap */
+	age = jiffies;
+	if (age >= rp->c_timestamp) {
+		age -= rp->c_timestamp;
+	} else {
+		age += (~0UL - rp->c_timestamp);
+	}
+
+	/* Excessive fast rexmit? */
+	rtn = RC_DROPIT;
+	if (age < RC_DELAY)
+		goto out;
+
 	rp->c_timestamp = jiffies;
 	lru_put_front(rp);

-	rtn = RC_DROPIT;
-	/* Request being processed or excessive rexmits */
-	if (rp->c_state == RC_INPROG || age < RC_DELAY)
+	/* Request being processed? */
+	if (rp->c_state == RC_INPROG)
 		goto out;

 	/* From the hall of fame of impractical attacks:



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
