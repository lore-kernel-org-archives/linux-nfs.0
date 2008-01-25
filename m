From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 019/100] knfsd: cache unregistration needn't return error
Date: Fri, 25 Jan 2008 18:15:59 -0500
Message-ID: <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47338 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762005AbYAYXR1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:27 -0500
In-Reply-To: <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's really nothing much the caller can do if cache unregistration
fails.  And indeed, all any caller does in this case is print an error
and continue.  So just return void and move the printk's inside
cache_unregister.

Acked-by: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/export.c                  |    6 ++----
 fs/nfsd/nfs4idmap.c               |    6 ++----
 include/linux/sunrpc/cache.h      |    2 +-
 net/sunrpc/auth_gss/svcauth_gss.c |    6 ++----
 net/sunrpc/cache.c                |    8 +++++---
 net/sunrpc/sunrpc_syms.c          |    6 ++----
 6 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 66d0aeb..d29b70a 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1670,10 +1670,8 @@ nfsd_export_shutdown(void)
 
 	exp_writelock();
 
-	if (cache_unregister(&svc_expkey_cache))
-		printk(KERN_ERR "nfsd: failed to unregister expkey cache\n");
-	if (cache_unregister(&svc_export_cache))
-		printk(KERN_ERR "nfsd: failed to unregister export cache\n");
+	cache_unregister(&svc_expkey_cache);
+	cache_unregister(&svc_export_cache);
 	svcauth_unix_purge();
 
 	exp_writeunlock();
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 5b56c77..ef22179 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -474,10 +474,8 @@ nfsd_idmap_init(void)
 void
 nfsd_idmap_shutdown(void)
 {
-	if (cache_unregister(&idtoname_cache))
-		printk(KERN_ERR "nfsd: failed to unregister idtoname cache\n");
-	if (cache_unregister(&nametoid_cache))
-		printk(KERN_ERR "nfsd: failed to unregister nametoid cache\n");
+	cache_unregister(&idtoname_cache);
+	cache_unregister(&nametoid_cache);
 }
 
 /*
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index bd7a6b0..b683b5d 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -170,7 +170,7 @@ extern void cache_flush(void);
 extern void cache_purge(struct cache_detail *detail);
 #define NEVER (0x7FFFFFFF)
 extern void cache_register(struct cache_detail *cd);
-extern int cache_unregister(struct cache_detail *cd);
+extern void cache_unregister(struct cache_detail *cd);
 
 extern void qword_add(char **bpp, int *lp, char *str);
 extern void qword_addhex(char **bpp, int *lp, char *buf, int blen);
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 73940df..d329a12 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1396,9 +1396,7 @@ gss_svc_init(void)
 void
 gss_svc_shutdown(void)
 {
-	if (cache_unregister(&rsc_cache))
-		printk(KERN_ERR "auth_rpcgss: failed to unregister rsc cache\n");
-	if (cache_unregister(&rsi_cache))
-		printk(KERN_ERR "auth_rpcgss: failed to unregister rsi cache\n");
+	cache_unregister(&rsc_cache);
+	cache_unregister(&rsi_cache);
 	svc_auth_unregister(RPC_AUTH_GSS);
 }
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 0d747e2..d05ea16 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -343,7 +343,7 @@ void cache_register(struct cache_detail *cd)
 	schedule_delayed_work(&cache_cleaner, 0);
 }
 
-int cache_unregister(struct cache_detail *cd)
+void cache_unregister(struct cache_detail *cd)
 {
 	cache_purge(cd);
 	spin_lock(&cache_list_lock);
@@ -351,7 +351,7 @@ int cache_unregister(struct cache_detail *cd)
 	if (cd->entries || atomic_read(&cd->inuse)) {
 		write_unlock(&cd->hash_lock);
 		spin_unlock(&cache_list_lock);
-		return -EBUSY;
+		goto out;
 	}
 	if (current_detail == cd)
 		current_detail = NULL;
@@ -373,7 +373,9 @@ int cache_unregister(struct cache_detail *cd)
 		/* module must be being unloaded so its safe to kill the worker */
 		cancel_delayed_work_sync(&cache_cleaner);
 	}
-	return 0;
+	return;
+out:
+	printk(KERN_ERR "nfsd: failed to unregister %s cache\n", cd->name);
 }
 
 /* clean cache tries to find something to clean
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 33d89e8..5793e00 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -164,10 +164,8 @@ cleanup_sunrpc(void)
 	cleanup_socket_xprt();
 	unregister_rpc_pipefs();
 	rpc_destroy_mempool();
-	if (cache_unregister(&ip_map_cache))
-		printk(KERN_ERR "sunrpc: failed to unregister ip_map cache\n");
-	if (cache_unregister(&unix_gid_cache))
-	      printk(KERN_ERR "sunrpc: failed to unregister unix_gid cache\n");
+	cache_unregister(&ip_map_cache);
+	cache_unregister(&unix_gid_cache);
 #ifdef RPC_DEBUG
 	rpc_unregister_sysctl();
 #endif
-- 
1.5.4.rc2.60.gb2e62

