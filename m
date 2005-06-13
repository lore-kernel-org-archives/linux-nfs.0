From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH] cache_register can use wrong module reference
Date: Mon, 13 Jun 2005 14:03:40 -0700
Message-ID: <1118696620.3955.175.camel@w-bwa3.beaverton.ibm.com>
Reply-To: bwa@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dhw68-00040l-Ov
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 14:03:56 -0700
Received: from e34.co.us.ibm.com ([32.97.110.132])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1Dhw60-0001hJ-SW
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 14:03:56 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5DL3g2h365808
	for <nfs@lists.sourceforge.net>; Mon, 13 Jun 2005 17:03:42 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5DL3gtH149574
	for <nfs@lists.sourceforge.net>; Mon, 13 Jun 2005 15:03:42 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5DL3gVK006959
	for <nfs@lists.sourceforge.net>; Mon, 13 Jun 2005 15:03:42 -0600
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@cse.unsw.edu.au>
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

When registering an RPC cache, cache_register() always sets the owner as
the sunrpc module.  However, there are caches owned by other modules. 
With the incorrect owner setting, the real owning module can be removed
potentially with an open reference to the cache from userspace.

For example, if one were to stop the nfs server and unmount the nfsd
filesystem, the nfsd module could be removed eventhough rpc.idmapd had
references to the idtoname and nametoid caches (i.e.
/proc/net/rpc/nfs4.<cachename>/channel is still open).  This resulted in
a system panic on one of our machines when attempting to restart the nfs
services after reloading the nfsd module.

The following patch fixes this by passing the address of the owning
struct module to cache_register().  In addition, printk's were added to
functions calling cache_unregister() to dump an error message on
failure.

Patch created against linux-2.6.12-rc6 (also applies cleanly to
linux-2.6.12-rc6-CITI_NFS4_ALL-3).

Signed-off-by: Bruce Allan <bruce.allan@us.ibm.com>

diff -Nurp linux-2.6.12-rc6-vanilla/fs/nfsd/export.c linux-2.6.12-rc6/fs/nfsd/export.c
--- linux-2.6.12-rc6-vanilla/fs/nfsd/export.c	2005-06-06 08:22:29.000000000 -0700
+++ linux-2.6.12-rc6/fs/nfsd/export.c	2005-06-13 20:28:08.613011400 -0700
@@ -26,6 +26,7 @@
 #include <linux/namei.h>
 #include <linux/mount.h>
 #include <linux/hash.h>
