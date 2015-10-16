Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:32837 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbbJPNZ6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 09:25:58 -0400
Subject: [PATCH v3 14/16] svcrdma: Add backward direction service for
 RPC/RDMA transport
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 16 Oct 2015 09:25:56 -0400
Message-ID: <20151016132556.6819.32755.stgit@oracle-122.nfsv4bat.org>
In-Reply-To: <20151016131958.6819.98407.stgit@oracle-122.nfsv4bat.org>
References: <20151016131958.6819.98407.stgit@oracle-122.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On NFSv4.1 mount points, the Linux NFS client uses this transport
endpoint to receive backward direction calls and route replies back
to the NFSv4.1 server.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: "J. Bruce Fields" <bfields@fieldses.org>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
---
 include/linux/sunrpc/svc_rdma.h          |    6 +++
 include/linux/sunrpc/xprt.h              |    1 +
 net/sunrpc/xprtrdma/svc_rdma.c           |    6 +++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   58 ++++++++++++++++++++++++++++++
 4 files changed, 70 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 7ccc961..fb4013e 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -228,9 +228,13 @@ extern void svc_rdma_put_frmr(struct svcxprt_rdma *,
 			      struct svc_rdma_fastreg_mr *);
 extern void svc_sq_reap(struct svcxprt_rdma *);
 extern void svc_rq_reap(struct svcxprt_rdma *);
-extern struct svc_xprt_class svc_rdma_class;
 extern void svc_rdma_prep_reply_hdr(struct svc_rqst *);
 
+extern struct svc_xprt_class svc_rdma_class;
+#ifdef CONFIG_SUNRPC_BACKCHANNEL
+extern struct svc_xprt_class svc_rdma_bc_class;
+#endif
+
 /* svc_rdma.c */
 extern int svc_rdma_init(void);
 extern void svc_rdma_cleanup(void);
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 3f79c4a..82c0839 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -158,6 +158,7 @@ enum xprt_transports {
 	XPRT_TRANSPORT_TCP	= IPPROTO_TCP,
 	XPRT_TRANSPORT_BC_TCP	= IPPROTO_TCP | XPRT_TRANSPORT_BC,
 	XPRT_TRANSPORT_RDMA	= 256,
+	XPRT_TRANSPORT_BC_RDMA	= XPRT_TRANSPORT_RDMA | XPRT_TRANSPORT_BC,
 	XPRT_TRANSPORT_LOCAL	= 257,
 };
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index 2cd252f..1b7051b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -239,6 +239,9 @@ void svc_rdma_cleanup(void)
 		unregister_sysctl_table(svcrdma_table_header);
 		svcrdma_table_header = NULL;
 	}
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
+	svc_unreg_xprt_class(&svc_rdma_bc_class);
+#endif
 	svc_unreg_xprt_class(&svc_rdma_class);
 	kmem_cache_destroy(svc_rdma_map_cachep);
 	kmem_cache_destroy(svc_rdma_ctxt_cachep);
@@ -286,6 +289,9 @@ int svc_rdma_init(void)
 
 	/* Register RDMA with the SVC transport switch */
 	svc_reg_xprt_class(&svc_rdma_class);
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
+	svc_reg_xprt_class(&svc_rdma_bc_class);
+#endif
 	return 0;
  err1:
 	kmem_cache_destroy(svc_rdma_map_cachep);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index fcc3eb8..a133b1e 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -56,6 +56,7 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
+static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *, int);
 static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 					struct net *net,
 					struct sockaddr *sa, int salen,
@@ -95,6 +96,63 @@ struct svc_xprt_class svc_rdma_class = {
 	.xcl_ident = XPRT_TRANSPORT_RDMA,
 };
 
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
+static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *, struct net *,
+					   struct sockaddr *, int, int);
+static void svc_rdma_bc_detach(struct svc_xprt *);
+static void svc_rdma_bc_free(struct svc_xprt *);
+
+static struct svc_xprt_ops svc_rdma_bc_ops = {
+	.xpo_create = svc_rdma_bc_create,
+	.xpo_detach = svc_rdma_bc_detach,
+	.xpo_free = svc_rdma_bc_free,
+	.xpo_prep_reply_hdr = svc_rdma_prep_reply_hdr,
+	.xpo_secure_port = svc_rdma_secure_port,
+};
+
+struct svc_xprt_class svc_rdma_bc_class = {
+	.xcl_name = "rdma-bc",
+	.xcl_owner = THIS_MODULE,
+	.xcl_ops = &svc_rdma_bc_ops,
+	.xcl_max_payload = (1024 - RPCRDMA_HDRLEN_MIN)
+};
+
+static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *serv,
+					   struct net *net,
+					   struct sockaddr *sa, int salen,
+					   int flags)
+{
+	struct svcxprt_rdma *cma_xprt;
+	struct svc_xprt *xprt;
+
+	cma_xprt = rdma_create_xprt(serv, 0);
+	if (!cma_xprt)
+		return ERR_PTR(-ENOMEM);
+	xprt = &cma_xprt->sc_xprt;
+
+	svc_xprt_init(net, &svc_rdma_bc_class, xprt, serv);
+	serv->sv_bc_xprt = xprt;
+
+	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
+	return xprt;
+}
+
+static void svc_rdma_bc_detach(struct svc_xprt *xprt)
+{
+	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
+}
+
+static void svc_rdma_bc_free(struct svc_xprt *xprt)
+{
+	struct svcxprt_rdma *rdma =
+		container_of(xprt, struct svcxprt_rdma, sc_xprt);
+
+	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
+	if (xprt)
+		kfree(rdma);
+}
+#endif	/* CONFIG_SUNRPC_BACKCHANNEL */
+
 struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 {
 	struct svc_rdma_op_ctxt *ctxt;

