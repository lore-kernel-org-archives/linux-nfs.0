Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21740 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581Ab3IZOp0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 10:45:26 -0400
Subject: [PATCH 2/4] SunRPC: Declare and use rpc_task_pid() to wrap
 task->tk_pid
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: David Howells <dhowells@redhat.com>
Cc: olof@lixom.net, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Sep 2013 15:45:17 +0100
Message-ID: <20130926144517.29424.12036.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
References: <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Declare and use rpc_task_pid() to wrap task->tk_pid (when it exists) and to
return 0 when it doesn't.  This allows us to move towards using no_printk().

This was mostly achieved with:

   perl -p -i -e 's/task->tk_pid/rpc_task_pid(task)/g' `git grep -l 'task->tk_pid'`
   perl -p -i -e 's/data->task.tk_pid/rpc_task_pid(&data->task)/g' `git grep -l 'data->task.tk_pid'`

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/lockd/clntproc.c            |    2 +
 fs/lockd/svc4proc.c            |    2 +
 fs/lockd/svcproc.c             |    2 +
 fs/nfs/direct.c                |    6 ++--
 fs/nfs/nfs4filelayout.c        |    8 ++---
 fs/nfs/nfs4proc.c              |    2 +
 fs/nfs/read.c                  |    4 +-
 fs/nfs/write.c                 |    8 ++---
 include/linux/sunrpc/sched.h   |    9 +++++
 include/trace/events/sunrpc.h  |    8 ++---
 net/sunrpc/auth.c              |   18 +++++------
 net/sunrpc/auth_gss/auth_gss.c |   20 ++++++------
 net/sunrpc/clnt.c              |   68 ++++++++++++++++++++--------------------
 net/sunrpc/rpcb_clnt.c         |   34 ++++++++++----------
 net/sunrpc/sched.c             |   32 +++++++++----------
 net/sunrpc/xprt.c              |   30 +++++++++---------
 net/sunrpc/xprtsock.c          |    2 +
 17 files changed, 132 insertions(+), 123 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index acd3947..5427b39 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -780,7 +780,7 @@ static void nlmclnt_cancel_callback(struct rpc_task *task, void *data)
 	}
 
 	dprintk("lockd: cancel status %u (task %u)\n",
-			status, task->tk_pid);
+			status, rpc_task_pid(task));
 
 	switch (status) {
 	case NLM_LCK_GRANTED:
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index b147d1a..d1c39c1 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -224,7 +224,7 @@ nlm4svc_proc_granted(struct svc_rqst *rqstp, struct nlm_args *argp,
  */
 static void nlm4svc_callback_exit(struct rpc_task *task, void *data)
 {
-	dprintk("lockd: %5u callback returned %d\n", task->tk_pid,
+	dprintk("lockd: %5u callback returned %d\n", rpc_task_pid(task),
 			-task->tk_status);
 }
 
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 21171f0..e54613f 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -257,7 +257,7 @@ nlmsvc_proc_granted(struct svc_rqst *rqstp, struct nlm_args *argp,
  */
 static void nlmsvc_callback_exit(struct rpc_task *task, void *data)
 {
-	dprintk("lockd: %5u callback returned %d\n", task->tk_pid,
+	dprintk("lockd: %5u callback returned %d\n", rpc_task_pid(task),
 			-task->tk_status);
 }
 
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 91ff089..3b3629a 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -534,14 +534,14 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 	nfs_init_cinfo_from_dreq(&cinfo, dreq);
 	if (status < 0) {
 		dprintk("NFS: %5u commit failed with error %d.\n",
-			data->task.tk_pid, status);
+			rpc_task_pid(&data->task), status);
 		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
 	} else if (memcmp(&dreq->verf, &data->verf, sizeof(data->verf))) {
-		dprintk("NFS: %5u commit verify failed\n", data->task.tk_pid);
+		dprintk("NFS: %5u commit verify failed\n", rpc_task_pid(&data->task));
 		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
 	}
 
-	dprintk("NFS: %5u commit returned %d\n", data->task.tk_pid, status);
+	dprintk("NFS: %5u commit returned %d\n", rpc_task_pid(&data->task), status);
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b86464b..c733aa4 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -92,7 +92,7 @@ static void filelayout_reset_write(struct nfs_write_data *data)
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		dprintk("%s Reset task %5u for i/o through MDS "
 			"(req %s/%lld, %u bytes @ offset %llu)\n", __func__,
-			data->task.tk_pid,
+			rpc_task_pid(&data->task),
 			hdr->inode->i_sb->s_id,
 			(long long)NFS_FILEID(hdr->inode),
 			data->args.count,
@@ -113,7 +113,7 @@ static void filelayout_reset_read(struct nfs_read_data *data)
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		dprintk("%s Reset task %5u for i/o through MDS "
 			"(req %s/%lld, %u bytes @ offset %llu)\n", __func__,
-			data->task.tk_pid,
+			rpc_task_pid(&data->task),
 			hdr->inode->i_sb->s_id,
 			(long long)NFS_FILEID(hdr->inode),
 			data->args.count,
@@ -312,7 +312,7 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
 		return;
 	}
 	if (filelayout_reset_to_mds(rdata->header->lseg)) {
-		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
+		dprintk("%s task %u reset io to MDS\n", __func__, rpc_task_pid(task));
 		filelayout_reset_read(rdata);
 		rpc_exit(task, 0);
 		return;
@@ -423,7 +423,7 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
 		return;
 	}
 	if (filelayout_reset_to_mds(wdata->header->lseg)) {
-		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
+		dprintk("%s task %u reset io to MDS\n", __func__, rpc_task_pid(task));
 		filelayout_reset_write(wdata);
 		rpc_exit(task, 0);
 		return;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 989bb9d..b73435d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7458,7 +7458,7 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 
 	dprintk("NFS: %4d initiating layoutcommit call. sync %d "
 		"lbw: %llu inode %lu\n",
-		data->task.tk_pid, sync,
+		rpc_task_pid(&data->task), sync,
 		data->args.lastbytewritten,
 		data->args.inode->i_ino);
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 31db5c3..c20fd20 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -230,7 +230,7 @@ int nfs_initiate_read(struct rpc_clnt *clnt,
 
 	dprintk("NFS: %5u initiated read call (req %s/%lld, %u bytes @ "
 			"offset %llu)\n",
-			data->task.tk_pid,
+			rpc_task_pid(&data->task),
 			inode->i_sb->s_id,
 			(long long)NFS_FILEID(inode),
 			data->args.count,
@@ -444,7 +444,7 @@ int nfs_readpage_result(struct rpc_task *task, struct nfs_read_data *data)
 	struct inode *inode = data->header->inode;
 	int status;
 
-	dprintk("NFS: %s: %5u, (status %d)\n", __func__, task->tk_pid,
+	dprintk("NFS: %s: %5u, (status %d)\n", __func__, rpc_task_pid(task),
 			task->tk_status);
 
 	status = NFS_PROTO(inode)->read_done(task, data);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ac1dc33..f7a9ddb 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1016,7 +1016,7 @@ int nfs_initiate_write(struct rpc_clnt *clnt,
 
 	dprintk("NFS: %5u initiated write call "
 		"(req %s/%lld, %u bytes @ offset %llu)\n",
-		data->task.tk_pid,
+		rpc_task_pid(&data->task),
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode),
 		data->args.count,
@@ -1361,7 +1361,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 	int status;
 
 	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
-		task->tk_pid, task->tk_status);
+		rpc_task_pid(task), task->tk_status);
 
 	/*
 	 * ->write_done will attempt to use post-op attributes to detect
@@ -1489,7 +1489,7 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 	/* Set up the initial task struct.  */
 	NFS_PROTO(data->inode)->commit_setup(data, &msg);
 
-	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
+	dprintk("NFS: %5u initiated commit call\n", rpc_task_pid(&data->task));
 
 	nfs4_state_protect(NFS_SERVER(data->inode)->nfs_client,
 		NFS_SP4_MACH_CRED_COMMIT, &task_setup_data.rpc_client, &msg);
@@ -1591,7 +1591,7 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 	struct nfs_commit_data	*data = calldata;
 
         dprintk("NFS: %5u nfs_commit_done (status %d)\n",
-                                task->tk_pid, task->tk_status);
+                                rpc_task_pid(task), task->tk_status);
 
 	/* Call the NFS version-specific code */
 	NFS_PROTO(data->inode)->commit_done(task, data);
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 096ee58..01543d0 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -268,4 +268,13 @@ static inline void rpc_assign_waitqueue_name(struct rpc_wait_queue *q,
 }
 #endif
 
+static inline unsigned short rpc_task_pid(const struct rpc_task *t)
+{
+#if defined(RPC_DEBUG) || defined(RPC_TRACEPOINTS)
+	return t->tk_pid;
+#else
+	return 0;
+#endif
+}
+
 #endif /* _LINUX_SUNRPC_SCHED_H_ */
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index d51d16c..0476cbb 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -23,7 +23,7 @@ DECLARE_EVENT_CLASS(rpc_task_status,
 	),
 
 	TP_fast_assign(
-		__entry->task_id = task->tk_pid;
+		__entry->task_id = rpc_task_pid(task);
 		__entry->client_id = task->tk_client->cl_clid;
 		__entry->status = task->tk_status;
 	),
@@ -57,7 +57,7 @@ TRACE_EVENT(rpc_connect_status,
 	),
 
 	TP_fast_assign(
-		__entry->task_id = task->tk_pid;
+		__entry->task_id = rpc_task_pid(task);
 		__entry->client_id = task->tk_client->cl_clid;
 		__entry->status = status;
 	),
@@ -84,7 +84,7 @@ DECLARE_EVENT_CLASS(rpc_task_running,
 
 	TP_fast_assign(
 		__entry->client_id = clnt->cl_clid;
-		__entry->task_id = task->tk_pid;
+		__entry->task_id = rpc_task_pid(task);
 		__entry->action = action;
 		__entry->runstate = task->tk_runstate;
 		__entry->status = task->tk_status;
@@ -142,7 +142,7 @@ DECLARE_EVENT_CLASS(rpc_task_queued,
 
 	TP_fast_assign(
 		__entry->client_id = clnt->cl_clid;
-		__entry->task_id = task->tk_pid;
+		__entry->task_id = rpc_task_pid(task);
 		__entry->timeout = task->tk_timeout;
 		__entry->runstate = task->tk_runstate;
 		__entry->status = task->tk_status;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 5285ead..6225c1b 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -613,7 +613,7 @@ EXPORT_SYMBOL_GPL(rpcauth_init_cred);
 struct rpc_cred *
 rpcauth_generic_bind_cred(struct rpc_task *task, struct rpc_cred *cred, int lookupflags)
 {
-	dprintk("RPC: %5u holding %s cred %p\n", task->tk_pid,
+	dprintk("RPC: %5u holding %s cred %p\n", rpc_task_pid(task),
 			cred->cr_auth->au_ops->au_name, cred);
 	return get_rpccred(cred);
 }
@@ -629,7 +629,7 @@ rpcauth_bind_root_cred(struct rpc_task *task, int lookupflags)
 	};
 
 	dprintk("RPC: %5u looking up %s cred\n",
-		task->tk_pid, task->tk_client->cl_auth->au_ops->au_name);
+		rpc_task_pid(task), task->tk_client->cl_auth->au_ops->au_name);
 	return auth->au_ops->lookup_cred(auth, &acred, lookupflags);
 }
 
@@ -639,7 +639,7 @@ rpcauth_bind_new_cred(struct rpc_task *task, int lookupflags)
 	struct rpc_auth *auth = task->tk_client->cl_auth;
 
 	dprintk("RPC: %5u looking up %s cred\n",
-		task->tk_pid, auth->au_ops->au_name);
+		rpc_task_pid(task), auth->au_ops->au_name);
 	return rpcauth_lookupcred(auth, lookupflags);
 }
 
@@ -708,7 +708,7 @@ rpcauth_marshcred(struct rpc_task *task, __be32 *p)
 	struct rpc_cred	*cred = task->tk_rqstp->rq_cred;
 
 	dprintk("RPC: %5u marshaling %s cred %p\n",
-		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
+		rpc_task_pid(task), cred->cr_auth->au_ops->au_name, cred);
 
 	return cred->cr_ops->crmarshal(task, p);
 }
@@ -719,7 +719,7 @@ rpcauth_checkverf(struct rpc_task *task, __be32 *p)
 	struct rpc_cred	*cred = task->tk_rqstp->rq_cred;
 
 	dprintk("RPC: %5u validating %s cred %p\n",
-		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
+		rpc_task_pid(task), cred->cr_auth->au_ops->au_name, cred);
 
 	return cred->cr_ops->crvalidate(task, p);
 }
@@ -740,7 +740,7 @@ rpcauth_wrap_req(struct rpc_task *task, kxdreproc_t encode, void *rqstp,
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
 
 	dprintk("RPC: %5u using %s cred %p to wrap rpc data\n",
-			task->tk_pid, cred->cr_ops->cr_name, cred);
+			rpc_task_pid(task), cred->cr_ops->cr_name, cred);
 	if (cred->cr_ops->crwrap_req)
 		return cred->cr_ops->crwrap_req(task, encode, rqstp, data, obj);
 	/* By default, we encode the arguments normally. */
@@ -765,7 +765,7 @@ rpcauth_unwrap_resp(struct rpc_task *task, kxdrdproc_t decode, void *rqstp,
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
 
 	dprintk("RPC: %5u using %s cred %p to unwrap rpc data\n",
-			task->tk_pid, cred->cr_ops->cr_name, cred);
+			rpc_task_pid(task), cred->cr_ops->cr_name, cred);
 	if (cred->cr_ops->crunwrap_resp)
 		return cred->cr_ops->crunwrap_resp(task, decode, rqstp,
 						   data, obj);
@@ -787,7 +787,7 @@ rpcauth_refreshcred(struct rpc_task *task)
 		cred = task->tk_rqstp->rq_cred;
 	}
 	dprintk("RPC: %5u refreshing %s cred %p\n",
-		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
+		rpc_task_pid(task), cred->cr_auth->au_ops->au_name, cred);
 
 	err = cred->cr_ops->crrefresh(task);
 out:
@@ -802,7 +802,7 @@ rpcauth_invalcred(struct rpc_task *task)
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
 
 	dprintk("RPC: %5u invalidating %s cred %p\n",
-		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
+		rpc_task_pid(task), cred->cr_auth->au_ops->au_name, cred);
 	if (cred)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 }
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 0846566..e3da2b3 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -536,7 +536,7 @@ gss_refresh_upcall(struct rpc_task *task)
 	int err = 0;
 
 	dprintk("RPC: %5u %s for uid %u\n",
-		task->tk_pid, __func__, from_kuid(&init_user_ns, cred->cr_uid));
+		rpc_task_pid(task), __func__, from_kuid(&init_user_ns, cred->cr_uid));
 	gss_msg = gss_setup_upcall(gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		/* XXX: warning on the first, under the assumption we
@@ -568,7 +568,7 @@ gss_refresh_upcall(struct rpc_task *task)
 	gss_release_msg(gss_msg);
 out:
 	dprintk("RPC: %5u %s for uid %u result %d\n",
-		task->tk_pid, __func__,
+		rpc_task_pid(task), __func__,
 		from_kuid(&init_user_ns, cred->cr_uid),	err);
 	return err;
 }
@@ -1387,7 +1387,7 @@ gss_marshal(struct rpc_task *task, __be32 *p)
 	struct kvec	iov;
 	struct xdr_buf	verf_buf;
 
-	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
+	dprintk("RPC: %5u %s\n", rpc_task_pid(task), __func__);
 
 	*p++ = htonl(RPC_AUTH_GSS);
 	cred_len = p++;
@@ -1514,7 +1514,7 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	u32		maj_stat;
 	__be32		*ret = ERR_PTR(-EIO);
 
-	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
+	dprintk("RPC: %5u %s\n", rpc_task_pid(task), __func__);
 
 	flav = ntohl(*p++);
 	if ((len = ntohl(*p++)) > RPC_MAX_AUTH_SIZE)
@@ -1534,7 +1534,7 @@ gss_validate(struct rpc_task *task, __be32 *p)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	if (maj_stat) {
 		dprintk("RPC: %5u %s: gss_verify_mic returned error 0x%08x\n",
-			task->tk_pid, __func__, maj_stat);
+			rpc_task_pid(task), __func__, maj_stat);
 		goto out_bad;
 	}
 	/* We leave it to unwrap to calculate au_rslack. For now we just
@@ -1542,11 +1542,11 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	cred->cr_auth->au_verfsize = XDR_QUADLEN(len) + 2;
 	gss_put_ctx(ctx);
 	dprintk("RPC: %5u %s: gss_verify_mic succeeded.\n",
-			task->tk_pid, __func__);
+			rpc_task_pid(task), __func__);
 	return p + XDR_QUADLEN(len);
 out_bad:
 	gss_put_ctx(ctx);
-	dprintk("RPC: %5u %s failed ret %ld.\n", task->tk_pid, __func__,
+	dprintk("RPC: %5u %s failed ret %ld.\n", rpc_task_pid(task), __func__,
 		PTR_ERR(ret));
 	return ret;
 }
@@ -1729,7 +1729,7 @@ gss_wrap_req(struct rpc_task *task,
 	struct gss_cl_ctx *ctx = gss_cred_get_ctx(cred);
 	int             status = -EIO;
 
-	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
+	dprintk("RPC: %5u %s\n", rpc_task_pid(task), __func__);
 	if (ctx->gc_proc != RPC_GSS_PROC_DATA) {
 		/* The spec seems a little ambiguous here, but I think that not
 		 * wrapping context destruction requests makes the most sense.
@@ -1752,7 +1752,7 @@ gss_wrap_req(struct rpc_task *task,
 	}
 out:
 	gss_put_ctx(ctx);
-	dprintk("RPC: %5u %s returning %d\n", task->tk_pid, __func__, status);
+	dprintk("RPC: %5u %s returning %d\n", rpc_task_pid(task), __func__, status);
 	return status;
 }
 
@@ -1868,7 +1868,7 @@ out_decode:
 out:
 	gss_put_ctx(ctx);
 	dprintk("RPC: %5u %s returning %d\n",
-		task->tk_pid, __func__, status);
+		rpc_task_pid(task), __func__, status);
 	return status;
 }
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7747960..ef452a29 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -47,7 +47,7 @@
 #endif
 
 #define dprint_status(t)					\
-	dprintk("RPC: %5u %s (status %d)\n", t->tk_pid,		\
+	dprintk("RPC: %5u %s (status %d)\n", rpc_task_pid(t),	\
 			__func__, t->tk_status)
 
 /*
@@ -1308,7 +1308,7 @@ call_start(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 
-	dprintk("RPC: %5u call_start %s%d proc %s (%s)\n", task->tk_pid,
+	dprintk("RPC: %5u call_start %s%d proc %s (%s)\n", rpc_task_pid(task),
 			clnt->cl_program->name, clnt->cl_vers,
 			rpc_proc_name(task),
 			(RPC_IS_ASYNC(task) ? "async" : "sync"));
@@ -1440,11 +1440,11 @@ call_refreshresult(struct rpc_task *task)
 			break;
 		task->tk_cred_retry--;
 		dprintk("RPC: %5u %s: retry refresh creds\n",
-				task->tk_pid, __func__);
+				rpc_task_pid(task), __func__);
 		return;
 	}
 	dprintk("RPC: %5u %s: refresh creds failed with error %d\n",
-				task->tk_pid, __func__, status);
+				rpc_task_pid(task), __func__, status);
 	rpc_exit(task, status);
 }
 
@@ -1489,7 +1489,7 @@ call_allocate(struct rpc_task *task)
 	if (req->rq_buffer != NULL)
 		return;
 
-	dprintk("RPC: %5u rpc_buffer allocation failed\n", task->tk_pid);
+	dprintk("RPC: %5u rpc_buffer allocation failed\n", rpc_task_pid(task));
 
 	if (RPC_IS_ASYNC(task) || !fatal_signal_pending(current)) {
 		task->tk_action = call_allocate;
@@ -1595,12 +1595,12 @@ call_bind_status(struct rpc_task *task)
 	trace_rpc_bind_status(task);
 	switch (task->tk_status) {
 	case -ENOMEM:
-		dprintk("RPC: %5u rpcbind out of memory\n", task->tk_pid);
+		dprintk("RPC: %5u rpcbind out of memory\n", rpc_task_pid(task));
 		rpc_delay(task, HZ >> 2);
 		goto retry_timeout;
 	case -EACCES:
 		dprintk("RPC: %5u remote rpcbind: RPC program/version "
-				"unavailable\n", task->tk_pid);
+				"unavailable\n", rpc_task_pid(task));
 		/* fail immediately if this is an RPC ping */
 		if (task->tk_msg.rpc_proc->p_proc == 0) {
 			status = -EOPNOTSUPP;
@@ -1613,16 +1613,16 @@ call_bind_status(struct rpc_task *task)
 		goto retry_timeout;
 	case -ETIMEDOUT:
 		dprintk("RPC: %5u rpcbind request timed out\n",
-				task->tk_pid);
+				rpc_task_pid(task));
 		goto retry_timeout;
 	case -EPFNOSUPPORT:
 		/* server doesn't support any rpcbind version we know of */
 		dprintk("RPC: %5u unrecognized remote rpcbind service\n",
-				task->tk_pid);
+				rpc_task_pid(task));
 		break;
 	case -EPROTONOSUPPORT:
 		dprintk("RPC: %5u remote rpcbind version unavailable, retrying\n",
-				task->tk_pid);
+				rpc_task_pid(task));
 		task->tk_status = 0;
 		task->tk_action = call_bind;
 		return;
@@ -1634,7 +1634,7 @@ call_bind_status(struct rpc_task *task)
 	case -ENETUNREACH:
 	case -EPIPE:
 		dprintk("RPC: %5u remote rpcbind unreachable: %d\n",
-				task->tk_pid, task->tk_status);
+				rpc_task_pid(task), task->tk_status);
 		if (!RPC_IS_SOFTCONN(task)) {
 			rpc_delay(task, 5*HZ);
 			goto retry_timeout;
@@ -1643,7 +1643,7 @@ call_bind_status(struct rpc_task *task)
 		break;
 	default:
 		dprintk("RPC: %5u unrecognized rpcbind error (%d)\n",
-				task->tk_pid, -task->tk_status);
+				rpc_task_pid(task), -task->tk_status);
 	}
 
 	rpc_exit(task, status);
