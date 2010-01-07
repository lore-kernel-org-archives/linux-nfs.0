From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/4] nfs: handle NFSv2 -EKEYEXPIRED returns from RPC layer appropriately
Date: Thu,  7 Jan 2010 09:42:05 -0500
Message-ID: <1262875325-4488-5-git-send-email-jlayton@redhat.com>
References: <1262875325-4488-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37768 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750939Ab0AGOma (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 09:42:30 -0500
In-Reply-To: <1262875325-4488-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a wrapper around rpc_call_sync that handles -EKEYEXPIRED errors from
the RPC layer as it would an -EJUKEBOX error if NFSv2 had such a thing.
Also, add a handler for that error for async calls that makes it
resubmit the RPC on -EKEYEXPIRED.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/proc.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index ef58385..2b6b6de 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -47,6 +47,39 @@
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
 /*
+ * wrapper to handle the -EKEYEXPIRED error message. This should generally
+ * only happen if using krb5 auth and a user's TGT expires. NFSv2 doesn't
+ * support the NFSERR_JUKEBOX error code, but we handle this situation in the
+ * same way that we handle that error with NFSv3.
+ */
+static int
+nfs_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
+{
+	int res;
+	do {
+		res = rpc_call_sync(clnt, msg, flags);
+		if (res != -EKEYEXPIRED)
+			break;
+		schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
+		res = -ERESTARTSYS;
+	} while (!fatal_signal_pending(current));
+	return res;
+}
+
+#define rpc_call_sync(clnt, msg, flags)	nfs_rpc_wrapper(clnt, msg, flags)
+
+static int
+nfs_async_handle_expired_key(struct rpc_task *task, struct inode *inode)
+{
+	if (task->tk_status != -EKEYEXPIRED)
+		return 0;
+	task->tk_status = 0;
+	rpc_restart_call(task);
+	rpc_delay(task, NFS_JUKEBOX_RETRY_TIME);
+	return 1;
+}
+
+/*
  * Bare-bones access to getattr: this is for nfs_read_super.
  */
 static int
@@ -307,6 +340,8 @@ nfs_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 
 static int nfs_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
+	if (nfs_async_handle_expired_key(task, dir))
+		return 0;
 	nfs_mark_for_revalidate(dir);
 	return 1;
 }
@@ -560,6 +595,9 @@ nfs_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 
 static int nfs_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
+	if (nfs_async_handle_expired_key(task, data->inode))
+		return -EAGAIN;
+
 	nfs_invalidate_atime(data->inode);
 	if (task->tk_status >= 0) {
 		nfs_refresh_inode(data->inode, data->res.fattr);
@@ -579,6 +617,9 @@ static void nfs_proc_read_setup(struct nfs_read_data *data, struct rpc_message *
 
 static int nfs_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
+	if (nfs_async_handle_expired_key(task, data->inode))
+		return -EAGAIN;
+
 	if (task->tk_status >= 0)
 		nfs_post_op_update_inode_force_wcc(data->inode, data->res.fattr);
 	return 0;
-- 
1.6.5.2