+#include <linux/module.h>
 
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
@@ -1161,9 +1162,8 @@ nfsd_export_init(void)
 {
 	dprintk("nfsd: initializing export module.\n");
 
-	cache_register(&svc_export_cache);
-	cache_register(&svc_expkey_cache);
-
+	cache_register(&svc_export_cache, THIS_MODULE);
+	cache_register(&svc_expkey_cache, THIS_MODULE);
 }
 
 /*
diff -Nurp linux-2.6.12-rc6-vanilla/fs/nfsd/nfs4idmap.c linux-2.6.12-rc6/fs/nfsd/nfs4idmap.c
--- linux-2.6.12-rc6-vanilla/fs/nfsd/nfs4idmap.c	2005-06-06 08:22:29.000000000 -0700
+++ linux-2.6.12-rc6/fs/nfsd/nfs4idmap.c	2005-06-13 20:28:08.614011248 -0700
@@ -397,15 +397,17 @@ static DefineSimpleCacheLookupMap(ent, n
 void
 nfsd_idmap_init(void)
 {
-	cache_register(&idtoname_cache);
-	cache_register(&nametoid_cache);
+	cache_register(&idtoname_cache, THIS_MODULE);
+	cache_register(&nametoid_cache, THIS_MODULE);
 }
 
 void
 nfsd_idmap_shutdown(void)
 {
-	cache_unregister(&idtoname_cache);
-	cache_unregister(&nametoid_cache);
+	if (cache_unregister(&idtoname_cache))
+		printk(KERN_ERR "nfsd: failed to unregister idtoname cache\n");
+	if (cache_unregister(&nametoid_cache))
+		printk(KERN_ERR "nfsd: failed to unregister nametoid cache\n");
 }
 
 /*
diff -Nurp linux-2.6.12-rc6-vanilla/include/linux/sunrpc/cache.h linux-2.6.12-rc6/include/linux/sunrpc/cache.h
--- linux-2.6.12-rc6-vanilla/include/linux/sunrpc/cache.h	2005-06-06 08:22:29.000000000 -0700
+++ linux-2.6.12-rc6/include/linux/sunrpc/cache.h	2005-06-13 20:28:08.615011096 -0700
@@ -278,7 +278,7 @@ extern int cache_check(struct cache_deta
 extern void cache_flush(void);
 extern void cache_purge(struct cache_detail *detail);
 #define NEVER (0x7FFFFFFF)
-extern void cache_register(struct cache_detail *cd);
+extern void cache_register(struct cache_detail *cd, struct module *owner);
 extern int cache_unregister(struct cache_detail *cd);
 
 extern void qword_add(char **bpp, int *lp, char *str);
diff -Nurp linux-2.6.12-rc6-vanilla/net/sunrpc/auth_gss/svcauth_gss.c linux-2.6.12-rc6/net/sunrpc/auth_gss/svcauth_gss.c
--- linux-2.6.12-rc6-vanilla/net/sunrpc/auth_gss/svcauth_gss.c	2005-06-06 08:22:29.000000000 -0700
+++ linux-2.6.12-rc6/net/sunrpc/auth_gss/svcauth_gss.c	2005-06-13 20:28:08.617010792 -0700
@@ -1065,8 +1065,8 @@ gss_svc_init(void)
 {
 	int rv = svc_auth_register(RPC_AUTH_GSS, &svcauthops_gss);
 	if (rv == 0) {
-		cache_register(&rsc_cache);
-		cache_register(&rsi_cache);
+		cache_register(&rsc_cache, THIS_MODULE);
+		cache_register(&rsi_cache, THIS_MODULE);
 	}
 	return rv;
 }
@@ -1074,7 +1074,9 @@ gss_svc_init(void)
 void
 gss_svc_shutdown(void)
 {
-	cache_unregister(&rsc_cache);
-	cache_unregister(&rsi_cache);
+	if (cache_unregister(&rsc_cache))
+		printk(KERN_ERR "sunrpc: failed to unregister rsc cache\n");
+	if (cache_unregister(&rsi_cache))
+		printk(KERN_ERR "sunrpc: failed to unregister rsi cache\n");
 	svc_auth_unregister(RPC_AUTH_GSS);
 }
diff -Nurp linux-2.6.12-rc6-vanilla/net/sunrpc/cache.c linux-2.6.12-rc6/net/sunrpc/cache.c
--- linux-2.6.12-rc6-vanilla/net/sunrpc/cache.c	2005-06-06 08:22:29.000000000 -0700
+++ linux-2.6.12-rc6/net/sunrpc/cache.c	2005-06-13 20:28:08.619010488 -0700
@@ -172,12 +172,12 @@ static struct file_operations cache_flus
 static void do_cache_clean(void *data);
 static DECLARE_WORK(cache_cleaner, do_cache_clean, NULL);
 
-void cache_register(struct cache_detail *cd)
+void cache_register(struct cache_detail *cd, struct module *owner)
 {
 	cd->proc_ent = proc_mkdir(cd->name, proc_net_rpc);
 	if (cd->proc_ent) {
 		struct proc_dir_entry *p;
-		cd->proc_ent->owner = THIS_MODULE;
+		cd->proc_ent->owner = owner;
 		cd->channel_ent = cd->content_ent = NULL;
 		
  		p = create_proc_entry("flush", S_IFREG|S_IRUSR|S_IWUSR,
@@ -185,7 +185,7 @@ void cache_register(struct cache_detail 
 		cd->flush_ent =  p;
  		if (p) {
  			p->proc_fops = &cache_flush_operations;
- 			p->owner = THIS_MODULE;
+ 			p->owner = owner;
  			p->data = cd;
  		}
  
@@ -195,7 +195,7 @@ void cache_register(struct cache_detail 
 			cd->channel_ent = p;
 			if (p) {
 				p->proc_fops = &cache_file_operations;
-				p->owner = THIS_MODULE;
+				p->owner = owner;
 				p->data = cd;
 			}
 		}
@@ -205,7 +205,7 @@ void cache_register(struct cache_detail 
 			cd->content_ent = p;
  			if (p) {
  				p->proc_fops = &content_file_operations;
- 				p->owner = THIS_MODULE;
+ 				p->owner = owner;
  				p->data = cd;
  			}
  		}
diff -Nurp linux-2.6.12-rc6-vanilla/net/sunrpc/sunrpc_syms.c linux-2.6.12-rc6/net/sunrpc/sunrpc_syms.c
--- linux-2.6.12-rc6-vanilla/net/sunrpc/sunrpc_syms.c	2005-06-06 08:22:29.000000000 -0700
+++ linux-2.6.12-rc6/net/sunrpc/sunrpc_syms.c	2005-06-13 20:28:08.619010488 -0700
@@ -160,8 +160,8 @@ init_sunrpc(void)
 #ifdef CONFIG_PROC_FS
 	rpc_proc_init();
 #endif
-	cache_register(&auth_domain_cache);
-	cache_register(&ip_map_cache);
+	cache_register(&auth_domain_cache, THIS_MODULE);
+	cache_register(&ip_map_cache, THIS_MODULE);
 out:
 	return err;
 }
@@ -171,8 +171,10 @@ cleanup_sunrpc(void)
 {
 	unregister_rpc_pipefs();
 	rpc_destroy_mempool();
-	cache_unregister(&auth_domain_cache);
-	cache_unregister(&ip_map_cache);
+	if (cache_unregister(&auth_domain_cache))
+		printk(KERN_ERR "sunrpc: failed to unregister auth_domain cache\n");
+	if (cache_unregister(&ip_map_cache))
+		printk(KERN_ERR "sunrpc: failed to unregister ip_map cache\n");
 #ifdef RPC_DEBUG
 	rpc_unregister_sysctl();
 #endif




-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
