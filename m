Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20402 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752138Ab3KRSw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Nov 2013 13:52:56 -0500
From: Anna Schumaker <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] NFS: Fix kbuild errors due to undefined symbols
Date: Mon, 18 Nov 2013 13:52:51 -0500
Message-ID: <1384800771-21649-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My recent patch 644aa303: "NFS: Enabling v4.2 should not recompile nfsd
and lockd" caused build errors when CONFIG_NFS_V4=n, the basic NFS
module needs NFS4_MAX_MINOR_VERSION, nfs4_label_alloc() and
nfs4_label_free() defined to compile.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h | 15 +++++++++++++++
 fs/nfs/nfs4_fs.h  | 34 +++++++++-------------------------
 2 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index bca6a3e..8b5cc04 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -269,6 +269,21 @@ extern const u32 nfs41_maxgetdevinfo_overhead;
 extern struct rpc_procinfo nfs4_procedures[];
 #endif
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+extern struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags);
+static inline void nfs4_label_free(struct nfs4_label *label)
+{
+	if (label) {
+		kfree(label->label);
+		kfree(label);
+	}
+	return;
+}
+#else
+static inline struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags) { return NULL; }
+static inline void nfs4_label_free(void *label) {}
+#endif /* CONFIG_NFS_V4_SECURITY_LABEL */
+
 /* proc.c */
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
 extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index e916e86..7545ec2 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -9,21 +9,20 @@
 #ifndef __LINUX_FS_NFS_NFS4_FS_H
 #define __LINUX_FS_NFS_NFS4_FS_H
 
-#if IS_ENABLED(CONFIG_NFS_V4)
-
-#define NFS4_MAX_LOOP_ON_RECOVER (10)
-
-#include <linux/seqlock.h>
-
 #if defined(CONFIG_NFS_V4_2)
 #define NFS4_MAX_MINOR_VERSION 2
-#else
-#if defined(CONFIG_NFS_V4_1)
+#elif defined(CONFIG_NFS_V4_1)
 #define NFS4_MAX_MINOR_VERSION 1
 #else
 #define NFS4_MAX_MINOR_VERSION 0
-#endif /* CONFIG_NFS_V4_1 */
-#endif /* CONFIG_NFS_V4_2 */
+#endif
+
+#if IS_ENABLED(CONFIG_NFS_V4)
+
+#define NFS4_MAX_LOOP_ON_RECOVER (10)
+
+#include <linux/seqlock.h>
+#include <linux/nfs_fs.h>
 
 struct idmap;
 
@@ -375,21 +374,6 @@ nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-#ifdef CONFIG_NFS_V4_SECURITY_LABEL
-extern struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags);
-static inline void nfs4_label_free(struct nfs4_label *label)
-{
-	if (label) {
-		kfree(label->label);
-		kfree(label);
-	}
-	return;
-}
-#else
-static inline struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags) { return NULL; }
-static inline void nfs4_label_free(void *label) {}
-#endif /* CONFIG_NFS_V4_SECURITY_LABEL */
-
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
 
 extern const u32 nfs4_fattr_bitmap[3];
-- 
1.8.4.2