@@ -1662,7 +1662,7 @@ call_connect(struct rpc_task *task)
 	struct rpc_xprt *xprt = task->tk_rqstp->rq_xprt;
 
 	dprintk("RPC: %5u call_connect xprt %p %s connected\n",
-			task->tk_pid, xprt,
+			rpc_task_pid(task), xprt,
 			(xprt_connected(xprt) ? "is" : "is not"));
 
 	task->tk_action = call_transmit;
@@ -1938,11 +1938,11 @@ call_timeout(struct rpc_task *task)
 	struct rpc_clnt	*clnt = task->tk_client;
 
 	if (xprt_adjust_timeout(task->tk_rqstp) == 0) {
-		dprintk("RPC: %5u call_timeout (minor)\n", task->tk_pid);
+		dprintk("RPC: %5u call_timeout (minor)\n", rpc_task_pid(task));
 		goto retry;
 	}
 
-	dprintk("RPC: %5u call_timeout (major)\n", task->tk_pid);
+	dprintk("RPC: %5u call_timeout (major)\n", rpc_task_pid(task));
 	task->tk_timeouts++;
 
 	if (RPC_IS_SOFTCONN(task)) {
@@ -2047,7 +2047,7 @@ call_decode(struct rpc_task *task)
 		task->tk_status = rpcauth_unwrap_resp(task, decode, req, p,
 						      task->tk_msg.rpc_resp);
 	}
