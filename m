From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH] sunrpc: cache_register can use wrong module reference
Date: Tue, 02 Aug 2005 14:29:36 -0700
Message-ID: <1123018176.3954.118.camel@w-bwa3.beaverton.ibm.com>
Reply-To: bwa@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <nfs@lists.sourceforge.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E04Kb-0004nf-N3
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 14:29:49 -0700
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1E04Kb-0000wN-4D
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 14:29:49 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j72LTcO7292560
	for <nfs@lists.sourceforge.net>; Tue, 2 Aug 2005 17:29:38 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j72LTZSk226988
	for <nfs@lists.sourceforge.net>; Tue, 2 Aug 2005 15:29:35 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j72LTbtg031123
	for <nfs@lists.sourceforge.net>; Tue, 2 Aug 2005 15:29:38 -0600
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

[resending to Neil, Trond and linux-nfs list; initial copy to lkml]

When registering an RPC cache, cache_register() always sets the owner as
the sunrpc module.  However, there are RPC caches owned by other modules. 
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

Signed-off-by: Bruce Allan <bwa@us.ibm.com>


diff -uprN -X linux-2.6.13-rc5/Documentation/dontdiff linux-2.6.13-rc5/fs/nfsd/export.c linux-2.6.13-rc5-rpc_cache_register/fs/nfsd/export.c
--- linux-2.6.13-rc5/fs/nfsd/export.c	2005-08-01 21:45:48.000000000 -0700
+++ linux-2.6.13-rc5-rpc_cache_register/fs/nfsd/export.c	2005-08-02 13:20:50.000000000 -0700
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
diff -uprN -X linux-2.6.13-rc5/Documentation/dontdiff linux-2.6.13-rc5/fs/nfsd/nfs4idmap.c linux-2.6.13-rc5-rpc_cache_register/fs/nfsd/nfs4idmap.c
--- linux-2.6.13-rc5/fs/nfsd/nfs4idmap.c	2005-08-01 21:45:48.000000000 -0700
+++ linux-2.6.13-rc5-rpc_cache_register/fs/nfsd/nfs4idmap.c	2005-08-02 13:20:50.000000000 -0700
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
diff -uprN -X linux-2.6.13-rc5/Documentation/dontdiff linux-2.6.13-rc5/include/linux/sunrpc/cache.h linux-2.6.13-rc5-rpc_cache_register/include/linux/sunrpc/cache.h
--- linux-2.6.13-rc5/include/linux/sunrpc/cache.h	2005-08-01 21:45:48.000000000 -0700
+++ linux-2.6.13-rc5-rpc_cache_register/include/linux/sunrpc/cache.h	2005-08-02 13:20:50.000000000 -0700
@@ -278,7 +278,7 @@ extern int cache_check(struct cache_deta
 extern void cache_flush(void);
 extern void cache_purge(struct cache_detail *detail);
 #define NEVER (0x7FFFFFFF)
-extern void cache_register(struct cache_detail *cd);
+extern void cache_register(struct cache_detail *cd, struct module *owner);
 extern int cache_unregister(struct cache_detail *cd);
 
 extern void qword_add(char **bpp, int *lp, char *str);
diff -uprN -X linux-2.6.13-rc5/Documentation/dontdiff linux-2.6.13-rc5/net/sunrpc/auth_gss/svcauth_gss.c linux-2.6.13-rc5-rpc_cache_register/net/sunrpc/auth_gss/svcauth_gss.c
--- linux-2.6.13-rc5/net/sunrpc/auth_gss/svcauth_gss.c	2005-08-01 21:45:48.000000000 -0700
+++ linux-2.6.13-rc5-rpc_cache_register/net/sunrpc/auth_gss/svcauth_gss.c	2005-08-02 13:20:50.000000000 -0700
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
diff -uprN -X linux-2.6.13-rc5/Documentation/dontdiff linux-2.6.13-rc5/net/sunrpc/cache.c linux-2.6.13-rc5-rpc_cache_register/net/sunrpc/cache.c
--- linux-2.6.13-rc5/net/sunrpc/cache.c	2005-08-01 21:45:48.000000000 -0700
+++ linux-2.6.13-rc5-rpc_cache_register/net/sunrpc/cache.c	2005-08-02 13:20:50.000000000 -0700
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
diff -uprN -X linux-2.6.13-rc5/Documentation/dontdiff linux-2.6.13-rc5/net/sunrpc/sunrpc_syms.c linux-2.6.13-rc5-rpc_cache_register/net/sunrpc/sunrpc_syms.c
--- linux-2.6.13-rc5/net/sunrpc/sunrpc_syms.c	2005-08-01 21:45:48.000000000 -0700
+++ linux-2.6.13-rc5-rpc_cache_register/net/sunrpc/sunrpc_syms.c	2005-08-02 13:20:50.000000000 -0700
@@ -165,8 +165,8 @@ init_sunrpc(void)
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
@@ -176,8 +176,10 @@ cleanup_sunrpc(void)
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
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
