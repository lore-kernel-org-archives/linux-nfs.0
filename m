From: Jeff Layton <jlayton@redhat.com>
Subject: [RFC PATCH 1/9] sunrpc: abstract out encoding function at rpc_clnt level
Date: Sun, 27 Sep 2009 12:50:22 -0400
Message-ID: <1254070230-13125-2-git-send-email-jlayton@redhat.com>
References: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, linux-cifs-client@lists.samba.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.122]:60227 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807AbZI0Qu2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2009 12:50:28 -0400
In-Reply-To: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to add the ability to do an SMB call with the sunrpc layer, we
need to abstract out the call encoding. Add a function pointer that hangs
off of the rpc_clnt to do the encoding. For now, all of the existing
callers will simply set it to rpc_xdr_encode.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/host.c             |    3 +++
 fs/lockd/mon.c              |    3 +++
 fs/nfs/client.c             |    3 +++
 fs/nfs/mount_clnt.c         |    3 +++
 fs/nfsd/nfs4callback.c      |    3 +++
 include/linux/sunrpc/clnt.h |    7 +++++++
 net/sunrpc/clnt.c           |   14 ++++++++++----
 net/sunrpc/rpcb_clnt.c      |    6 ++++++
 8 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 4600c20..b7189ce 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -362,6 +362,9 @@ nlm_bind_host(struct nlm_host *host)
 			.program	= &nlm_program,
 			.version	= host->h_version,
 			.authflavor	= RPC_AUTH_UNIX,
+			.encode		= rpc_xdr_encode,
+			.callhdr_size	= RPC_CALLHDRSIZE,
+			.replhdr_size	= RPC_REPHDRSIZE,
 			.flags		= (RPC_CLNT_CREATE_NOPING |
 					   RPC_CLNT_CREATE_AUTOBIND),
 		};
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index f956651..ea24301 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -75,6 +75,9 @@ static struct rpc_clnt *nsm_create(void)
 		.program		= &nsm_program,
 		.version		= NSM_VERSION,
 		.authflavor		= RPC_AUTH_NULL,
+		.encode			= rpc_xdr_encode,
+		.callhdr_size		= RPC_CALLHDRSIZE,
+		.replhdr_size		= RPC_REPHDRSIZE,
 		.flags			= RPC_CLNT_CREATE_NOPING,
 	};
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 63976c0..5505ddf 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -606,6 +606,9 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 		.servername	= clp->cl_hostname,
 		.program	= &nfs_program,
 		.version	= clp->rpc_ops->version,
+		.encode		= rpc_xdr_encode,
+		.callhdr_size	= RPC_CALLHDRSIZE,
+		.replhdr_size	= RPC_REPHDRSIZE,
 		.authflavor	= flavor,
 	};
 
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 0adefc4..14f79e5 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -159,6 +159,9 @@ int nfs_mount(struct nfs_mount_request *info)
 		.servername	= info->hostname,
 		.program	= &mnt_program,
 		.version	= info->version,
+		.encode		= rpc_xdr_encode,
+		.callhdr_size	= RPC_CALLHDRSIZE,
+		.replhdr_size	= RPC_REPHDRSIZE,
 		.authflavor	= RPC_AUTH_UNIX,
 	};
 	struct rpc_clnt		*mnt_clnt;
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 24e8d78..dbfd91c 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -494,6 +494,9 @@ int setup_callback_client(struct nfs4_client *clp)
 		.authflavor	= clp->cl_flavor,
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
 		.client_name    = clp->cl_principal,
+		.encode		= rpc_xdr_encode,
+		.callhdr_size	= RPC_CALLHDRSIZE,
+		.replhdr_size	= RPC_REPHDRSIZE,
 	};
 	struct rpc_clnt *client;
 
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 8ed9642..6209c39 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -63,6 +63,9 @@ struct rpc_clnt {
 	struct rpc_program *	cl_program;
 	char			cl_inline_name[32];
 	char			*cl_principal;	/* target to authenticate to */
+	void			(*cl_encode) (struct rpc_task *task);
+	size_t			cl_callhdr_sz; /* in quadwords */
+	size_t			cl_replhdr_sz; /* in quadwords */
 };
 
 /*
@@ -115,6 +118,9 @@ struct rpc_create_args {
 	unsigned long		flags;
 	char			*client_name;
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
+	size_t			callhdr_size;	/* in quadwords */
+	size_t			replhdr_size;	/* in quadwords */
+	void			(*encode) (struct rpc_task *task);
 };
 
 /* Values for "flags" field */