-	dprintk("RPC: %5u call_decode result %d\n", task->tk_pid,
+	dprintk("RPC: %5u call_decode result %d\n", rpc_task_pid(task),
 			task->tk_status);
 	return;
 out_retry:
@@ -2099,7 +2099,7 @@ rpc_verify_header(struct rpc_task *task)
 		 *   undefined results
 		 */
 		dprintk("RPC: %5u %s: XDR representation not a multiple of"
-		       " 4 bytes: 0x%x\n", task->tk_pid, __func__,
+		       " 4 bytes: 0x%x\n", rpc_task_pid(task), __func__,
 		       task->tk_rqstp->rq_rcv_buf.len);
 		error = -EIO;
 		goto out_err;
@@ -2110,7 +2110,7 @@ rpc_verify_header(struct rpc_task *task)
 	p += 1; /* skip XID */
 	if ((n = ntohl(*p++)) != RPC_REPLY) {
 		dprintk("RPC: %5u %s: not an RPC reply: %x\n",
-			task->tk_pid, __func__, n);
+			rpc_task_pid(task), __func__, n);
 		error = -EIO;
 		goto out_garbage;
 	}
@@ -2123,13 +2123,13 @@ rpc_verify_header(struct rpc_task *task)
 			break;
 		case RPC_MISMATCH:
 			dprintk("RPC: %5u %s: RPC call version mismatch!\n",
-				task->tk_pid, __func__);
+				rpc_task_pid(task), __func__);
 			error = -EPROTONOSUPPORT;
 			goto out_err;
 		default:
 			dprintk("RPC: %5u %s: RPC call rejected, "
 				"unknown error: %x\n",
-				task->tk_pid, __func__, n);
+				rpc_task_pid(task), __func__, n);
 			error = -EIO;
 			goto out_err;
 		}
