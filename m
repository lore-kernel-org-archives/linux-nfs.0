Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35196 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751282AbdDADQH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 31 Mar 2017 23:16:07 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 6/6] NFS: Always wait for I/O completion before unlock
Date: Fri, 31 Mar 2017 23:16:03 -0400
Message-Id: <8d98330d8b00b662b7202b8a0dbcd73f70d30696.1491015671.git.bcodding@redhat.com>
In-Reply-To: <cover.1491015671.git.bcodding@redhat.com>
References: <cover.1491015671.git.bcodding@redhat.com>
In-Reply-To: <cover.1491015671.git.bcodding@redhat.com>
References: <cover.1491015671.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS attempts to wait for read and write completion before unlocking in
order to ensure that the data returned was protected by the lock.  When
this waiting is interrupted by a signal, the unlock may be skipped, and
messages similar to the following are seen in the kernel ring buffer:

[20.167876] Leaked locks on dev=0x0:0x2b ino=0x8dd4c3:
[20.168286] POSIX: fl_owner=ffff880078b06940 fl_flags=0x1 fl_type=0x0 fl_pid=20183
[20.168727] POSIX: fl_owner=ffff880078b06680 fl_flags=0x1 fl_type=0x0 fl_pid=20185

For NFSv3, the missing unlock will cause the server to refuse conflicting
locks indefinitely.  For NFSv4, the leftover lock will be removed by the
server after the lease timeout.

This patch fixes this issue by skipping the usual wait in
nfs_iocounter_wait if the FL_CLOSE flag is set when signaled.  Instead, the
wait happens in the unlock RPC task on the NFS UOC rpc_waitqueue.

For NFSv3, use lockd's new nlmclnt_operations along with
nfs_async_iocounter_wait to defer NLM's unlock task until the lock
context's iocounter reaches zero.

For NFSv4, call nfs_async_iocounter_wait() directly from unlock's
current rpc_call_prepare.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/file.c     | 10 +++++-----
 fs/nfs/nfs3proc.c | 38 +++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4proc.c | 10 +++++++---
 3 files changed, 49 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index a490f45df4db..df695f52bb9d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -697,14 +697,14 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	if (!IS_ERR(l_ctx)) {
 		status = nfs_iocounter_wait(l_ctx);
 		nfs_put_lock_context(l_ctx);
-		if (status < 0)
+		/*  NOTE: special case
+		 * 	If we're signalled while cleaning up locks on process exit, we
+		 * 	still need to complete the unlock.
+		 */
+		if (status < 0 && !(fl->fl_flags & FL_CLOSE))
 			return status;
 	}
 
-	/* NOTE: special case
-	 * 	If we're signalled while cleaning up locks on process exit, we
-	 * 	still need to complete the unlock.
-	 */
 	/*
 	 * Use local locking if mounted with "-onolock" or with appropriate
 	 * "-olocal_lock="
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 086623ab07b1..0e21306bfed9 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -865,12 +865,48 @@ static void nfs3_proc_commit_setup(struct nfs_commit_data *data, struct rpc_mess
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_COMMIT];
 }
 
+void nfs3_nlm_alloc_call(void *data)
+{
+	struct nfs_lock_context *l_ctx = data;
+	nfs_get_lock_context(l_ctx->open_context);
+}
+
+void nfs3_nlm_release_call(void *data)
+{
+	struct nfs_lock_context *l_ctx = data;
+	nfs_put_lock_context(l_ctx);
+}
+
+const struct nlmclnt_operations nlmclnt_fl_close_lock_ops = {
+	.nlmclnt_alloc_call = nfs3_nlm_alloc_call,
+	.nlmclnt_unlock_prepare = nfs_async_iocounter_wait,
+	.nlmclnt_release_call = nfs3_nlm_release_call,
+};
+
 static int
 nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = file_inode(filp);
+	struct nfs_lock_context *l_ctx = NULL;
+	const struct nlmclnt_operations *nlmclnt_ops = NULL;
+	int status;
 
-	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl, NULL, NULL);
+	if (fl->fl_flags & FL_CLOSE) {
+		l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
+		if (IS_ERR(l_ctx)) {
+			l_ctx = NULL;
+		} else {
+			set_bit(NFS_CONTEXT_UNLOCK, &l_ctx->open_context->flags);
+			nlmclnt_ops = &nlmclnt_fl_close_lock_ops;
+		}
+	}
+
+	status = nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl,
+				nlmclnt_ops, l_ctx);
+	if (l_ctx)
+		nfs_put_lock_context(l_ctx);
+
+	return status;
 }
 
 static int nfs3_have_delegation(struct inode *inode, fmode_t flags)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 91f88bfbbe79..e46cc2be60e2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5905,7 +5905,7 @@ struct nfs4_unlockdata {
 	struct nfs_locku_args arg;
 	struct nfs_locku_res res;
 	struct nfs4_lock_state *lsp;
-	struct nfs_open_context *ctx;
+	struct nfs_lock_context *l_ctx;
 	struct file_lock fl;
 	struct nfs_server *server;
 	unsigned long timestamp;
@@ -5929,7 +5929,7 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	p->lsp = lsp;
 	atomic_inc(&lsp->ls_count);
 	/* Ensure we don't close file until we're done freeing locks! */
-	p->ctx = get_nfs_open_context(ctx);
+	p->l_ctx = nfs_get_lock_context(ctx);
 	memcpy(&p->fl, fl, sizeof(p->fl));
 	p->server = NFS_SERVER(inode);
 	return p;
@@ -5940,7 +5940,7 @@ static void nfs4_locku_release_calldata(void *data)
 	struct nfs4_unlockdata *calldata = data;
 	nfs_free_seqid(calldata->arg.seqid);
 	nfs4_put_lock_state(calldata->lsp);
-	put_nfs_open_context(calldata->ctx);
+	nfs_put_lock_context(calldata->l_ctx);
 	kfree(calldata);
 }
 
@@ -5981,6 +5981,10 @@ static void nfs4_locku_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs4_unlockdata *calldata = data;
 
+	if (calldata->fl.fl_flags & FL_CLOSE &&
+		nfs_async_iocounter_wait(task, calldata->l_ctx))
+		return;
+
 	if (nfs_wait_on_sequence(calldata->arg.seqid, task) != 0)
 		goto out_wait;
 	nfs4_stateid_copy(&calldata->arg.stateid, &calldata->lsp->ls_stateid);
-- 
2.9.3