@@ -150,6 +156,7 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred,
 			       int flags);
 void		rpc_restart_call_prepare(struct rpc_task *);
 void		rpc_restart_call(struct rpc_task *);
+void		rpc_xdr_encode(struct rpc_task *);
 void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
 size_t		rpc_max_payload(struct rpc_clnt *);
 void		rpc_force_rebind(struct rpc_clnt *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 38829e2..f675416 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -200,6 +200,10 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	clnt->cl_vers     = version->number;
 	clnt->cl_stats    = program->stats;
 	clnt->cl_metrics  = rpc_alloc_iostats(clnt);
+	clnt->cl_encode   = args->encode;
+	clnt->cl_callhdr_sz	= args->callhdr_size;
+	clnt->cl_replhdr_sz	= args->replhdr_size;
+
 	err = -ENOMEM;
 	if (clnt->cl_metrics == NULL)
 		goto out_no_stats;
@@ -905,6 +909,7 @@ call_allocate(struct rpc_task *task)
 	unsigned int slack = task->tk_msg.rpc_cred->cr_auth->au_cslack;
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = task->tk_xprt;
+	struct rpc_clnt *clnt = task->tk_client;
 	struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
 
 	dprint_status(task);
@@ -926,9 +931,9 @@ call_allocate(struct rpc_task *task)
 	 * and reply headers, and convert both values
 	 * to byte sizes.
 	 */
-	req->rq_callsize = RPC_CALLHDRSIZE + (slack << 1) + proc->p_arglen;
+	req->rq_callsize = clnt->cl_callhdr_sz + (slack << 1) + proc->p_arglen;
 	req->rq_callsize <<= 2;
-	req->rq_rcvsize = RPC_REPHDRSIZE + slack + proc->p_replen;
+	req->rq_rcvsize = clnt->cl_replhdr_sz + slack + proc->p_replen;
 	req->rq_rcvsize <<= 2;
 
 	req->rq_buffer = xprt->ops->buf_alloc(task,
@@ -975,7 +980,7 @@ rpc_xdr_buf_init(struct xdr_buf *buf, void *start, size_t len)
 /*
  * 3.	Encode arguments of an RPC call
  */
-static void
+void
 rpc_xdr_encode(struct rpc_task *task)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
@@ -1005,6 +1010,7 @@ rpc_xdr_encode(struct rpc_task *task)
 	task->tk_status = rpcauth_wrap_req(task, encode, req, p,
 			task->tk_msg.rpc_argp);
 }
+EXPORT_SYMBOL_GPL(rpc_xdr_encode);
 
 /*
  * 4.	Get the server port number if not yet set
@@ -1148,7 +1154,7 @@ call_transmit(struct rpc_task *task)
 	/* Encode here so that rpcsec_gss can use correct sequence number. */
 	if (rpc_task_need_encode(task)) {
 		BUG_ON(task->tk_rqstp->rq_bytes_sent != 0);
-		rpc_xdr_encode(task);
+		task->tk_client->cl_encode(task);
 		/* Did the encode result in an error condition? */
 		if (task->tk_status != 0) {
 			/* Was the error nonfatal? */
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 830faf4..65764ba 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -174,6 +174,9 @@ static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
 		.program	= &rpcb_program,
 		.version	= version,
 		.authflavor	= RPC_AUTH_UNIX,
+		.encode		= rpc_xdr_encode,
+		.callhdr_size	= RPC_CALLHDRSIZE,
+		.replhdr_size	= RPC_REPHDRSIZE,
 		.flags		= RPC_CLNT_CREATE_NOPING,
 	};
 
@@ -191,6 +194,9 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 		.program	= &rpcb_program,
 		.version	= version,
 		.authflavor	= RPC_AUTH_UNIX,
+		.encode		= rpc_xdr_encode,
+		.callhdr_size	= RPC_CALLHDRSIZE,
+		.replhdr_size	= RPC_REPHDRSIZE,
 		.flags		= (RPC_CLNT_CREATE_NOPING |
 					RPC_CLNT_CREATE_NONPRIVPORT),
 	};
-- 
1.6.0.6

