From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] interruptible_sleep_on in lockd
Date: Thu, 1 Apr 2004 20:26:56 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040401202656.A24371@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B97q9-0000TU-Kp
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 11:27:01 -0800
Received: from phoenix.infradead.org ([213.86.99.234])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B97q9-0004ho-6S
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 11:27:01 -0800
Received: from hch by phoenix.infradead.org with local (Exim 4.30 #5 (Red Hat Linux))
	id 1B97q4-0006Le-Vn
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 20:26:56 +0100
To: nfs@lists.sourceforge.net
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

interruptible_sleep_on looks rather bogus, especially when ignoring whether
it actually was interrupted.  What about the patch below?


--- 1.8/fs/lockd/clntproc.c	Fri Feb  7 21:25:20 2003
+++ edited/fs/lockd/clntproc.c	Sat Feb  7 15:58:42 2004
@@ -254,8 +241,11 @@
 		msg.rpc_cred = nfs_file_cred(filp);
 
 	do {
-		if (host->h_reclaiming && !argp->reclaim) {
-			interruptible_sleep_on(&host->h_gracewait);
+		status = wait_event_interruptible(host->h_gracewait,
+				(!host->h_reclaiming || argp->reclaim));
+		if (status) {
+			if (signalled())
+				return -EINTR;
 			continue;
 		}
 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