@@ -2144,7 +2144,7 @@ rpc_verify_header(struct rpc_task *task)
 				break;
 			task->tk_cred_retry--;
 			dprintk("RPC: %5u %s: retry stale creds\n",
-					task->tk_pid, __func__);
+					rpc_task_pid(task), __func__);
 			rpcauth_invalcred(task);
 			/* Ensure we obtain a new XID! */
 			xprt_release(task);
@@ -2157,7 +2157,7 @@ rpc_verify_header(struct rpc_task *task)
 				break;
 			task->tk_garb_retry--;
 			dprintk("RPC: %5u %s: retry garbled creds\n",
-					task->tk_pid, __func__);
+					rpc_task_pid(task), __func__);
 			task->tk_action = call_bind;
 			goto out_retry;
 		case RPC_AUTH_TOOWEAK:
@@ -2169,18 +2169,18 @@ rpc_verify_header(struct rpc_task *task)
 			break;
 		default:
 			dprintk("RPC: %5u %s: unknown auth error: %x\n",
-					task->tk_pid, __func__, n);
+					rpc_task_pid(task), __func__, n);
 			error = -EIO;
 		}
 		dprintk("RPC: %5u %s: call rejected %d\n",
-				task->tk_pid, __func__, n);
+				rpc_task_pid(task), __func__, n);
 		goto out_err;
 	}
 	p = rpcauth_checkverf(task, p);
 	if (IS_ERR(p)) {
 		error = PTR_ERR(p);
 		dprintk("RPC: %5u %s: auth check failed with %d\n",
-				task->tk_pid, __func__, error);
+				rpc_task_pid(task), __func__, error);
 		goto out_garbage;		/* bad verifier, retry */
 	}
 	len = p - (__be32 *)iov->iov_base - 1;
