From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 59/67] nfs41: lease renewal
Date: Thu,  2 Apr 2009 16:59:00 +0300
Message-ID: <1238680740-15247-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1833 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756924AbZDBN7e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:59:34 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Send a NFSv4.1 SEQUENCE op rather than RENEW that was deprecated in
minorversion 1.
Use the nfs_client minorversion to select reboot_recover/
network_partition_recovery/state_renewal ops.

Note: we use reclaimer to create the nfs41 session before there are any
cl_superblocks for the nfs_client.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: check for session not minorversion]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[revamped patch for new nfs4_state_manager design]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: obliterate nfs4_state_recovery_ops.renew_lease method]
    moved to nfs4_state_maintenance_ops
[also undid per-minorversion nfs4_state_recovery_ops here]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h    |    6 ++++++
 fs/nfs/nfs4proc.c   |   24 ++++++++++++++++++++++++
 fs/nfs/nfs4renewd.c |    4 +++-
 3 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ea59327..43310ee 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -180,6 +180,10 @@ struct nfs4_state_recovery_ops {
 	int (*recover_lock)(struct nfs4_state *, struct file_lock *);
 };
 
+struct nfs4_state_maintenance_ops {
+	int (*sched_state_renewal)(struct nfs_client *, struct rpc_cred *);
+};
+
 extern struct dentry_operations nfs4_dentry_operations;
 extern const struct inode_operations nfs4_dir_inode_operations;
 
@@ -220,6 +224,8 @@ static inline int nfs4_setup_sequence(struct nfs_client *clp,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+extern struct nfs4_state_maintenance_ops *nfs4_state_renewal_ops[];
+
 extern const u32 nfs4_fattr_bitmap[2];
 extern const u32 nfs4_statfs_bitmap[2];
 extern const u32 nfs4_pathconf_bitmap[2];
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3b3d1df..f047185 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3031,6 +3031,9 @@ static void nfs4_renew_done(struct rpc_task *task, void *data)
 	if (time_before(clp->cl_last_renewal,timestamp))
 		clp->cl_last_renewal = timestamp;
 	spin_unlock(&clp->cl_lock);
+	dprintk("%s calling put_rpccred on rpc_cred %p\n", __func__,
+				task->tk_msg.rpc_cred);
+	put_rpccred(task->tk_msg.rpc_cred);
 }
 
 static const struct rpc_call_ops nfs4_renew_ops = {
@@ -4805,6 +4808,27 @@ struct nfs4_state_recovery_ops nfs4_nograce_recovery_ops = {
 	.recover_lock	= nfs4_lock_expired,
 };
 
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
+struct nfs4_state_maintenance_ops *nfs4_state_renewal_ops[] = {
+	&nfs40_state_renewal_ops,
+#if defined(CONFIG_NFS_V4_1)
+	&nfs41_state_renewal_ops,
+#endif
+};
+
 static const struct inode_operations nfs4_file_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index f524e93..92b43e8 100644
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
 	dprintk("%s: start\n", __func__);
 	/* Are there any active superblocks? */
 	if (list_empty(&clp->cl_superblocks))
@@ -86,7 +88,7 @@ nfs4_renew_state(struct work_struct *work)
 			nfs_expire_all_delegations(clp);
 		} else {
 			/* Queue an asynchronous RENEW. */
-			nfs4_proc_async_renew(clp, cred);
+			ops->sched_state_renewal(clp, cred);
 			put_rpccred(cred);
 		}
 		timeout = (2 * lease) / 3;
-- 
1.6.2.1

