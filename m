From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfsd/sunrpc boot on reboot in 2.5.44
Date: Mon, 21 Oct 2002 13:25:21 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <15795.29601.539191.253507@notabene.cse.unsw.edu.au>
References: <20021020173142.GA26384@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <ahu@ds9a.nl>) (for <linux-kernel@vger.kernel.org>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Mon, 21 Oct 2002 13:25:29 +1000
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: message from bert hubert on Sunday October 20
List-ID: <nfs.lists.sourceforge.net>

On Sunday October 20, ahu@ds9a.nl wrote:
> My Debian sid machine oopses when I run 'sudo reboot'.
> 

Sorry 'bout that.  Appended patch should fix it.
When the last daemon exits all exports are automatically unexported,
and it was releasing too much so when "exportfs -a" came along it
tried to access some deallocated data strctures.

NeilBrown

-------------------------
Fix nfs shutdown problem.

The 'unexport everything' that happens when the
last nfsd thread dies was shuting down too much - 
things that should only be shut down on module unload.



 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |   31 ++++++++++++-------------------
 ./fs/nfsd/nfssvc.c            |    2 +-
 ./include/linux/nfsd/export.h |    1 +
 ./net/sunrpc/sunrpc_syms.c    |    1 +
 4 files changed, 15 insertions(+), 20 deletions(-)

--- ./fs/nfsd/export.c	2002/10/20 23:48:51	1.1
+++ ./fs/nfsd/export.c	2002/10/21 03:23:44	1.2
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
--- ./fs/nfsd/nfssvc.c	2002/10/20 23:53:59	1.1
+++ ./fs/nfsd/nfssvc.c	2002/10/21 03:23:44	1.2
@@ -238,7 +238,7 @@ nfsd(struct svc_rqst *rqstp)
 		printk(KERN_WARNING "nfsd: last server has exited\n");
 		if (err != SIG_NOCLEAN) {
 			printk(KERN_WARNING "nfsd: unexporting all filesystems\n");
-			nfsd_export_shutdown();
+			nfsd_export_flush();
 		}
 		nfsd_serv = NULL;
 	        nfsd_racache_shutdown();	/* release read-ahead cache */
--- ./include/linux/nfsd/export.h	2002/10/20 23:53:38	1.1
+++ ./include/linux/nfsd/export.h	2002/10/21 03:23:44	1.2
@@ -83,6 +83,7 @@ struct svc_expkey {
  */
 void			nfsd_export_init(void);
 void			nfsd_export_shutdown(void);
+void			nfsd_export_flush(void);
 void			exp_readlock(void);
 void			exp_readunlock(void);
 struct svc_expkey *	exp_find_key(struct auth_domain *clp, 
--- ./net/sunrpc/sunrpc_syms.c	2002/10/20 23:53:09	1.1
+++ ./net/sunrpc/sunrpc_syms.c	2002/10/21 03:23:44	1.2
@@ -101,6 +101,7 @@ EXPORT_SYMBOL(auth_unix_lookup);
 EXPORT_SYMBOL(cache_check);
 EXPORT_SYMBOL(cache_clean);
 EXPORT_SYMBOL(cache_flush);
+EXPORT_SYMBOL(cache_purge);
 EXPORT_SYMBOL(cache_fresh);
 EXPORT_SYMBOL(cache_init);
 EXPORT_SYMBOL(cache_register);
