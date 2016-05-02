Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34902 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695AbcEBSkm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 14:40:42 -0400
Subject: [PATCH v3 03/20] sunrpc: Advertise maximum backchannel payload size
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 02 May 2016 14:40:40 -0400
Message-ID: <20160502184039.10798.82141.stgit@manet.1015granger.net>
In-Reply-To: <20160502183144.10798.99847.stgit@manet.1015granger.net>
References: <20160502183144.10798.99847.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RPC-over-RDMA transports have a limit on how large a backward
direction (backchannel) RPC message can be. Ensure that the NFSv4.x
CREATE_SESSION operation advertises this limit to servers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
---
 fs/nfs/nfs4proc.c                 |   10 ++++++----
 include/linux/sunrpc/clnt.h       |    1 +
 include/linux/sunrpc/xprt.h       |    1 +
 net/sunrpc/clnt.c                 |   17 +++++++++++++++++
 net/sunrpc/xprtrdma/backchannel.c |   16 ++++++++++++++++
 net/sunrpc/xprtrdma/transport.c   |    1 +
 net/sunrpc/xprtrdma/xprt_rdma.h   |    1 +
 net/sunrpc/xprtsock.c             |    6 ++++++
 8 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 327b8c3..01bef06 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7351,9 +7351,11 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
  * always set csa_cachethis to FALSE because the current implementation
  * of the back channel DRC only supports caching the CB_SEQUENCE operation.
  */
-static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
+static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args,
+				    struct rpc_clnt *clnt)
 {
 	unsigned int max_rqst_sz, max_resp_sz;
+	unsigned int max_bc_payload = rpc_max_bc_payload(clnt);
 
 	max_rqst_sz = NFS_MAX_FILE_IO_SIZE + nfs41_maxwrite_overhead;
 	max_resp_sz = NFS_MAX_FILE_IO_SIZE + nfs41_maxread_overhead;
@@ -7371,8 +7373,8 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 		args->fc_attrs.max_ops, args->fc_attrs.max_reqs);
 
 	/* Back channel attributes */
-	args->bc_attrs.max_rqst_sz = PAGE_SIZE;
-	args->bc_attrs.max_resp_sz = PAGE_SIZE;
+	args->bc_attrs.max_rqst_sz = max_bc_payload;
+	args->bc_attrs.max_resp_sz = max_bc_payload;
 	args->bc_attrs.max_resp_sz_cached = 0;
 	args->bc_attrs.max_ops = NFS4_MAX_BACK_CHANNEL_OPS;
 	args->bc_attrs.max_reqs = NFS41_BC_MAX_CALLBACKS;
@@ -7476,7 +7478,7 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
 	};
 	int status;
 
-	nfs4_init_channel_attrs(&args);
+	nfs4_init_channel_attrs(&args, clp->cl_rpcclient);
 	args.flags = (SESSION4_PERSIST | SESSION4_BACK_CHAN);
 
 	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 9a7ddba..19c659d 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -176,6 +176,7 @@ void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
 int		rpc_protocol(struct rpc_clnt *);
 struct net *	rpc_net_ns(struct rpc_clnt *);
 size_t		rpc_max_payload(struct rpc_clnt *);
+size_t		rpc_max_bc_payload(struct rpc_clnt *);
 unsigned long	rpc_get_timeout(struct rpc_clnt *clnt);
 void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index fb0d212..5aa3834 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -142,6 +142,7 @@ struct rpc_xprt_ops {
 	int		(*bc_setup)(struct rpc_xprt *xprt,
 				    unsigned int min_reqs);
 	int		(*bc_up)(struct svc_serv *serv, struct net *net);
+	size_t		(*bc_maxpayload)(struct rpc_xprt *xprt);
 	void		(*bc_free_rqst)(struct rpc_rqst *rqst);
 	void		(*bc_destroy)(struct rpc_xprt *xprt,
 				      unsigned int max_reqs);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7e0c9bf..06b4df9 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1414,6 +1414,23 @@ size_t rpc_max_payload(struct rpc_clnt *clnt)
 EXPORT_SYMBOL_GPL(rpc_max_payload);
 
 /**
+ * rpc_max_bc_payload - Get maximum backchannel payload size, in bytes
+ * @clnt: RPC client to query
+ */
+size_t rpc_max_bc_payload(struct rpc_clnt *clnt)
+{
+	struct rpc_xprt *xprt;
+	size_t ret;
+
+	rcu_read_lock();
+	xprt = rcu_dereference(clnt->cl_xprt);
+	ret = xprt->ops->bc_maxpayload(xprt);
+	rcu_read_unlock();
+	return ret;
+}
+EXPORT_SYMBOL_GPL(rpc_max_bc_payload);
+
+/**
  * rpc_get_timeout - Get timeout for transport in units of HZ
  * @clnt: RPC client to query
  */
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 2dcd764..87762d9 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -192,6 +192,22 @@ int xprt_rdma_bc_up(struct svc_serv *serv, struct net *net)
 }
 
 /**
+ * xprt_rdma_bc_maxpayload - Return maximum backchannel message size
+ * @xprt: transport
+ *
+ * Returns maximum size, in bytes, of a backchannel message
+ */
+size_t xprt_rdma_bc_maxpayload(struct rpc_xprt *xprt)
+{
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
+	size_t maxmsg;
+
+	maxmsg = min_t(unsigned int, cdata->inline_rsize, cdata->inline_wsize);
+	return maxmsg - RPCRDMA_HDRLEN_MIN;
+}
+
+/**
  * rpcrdma_bc_marshal_reply - Send backwards direction reply
  * @rqst: buffer containing RPC reply data
  *
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index b1b009f..9954342 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -707,6 +707,7 @@ static struct rpc_xprt_ops xprt_rdma_procs = {
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	.bc_setup		= xprt_rdma_bc_setup,
 	.bc_up			= xprt_rdma_bc_up,
+	.bc_maxpayload		= xprt_rdma_bc_maxpayload,
 	.bc_free_rqst		= xprt_rdma_bc_free_rqst,
 	.bc_destroy		= xprt_rdma_bc_destroy,
 #endif
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 2ebc743..7723e5f 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -534,6 +534,7 @@ void xprt_rdma_cleanup(void);
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 int xprt_rdma_bc_setup(struct rpc_xprt *, unsigned int);
 int xprt_rdma_bc_up(struct svc_serv *, struct net *);
+size_t xprt_rdma_bc_maxpayload(struct rpc_xprt *);
 int rpcrdma_bc_post_recv(struct rpcrdma_xprt *, unsigned int);
 void rpcrdma_bc_receive_call(struct rpcrdma_xprt *, struct rpcrdma_rep *);
 int rpcrdma_bc_marshal_reply(struct rpc_rqst *);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 65e7595..f1faf6b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1365,6 +1365,11 @@ static int xs_tcp_bc_up(struct svc_serv *serv, struct net *net)
 		return ret;
 	return 0;
 }
+
+static size_t xs_tcp_bc_maxpayload(struct rpc_xprt *xprt)
+{
+	return PAGE_SIZE;
+}
 #else
 static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
 					struct xdr_skb_reader *desc)
@@ -2660,6 +2665,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 #ifdef CONFIG_SUNRPC_BACKCHANNEL
 	.bc_setup		= xprt_setup_bc,
 	.bc_up			= xs_tcp_bc_up,
+	.bc_maxpayload		= xs_tcp_bc_maxpayload,
 	.bc_free_rqst		= xprt_free_bc_rqst,
 	.bc_destroy		= xprt_destroy_bc,
 #endif

