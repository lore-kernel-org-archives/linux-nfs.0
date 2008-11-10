From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 46/85] nfs41: introduce get_state_renewal_cred
Date: Mon, 10 Nov 2008 22:26:17 +0200
Message-ID: <1226348777-8761-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48855 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbYKJU0Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:26:25 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Reuse the cred used at exchange_id time for
sending SEQUENCE to renew the client's lease.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c           |    4 ++++
 fs/nfs/nfs4_fs.h          |    4 ++++
 fs/nfs/nfs4proc.c         |   13 +++++++++++++
 fs/nfs/nfs4renewd.c       |    2 +-
 fs/nfs/nfs4state.c        |   14 +++++++++++++-
 include/linux/nfs_fs_sb.h |    1 +
 6 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 560b10b..c69424d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -207,6 +207,10 @@ static void nfs_free_client(struct nfs_client *clp)
 
 	if (clp->cl_machine_cred != NULL)
 		put_rpccred(clp->cl_machine_cred);
+#ifdef CONFIG_NFS_V4_1
+	if (clp->cl_ex_cred != NULL)
+		put_rpccred(clp->cl_ex_cred);
+#endif /* CONFIG_NFS_V4_1 */
 
 	kfree(clp->cl_hostname);
 	kfree(clp);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ff367df..904b19e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -167,6 +167,7 @@ struct nfs4_state_recovery_ops {
 
 struct nfs4_state_maintenance_ops {
 	int (*sched_state_renewal)(struct nfs_client *, struct rpc_cred *);
+	struct rpc_cred * (*get_state_renewal_cred)(struct nfs_client *);
 };
 
 extern struct dentry_operations nfs4_dentry_operations;
@@ -228,6 +229,9 @@ extern void nfs4_renew_state(struct work_struct *);
 
 /* nfs4state.c */
 struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp);
+#ifdef CONFIG_NFS_V4_1
+struct rpc_cred *nfs41_get_state_renewal_cred(struct nfs_client *clp);
+#endif /* CONFIG_NFS_V4_1 */
 
 extern struct nfs4_state_owner * nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *);
 extern void nfs4_put_state_owner(struct nfs4_state_owner *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 12f3b9f..5b1f6d0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4317,6 +4317,17 @@ static int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 		else if (++clp->cl_id_uniquifier == 0)
 			break;
 	}
+	if (status == 0) {
+		if (clp->cl_ex_cred) {
+			dprintk("%s put cl_ex_cred %p\n", __func__,
+				clp->cl_ex_cred);
+			put_rpccred(clp->cl_ex_cred);
+		}
+
+		BUG_ON(cred == NULL);
+		clp->cl_ex_cred = get_rpccred(cred);
+		dprintk("%s set cl_ex_cred %p\n", __func__, clp->cl_ex_cred);
+	}
 
 	dprintk("<-- %s status= %d\n", __func__, status);
 	return status;
@@ -4907,11 +4918,13 @@ struct nfs4_state_recovery_ops nfs41_network_partition_recovery_ops = {
 
 struct nfs4_state_maintenance_ops nfs40_state_renewal_ops = {
 	.sched_state_renewal = nfs4_proc_async_renew,
+	.get_state_renewal_cred = nfs4_get_renew_cred,
 };
 
 #if defined(CONFIG_NFS_V4_1)
 struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 	.sched_state_renewal = nfs41_proc_async_sequence,
+	.get_state_renewal_cred = nfs41_get_state_renewal_cred,
 };
 #endif
 
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index a1bab0c..1d609ed 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -79,7 +79,7 @@ nfs4_renew_state(struct work_struct *work)
 	timeout = (2 * lease) / 3 + (long)last - (long)now;
 	/* Are we close to a lease timeout? */
 	if (time_after(now, last + lease/3)) {
-		cred = nfs4_get_renew_cred(clp);
+		cred = ops->get_state_renewal_cred(clp);
 		if (cred == NULL) {
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 			spin_unlock(&clp->cl_lock);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index cf6666d..5a91072 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -73,6 +73,16 @@ static int nfs4_init_client(struct nfs_client *clp, struct rpc_cred *cred)
 	return status;
 }
 
+#if defined(CONFIG_NFS_V4_1)
+struct rpc_cred *
+nfs41_get_state_renewal_cred(struct nfs_client *clp)
+{
+	if (clp->cl_ex_cred)
+		get_rpccred(clp->cl_ex_cred);
+	return (clp->cl_ex_cred);
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 static struct rpc_cred *nfs4_get_machine_cred(struct nfs_client *clp)
 {
 	struct rpc_cred *cred = NULL;
@@ -943,6 +953,7 @@ static int reclaimer(void *ptr)
 	struct nfs4_state_owner *sp;
 	struct rb_node *pos;
 	struct nfs4_state_recovery_ops *ops;
+	struct nfs4_state_maintenance_ops *m_ops;
 	struct rpc_cred *cred;
 	int status = 0;
 
@@ -957,8 +968,9 @@ static int reclaimer(void *ptr)
 restart_loop:
 	dprintk("%s: starting loop\n", __func__);
 	ops = nfs4_network_partition_recovery_ops[clp->cl_minorversion];
+	m_ops = nfs4_state_renewal_ops[clp->cl_minorversion];
 	/* Are there any open files on this volume? */
-	cred = nfs4_get_renew_cred(clp);
+	cred = m_ops->get_state_renewal_cred(clp);
 	if (cred != NULL) {
 		/* Yes there are: try to renew the old lease */
 		status = ops->renew_lease(clp, cred);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 9917c09..17720b9 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -81,6 +81,7 @@ struct nfs_client {
 	u32			cl_seqid;
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
 	u32			cl_exchange_flags;
+	struct rpc_cred		*cl_ex_cred;	/* exchange_id credential */
 	struct nfs4_session	*cl_session; 	/* sharred session */
 #endif /* CONFIG_NFS_V4_1 */
 };
-- 
1.6.0.2

