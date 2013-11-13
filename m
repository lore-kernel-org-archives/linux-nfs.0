Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:10320 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758788Ab3KMR3N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 12:29:13 -0500
From: Anna Schumaker <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: Enabling v4.2 should not recompile nfsd and lockd
Date: Wed, 13 Nov 2013 12:29:08 -0500
Message-ID: <1384363748-14028-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When CONFIG_NFS_V4_2 is toggled nfsd and lockd will be recompiled,
instead of only the nfs client.  This patch moves a small amount of code
into the client directory to avoid unnecessary recompiles.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4_fs.h       | 25 +++++++++++++++++++++++++
 include/linux/nfs4.h   | 10 ----------
 include/linux/nfs_fs.h | 18 ------------------
 3 files changed, 25 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3ce79b0..e916e86 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -15,6 +15,16 @@
 
 #include <linux/seqlock.h>
 
+#if defined(CONFIG_NFS_V4_2)
+#define NFS4_MAX_MINOR_VERSION 2
+#else
+#if defined(CONFIG_NFS_V4_1)
+#define NFS4_MAX_MINOR_VERSION 1
+#else
+#define NFS4_MAX_MINOR_VERSION 0
+#endif /* CONFIG_NFS_V4_1 */
+#endif /* CONFIG_NFS_V4_2 */
+
 struct idmap;
 
 enum nfs4_client_state {
@@ -365,6 +375,21 @@ nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
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
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
 
 extern const u32 nfs4_fattr_bitmap[3];
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index c6f41b6..ddd8487 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -410,16 +410,6 @@ enum lock_type4 {
 #define NFS4_VERSION 4
 #define NFS4_MINOR_VERSION 0
 
-#if defined(CONFIG_NFS_V4_2)
-#define NFS4_MAX_MINOR_VERSION 2
-#else
-#if defined(CONFIG_NFS_V4_1)
-#define NFS4_MAX_MINOR_VERSION 1
-#else
-#define NFS4_MAX_MINOR_VERSION 0
-#endif /* CONFIG_NFS_V4_1 */
-#endif /* CONFIG_NFS_V4_2 */
-
 #define NFS4_DEBUG 1
 
 /* Index of predefined Linux client operations */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 14a4820..4899737 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -507,24 +507,6 @@ extern int nfs_mountpoint_expiry_timeout;
 extern void nfs_release_automount_timer(void);
 
 /*
- * linux/fs/nfs/nfs4proc.c
- */
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
-#endif
-
-/*
  * linux/fs/nfs/unlink.c
  */
 extern void nfs_complete_unlink(struct dentry *dentry, struct inode *);
-- 
1.8.4.2

