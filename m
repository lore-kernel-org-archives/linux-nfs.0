From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] eliminate hangs during RPC client shutdown
Date: Thu, 22 Aug 2002 18:15:04 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16088.6420206682$1030054963@news.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dexter.citi.umich.edu ([141.211.133.33])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17i0ET-00037K-00
	for <nfs@lists.sourceforge.net>; Thu, 22 Aug 2002 15:15:13 -0700
To: Linus Torvalds <torvalds@transmeta.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

linus-

this is against 2.5.31 with the recent RPC call_start/reserve patches
applied, and eliminates an infinite loop in rpciod if an RPC client's
reference counter accidentally goes negative.  i've been running this
under load since 2.5.30 with no ill effects.


diff -drN -U2 06-connect2/net/sunrpc/clnt.c 07-shutdown/net/sunrpc/clnt.c
--- 06-connect2/net/sunrpc/clnt.c	Mon Aug 12 16:31:53 2002
+++ 07-shutdown/net/sunrpc/clnt.c	Mon Aug 12 16:53:24 2002
@@ -138,11 +138,9 @@
 rpc_shutdown_client(struct rpc_clnt *clnt)
 {
-	dprintk("RPC: shutting down %s client for %s\n",
-		clnt->cl_protname, clnt->cl_server);
-	while (atomic_read(&clnt->cl_users)) {
-#ifdef RPC_DEBUG
-		dprintk("RPC: rpc_shutdown_client: client %s, tasks=%d\n",
-			clnt->cl_protname, atomic_read(&clnt->cl_users));
-#endif
+	dprintk("RPC: shutting down %s client for %s, tasks=%d\n",
+			clnt->cl_protname, clnt->cl_server,
+			atomic_read(&clnt->cl_users));
+
+	while (atomic_read(&clnt->cl_users) > 0) {
 		/* Don't let rpc_release_client destroy us */
 		clnt->cl_oneshot = 0;
@@ -151,4 +149,14 @@
 		sleep_on_timeout(&destroy_wait, 1*HZ);
 	}
+
+	if (atomic_read(&clnt->cl_users) < 0) {
+		printk(KERN_ERR "RPC: rpc_shutdown_client clnt %p tasks=%d\n",
+				clnt, atomic_read(&clnt->cl_users));
+#ifdef RPC_DEBUG
+		rpc_show_tasks();
+#endif
+		BUG();
+	}
+
 	return rpc_destroy_client(clnt);
 }

-- 

corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
