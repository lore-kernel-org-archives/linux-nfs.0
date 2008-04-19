From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/33] NFSv4: Only increment the sequence id if the server
	saw it
Date: Sat, 19 Apr 2008 16:40:49 -0400
Message-ID: <20080419204049.14124.65377.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61904 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756766AbYDSUuc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:32 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoWNm026098
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:32 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is quite possible that the OPEN, CLOSE, LOCK, LOCKU,... compounds fail
before the actual stateful operation has been executed (for instance in the
PUTFH call). There is no way to tell from the overall status result which
operations were executed from the COMPOUND.

The fix is to move incrementing of the sequence id into the XDR layer,
so that we do it as we process the results from the stateful operation.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c       |   12 ++++++------
 fs/nfs/nfs4xdr.c        |   18 +++++++++++++++++-
 include/linux/nfs_xdr.h |   10 ++++++++--
 3 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 424aa20..9f2759d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -240,6 +240,8 @@ static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 {
 	p->o_res.f_attr = &p->f_attr;
 	p->o_res.dir_attr = &p->dir_attr;
+	p->o_res.seqid = p->o_arg.seqid;
+	p->c_res.seqid = p->c_arg.seqid;
 	p->o_res.server = p->o_arg.server;
 	nfs_fattr_init(&p->f_attr);
 	nfs_fattr_init(&p->dir_attr);
@@ -730,7 +732,6 @@ static void nfs4_open_confirm_done(struct rpc_task *task, void *calldata)
 		renew_lease(data->o_res.server, data->timestamp);
 		data->rpc_done = 1;
 	}
-	nfs_increment_open_seqid(data->rpc_status, data->c_arg.seqid);
 }
 
 static void nfs4_open_confirm_release(void *calldata)
@@ -860,7 +861,6 @@ static void nfs4_open_done(struct rpc_task *task, void *calldata)
 		if (!(data->o_res.rflags & NFS4_OPEN_RESULT_CONFIRM))
 			nfs_confirm_seqid(&data->owner->so_seqid, 0);
 	}
-	nfs_increment_open_seqid(data->rpc_status, data->o_arg.seqid);
 	data->rpc_done = 1;
 }
 
@@ -1226,7 +1226,6 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
         /* hmm. we are done with the inode, and in the process of freeing
 	 * the state_owner. we keep this around to process errors
 	 */
