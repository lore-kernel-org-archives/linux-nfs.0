From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 5 - Fix nfs shutdown problem.
Date: Thu, 31 Oct 2002 11:07:39 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1021031000739.29547@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1872sM-0004Pw-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 16:07:54 -0800
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Here begins a set of 5 patches for kNFSd, the last this month..

The first 3 fix little bugs.
The 4th tidies up nfsd_readdir which has become a bit of a mess.
The 5th restructures the way nfsd manages buffers for requests/replies
so that (among other things) it should be very easy to incorporate the
zero-copy changes from  Hirokazu Takahashi <taka@valinux.co.jp>.

### Comments for ChangeSet

The 'unexport everything' that happens when the
last nfsd thread dies was shuting down too much - 
things that should only be shut down on module unload.



 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |   31 ++++++++++++-------------------
 ./fs/nfsd/nfssvc.c            |    2 +-
 ./include/linux/nfsd/export.h |    1 +
 ./net/sunrpc/sunrpc_syms.c    |    1 +
 4 files changed, 15 insertions(+), 20 deletions(-)

--- ./fs/nfsd/export.c	2002/10/30 22:39:32	1.1
+++ ./fs/nfsd/export.c	2002/10/30 22:40:03	1.2
@@ -738,23 +738,6 @@ exp_do_unexport(svc_export *unexp)
 	exp_fsid_unhash(unexp);
 }
 
-/*
- * Revoke all exports for a given client.
- */
-static void
-exp_unexport_all(svc_client *clp)
-{
-	struct svc_export *exp;
-	int index;
-
-	dprintk("unexporting all fs's for clnt %p\n", clp);
-
-	cache_for_each(exp, &svc_export_cache, index, h)
-		if (exp->ex_client == clp)
-			exp_do_unexport(exp);
-	cache_flush();
-
-}
 
 /*
  * unexport syscall.
@@ -1109,6 +1092,18 @@ nfsd_export_init(void)
 }
 
 /*
+ * Flush exports table - called when last nfsd thread is killed
+ */
+void
+nfsd_export_flush(void)
+{
+	exp_writelock();
+	cache_purge(&svc_expkey_cache);
+	cache_purge(&svc_export_cache);
+	exp_writeunlock();
+}
+
+/*
  * Shutdown the exports module.
  */
 void
@@ -1119,8 +1114,6 @@ nfsd_export_shutdown(void)
 
 	exp_writelock();
 
-	exp_unexport_all(NULL);
-
 	if (cache_unregister(&svc_expkey_cache))
 		printk(KERN_ERR "nfsd: failed to unregister expkey cache\n");
 	if (cache_unregister(&svc_export_cache))
--- ./fs/nfsd/nfssvc.c	2002/10/30 22:39:33	1.1
+++ ./fs/nfsd/nfssvc.c	2002/10/30 22:40:03	1.2
@@ -238,7 +238,7 @@ nfsd(struct svc_rqst *rqstp)
 		printk(KERN_WARNING "nfsd: last server has exited\n");
 		if (err != SIG_NOCLEAN) {
 			printk(KERN_WARNING "nfsd: unexporting all filesystems\n");
-			nfsd_export_shutdown();
+			nfsd_export_flush();
 		}
 		nfsd_serv = NULL;
 	        nfsd_racache_shutdown();	/* release read-ahead cache */
--- ./include/linux/nfsd/export.h	2002/10/30 22:39:33	1.1
+++ ./include/linux/nfsd/export.h	2002/10/30 22:40:03	1.2
@@ -83,6 +83,7 @@ struct svc_expkey {
  */
 void			nfsd_export_init(void);
 void			nfsd_export_shutdown(void);
+void			nfsd_export_flush(void);
 void			exp_readlock(void);
 void			exp_readunlock(void);
 struct svc_expkey *	exp_find_key(struct auth_domain *clp, 
--- ./net/sunrpc/sunrpc_syms.c	2002/10/30 22:39:33	1.1
+++ ./net/sunrpc/sunrpc_syms.c	2002/10/30 22:40:03	1.2
@@ -101,6 +101,7 @@ EXPORT_SYMBOL(auth_unix_lookup);
 EXPORT_SYMBOL(cache_check);
 EXPORT_SYMBOL(cache_clean);
 EXPORT_SYMBOL(cache_flush);
+EXPORT_SYMBOL(cache_purge);
 EXPORT_SYMBOL(cache_fresh);
 EXPORT_SYMBOL(cache_init);
 EXPORT_SYMBOL(cache_register);


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
