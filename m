Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f45.google.com ([209.85.213.45]:59997 "EHLO
	mail-yh0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968171Ab3HIQtN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:49:13 -0400
Received: by mail-yh0-f45.google.com with SMTP id i72so156632yha.4
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:49:12 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id e69sm20694751yhl.3.2013.08.09.09.49.11
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:49:12 -0700 (PDT)
Subject: [PATCH v2 10/33] NFS: Add a slot table to struct nfs_client for
 NFSv4.0 transport blocking
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:49:11 -0400
Message-ID: <20130809164910.5362.84774.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Anchor an nfs4_slot_table in the nfs_client for use with NFSv4.0
transport blocking.  It is initialized only for NFSv4.0 nfs_client's.

Introduce appropriate minor version ops to handle nfs_client
initialization and shutdown requirements that differ for each minor
version.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h          |    6 +++
 fs/nfs/nfs4client.c       |  101 +++++++++++++++++++++++++++++++++------------
 fs/nfs/nfs4proc.c         |    6 +++
 include/linux/nfs_fs_sb.h |    3 +
 4 files changed, 89 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 8de9b93..af2d5bf 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -38,6 +38,8 @@ struct nfs4_minor_version_ops {
 	u32	minor_version;
 	unsigned init_caps;
 
+	int	(*init_client)(struct nfs_client *);
+	void	(*shutdown_client)(struct nfs_client *);
 	bool	(*match_stateid)(const nfs4_stateid *,
 			const nfs4_stateid *);
 	int	(*find_root_sec)(struct nfs_server *, struct nfs_fh *,
@@ -292,6 +294,10 @@ extern const u32 nfs4_pathconf_bitmap[3];
 extern const u32 nfs4_fsinfo_bitmap[3];
 extern const u32 nfs4_fs_locations_bitmap[3];
 
+void nfs40_shutdown_client(struct nfs_client *);
+void nfs41_shutdown_client(struct nfs_client *);
+int nfs40_init_client(struct nfs_client *);
+int nfs41_init_client(struct nfs_client *);
 void nfs4_free_client(struct nfs_client *);
 
 struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 90dce91..eedd686 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -41,7 +41,7 @@ static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
 }
 
 #ifdef CONFIG_NFS_V4_1
-static void nfs4_shutdown_session(struct nfs_client *clp)
+void nfs41_shutdown_client(struct nfs_client *clp)
 {
 	if (nfs4_has_session(clp)) {
 		nfs4_destroy_session(clp->cl_session);
@@ -49,11 +49,15 @@ static void nfs4_shutdown_session(struct nfs_client *clp)
 	}
 
 }
-#else /* CONFIG_NFS_V4_1 */
-static void nfs4_shutdown_session(struct nfs_client *clp)
+#endif	/* CONFIG_NFS_V4_1 */
+
+void nfs40_shutdown_client(struct nfs_client *clp)
 {
+	if (clp->cl_slot_tbl) {
+		nfs4_release_slot_table(clp->cl_slot_tbl);
+		kfree(clp->cl_slot_tbl);
+	}
 }
-#endif /* CONFIG_NFS_V4_1 */
 
 struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
 {
@@ -97,7 +101,7 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 {
 	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
 		nfs4_kill_renewd(clp);
-	nfs4_shutdown_session(clp);
+	clp->cl_mvops->shutdown_client(clp);
 	nfs4_destroy_callback(clp);
 	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
 		nfs_idmap_delete(clp);
@@ -144,34 +148,77 @@ static int nfs4_init_callback(struct nfs_client *clp)
 	return 0;
 }
 
+/**
+ * nfs40_init_client - nfs_client initialization tasks for NFSv4.0
+ * @clp - nfs_client to initialize
+ *
+ * Returns zero on success, or a negative errno if some error occurred.
+ */
+int nfs40_init_client(struct nfs_client *clp)
+{
+	struct nfs4_slot_table *tbl;
+	int ret;
+
+	tbl = kzalloc(sizeof(*tbl), GFP_NOFS);
+	if (tbl == NULL)
+		return -ENOMEM;
+
+	ret = nfs4_setup_slot_table(tbl, NFS4_MAX_SLOT_TABLE,
+					"NFSv4.0 transport Slot table");
+	if (ret) {
+		kfree(tbl);
+		return ret;
+	}
+
+	clp->cl_slot_tbl = tbl;
+	return 0;
+}
+
+#if defined(CONFIG_NFS_V4_1)
+
+/**
+ * nfs41_init_client - nfs_client initialization tasks for NFSv4.1+
+ * @clp - nfs_client to initialize
+ *
+ * Returns zero on success, or a negative errno if some error occurred.
+ */
+int nfs41_init_client(struct nfs_client *clp)
+{
+	struct nfs4_session *session = NULL;
+
+	/*
+	 * Create the session and mark it expired.
+	 * When a SEQUENCE operation encounters the expired session
+	 * it will do session recovery to initialize it.
+	 */
+	session = nfs4_alloc_session(clp);
+	if (!session)
+		return -ENOMEM;
+
+	clp->cl_session = session;
+
+	/*
+	 * The create session reply races with the server back
+	 * channel probe. Mark the client NFS_CS_SESSION_INITING
+	 * so that the client back channel can find the
+	 * nfs_client struct
+	 */
+	nfs_mark_client_ready(clp, NFS_CS_SESSION_INITING);
+	return 0;
+}
+
+#endif	/* CONFIG_NFS_V4_1 */
+
 /*
  * Initialize the minor version specific parts of an NFS4 client record
  */
 static int nfs4_init_client_minor_version(struct nfs_client *clp)
 {
-#if defined(CONFIG_NFS_V4_1)
-	if (clp->cl_mvops->minor_version) {
-		struct nfs4_session *session = NULL;
-		/*
-		 * Create the session and mark it expired.
-		 * When a SEQUENCE operation encounters the expired session
-		 * it will do session recovery to initialize it.
-		 */
-		session = nfs4_alloc_session(clp);
-		if (!session)
-			return -ENOMEM;
-
-		clp->cl_session = session;
-		/*
-		 * The create session reply races with the server back
-		 * channel probe. Mark the client NFS_CS_SESSION_INITING
-		 * so that the client back channel can find the
-		 * nfs_client struct
-		 */
-		nfs_mark_client_ready(clp, NFS_CS_SESSION_INITING);
-	}
-#endif /* CONFIG_NFS_V4_1 */
+	int ret;
 
+	ret = clp->cl_mvops->init_client(clp);
+	if (ret)
+		return ret;
 	return nfs4_init_callback(clp);
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0ba7e35..4352d51 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7417,6 +7417,8 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 		| NFS_CAP_ATOMIC_OPEN
 		| NFS_CAP_CHANGE_ATTR
 		| NFS_CAP_POSIX_LOCK,
+	.init_client = nfs40_init_client,
+	.shutdown_client = nfs40_shutdown_client,
 	.match_stateid = nfs4_match_stateid,
 	.find_root_sec = nfs4_find_root_sec,
 	.free_lock_state = nfs4_release_lockowner,
@@ -7435,6 +7437,8 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1,
+	.init_client = nfs41_init_client,
+	.shutdown_client = nfs41_shutdown_client,
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
 	.free_lock_state = nfs41_free_lock_state,
@@ -7454,6 +7458,8 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1,
+	.init_client = nfs41_init_client,
+	.shutdown_client = nfs41_shutdown_client,
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
 	.free_lock_state = nfs41_free_lock_state,
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index d221243..fc83d3d 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -78,6 +78,9 @@ struct nfs_client {
 	u32			cl_cb_ident;	/* v4.0 callback identifier */
 	const struct nfs4_minor_version_ops *cl_mvops;
 
+	/* NFSv4.0 transport blocking */
+	struct nfs4_slot_table	*cl_slot_tbl;
+
 	/* The sequence id to use for the next CREATE_SESSION */
 	u32			cl_seqid;
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */

