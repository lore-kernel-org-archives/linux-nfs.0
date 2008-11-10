From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 41/85] nfs41: lease renewal
Date: Mon, 10 Nov 2008 22:25:24 +0200
Message-ID: <1226348724-8592-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48833 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbYKJUZa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:25:30 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Send a NFSv4.1 SEQUENCE op rather than RENEW that was deprecated in
minorversion 1.
Use the nfs_client minorversion to select reboot_recover/
network_partition_recovery/state_renewal ops.

Note: we use reclaimer to create the nfs41 session before there are any
cl_superblocks for the nfs_client.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h    |   11 +++++++-
 fs/nfs/nfs4proc.c   |   60 +++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4renewd.c |    5 ++-
 fs/nfs/nfs4state.c  |   21 +++++++++--------
 4 files changed, 81 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 8cdc3c4..ff367df 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -162,6 +162,11 @@ struct nfs4_exception {
 struct nfs4_state_recovery_ops {
 	int (*recover_open)(struct nfs4_state_owner *, struct nfs4_state *);
 	int (*recover_lock)(struct nfs4_state *, struct file_lock *);
+	int (*renew_lease)(struct nfs_client *, struct rpc_cred *);
+};
+
+struct nfs4_state_maintenance_ops {
+	int (*sched_state_renewal)(struct nfs_client *, struct rpc_cred *);
 };
 
 extern struct dentry_operations nfs4_dentry_operations;
@@ -187,8 +192,8 @@ extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fh
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
 
-extern struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops;
-extern struct nfs4_state_recovery_ops nfs4_network_partition_recovery_ops;
+extern struct nfs4_state_recovery_ops *nfs4_reboot_recovery_ops[];
+extern struct nfs4_state_recovery_ops *nfs4_network_partition_recovery_ops[];
 #if defined(CONFIG_NFS_V4_1)
 extern int nfs4_setup_sequence(struct nfs_client *clp,
 	struct nfs41_sequence_args *args, struct nfs41_sequence_res *res,
@@ -207,6 +212,8 @@ static inline int nfs4_setup_sequence(struct nfs_client *clp,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+extern struct nfs4_state_maintenance_ops *nfs4_state_renewal_ops[];
+
 extern const u32 nfs4_fattr_bitmap[2];
 extern const u32 nfs4_statfs_bitmap[2];
 extern const u32 nfs4_pathconf_bitmap[2];
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 41f4f74..f6107b0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2966,6 +2966,9 @@ static void nfs4_renew_done(struct rpc_task *task, void *data)
 	if (time_before(clp->cl_last_renewal,timestamp))
 		clp->cl_last_renewal = timestamp;
 	spin_unlock(&clp->cl_lock);
+	dprintk("%s calling put_rpccred on rpc_cred %p\n", __func__,
+				task->tk_msg.rpc_cred);
+	put_rpccred(task->tk_msg.rpc_cred);
 }
 
 static const struct rpc_call_ops nfs4_renew_ops = {
@@ -4788,14 +4791,67 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops = {
+struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
+	.renew_lease	= nfs4_proc_renew,
 };
 
-struct nfs4_state_recovery_ops nfs4_network_partition_recovery_ops = {
+#if defined(CONFIG_NFS_V4_1)
+struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
+	.recover_open	= nfs4_open_reclaim,
+	.recover_lock	= nfs4_lock_reclaim,
+	.renew_lease	= nfs4_proc_sequence,
+};
+#endif /* CONFIG_NFS_V4_1 */
+
+struct nfs4_state_recovery_ops nfs40_network_partition_recovery_ops = {
 	.recover_open	= nfs4_open_expired,
 	.recover_lock	= nfs4_lock_expired,
+	.renew_lease	= nfs4_proc_renew,
+};
+
+#if defined(CONFIG_NFS_V4_1)
+struct nfs4_state_recovery_ops nfs41_network_partition_recovery_ops = {
+	.recover_open	= nfs4_open_expired,
+	.recover_lock	= nfs4_lock_expired,
+	.renew_lease	= nfs4_proc_sequence,
+};
+#endif /* CONFIG_NFS_V4_1 */
+
+struct nfs4_state_maintenance_ops nfs40_state_renewal_ops = {
+	.sched_state_renewal = nfs4_proc_async_renew,
+};
+
+#if defined(CONFIG_NFS_V4_1)
+struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
+	.sched_state_renewal = nfs41_proc_async_sequence,
+};
+#endif
+
+/*
+ * Per minor version reboot and network partition recovery ops
+ */
+
+struct nfs4_state_recovery_ops *nfs4_reboot_recovery_ops[] = {
+	&nfs40_reboot_recovery_ops,
+#if defined(CONFIG_NFS_V4_1)
+	&nfs41_reboot_recovery_ops,
+#endif
+};
+
+struct nfs4_state_recovery_ops *nfs4_network_partition_recovery_ops[] = {
+	&nfs40_network_partition_recovery_ops,
+#if defined(CONFIG_NFS_V4_1)
+	&nfs41_network_partition_recovery_ops,
+#endif
+};
+
+struct nfs4_state_maintenance_ops *nfs4_state_renewal_ops[] = {
+	&nfs40_state_renewal_ops,
+#if defined(CONFIG_NFS_V4_1)
+	&nfs41_state_renewal_ops,
+#endif
 };
 
 static const struct inode_operations nfs4_file_inode_operations = {
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 3305acb..a1bab0c 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -59,12 +59,14 @@
 void
 nfs4_renew_state(struct work_struct *work)
 {
+	struct nfs4_state_maintenance_ops *ops;
 	struct nfs_client *clp =
 		container_of(work, struct nfs_client, cl_renewd.work);
 	struct rpc_cred *cred;
 	long lease, timeout;
 	unsigned long last, now;
 
+	ops = nfs4_state_renewal_ops[clp->cl_minorversion];
 	down_read(&clp->cl_sem);
 	dprintk("%s: start\n", __func__);
 	/* Are there any active superblocks? */
@@ -86,8 +88,7 @@ nfs4_renew_state(struct work_struct *work)
 		}
 		spin_unlock(&clp->cl_lock);
 		/* Queue an asynchronous RENEW. */
-		nfs4_proc_async_renew(clp, cred);
-		put_rpccred(cred);
+		ops->sched_state_renewal(clp, cred);
 		timeout = (2 * lease) / 3;
 		spin_lock(&clp->cl_lock);
 	} else
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 09ca7b1..cf6666d 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -952,24 +952,24 @@ static int reclaimer(void *ptr)
 	/* Ensure exclusive access to NFSv4 state */
 	down_write(&clp->cl_sem);
 	/* Are there any NFS mounts out there? */
-	if (list_empty(&clp->cl_superblocks))
+	if (clp->cl_minorversion == 0 && list_empty(&clp->cl_superblocks))
 		goto out;
 restart_loop:
 	dprintk("%s: starting loop\n", __func__);
-	ops = &nfs4_network_partition_recovery_ops;
+	ops = nfs4_network_partition_recovery_ops[clp->cl_minorversion];
 	/* Are there any open files on this volume? */
 	cred = nfs4_get_renew_cred(clp);
 	if (cred != NULL) {
 		/* Yes there are: try to renew the old lease */
-		status = nfs4_proc_renew(clp, cred);
+		status = ops->renew_lease(clp, cred);
 		put_rpccred(cred);
 		switch (status) {
-			case 0:
-			case -NFS4ERR_CB_PATH_DOWN:
-				goto out;
-			case -NFS4ERR_STALE_CLIENTID:
-			case -NFS4ERR_LEASE_MOVED:
-				ops = &nfs4_reboot_recovery_ops;
+		case 0:
+		case -NFS4ERR_CB_PATH_DOWN:
+			goto out;
+		case -NFS4ERR_STALE_CLIENTID:
+		case -NFS4ERR_LEASE_MOVED:
+			ops = nfs4_reboot_recovery_ops[clp->cl_minorversion];
 		}
 	} else {
 		/* "reboot" to ensure we clear all state on the server */
@@ -998,7 +998,8 @@ restart_loop:
 		status = nfs4_reclaim_open_state(ops, sp);
 		if (status < 0) {
 			if (status == -NFS4ERR_NO_GRACE) {
-				ops = &nfs4_network_partition_recovery_ops;
+				ops = nfs4_network_partition_recovery_ops[
+							clp->cl_minorversion];
 				status = nfs4_reclaim_open_state(ops, sp);
 			}
 			if (status == -NFS4ERR_STALE_CLIENTID)
-- 
1.6.0.2