@@ -2191,14 +2191,14 @@ rpc_verify_header(struct rpc_task *task)
 		return p;
 	case RPC_PROG_UNAVAIL:
 		dprintk_rcu("RPC: %5u %s: program %u is unsupported "
-				"by server %s\n", task->tk_pid, __func__,
+				"by server %s\n", rpc_task_pid(task), __func__,
 				(unsigned int)clnt->cl_prog,
 				rcu_dereference(clnt->cl_xprt)->servername);
 		error = -EPFNOSUPPORT;
 		goto out_err;
 	case RPC_PROG_MISMATCH:
 		dprintk_rcu("RPC: %5u %s: program %u, version %u unsupported "
-				"by server %s\n", task->tk_pid, __func__,
+				"by server %s\n", rpc_task_pid(task), __func__,
 				(unsigned int)clnt->cl_prog,
 				(unsigned int)clnt->cl_vers,
 				rcu_dereference(clnt->cl_xprt)->servername);
@@ -2207,7 +2207,7 @@ rpc_verify_header(struct rpc_task *task)
 	case RPC_PROC_UNAVAIL:
 		dprintk_rcu("RPC: %5u %s: proc %s unsupported by program %u, "
 				"version %u on server %s\n",
-				task->tk_pid, __func__,
+				rpc_task_pid(task), __func__,
 				rpc_proc_name(task),
 				clnt->cl_prog, clnt->cl_vers,
 				rcu_dereference(clnt->cl_xprt)->servername);
@@ -2215,11 +2215,11 @@ rpc_verify_header(struct rpc_task *task)
 		goto out_err;
 	case RPC_GARBAGE_ARGS:
 		dprintk("RPC: %5u %s: server saw garbage\n",
-				task->tk_pid, __func__);
+				rpc_task_pid(task), __func__);
 		break;			/* retry */
 	default:
 		dprintk("RPC: %5u %s: server accept status: %x\n",
-				task->tk_pid, __func__, n);
+				rpc_task_pid(task), __func__, n);
 		/* Also retry */
 	}
 
@@ -2228,18 +2228,18 @@ out_garbage:
 	if (task->tk_garb_retry) {
 		task->tk_garb_retry--;
 		dprintk("RPC: %5u %s: retrying\n",
-				task->tk_pid, __func__);
+				rpc_task_pid(task), __func__);
 		task->tk_action = call_bind;
 out_retry:
 		return ERR_PTR(-EAGAIN);
 	}
 out_err:
 	rpc_exit(task, error);
