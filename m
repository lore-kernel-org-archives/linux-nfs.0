From: Jeff Layton <jlayton@redhat.com>
Subject: [RFC PATCH 3/9] sunrpc: abstract our call decoding routine
Date: Sun, 27 Sep 2009 12:50:24 -0400
Message-ID: <1254070230-13125-4-git-send-email-jlayton@redhat.com>
References: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, linux-cifs-client@lists.samba.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.121]:63274 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082AbZI0Q5N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2009 12:57:13 -0400
In-Reply-To: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...all of the existing rpc users will use the new rpc_xdr_decode function.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/host.c             |    1 +
 fs/lockd/mon.c              |    1 +
 fs/nfs/client.c             |    1 +
 fs/nfs/mount_clnt.c         |    1 +
 fs/nfsd/nfs4callback.c      |    1 +
 include/linux/sunrpc/clnt.h |    3 ++
 net/sunrpc/clnt.c           |   46 +++++++++++++++++++++++++++++-------------
 net/sunrpc/rpcb_clnt.c      |    2 +
 8 files changed, 42 insertions(+), 14 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index b7189ce..2159ee2 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -363,6 +363,7 @@ nlm_bind_host(struct nlm_host *host)
 			.version	= host->h_version,
 			.authflavor	= RPC_AUTH_UNIX,
 			.encode		= rpc_xdr_encode,
+			.decode		= rpc_xdr_decode,
 			.callhdr_size	= RPC_CALLHDRSIZE,
 			.replhdr_size	= RPC_REPHDRSIZE,
 			.flags		= (RPC_CLNT_CREATE_NOPING |
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index ea24301..bb4e1ad 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -76,6 +76,7 @@ static struct rpc_clnt *nsm_create(void)
 		.version		= NSM_VERSION,
 		.authflavor		= RPC_AUTH_NULL,
 		.encode			= rpc_xdr_encode,
+		.decode			= rpc_xdr_decode,
 		.callhdr_size		= RPC_CALLHDRSIZE,
 		.replhdr_size		= RPC_REPHDRSIZE,
 		.flags			= RPC_CLNT_CREATE_NOPING,
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5505ddf..5ec2a45 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -607,6 +607,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 		.program	= &nfs_program,
 		.version	= clp->rpc_ops->version,
 		.encode		= rpc_xdr_encode,
+		.decode		= rpc_xdr_decode,
 		.callhdr_size	= RPC_CALLHDRSIZE,
 		.replhdr_size	= RPC_REPHDRSIZE,
 		.authflavor	= flavor,
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 14f79e5..86a3b9e 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -160,6 +160,7 @@ int nfs_mount(struct nfs_mount_request *info)
 		.program	= &mnt_program,
 		.version	= info->version,
 		.encode		= rpc_xdr_encode,
+		.decode		= rpc_xdr_decode,
 		.callhdr_size	= RPC_CALLHDRSIZE,
 		.replhdr_size	= RPC_REPHDRSIZE,
 		.authflavor	= RPC_AUTH_UNIX,
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index dbfd91c..bb655a2 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -495,6 +495,7 @@ int setup_callback_client(struct nfs4_client *clp)
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
 		.client_name    = clp->cl_principal,
 		.encode		= rpc_xdr_encode,
+		.decode		= rpc_xdr_decode,
 		.callhdr_size	= RPC_CALLHDRSIZE,
 		.replhdr_size	= RPC_REPHDRSIZE,
 	};
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 6209c39..00afedc 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -64,6 +64,7 @@ struct rpc_clnt {
 	char			cl_inline_name[32];
 	char			*cl_principal;	/* target to authenticate to */
 	void			(*cl_encode) (struct rpc_task *task);
+	int			(*cl_decode) (struct rpc_task *task);
 	size_t			cl_callhdr_sz; /* in quadwords */
 	size_t			cl_replhdr_sz; /* in quadwords */
 };
@@ -121,6 +122,7 @@ struct rpc_create_args {
 	size_t			callhdr_size;	/* in quadwords */
 	size_t			replhdr_size;	/* in quadwords */
 	void			(*encode) (struct rpc_task *task);
+	int			(*decode) (struct rpc_task *task);
 };
 
 /* Values for "flags" field */
