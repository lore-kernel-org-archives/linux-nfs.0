Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:46239 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760224Ab2DKNdL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Apr 2012 09:33:11 -0400
Subject: [PATCH 1/4] nfsd: pass network context to idmap init/exit functions
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 11 Apr 2012 17:32:44 +0400
Message-ID: <20120411133244.26953.78000.stgit@localhost6.localdomain6>
In-Reply-To: <20120411133139.26953.85254.stgit@localhost6.localdomain6>
References: <20120411133139.26953.85254.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These functions will be called from per-net operations.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/idmap.h     |    8 ++++----
 fs/nfsd/nfs4idmap.c |   14 +++++++-------
 fs/nfsd/nfsctl.c    |    6 +++---
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/idmap.h b/fs/nfsd/idmap.h
index 2f3be13..9d513ef 100644
--- a/fs/nfsd/idmap.h
+++ b/fs/nfsd/idmap.h
@@ -42,14 +42,14 @@
 #define IDMAP_NAMESZ 128
 
 #ifdef CONFIG_NFSD_V4
-int nfsd_idmap_init(void);
-void nfsd_idmap_shutdown(void);
+int nfsd_idmap_init(struct net *);
+void nfsd_idmap_shutdown(struct net *);
 #else
-static inline int nfsd_idmap_init(void)
+static inline int nfsd_idmap_init(struct net *net)
 {
 	return 0;
 }
-static inline void nfsd_idmap_shutdown(void)
+static inline void nfsd_idmap_shutdown(struct net *net)
 {
 }
 #endif
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 2ff4470..d37405f 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -469,24 +469,24 @@ nametoid_update(struct cache_detail *cd, struct ent *new, struct ent *old)
  */
 
 int
-nfsd_idmap_init(void)
+nfsd_idmap_init(struct net *net)
 {
 	int rv;
 
-	rv = cache_register_net(&idtoname_cache, &init_net);
+	rv = cache_register_net(&idtoname_cache, net);
 	if (rv)
 		return rv;
-	rv = cache_register_net(&nametoid_cache, &init_net);
+	rv = cache_register_net(&nametoid_cache, net);
 	if (rv)
-		cache_unregister_net(&idtoname_cache, &init_net);
+		cache_unregister_net(&idtoname_cache, net);
 	return rv;
 }
 
 void
-nfsd_idmap_shutdown(void)
+nfsd_idmap_shutdown(struct net *net)
 {
-	cache_unregister_net(&idtoname_cache, &init_net);
-	cache_unregister_net(&nametoid_cache, &init_net);
+	cache_unregister_net(&idtoname_cache, net);
+	cache_unregister_net(&nametoid_cache, net);
 }
 
 static int
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 08cd87a..d6e8b85 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1186,7 +1186,7 @@ static int __init init_nfsd(void)
 	if (retval)
 		goto out_free_stat;
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
-	retval = nfsd_idmap_init();
+	retval = nfsd_idmap_init(&init_net);
 	if (retval)
 		goto out_free_lockd;
 	retval = create_proc_exports_entry();
@@ -1200,7 +1200,7 @@ out_free_all:
 	remove_proc_entry("fs/nfs/exports", NULL);
 	remove_proc_entry("fs/nfs", NULL);
 out_free_idmap:
-	nfsd_idmap_shutdown();
+	nfsd_idmap_shutdown(&init_net);
 out_free_lockd:
 	nfsd_lockd_shutdown();
 	nfsd_reply_cache_shutdown();
@@ -1223,7 +1223,7 @@ static void __exit exit_nfsd(void)
 	remove_proc_entry("fs/nfs", NULL);
 	nfsd_stat_shutdown();
 	nfsd_lockd_shutdown();
-	nfsd_idmap_shutdown();
+	nfsd_idmap_shutdown(&init_net);
 	nfsd4_free_slabs();
 	nfsd_fault_inject_cleanup();
 	unregister_filesystem(&nfsd_fs_type);

