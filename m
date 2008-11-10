From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 48/85] nfs41: establish sessions-based clientid
Date: Mon, 10 Nov 2008 22:26:39 +0200
Message-ID: <1226348799-8828-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:59959 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbYKJU0p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:26:45 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsv4.1 clientid is established via EXCHANGE_ID rather than
SETCLIENTID{,_CONFIRM}

This is implemented using a new establish_clid method in
nfs4_state_recovery_ops.

nfs41: establish clientid via exchange id only if cred != NULL

>From 2.6.26 reclaimer() uses machine cred for setting up the client id
therefore it is never expected to be NULL.

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h   |    2 ++
 fs/nfs/nfs4proc.c  |    4 ++++
 fs/nfs/nfs4state.c |    5 +++--
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b9771f2..44282b0 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -163,6 +163,7 @@ struct nfs4_state_recovery_ops {
 	int (*recover_open)(struct nfs4_state_owner *, struct nfs4_state *);
 	int (*recover_lock)(struct nfs4_state *, struct file_lock *);
 	int (*renew_lease)(struct nfs_client *, struct rpc_cred *);
+	int (*establish_clid)(struct nfs_client *, struct rpc_cred *);
 };
 
 struct nfs4_state_maintenance_ops {
@@ -186,6 +187,7 @@ extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct rpc_cred *)
 extern int nfs4_proc_async_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_wait_bit_killable(void *);
+extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait);
 extern struct dentry *nfs4_atomic_open(struct inode *, struct dentry *, struct nameidata *);
 extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, struct nameidata *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8c28d0c..749027d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4904,6 +4904,7 @@ struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
 	.renew_lease	= nfs4_proc_renew,
+	.establish_clid = nfs4_init_clientid,
 };
 
 #if defined(CONFIG_NFS_V4_1)
@@ -4911,6 +4912,7 @@ struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
 	.renew_lease	= nfs4_proc_sequence,
+	.establish_clid = nfs4_proc_exchange_id,
 };
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -4918,6 +4920,7 @@ struct nfs4_state_recovery_ops nfs40_network_partition_recovery_ops = {
 	.recover_open	= nfs4_open_expired,
 	.recover_lock	= nfs4_lock_expired,
 	.renew_lease	= nfs4_proc_renew,
+	.establish_clid = nfs4_init_clientid,
 };
 
 #if defined(CONFIG_NFS_V4_1)
@@ -4925,6 +4928,7 @@ struct nfs4_state_recovery_ops nfs41_network_partition_recovery_ops = {
 	.recover_open	= nfs4_open_expired,
 	.recover_lock	= nfs4_lock_expired,
 	.renew_lease	= nfs4_proc_sequence,
+	.establish_clid = nfs4_proc_exchange_id,
 };
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 693e5a6..d3c5e92 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -62,7 +62,7 @@ const nfs4_stateid zero_stateid;
 
 static LIST_HEAD(nfs4_clientid_list);
 
-static int nfs4_init_client(struct nfs_client *clp, struct rpc_cred *cred)
+int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	int status = nfs4_proc_setclientid(clp, NFS4_CALLBACK,
 			nfs_callback_tcpport, cred);
@@ -991,8 +991,9 @@ restart_loop:
 	nfs4_state_mark_reclaim(clp);
 	status = -ENOENT;
 	cred = nfs4_get_setclientid_cred(clp);
+	dprintk("%s: setclientid_cred %p\n", __func__, cred);
 	if (cred != NULL) {
-		status = nfs4_init_client(clp, cred);
+		status = ops->establish_clid(clp, cred);
 		put_rpccred(cred);
 		/* Handle case where the user hasn't set up machine creds */
 		if (status == -EACCES && cred == clp->cl_machine_cred) {
-- 
1.6.0.2

