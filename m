From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 24/85] nfs41: stubs for nfs41 procedures
Date: Mon, 10 Nov 2008 22:22:13 +0200
Message-ID: <1226348533-7989-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48758 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbYKJUWU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:22:20 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h  |    2 ++
 fs/nfs/nfs4proc.c |   26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a28427f..dd3a6d0 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -192,6 +192,8 @@ extern struct nfs4_state_recovery_ops nfs4_network_partition_recovery_ops;
 extern void nfs4_put_session(struct nfs4_session **session);
 extern void nfs4_get_session(struct nfs_client *clp);
 extern struct nfs4_session *nfs4_alloc_session(void);
+extern int nfs4_proc_create_session(struct nfs4_session *);
+extern int nfs4_proc_destroy_session(struct nfs4_session *);
 #endif /* CONFIG_NFS_V4_1 */
 
 extern const u32 nfs4_fattr_bitmap[2];
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d26f61d..6418aa8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3825,6 +3825,11 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 }
 
 #ifdef CONFIG_NFS_V4_1
+static int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
+{
+	return -1;	/* stub */
+}
+
 /*
  * Initialize slot table
  *
@@ -3947,6 +3952,27 @@ void nfs4_get_session(struct nfs_client *clp)
 	if (clp->cl_minorversion == 1)
 		atomic_inc(&clp->cl_session->ref_count);
 }
+
+int nfs4_proc_create_session(struct nfs4_session *session)
+{
+	return -1;	/* stub */
+}
+
+int nfs4_proc_destroy_session(struct nfs4_session *session)
+{
+	return -1;	/* stub */
+}
+
+static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
+{
+	return -1;	/* stub */
+}
+
+static int nfs41_proc_async_sequence(struct nfs_client *clp,
+				     struct rpc_cred *cred)
+{
+	return -1;	/* stub */
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops = {
-- 
1.6.0.2

