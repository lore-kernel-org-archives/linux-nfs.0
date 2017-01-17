Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:46730 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751142AbdAQUcv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Jan 2017 15:32:51 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 01/10] NFS: Fix inconsistent indentation in nfs4proc.c
Date: Tue, 17 Jan 2017 15:31:56 -0500
Message-ID: <20170117203205.29033-2-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
References: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 56 +++++++++++++++++++++++++++----------------------------
 1 file changed, 28 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 94fdf26f9bf4..e10ec98ef5ce 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2208,15 +2208,15 @@ static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
 		data->is_recover = 1;
 	}
 	task = rpc_run_task(&task_setup_data);
-        if (IS_ERR(task))
-                return PTR_ERR(task);
-        status = nfs4_wait_for_completion_rpc_task(task);
-        if (status != 0) {
-                data->cancelled = 1;
-                smp_wmb();
-        } else
-                status = data->rpc_status;
-        rpc_put_task(task);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	status = nfs4_wait_for_completion_rpc_task(task);
+	if (status != 0) {
+		data->cancelled = 1;
+		smp_wmb();
+	} else
+		status = data->rpc_status;
+	rpc_put_task(task);
 
 	return status;
 }
@@ -2225,7 +2225,7 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data)
 {
 	struct inode *dir = d_inode(data->dir);
 	struct nfs_openres *o_res = &data->o_res;
-        int status;
+	int status;
 
 	status = nfs4_run_open_task(data, 1);
 	if (status != 0 || !data->rpc_done)
@@ -2856,12 +2856,12 @@ static int _nfs4_do_setattr(struct inode *inode,
 			    struct nfs_open_context *ctx)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-        struct rpc_message msg = {
+	struct rpc_message msg = {
 		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_SETATTR],
 		.rpc_argp	= arg,
 		.rpc_resp	= res,
 		.rpc_cred	= cred,
-        };
+	};
 	struct rpc_cred *delegation_cred = NULL;
 	unsigned long timestamp = jiffies;
 	fmode_t fmode;
@@ -2909,18 +2909,18 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs4_state *state = ctx ? ctx->state : NULL;
-        struct nfs_setattrargs  arg = {
-                .fh             = NFS_FH(inode),
-                .iap            = sattr,
+	struct nfs_setattrargs	arg = {
+		.fh		= NFS_FH(inode),
+		.iap		= sattr,
 		.server		= server,
 		.bitmask = server->attr_bitmask,
 		.label		= ilabel,
-        };
-        struct nfs_setattrres  res = {
+	};
+	struct nfs_setattrres  res = {
 		.fattr		= fattr,
 		.label		= olabel,
 		.server		= server,
-        };
+	};
 	struct nfs4_exception exception = {
 		.state = state,
 		.inode = inode,
@@ -3034,7 +3034,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 		}
 	}
 
-        /* hmm. we are done with the inode, and in the process of freeing
+	/* hmm. we are done with the inode, and in the process of freeing
 	 * the state_owner. we keep this around to process errors
 	 */
 	switch (task->tk_status) {
@@ -4885,8 +4885,8 @@ static int buf_to_pages_noslab(const void *buf, size_t buflen,
 		if (newpage == NULL)
 			goto unwind;
 		memcpy(page_address(newpage), buf, len);
-                buf += len;
-                buflen -= len;
+		buf += len;
+		buflen -= len;
 		*pages++ = newpage;
 		rc++;
 	} while (buflen != 0);
@@ -5209,8 +5209,8 @@ static int _nfs4_do_set_security_label(struct inode *inode,
 	struct nfs_server *server = NFS_SERVER(inode);
 	const u32 bitmask[3] = { 0, 0, FATTR4_WORD2_SECURITY_LABEL };
 	struct nfs_setattrargs arg = {
-		.fh             = NFS_FH(inode),
-		.iap            = &sattr,
+		.fh		= NFS_FH(inode),
+		.iap		= &sattr,
 		.server		= server,
 		.bitmask	= bitmask,
 		.label		= ilabel,
@@ -5221,9 +5221,9 @@ static int _nfs4_do_set_security_label(struct inode *inode,
 		.server		= server,
 	};
 	struct rpc_message msg = {
-		.rpc_proc       = &nfs4_procedures[NFSPROC4_CLNT_SETATTR],
-		.rpc_argp       = &arg,
-		.rpc_resp       = &res,
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_SETATTR],
+		.rpc_argp	= &arg,
+		.rpc_resp	= &res,
 	};
 	int status;
 
@@ -5769,8 +5769,8 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 	};
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_LOCKT],
-		.rpc_argp       = &arg,
-		.rpc_resp       = &res,
+		.rpc_argp	= &arg,
+		.rpc_resp	= &res,
 		.rpc_cred	= state->owner->so_cred,
 	};
 	struct nfs4_lock_state *lsp;
-- 
2.11.0