-	dprintk("RPC: %5u %s: call failed with error %d\n", task->tk_pid,
+	dprintk("RPC: %5u %s: call failed with error %d\n", rpc_task_pid(task),
 			__func__, error);
 	return ERR_PTR(error);
 out_overflow:
-	dprintk("RPC: %5u %s: server reply was truncated.\n", task->tk_pid,
+	dprintk("RPC: %5u %s: server reply was truncated.\n", rpc_task_pid(task),
 			__func__);
 	goto out_garbage;
 }
@@ -2302,7 +2302,7 @@ static void rpc_show_task(const struct rpc_clnt *clnt,
 		rpc_waitq = rpc_qname(task->tk_waitqueue);
 
 	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %sv%u %s a:%ps q:%s\n",
-		task->tk_pid, task->tk_flags, task->tk_status,
+		rpc_task_pid(task), task->tk_flags, task->tk_status,
 		clnt, task->tk_rqstp, task->tk_timeout, task->tk_ops,
 		clnt->cl_program->name, clnt->cl_vers, rpc_proc_name(task),
 		task->tk_action, rpc_waitq);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 1891a10..c98ee85 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -688,7 +688,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	rcu_read_unlock();
 
 	dprintk("RPC: %5u %s(%s, %u, %u, %d)\n",
-		task->tk_pid, __func__,
+		rpc_task_pid(task), __func__,
 		xprt->servername, clnt->cl_prog, clnt->cl_vers, xprt->prot);
 
 	/* Put self on the wait queue to ensure we get notified if
@@ -697,7 +697,7 @@ void rpcb_getport_async(struct rpc_task *task)
 
 	if (xprt_test_and_set_binding(xprt)) {
 		dprintk("RPC: %5u %s: waiting for another binder\n",
-			task->tk_pid, __func__);
+			rpc_task_pid(task), __func__);
 		xprt_put(xprt);
 		return;
 	}
@@ -706,7 +706,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	if (xprt_bound(xprt)) {
 		status = 0;
 		dprintk("RPC: %5u %s: already bound\n",
-			task->tk_pid, __func__);
+			rpc_task_pid(task), __func__);
 		goto bailout_nofree;
 	}
 
@@ -726,26 +726,26 @@ void rpcb_getport_async(struct rpc_task *task)
 	default:
 		status = -EAFNOSUPPORT;
 		dprintk("RPC: %5u %s: bad address family\n",
-				task->tk_pid, __func__);
+				rpc_task_pid(task), __func__);
 		goto bailout_nofree;
 	}
 	if (proc == NULL) {
 		xprt->bind_index = 0;
 		status = -EPFNOSUPPORT;
 		dprintk("RPC: %5u %s: no more getport versions available\n",
-			task->tk_pid, __func__);
+			rpc_task_pid(task), __func__);
 		goto bailout_nofree;
 	}
 
 	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
-		task->tk_pid, __func__, bind_version);
+		rpc_task_pid(task), __func__, bind_version);
 
 	rpcb_clnt = rpcb_create(xprt->xprt_net, xprt->servername, sap, salen,
 				xprt->prot, bind_version);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
 		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",
-			task->tk_pid, __func__, PTR_ERR(rpcb_clnt));
+			rpc_task_pid(task), __func__, PTR_ERR(rpcb_clnt));
 		goto bailout_nofree;
 	}
 
@@ -753,7 +753,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	if (!map) {
 		status = -ENOMEM;
 		dprintk("RPC: %5u %s: no memory available\n",
-			task->tk_pid, __func__);
+			rpc_task_pid(task), __func__);
 		goto bailout_release_client;
 	}
 	map->r_prog = clnt->cl_prog;
@@ -782,7 +782,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	if (IS_ERR(child)) {
 		/* rpcb_map_release() has freed the arguments */
 		dprintk("RPC: %5u %s: rpc_run_task failed\n",
-			task->tk_pid, __func__);
+			rpc_task_pid(task), __func__);
 		return;
 	}
 
@@ -831,7 +831,7 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
 	}
 
 	dprintk("RPC: %5u rpcb_getport_done(status %d, port %u)\n",
-			child->tk_pid, status, map->r_port);
+		rpc_task_pid(child), status, map->r_port);
 
 	map->r_status = status;
 }
