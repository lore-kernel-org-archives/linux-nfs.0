Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:29303 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754627Ab2DKLNk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Apr 2012 07:13:40 -0400
Subject: [PATCH 1/4] nfsd: pass network context to export caches init/shutdown
 routines
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 11 Apr 2012 15:13:14 +0400
Message-ID: <20120411111314.13840.48019.stgit@localhost6.localdomain6>
In-Reply-To: <20120411111053.13840.66083.stgit@localhost6.localdomain6>
References: <20120411111053.13840.66083.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These functions will be called from per-net operations.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/export.c            |   20 ++++++++++----------
 fs/nfsd/nfsctl.c            |    6 +++---
 include/linux/nfsd/export.h |    4 ++--
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 429b2f5..688264b 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1235,17 +1235,17 @@ const struct seq_operations nfs_exports_op = {
  * Initialize the exports module.
  */
 int
-nfsd_export_init(void)
+nfsd_export_init(struct net *net)
 {
 	int rv;
-	dprintk("nfsd: initializing export module.\n");
+	dprintk("nfsd: initializing export module (net: %p).\n", net);
 
-	rv = cache_register_net(&svc_export_cache, &init_net);
+	rv = cache_register_net(&svc_export_cache, net);
 	if (rv)
 		return rv;
-	rv = cache_register_net(&svc_expkey_cache, &init_net);
+	rv = cache_register_net(&svc_expkey_cache, net);
 	if (rv)
-		cache_unregister_net(&svc_export_cache, &init_net);
+		cache_unregister_net(&svc_export_cache, net);
 	return rv;
 
 }
@@ -1264,14 +1264,14 @@ nfsd_export_flush(void)
  * Shutdown the exports module.
  */
 void
-nfsd_export_shutdown(void)
+nfsd_export_shutdown(struct net *net)
 {
 
-	dprintk("nfsd: shutting down export module.\n");
+	dprintk("nfsd: shutting down export module (net: %p).\n", net);
 
-	cache_unregister_net(&svc_expkey_cache, &init_net);
-	cache_unregister_net(&svc_export_cache, &init_net);
+	cache_unregister_net(&svc_expkey_cache, net);
+	cache_unregister_net(&svc_export_cache, net);
 	svcauth_unix_purge();
 
-	dprintk("nfsd: export shutdown complete.\n");
+	dprintk("nfsd: export shutdown complete (net: %p).\n", net);
 }
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index ae19293..bc76f8e 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1163,7 +1163,7 @@ static int __init init_nfsd(void)
 	retval = nfsd_reply_cache_init();
 	if (retval)
 		goto out_free_stat;
-	retval = nfsd_export_init();
+	retval = nfsd_export_init(&init_net);
 	if (retval)
 		goto out_free_cache;
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
@@ -1184,7 +1184,7 @@ out_free_idmap:
 	nfsd_idmap_shutdown();
 out_free_lockd:
 	nfsd_lockd_shutdown();
-	nfsd_export_shutdown();
+	nfsd_export_shutdown(&init_net);
 out_free_cache:
 	nfsd_reply_cache_shutdown();
 out_free_stat:
@@ -1201,7 +1201,7 @@ out_unregister_notifier:
 
 static void __exit exit_nfsd(void)
 {
-	nfsd_export_shutdown();
+	nfsd_export_shutdown(&init_net);
 	nfsd_reply_cache_shutdown();
 	remove_proc_entry("fs/nfs/exports", NULL);
 	remove_proc_entry("fs/nfs", NULL);
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 485c2af..375096c 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -130,8 +130,8 @@ __be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp);
 /*
  * Function declarations
  */
-int			nfsd_export_init(void);
-void			nfsd_export_shutdown(void);
+int			nfsd_export_init(struct net *);
+void			nfsd_export_shutdown(struct net *);
 void			nfsd_export_flush(void);
 struct svc_export *	rqst_exp_get_by_name(struct svc_rqst *,
 					     struct path *);