-	nfs_increment_open_seqid(task->tk_status, calldata->arg.seqid);
 	switch (task->tk_status) {
 		case 0:
 			nfs_set_open_stateid(state, &calldata->res.stateid, 0);
@@ -1333,6 +1332,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 		goto out_free_calldata;
 	calldata->arg.bitmask = server->attr_bitmask;
 	calldata->res.fattr = &calldata->fattr;
+	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
 	calldata->path.mnt = mntget(path->mnt);
 	calldata->path.dentry = dget(path->dentry);
@@ -3159,6 +3159,7 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	p->arg.fh = NFS_FH(inode);
 	p->arg.fl = &p->fl;
 	p->arg.seqid = seqid;
+	p->res.seqid = seqid;
 	p->arg.stateid = &lsp->ls_stateid;
 	p->lsp = lsp;
 	atomic_inc(&lsp->ls_count);
@@ -3184,7 +3185,6 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 
 	if (RPC_ASSASSINATED(task))
 		return;
-	nfs_increment_lock_seqid(task->tk_status, calldata->arg.seqid);
 	switch (task->tk_status) {
 		case 0:
 			memcpy(calldata->lsp->ls_stateid.data,
@@ -3322,6 +3322,7 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->arg.lock_stateid = &lsp->ls_stateid;
 	p->arg.lock_owner.clientid = server->nfs_client->cl_clientid;
 	p->arg.lock_owner.id = lsp->ls_id.id;
+	p->res.lock_seqid = p->arg.lock_seqid;
 	p->lsp = lsp;
 	atomic_inc(&lsp->ls_count);
 	p->ctx = get_nfs_open_context(ctx);
@@ -3348,6 +3349,7 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 			return;
 		data->arg.open_stateid = &state->stateid;
 		data->arg.new_lock_owner = 1;
+		data->res.open_seqid = data->arg.open_seqid;
 	} else
 		data->arg.new_lock_owner = 0;
 	data->timestamp = jiffies;
@@ -3365,7 +3367,6 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 	if (RPC_ASSASSINATED(task))
 		goto out;
 	if (data->arg.new_lock_owner != 0) {
-		nfs_increment_open_seqid(data->rpc_status, data->arg.open_seqid);
 		if (data->rpc_status == 0)
 			nfs_confirm_seqid(&data->lsp->ls_seqid, 0);
 		else
@@ -3377,7 +3378,6 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 		data->lsp->ls_flags |= NFS_LOCK_INITIALIZED;
 		renew_lease(NFS_SERVER(data->ctx->path.dentry->d_inode), data->timestamp);
 	}
-	nfs_increment_lock_seqid(data->rpc_status, data->arg.lock_seqid);
 out:
 	dprintk("%s: done, ret = %d!\n", __FUNCTION__, data->rpc_status);
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2b519f6..b8b2e39 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3005,6 +3005,8 @@ static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
 	int status;
 
 	status = decode_op_hdr(xdr, OP_CLOSE);
+	if (status != -EIO)
+		nfs_increment_open_seqid(status, res->seqid);
 	if (status)
 		return status;
 	READ_BUF(NFS4_STATEID_SIZE);
@@ -3296,11 +3298,17 @@ static int decode_lock(struct xdr_stream *xdr, struct nfs_lock_res *res)
 	int status;
 
 	status = decode_op_hdr(xdr, OP_LOCK);
+	if (status == -EIO)
+		goto out;
 	if (status == 0) {
 		READ_BUF(NFS4_STATEID_SIZE);
 		COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
 	} else if (status == -NFS4ERR_DENIED)
-		return decode_lock_denied(xdr, NULL);
+		status = decode_lock_denied(xdr, NULL);
+	if (res->open_seqid != NULL)
+		nfs_increment_open_seqid(status, res->open_seqid);
+	nfs_increment_lock_seqid(status, res->lock_seqid);
+out:
 	return status;
 }
 
@@ -3319,6 +3327,8 @@ static int decode_locku(struct xdr_stream *xdr, struct nfs_locku_res *res)
 	int status;
 
 	status = decode_op_hdr(xdr, OP_LOCKU);
+	if (status != -EIO)
+		nfs_increment_lock_seqid(status, res->seqid);
 	if (status == 0) {
 		READ_BUF(NFS4_STATEID_SIZE);
 		COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
@@ -3384,6 +3394,8 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
         int status;
 
         status = decode_op_hdr(xdr, OP_OPEN);
+	if (status != -EIO)
+		nfs_increment_open_seqid(status, res->seqid);
         if (status)
                 return status;
         READ_BUF(NFS4_STATEID_SIZE);
@@ -3416,6 +3428,8 @@ static int decode_open_confirm(struct xdr_stream *xdr, struct nfs_open_confirmre
 	int status;
 
         status = decode_op_hdr(xdr, OP_OPEN_CONFIRM);
+	if (status != -EIO)
+		nfs_increment_open_seqid(status, res->seqid);
         if (status)
                 return status;
         READ_BUF(NFS4_STATEID_SIZE);
@@ -3429,6 +3443,8 @@ static int decode_open_downgrade(struct xdr_stream *xdr, struct nfs_closeres *re
 	int status;
 
 	status = decode_op_hdr(xdr, OP_OPEN_DOWNGRADE);
+	if (status != -EIO)
+		nfs_increment_open_seqid(status, res->seqid);
 	if (status)
 		return status;
 	READ_BUF(NFS4_STATEID_SIZE);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f301d0b..24263bb 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -140,6 +140,7 @@ struct nfs_openres {
 	__u32                   rflags;
 	struct nfs_fattr *      f_attr;
 	struct nfs_fattr *      dir_attr;
+	struct nfs_seqid *	seqid;
 	const struct nfs_server *server;
 	int			delegation_type;
 	nfs4_stateid		delegation;
@@ -159,6 +160,7 @@ struct nfs_open_confirmargs {
 
 struct nfs_open_confirmres {
 	nfs4_stateid            stateid;
+	struct nfs_seqid *	seqid;
 };
 
 /*
@@ -175,6 +177,7 @@ struct nfs_closeargs {
 struct nfs_closeres {
 	nfs4_stateid            stateid;
 	struct nfs_fattr *	fattr;
+	struct nfs_seqid *	seqid;
 	const struct nfs_server *server;
 };
 /*
@@ -199,7 +202,9 @@ struct nfs_lock_args {
 };
 
 struct nfs_lock_res {
-	nfs4_stateid			stateid;
+	nfs4_stateid		stateid;
+	struct nfs_seqid *	lock_seqid;
+	struct nfs_seqid *	open_seqid;
 };
 
 struct nfs_locku_args {
@@ -210,7 +215,8 @@ struct nfs_locku_args {
 };
 
 struct nfs_locku_res {
-	nfs4_stateid			stateid;
+	nfs4_stateid		stateid;
+	struct nfs_seqid *	seqid;
 };
 
 struct nfs_lockt_args {