@@ -846,7 +846,7 @@ static void rpcb_enc_mapping(struct rpc_rqst *req, struct xdr_stream *xdr,
 	__be32 *p;
 
 	dprintk("RPC: %5u encoding PMAP_%s call (%u, %u, %d, %u)\n",
-			req->rq_task->tk_pid,
+			rpc_task_pid(req->rq_task),
 			req->rq_task->tk_msg.rpc_proc->p_name,
 			rpcb->r_prog, rpcb->r_vers, rpcb->r_prot, rpcb->r_port);
 
@@ -870,7 +870,7 @@ static int rpcb_dec_getport(struct rpc_rqst *req, struct xdr_stream *xdr,
 		return -EIO;
 
 	port = be32_to_cpup(p);
-	dprintk("RPC: %5u PMAP_%s result: %lu\n", req->rq_task->tk_pid,
+	dprintk("RPC: %5u PMAP_%s result: %lu\n", rpc_task_pid(req->rq_task),
 			req->rq_task->tk_msg.rpc_proc->p_name, port);
 	if (unlikely(port > USHRT_MAX))
 		return -EIO;
@@ -893,7 +893,7 @@ static int rpcb_dec_set(struct rpc_rqst *req, struct xdr_stream *xdr,
 		*boolp = 1;
 
 	dprintk("RPC: %5u RPCB_%s call %s\n",
-			req->rq_task->tk_pid,
+			rpc_task_pid(req->rq_task),
 			req->rq_task->tk_msg.rpc_proc->p_name,
 			(*boolp ? "succeeded" : "failed"));
 	return 0;
@@ -920,7 +920,7 @@ static void rpcb_enc_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 	__be32 *p;
 
 	dprintk("RPC: %5u encoding RPCB_%s call (%u, %u, '%s', '%s')\n",
-			req->rq_task->tk_pid,
+			rpc_task_pid(req->rq_task),
 			req->rq_task->tk_msg.rpc_proc->p_name,
 			rpcb->r_prog, rpcb->r_vers,
 			rpcb->r_netid, rpcb->r_addr);
@@ -955,7 +955,7 @@ static int rpcb_dec_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 	 */
 	if (len == 0) {
 		dprintk("RPC: %5u RPCB reply: program not registered\n",
-				req->rq_task->tk_pid);
+				rpc_task_pid(req->rq_task));
 		return 0;
 	}
 
@@ -965,7 +965,7 @@ static int rpcb_dec_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 	p = xdr_inline_decode(xdr, len);
 	if (unlikely(p == NULL))
 		goto out_fail;
-	dprintk("RPC: %5u RPCB_%s reply: %s\n", req->rq_task->tk_pid,
+	dprintk("RPC: %5u RPCB_%s reply: %s\n", rpc_task_pid(req->rq_task),
 			req->rq_task->tk_msg.rpc_proc->p_name, (char *)p);
 
 	if (rpc_uaddr2sockaddr(req->rq_xprt->xprt_net, (char *)p, len,
@@ -977,7 +977,7 @@ static int rpcb_dec_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 
 out_fail:
 	dprintk("RPC: %5u malformed RPCB_%s reply\n",
-			req->rq_task->tk_pid,
+			rpc_task_pid(req->rq_task),
 			req->rq_task->tk_msg.rpc_proc->p_name);
 	return -EIO;
 }
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index ff3cc4b..0a4b07c 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -66,7 +66,7 @@ __rpc_disable_timer(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
 	if (task->tk_timeout == 0)
 		return;
-	dprintk("RPC: %5u disabling timer\n", task->tk_pid);
+	dprintk("RPC: %5u disabling timer\n", rpc_task_pid(task));
 	task->tk_timeout = 0;
 	list_del(&task->u.tk_wait.timer_list);
 	if (list_empty(&queue->timer_list.list))
@@ -90,7 +90,7 @@ __rpc_add_timer(struct rpc_wait_queue *queue, struct rpc_task *task)
 		return;
 
 	dprintk("RPC: %5u setting alarm for %lu ms\n",
-			task->tk_pid, task->tk_timeout * 1000 / HZ);
+			rpc_task_pid(task), task->tk_timeout * 1000 / HZ);
 
 	task->u.tk_wait.expires = jiffies + task->tk_timeout;
 	if (list_empty(&queue->timer_list.list) || time_before(task->u.tk_wait.expires, queue->timer_list.expires))
@@ -185,7 +185,7 @@ static void __rpc_add_wait_queue(struct rpc_wait_queue *queue,
 	rpc_set_queued(task);
 
 	dprintk("RPC: %5u added to queue %p \"%s\"\n",
-			task->tk_pid, queue, rpc_qname(queue));
+			rpc_task_pid(task), queue, rpc_qname(queue));
 }
 
 /*
@@ -214,7 +214,7 @@ static void __rpc_remove_wait_queue(struct rpc_wait_queue *queue, struct rpc_tas
 	list_del(&task->u.tk_wait.list);
 	queue->qlen--;
 	dprintk("RPC: %5u removed from queue %p \"%s\"\n",
-			task->tk_pid, queue, rpc_qname(queue));
+			rpc_task_pid(task), queue, rpc_qname(queue));
 }
 
 static void __rpc_init_priority_wait_queue(struct rpc_wait_queue *queue, const char *qname, unsigned char nr_queues)
@@ -263,7 +263,7 @@ static void rpc_task_set_debuginfo(struct rpc_task *task)
 {
 	static atomic_t rpc_pid;
 
-	task->tk_pid = atomic_inc_return(&rpc_pid);
+	rpc_task_pid(task) = atomic_inc_return(&rpc_pid);
 }
 #else
 static inline void rpc_task_set_debuginfo(struct rpc_task *task)
@@ -355,7 +355,7 @@ static void __rpc_sleep_on_priority(struct rpc_wait_queue *q,
 		unsigned char queue_priority)
 {
 	dprintk("RPC: %5u sleep_on(queue \"%s\" time %lu)\n",
-			task->tk_pid, rpc_qname(q), jiffies);
+			rpc_task_pid(task), rpc_qname(q), jiffies);
 
 	trace_rpc_task_sleep(task->tk_client, task, q);
 
@@ -416,7 +416,7 @@ EXPORT_SYMBOL_GPL(rpc_sleep_on_priority);
 static void __rpc_do_wake_up_task(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
 	dprintk("RPC: %5u __rpc_wake_up_task (now %lu)\n",
-			task->tk_pid, jiffies);
+			rpc_task_pid(task), jiffies);
 
 	/* Has the task been executed yet? If not, we cannot wake it up! */
 	if (!RPC_IS_ACTIVATED(task)) {
@@ -622,7 +622,7 @@ static void __rpc_queue_timer_fn(unsigned long ptr)
 	list_for_each_entry_safe(task, n, &queue->timer_list.list, u.tk_wait.timer_list) {
 		timeo = task->u.tk_wait.expires;
 		if (time_after_eq(now, timeo)) {
-			dprintk("RPC: %5u timeout\n", task->tk_pid);
+			dprintk("RPC: %5u timeout\n", rpc_task_pid(task));
 			task->tk_status = -ETIMEDOUT;
 			rpc_wake_up_task_queue_locked(queue, task);
 			continue;
@@ -721,7 +721,7 @@ static void __rpc_execute(struct rpc_task *task)
 	int status = 0;
 
 	dprintk("RPC: %5u __rpc_execute flags=0x%x\n",
-			task->tk_pid, task->tk_flags);
+			rpc_task_pid(task), task->tk_flags);
 
 	WARN_ON_ONCE(RPC_IS_QUEUED(task));
 	if (RPC_IS_QUEUED(task))
@@ -775,7 +775,7 @@ static void __rpc_execute(struct rpc_task *task)
 			return;
 
 		/* sync task: sleep here */
-		dprintk("RPC: %5u sync task going to sleep\n", task->tk_pid);
+		dprintk("RPC: %5u sync task going to sleep\n", rpc_task_pid(task));
 		status = out_of_line_wait_on_bit(&task->tk_runstate,
 				RPC_TASK_QUEUED, rpc_wait_bit_killable,
 				TASK_KILLABLE);
@@ -786,14 +786,14 @@ static void __rpc_execute(struct rpc_task *task)
 			 * clean up after sleeping on some queue, we don't
 			 * break the loop here, but go around once more.
 			 */
-			dprintk("RPC: %5u got signal\n", task->tk_pid);
+			dprintk("RPC: %5u got signal\n", rpc_task_pid(task));
 			task->tk_flags |= RPC_TASK_KILLED;
 			rpc_exit(task, -ERESTARTSYS);
 		}
-		dprintk("RPC: %5u sync task resuming\n", task->tk_pid);
+		dprintk("RPC: %5u sync task resuming\n", rpc_task_pid(task));
 	}
 
-	dprintk("RPC: %5u return %d, status %d\n", task->tk_pid, status,
+	dprintk("RPC: %5u return %d, status %d\n", rpc_task_pid(task), status,
 			task->tk_status);
 	/* Release all resources associated with the task */
 	rpc_release_task(task);
@@ -860,7 +860,7 @@ void *rpc_malloc(struct rpc_task *task, size_t size)
 
 	buf->len = size;
 	dprintk("RPC: %5u allocated buffer of size %zu at %p\n",
-			task->tk_pid, size, buf);
+			rpc_task_pid(task), size, buf);
 	return &buf->data;
 }
 EXPORT_SYMBOL_GPL(rpc_malloc);
@@ -974,7 +974,7 @@ static void rpc_free_task(struct rpc_task *task)
 	rpc_release_calldata(task->tk_ops, task->tk_calldata);
 
 	if (tk_flags & RPC_TASK_DYNAMIC) {
-		dprintk("RPC: %5u freeing task\n", task->tk_pid);
+		dprintk("RPC: %5u freeing task\n", rpc_task_pid(task));
 		mempool_free(task, rpc_task_mempool);
 	}
 }
@@ -1026,7 +1026,7 @@ EXPORT_SYMBOL_GPL(rpc_put_task_async);
 
 static void rpc_release_task(struct rpc_task *task)
 {
-	dprintk("RPC: %5u release task\n", task->tk_pid);
+	dprintk("RPC: %5u release task\n", rpc_task_pid(task));
 
 	WARN_ON_ONCE(RPC_IS_QUEUED(task));
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 095363e..b7d2042 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -214,7 +214,7 @@ int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 
 out_sleep:
 	dprintk("RPC: %5u failed to lock transport %p\n",
-			task->tk_pid, xprt);
+			rpc_task_pid(task), xprt);
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
 	if (req == NULL)
@@ -269,7 +269,7 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 	}
 	xprt_clear_locked(xprt);
 out_sleep:
-	dprintk("RPC: %5u failed to lock transport %p\n", task->tk_pid, xprt);
+	dprintk("RPC: %5u failed to lock transport %p\n", rpc_task_pid(task), xprt);
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
 	if (req == NULL)
@@ -400,7 +400,7 @@ __xprt_get_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 	if (req->rq_cong)
 		return 1;
 	dprintk("RPC: %5u xprt_cwnd_limited cong = %lu cwnd = %lu\n",
-			task->tk_pid, xprt->cong, xprt->cwnd);
+			rpc_task_pid(task), xprt->cong, xprt->cwnd);
 	if (RPCXPRT_CONGESTED(xprt))
 		return 0;
 	req->rq_cong = 1;