@@ -157,6 +159,7 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred,
 void		rpc_restart_call_prepare(struct rpc_task *);
 void		rpc_restart_call(struct rpc_task *);
 void		rpc_xdr_encode(struct rpc_task *);
+int		rpc_xdr_decode(struct rpc_task *);
 void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
 size_t		rpc_max_payload(struct rpc_clnt *);
 void		rpc_force_rebind(struct rpc_clnt *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e504b59..f05d289 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -201,6 +201,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	clnt->cl_stats    = program->stats;
 	clnt->cl_metrics  = rpc_alloc_iostats(clnt);
 	clnt->cl_encode   = args->encode;
+	clnt->cl_decode   = args->decode;
 	clnt->cl_callhdr_sz	= args->callhdr_size;
 	clnt->cl_replhdr_sz	= args->replhdr_size;
 
@@ -1379,6 +1380,27 @@ retry:
 	task->tk_status = 0;
 }
 
+int
+rpc_xdr_decode(struct rpc_task *task)
+{
+	struct rpc_rqst	*req = task->tk_rqstp;
+	kxdrproc_t	decode = task->tk_msg.rpc_proc->p_decode;
+	__be32		*p;
+
+	p = rpc_verify_header(task);
+	if (IS_ERR(p))
+		return PTR_ERR(p);
+
+	if (decode)
+		task->tk_status = rpcauth_unwrap_resp(task, decode, req, p,
+						      task->tk_msg.rpc_resp);
+
+	dprintk("RPC: %5u %s result %d\n", task->tk_pid, __func__,
+			task->tk_status);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rpc_xdr_decode);
+
 /*
  * 7.	Decode the RPC reply
  */
@@ -1387,8 +1409,7 @@ call_decode(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 	struct rpc_rqst	*req = task->tk_rqstp;
-	kxdrproc_t	decode = task->tk_msg.rpc_proc->p_decode;
-	__be32		*p;
+	int status;
 
 	dprintk("RPC: %5u call_decode (status %d)\n",
 			task->tk_pid, task->tk_status);
@@ -1411,22 +1432,19 @@ call_decode(struct rpc_task *task)
 	WARN_ON(memcmp(&req->rq_rcv_buf, &req->rq_private_buf,
 				sizeof(req->rq_rcv_buf)) != 0);
 
-	p = rpc_verify_header(task);
-	if (IS_ERR(p)) {
-		if (p == ERR_PTR(-EAGAIN))
-			goto out_retry;
+	if (!clnt->cl_decode)
+		BUG();
+
+	status = clnt->cl_decode(task);
+
+	if (status == -EAGAIN)
+		goto out_retry;
+	else if (status)
 		return;
-	}
 
 	task->tk_action = rpc_exit_task;
-
-	if (decode) {
-		task->tk_status = rpcauth_unwrap_resp(task, decode, req, p,
-						      task->tk_msg.rpc_resp);
-	}
-	dprintk("RPC: %5u call_decode result %d\n", task->tk_pid,
-			task->tk_status);
 	return;
+
 out_retry:
 	task->tk_status = 0;
 	/* Note: rpc_verify_header() may have freed the RPC slot */
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 65764ba..db053bf 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -175,6 +175,7 @@ static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
 		.version	= version,
 		.authflavor	= RPC_AUTH_UNIX,
 		.encode		= rpc_xdr_encode,
+		.decode		= rpc_xdr_decode,
 		.callhdr_size	= RPC_CALLHDRSIZE,
 		.replhdr_size	= RPC_REPHDRSIZE,
 		.flags		= RPC_CLNT_CREATE_NOPING,
@@ -195,6 +196,7 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 		.version	= version,
 		.authflavor	= RPC_AUTH_UNIX,
 		.encode		= rpc_xdr_encode,
+		.decode		= rpc_xdr_decode,
 		.callhdr_size	= RPC_CALLHDRSIZE,
 		.replhdr_size	= RPC_REPHDRSIZE,
 		.flags		= (RPC_CLNT_CREATE_NOPING |
-- 
1.6.0.6

