From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 62/67] nfs41: establish sessions-based clientid
Date: Thu,  2 Apr 2009 16:59:24 +0300
Message-ID: <1238680764-15341-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30602 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757488AbZDBN7h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:59:37 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfsv4.1 clientid is established via EXCHANGE_ID rather than
SETCLIENTID{,_CONFIRM}

This is implemented using a new establish_clid method in
nfs4_state_recovery_ops.

nfs41: establish clientid via exchange id only if cred != NULL

>From 2.6.26 reclaimer() uses machine cred for setting up the client id
therefore it is never expected to be NULL.

Signed-off-by: Rahul Iyer <iyer@netapp.com>
[removed dprintk]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: lease renewal]
[revamped patch for new nfs4_state_manager design]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h   |    6 ++++--
 fs/nfs/nfs4proc.c  |   40 ++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4state.c |   12 ++++++++----
 3 files changed, 50 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 757245e..e74d310 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -178,6 +178,7 @@ struct nfs4_state_recovery_ops {
 	int state_flag_bit;
 	int (*recover_open)(struct nfs4_state_owner *, struct nfs4_state *);
 	int (*recover_lock)(struct nfs4_state *, struct file_lock *);
+	int (*establish_clid)(struct nfs_client *, struct rpc_cred *);
 };
 
 struct nfs4_state_maintenance_ops {
@@ -200,6 +201,7 @@ extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struc
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_async_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
+extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait);
 extern struct dentry *nfs4_atomic_open(struct inode *, struct dentry *, struct nameidata *);
 extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, struct nameidata *);
@@ -207,8 +209,8 @@ extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fh
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
 
-extern struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops;
-extern struct nfs4_state_recovery_ops nfs4_nograce_recovery_ops;
+extern struct nfs4_state_recovery_ops *nfs4_reboot_recovery_ops[];
+extern struct nfs4_state_recovery_ops *nfs4_nograce_recovery_ops[];
 #if defined(CONFIG_NFS_V4_1)
 extern int nfs4_setup_sequence(struct nfs_client *clp,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fd8a950..7ad40fa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4795,19 +4795,41 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp,
 
 #endif /* CONFIG_NFS_V4_1 */
 
-struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops = {
+struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 	.owner_flag_bit = NFS_OWNER_RECLAIM_REBOOT,
 	.state_flag_bit	= NFS_STATE_RECLAIM_REBOOT,
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
+	.establish_clid = nfs4_init_clientid,
 };
 
-struct nfs4_state_recovery_ops nfs4_nograce_recovery_ops = {
+#if defined(CONFIG_NFS_V4_1)
+struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
+	.owner_flag_bit = NFS_OWNER_RECLAIM_REBOOT,
+	.state_flag_bit	= NFS_STATE_RECLAIM_REBOOT,
+	.recover_open	= nfs4_open_reclaim,
+	.recover_lock	= nfs4_lock_reclaim,
+	.establish_clid = nfs4_proc_exchange_id,
+};
+#endif /* CONFIG_NFS_V4_1 */
+
+struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
+	.owner_flag_bit = NFS_OWNER_RECLAIM_NOGRACE,
+	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
+	.recover_open	= nfs4_open_expired,
+	.recover_lock	= nfs4_lock_expired,
+	.establish_clid = nfs4_init_clientid,
+};
+
+#if defined(CONFIG_NFS_V4_1)
+struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
 	.owner_flag_bit = NFS_OWNER_RECLAIM_NOGRACE,
 	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
 	.recover_open	= nfs4_open_expired,
 	.recover_lock	= nfs4_lock_expired,
+	.establish_clid = nfs4_proc_exchange_id,
 };
+#endif /* CONFIG_NFS_V4_1 */
 
 struct nfs4_state_maintenance_ops nfs40_state_renewal_ops = {
 	.sched_state_renewal = nfs4_proc_async_renew,
@@ -4827,6 +4849,20 @@ struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
  * Per minor version reboot and network partition recovery ops
  */
 
+struct nfs4_state_recovery_ops *nfs4_reboot_recovery_ops[] = {
+	&nfs40_reboot_recovery_ops,
+#if defined(CONFIG_NFS_V4_1)
+	&nfs41_reboot_recovery_ops,
+#endif
+};
+
+struct nfs4_state_recovery_ops *nfs4_nograce_recovery_ops[] = {
+	&nfs40_nograce_recovery_ops,
+#if defined(CONFIG_NFS_V4_1)
+	&nfs41_nograce_recovery_ops,
+#endif
+};
+
 struct nfs4_state_maintenance_ops *nfs4_state_renewal_ops[] = {
 	&nfs40_state_renewal_ops,
 #if defined(CONFIG_NFS_V4_1)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index da940ab..e17bd44 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -60,7 +60,7 @@ const nfs4_stateid zero_stateid;
 
 static LIST_HEAD(nfs4_clientid_list);
 
-static int nfs4_init_client(struct nfs_client *clp, struct rpc_cred *cred)
+int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	unsigned short port;
 	int status;
@@ -1098,11 +1098,13 @@ out:
 static int nfs4_reclaim_lease(struct nfs_client *clp)
 {
 	struct rpc_cred *cred;
+	struct nfs4_state_recovery_ops *ops =
+		nfs4_reboot_recovery_ops[clp->cl_minorversion];
 	int status = -ENOENT;
 
 	cred = nfs4_get_setclientid_cred(clp);
 	if (cred != NULL) {
-		status = nfs4_init_client(clp, cred);
+		status = ops->establish_clid(clp, cred);
 		put_rpccred(cred);
 		/* Handle case where the user hasn't set up machine creds */
 		if (status == -EACCES && cred == clp->cl_machine_cred) {
@@ -1208,7 +1210,8 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		}
 		/* First recover reboot state... */
 		if (test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
-			status = nfs4_do_reclaim(clp, &nfs4_reboot_recovery_ops);
+			status = nfs4_do_reclaim(clp,
+				nfs4_reboot_recovery_ops[clp->cl_minorversion]);
 			if (status == -NFS4ERR_STALE_CLIENTID)
 				continue;
 			if (test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state))
@@ -1219,7 +1222,8 @@ static void nfs4_state_manager(struct nfs_client *clp)
 
 		/* Now recover expired state... */
 		if (test_and_clear_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state)) {
-			status = nfs4_do_reclaim(clp, &nfs4_nograce_recovery_ops);
+			status = nfs4_do_reclaim(clp,
+				nfs4_nograce_recovery_ops[clp->cl_minorversion]);
 			if (status < 0) {
 				set_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state);
 				if (status == -NFS4ERR_STALE_CLIENTID)
-- 
1.6.2.1