@@ -703,7 +703,7 @@ void xprt_connect(struct rpc_task *task)
 {
 	struct rpc_xprt	*xprt = task->tk_rqstp->rq_xprt;
 
-	dprintk("RPC: %5u xprt_connect xprt %p %s connected\n", task->tk_pid,
+	dprintk("RPC: %5u xprt_connect xprt %p %s connected\n", rpc_task_pid(task),
 			xprt, (xprt_connected(xprt) ? "is" : "is not"));
 
 	if (!xprt_bound(xprt)) {
@@ -740,21 +740,21 @@ static void xprt_connect_status(struct rpc_task *task)
 		xprt->stat.connect_count++;
 		xprt->stat.connect_time += (long)jiffies - xprt->stat.connect_start;
 		dprintk("RPC: %5u xprt_connect_status: connection established\n",
-				task->tk_pid);
+				rpc_task_pid(task));
 		return;
 	}
 
 	switch (task->tk_status) {
 	case -EAGAIN:
-		dprintk("RPC: %5u xprt_connect_status: retrying\n", task->tk_pid);
+		dprintk("RPC: %5u xprt_connect_status: retrying\n", rpc_task_pid(task));
 		break;
 	case -ETIMEDOUT:
 		dprintk("RPC: %5u xprt_connect_status: connect attempt timed "
-				"out\n", task->tk_pid);
+				"out\n", rpc_task_pid(task));
 		break;
 	default:
 		dprintk("RPC: %5u xprt_connect_status: error %d connecting to "
-				"server %s\n", task->tk_pid, -task->tk_status,
+				"server %s\n", rpc_task_pid(task), -task->tk_status,
 				xprt->servername);
 		xprt_release_write(xprt, task);
 		task->tk_status = -EIO;
@@ -809,7 +809,7 @@ void xprt_complete_rqst(struct rpc_task *task, int copied)
 	struct rpc_xprt *xprt = req->rq_xprt;
 
 	dprintk("RPC: %5u xid %08x complete (%d bytes received)\n",
-			task->tk_pid, ntohl(req->rq_xid), copied);
+			rpc_task_pid(task), ntohl(req->rq_xid), copied);
 
 	xprt->stat.recvs++;
 	req->rq_rtt = ktime_sub(ktime_get(), req->rq_xtime);
@@ -833,7 +833,7 @@ static void xprt_timer(struct rpc_task *task)
 
 	if (task->tk_status != -ETIMEDOUT)
 		return;
-	dprintk("RPC: %5u xprt_timer\n", task->tk_pid);
+	dprintk("RPC: %5u xprt_timer\n", rpc_task_pid(task));
 
 	spin_lock_bh(&xprt->transport_lock);
 	if (!req->rq_reply_bytes_recvd) {
@@ -860,7 +860,7 @@ int xprt_prepare_transmit(struct rpc_task *task)
 	struct rpc_xprt	*xprt = req->rq_xprt;
 	int err = 0;
 
-	dprintk("RPC: %5u xprt_prepare_transmit\n", task->tk_pid);
+	dprintk("RPC: %5u xprt_prepare_transmit\n", rpc_task_pid(task));
 
 	spin_lock_bh(&xprt->transport_lock);
 	if (req->rq_reply_bytes_recvd && !req->rq_bytes_sent) {
@@ -891,7 +891,7 @@ void xprt_transmit(struct rpc_task *task)
 	struct rpc_xprt	*xprt = req->rq_xprt;
 	int status, numreqs;
 
-	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
+	dprintk("RPC: %5u xprt_transmit(%u)\n", rpc_task_pid(task), req->rq_slen);
 
 	if (!req->rq_reply_bytes_recvd) {
 		if (list_empty(&req->rq_list) && rpc_reply_expected(task)) {
@@ -920,7 +920,7 @@ void xprt_transmit(struct rpc_task *task)
 		return;
 	}
 
-	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
+	dprintk("RPC: %5u xmit complete\n", rpc_task_pid(task));
 	task->tk_flags |= RPC_TASK_SENT;
 	spin_lock_bh(&xprt->transport_lock);
 
@@ -1188,7 +1188,7 @@ static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
 	req->rq_xid     = xprt_alloc_xid(xprt);
 	req->rq_release_snd_buf = NULL;
 	xprt_reset_majortimeo(req);
-	dprintk("RPC: %5u reserved req %p xid %08x\n", task->tk_pid,
+	dprintk("RPC: %5u reserved req %p xid %08x\n", rpc_task_pid(task),
 			req, ntohl(req->rq_xid));
 }
 
@@ -1237,7 +1237,7 @@ void xprt_release(struct rpc_task *task)
 	if (req->rq_release_snd_buf)
 		req->rq_release_snd_buf(req);
 
-	dprintk("RPC: %5u release request %p\n", task->tk_pid, req);
+	dprintk("RPC: %5u release request %p\n", rpc_task_pid(task), req);
 	if (likely(!bc_prealloc(req)))
 		xprt_free_slot(xprt, req);
 	else
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ee03d35..5bfcdf6 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -501,7 +501,7 @@ static int xs_nospace(struct rpc_task *task)
 	int ret = -EAGAIN;
 
 	dprintk("RPC: %5u xmit incomplete (%u left of %u)\n",
-			task->tk_pid, req->rq_slen - req->rq_bytes_sent,
+			rpc_task_pid(task), req->rq_slen - req->rq_bytes_sent,
 			req->rq_slen);
 
 	/* Protect against races with write_space */

