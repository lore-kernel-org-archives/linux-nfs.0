Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15622 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753765Ab1AFCFJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 21:05:09 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V9 07/12] NFS implement v4.0 callback_ident
Date: Wed,  5 Jan 2011 21:04:30 -0500
Message-Id: <1294279475-8540-8-git-send-email-andros@netapp.com>
In-Reply-To: <1294279475-8540-7-git-send-email-andros@netapp.com>
References: <1294279475-8540-1-git-send-email-andros@netapp.com>
 <1294279475-8540-2-git-send-email-andros@netapp.com>
 <1294279475-8540-3-git-send-email-andros@netapp.com>
 <1294279475-8540-4-git-send-email-andros@netapp.com>
 <1294279475-8540-5-git-send-email-andros@netapp.com>
 <1294279475-8540-6-git-send-email-andros@netapp.com>
 <1294279475-8540-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Use the small id to pointer translator service to provide a unique callback
identifier per SETCLIENTID call used to identify the v4.0 callback service
associated with the clientid.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c           |   51 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/inode.c            |    1 +
 fs/nfs/internal.h         |    1 +
 fs/nfs/nfs4proc.c         |    1 +
 include/linux/nfs_fs_sb.h |    1 +
 5 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 855add6..bc3a862 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -56,6 +56,30 @@ static DEFINE_SPINLOCK(nfs_client_lock);
 static LIST_HEAD(nfs_client_list);
 static LIST_HEAD(nfs_volume_list);
 static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
+#ifdef CONFIG_NFS_V4
+static DEFINE_IDR(cb_ident_idr); /* Protected by nfs_client_lock */
+
+/*
+ * Get a unique NFSv4.0 callback identifier which will be used
+ * by the V4.0 callback service to lookup the nfs_client struct
+ */
+static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
+{
+	int ret = 0;
+
+	if (clp->rpc_ops->version != 4 || minorversion != 0)
+		return ret;
+retry:
+	if (!idr_pre_get(&cb_ident_idr, GFP_KERNEL))
+		return -ENOMEM;
+	spin_lock(&nfs_client_lock);
+	ret = idr_get_new(&cb_ident_idr, clp, &clp->cl_cb_ident);
+	spin_unlock(&nfs_client_lock);
+	if (ret == -EAGAIN)
+		goto retry;
+	return ret;
+}
+#endif /* CONFIG_NFS_V4 */
 
 /*
  * RPC cruft for NFS
@@ -144,6 +168,10 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_proto = cl_init->proto;
 
 #ifdef CONFIG_NFS_V4
+	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
+	if (err)
+		goto error_cleanup;
+
 	INIT_LIST_HEAD(&clp->cl_delegations);
 	spin_lock_init(&clp->cl_lock);
 	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
@@ -202,10 +230,32 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 
 	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
 }
+
+/* idr_remove_all is not needed as all id's are removed by nfs_put_client */
+void nfs_cleanup_cb_ident_idr(void)
+{
+	idr_destroy(&cb_ident_idr);
+}
+
+/* nfs_client_lock held */
+static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
+{
+	if (clp->cl_cb_ident)
+		idr_remove(&cb_ident_idr, clp->cl_cb_ident);
+}
+
 #else
 static void nfs4_shutdown_client(struct nfs_client *clp)
 {
 }
+
+void nfs_cleanup_cb_ident_idr(void)
+{
+}
+
+static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
+{
+}
 #endif /* CONFIG_NFS_V4 */
 
 /*
@@ -244,6 +294,7 @@ void nfs_put_client(struct nfs_client *clp)
 
 	if (atomic_dec_and_lock(&clp->cl_count, &nfs_client_lock)) {
 		list_del(&clp->cl_share_link);
+		nfs_cb_idr_remove_locked(clp);
 		spin_unlock(&nfs_client_lock);
 
 		BUG_ON(!list_empty(&clp->cl_superblocks));
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e67e31c..c7782b2 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1612,6 +1612,7 @@ static void __exit exit_nfs_fs(void)
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister("nfs");
 #endif
+	nfs_cleanup_cb_ident_idr();
 	unregister_nfs_fs();
 	nfs_fs_proc_exit();
 	nfsiod_stop();
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 435eae3..7c803c9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -128,6 +128,7 @@ extern void nfs_umount(const struct nfs_mount_request *info);
 /* client.c */
 extern struct rpc_program nfs_program;
 
+extern void nfs_cleanup_cb_ident_idr(void);
 extern void nfs_put_client(struct nfs_client *);
 extern struct nfs_client *nfs_find_client(const struct sockaddr *, u32);
 extern struct nfs_client *nfs_find_client_next(struct nfs_client *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 78b0899..d3510ba 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3478,6 +3478,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 	struct nfs4_setclientid setclientid = {
 		.sc_verifier = &sc_verifier,
 		.sc_prog = program,
+		.sc_cb_ident = clp->cl_cb_ident,
 	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SETCLIENTID],
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 452d964..1eaa054 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -71,6 +71,7 @@ struct nfs_client {
 	 */
 	char			cl_ipaddr[48];
 	unsigned char		cl_id_uniquifier;
+	u32			cl_cb_ident;	/* v4.0 callback identifier */
 	const struct nfs4_minor_version_ops *cl_mvops;
 #endif /* CONFIG_NFS_V4 */
 
-- 
1.6.6

