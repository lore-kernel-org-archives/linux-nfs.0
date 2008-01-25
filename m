From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 023/100] knfsd: allow cache_register to return error on failure
Date: Fri, 25 Jan 2008 18:16:03 -0500
Message-ID: <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
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
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Andrew Morton <akpm@linux-foundation.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47372 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761788AbYAYXRd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:33 -0500
In-Reply-To: <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Newer server features such as nfsv4 and gss depend on proc to work, so a
failure to initialize the proc files they need should be treated as
fatal.

Thanks to Andrew Morton for style fix and compile fix in case where
CONFIG_NFSD_V4 is undefined.

Cc: Andrew Morton <akpm@linux-foundation.org>
Acked-by: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/export.c                  |   12 +++++++++---
 fs/nfsd/nfs4idmap.c               |   13 ++++++++++---
 fs/nfsd/nfsctl.c                  |   12 +++++++++---
 include/linux/nfsd/export.h       |    2 +-
 include/linux/nfsd_idmap.h        |   11 ++++++++---
 include/linux/sunrpc/cache.h      |    2 +-
 net/sunrpc/auth_gss/svcauth_gss.c |   17 +++++++++++++----
 net/sunrpc/cache.c                |   30 +++++++++++++++++++++++-------
 8 files changed, 74 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index d29b70a..cbbc594 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1637,13 +1637,19 @@ exp_verify_string(char *cp, int max)
 /*
  * Initialize the exports module.
  */
-void
+int
 nfsd_export_init(void)
 {
+	int rv;
 	dprintk("nfsd: initializing export module.\n");
 
-	cache_register(&svc_export_cache);
-	cache_register(&svc_expkey_cache);
+	rv = cache_register(&svc_export_cache);
+	if (rv)
+		return rv;
+	rv = cache_register(&svc_expkey_cache);
+	if (rv)
+		cache_unregister(&svc_export_cache);
+	return rv;
 
 }
 
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index ef22179..996bd88 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -464,11 +464,18 @@ nametoid_update(struct ent *new, struct ent *old)
  * Exported API
  */
 
-void
+int
 nfsd_idmap_init(void)
 {
-	cache_register(&idtoname_cache);
-	cache_register(&nametoid_cache);
+	int rv;
+
+	rv = cache_register(&idtoname_cache);
+	if (rv)
+		return rv;
+	rv = cache_register(&nametoid_cache);
+	if (rv)
+		cache_unregister(&idtoname_cache);
+	return rv;
 }
 
 void
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 63d8075..e307972 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -707,9 +707,13 @@ static int __init init_nfsd(void)
 	retval = nfsd_reply_cache_init();
 	if (retval)
 		goto out_free_stat;
-	nfsd_export_init();	/* Exports table */
+	retval = nfsd_export_init();
+	if (retval)
+		goto out_free_cache;
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
-	nfsd_idmap_init();      /* Name to ID mapping */
+	retval = nfsd_idmap_init();
+	if (retval)
+		goto out_free_lockd;
 	retval = create_proc_exports_entry();
 	if (retval)
 		goto out_free_idmap;
@@ -720,10 +724,12 @@ static int __init init_nfsd(void)
 out_free_all:
 	remove_proc_entry("fs/nfs/exports", NULL);
 	remove_proc_entry("fs/nfs", NULL);
-	nfsd_idmap_shutdown();
 out_free_idmap:
+	nfsd_idmap_shutdown();
+out_free_lockd:
 	nfsd_lockd_shutdown();
 	nfsd_export_shutdown();
+out_free_cache:
 	nfsd_reply_cache_shutdown();
 out_free_stat:
 	nfsd_stat_shutdown();
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index bcb7aba..3a16872 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -122,7 +122,7 @@ __be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp);
 /*
  * Function declarations
  */
-void			nfsd_export_init(void);
+int			nfsd_export_init(void);
 void			nfsd_export_shutdown(void);
 void			nfsd_export_flush(void);
 void			exp_readlock(void);
diff --git a/include/linux/nfsd_idmap.h b/include/linux/nfsd_idmap.h
index e82746f..d4a2ac1 100644
--- a/include/linux/nfsd_idmap.h
+++ b/include/linux/nfsd_idmap.h
@@ -44,11 +44,16 @@
 #define IDMAP_NAMESZ 128
 
 #ifdef CONFIG_NFSD_V4
-void nfsd_idmap_init(void);
+int nfsd_idmap_init(void);
 void nfsd_idmap_shutdown(void);
 #else
-static inline void nfsd_idmap_init(void) {};
-static inline void nfsd_idmap_shutdown(void) {};
+static inline int nfsd_idmap_init(void)
+{
+	return 0;
+}
+static inline void nfsd_idmap_shutdown(void)
+{
+}
 #endif
 
 int nfsd_map_name_to_uid(struct svc_rqst *, const char *, size_t, __u32 *);
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index b683b5d..03547d6 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -169,7 +169,7 @@ extern int cache_check(struct cache_detail *detail,
 extern void cache_flush(void);
 extern void cache_purge(struct cache_detail *detail);
 #define NEVER (0x7FFFFFFF)
-extern void cache_register(struct cache_detail *cd);
+extern int cache_register(struct cache_detail *cd);
 extern void cache_unregister(struct cache_detail *cd);
 
 extern void qword_add(char **bpp, int *lp, char *str);
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index d329a12..aa790bb 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1386,10 +1386,19 @@ int
 gss_svc_init(void)
 {
 	int rv = svc_auth_register(RPC_AUTH_GSS, &svcauthops_gss);
-	if (rv == 0) {
-		cache_register(&rsc_cache);
-		cache_register(&rsi_cache);
-	}
+	if (rv)
+		return rv;
+	rv = cache_register(&rsc_cache);
+	if (rv)
+		goto out1;
+	rv = cache_register(&rsi_cache);
+	if (rv)
+		goto out2;
+	return 0;
+out2:
+	cache_unregister(&rsc_cache);
+out1:
+	svc_auth_unregister(RPC_AUTH_GSS);
 	return rv;
 }
 
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 504b4e8..d41fe3c 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -304,20 +304,21 @@ void remove_cache_proc_entries(struct cache_detail *cd)
 	remove_proc_entry(cd->name, proc_net_rpc);
 }
 
-void create_cache_proc_entries(struct cache_detail *cd)
+#ifdef CONFIG_PROC_FS
+int create_cache_proc_entries(struct cache_detail *cd)
 {
 	struct proc_dir_entry *p;
 
 	cd->proc_ent = proc_mkdir(cd->name, proc_net_rpc);
 	if (cd->proc_ent == NULL)
-		return;
+		goto out_nomem;
 	cd->proc_ent->owner = cd->owner;
 	cd->channel_ent = cd->content_ent = NULL;
 
 	p = create_proc_entry("flush", S_IFREG|S_IRUSR|S_IWUSR, cd->proc_ent);
 	cd->flush_ent = p;
 	if (p == NULL)
-		return;
+		goto out_nomem;
 	p->proc_fops = &cache_flush_operations;
 	p->owner = cd->owner;
 	p->data = cd;
@@ -327,7 +328,7 @@ void create_cache_proc_entries(struct cache_detail *cd)
 				      cd->proc_ent);
 		cd->channel_ent = p;
 		if (p == NULL)
-			return;
+			goto out_nomem;
 		p->proc_fops = &cache_file_operations;
 		p->owner = cd->owner;
 		p->data = cd;
@@ -337,16 +338,30 @@ void create_cache_proc_entries(struct cache_detail *cd)
 				      cd->proc_ent);
 		cd->content_ent = p;
 		if (p == NULL)
-			return;
+			goto out_nomem;
 		p->proc_fops = &content_file_operations;
 		p->owner = cd->owner;
 		p->data = cd;
 	}
+	return 0;
+out_nomem:
+	remove_cache_proc_entries(cd);
+	return -ENOMEM;
 }
+#else /* CONFIG_PROC_FS */
+int create_cache_proc_entries(struct cache_detail *cd)
+{
+	return 0;
+}
+#endif
 
-void cache_register(struct cache_detail *cd)
+int cache_register(struct cache_detail *cd)
 {
-	create_cache_proc_entries(cd);
+	int ret;
+
+	ret = create_cache_proc_entries(cd);
+	if (ret)
+		return ret;
 	rwlock_init(&cd->hash_lock);
 	INIT_LIST_HEAD(&cd->queue);
 	spin_lock(&cache_list_lock);
@@ -360,6 +375,7 @@ void cache_register(struct cache_detail *cd)
 
 	/* start the cleaning process */
 	schedule_delayed_work(&cache_cleaner, 0);
+	return 0;
 }
 
 void cache_unregister(struct cache_detail *cd)
-- 
1.5.4.rc2.60.gb2e62

