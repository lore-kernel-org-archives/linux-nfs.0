Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:45713 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755528AbaGVOv1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 10:51:27 -0400
Subject: [PATCH v4 03/21] xprtrdma: Limit data payload size for ALLPHYSICAL
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 22 Jul 2014 10:51:24 -0400
Message-ID: <20140722145124.6010.84328.stgit@manet.1015granger.net>
In-Reply-To: <20140722144459.6010.99389.stgit@manet.1015granger.net>
References: <20140722144459.6010.99389.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the client uses physical memory registration, each page in the
payload gets its own array entry in the RPC/RDMA header's chunk list.

Therefore, don't advertise a maximum payload size that would require
more array entries than can fit in the RPC buffer where RPC/RDMA
headers are built.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=248
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
Tested-by: Shirley Ma <shirley.ma@oracle.com>
Tested-by: Devesh Sharma <devesh.sharma@emulex.com>
---
 net/sunrpc/xprtrdma/transport.c |    4 +++-
 net/sunrpc/xprtrdma/verbs.c     |   41 +++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 3 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 66f91f0..4185102 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -296,7 +296,6 @@ xprt_setup_rdma(struct xprt_create *args)
 
 	xprt->resvport = 0;		/* privileged port not needed */
 	xprt->tsh_size = 0;		/* RPC-RDMA handles framing */
-	xprt->max_payload = RPCRDMA_MAX_DATA_SEGS * PAGE_SIZE;
 	xprt->ops = &xprt_rdma_procs;
 
 	/*
@@ -382,6 +381,9 @@ xprt_setup_rdma(struct xprt_create *args)
 	new_ep->rep_xprt = xprt;
 
 	xprt_rdma_format_addresses(xprt);
+	xprt->max_payload = rpcrdma_max_payload(new_xprt);
+	dprintk("RPC:       %s: transport data payload maximum: %zu bytes\n",
+		__func__, xprt->max_payload);
 
 	if (!try_module_get(THIS_MODULE))
 		goto out4;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index cab742d..0d5187d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1822,3 +1822,44 @@ rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
 			rc);
 	return rc;
 }
+
+/* Physical mapping means one Read/Write list entry per-page.
+ * All list entries must fit within an inline buffer
+ *
+ * NB: The server must return a Write list for NFS READ,
+ *     which has the same constraint. Factor in the inline
+ *     rsize as well.
+ */
+static size_t
+rpcrdma_physical_max_payload(struct rpcrdma_xprt *r_xprt)
+{
+	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
+	unsigned int inline_size, pages;
+
+	inline_size = min_t(unsigned int,
+			    cdata->inline_wsize, cdata->inline_rsize);
+	inline_size -= RPCRDMA_HDRLEN_MIN;
+	pages = inline_size / sizeof(struct rpcrdma_segment);
+	return pages << PAGE_SHIFT;
+}
+
+static size_t
+rpcrdma_mr_max_payload(struct rpcrdma_xprt *r_xprt)
+{
+	return RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT;
+}
+
+size_t
+rpcrdma_max_payload(struct rpcrdma_xprt *r_xprt)
+{
+	size_t result;
+
+	switch (r_xprt->rx_ia.ri_memreg_strategy) {
+	case RPCRDMA_ALLPHYSICAL:
+		result = rpcrdma_physical_max_payload(r_xprt);
+		break;
+	default:
+		result = rpcrdma_mr_max_payload(r_xprt);
+	}
+	return result;
+}
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 97ca516..f3d86b2 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -348,6 +348,7 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *);
  * RPC/RDMA protocol calls - xprtrdma/rpc_rdma.c
  */
 int rpcrdma_marshal_req(struct rpc_rqst *);
+size_t rpcrdma_max_payload(struct rpcrdma_xprt *);
 
 /* Temporary NFS request map cache. Created in svc_rdma.c  */
 extern struct kmem_cache *svc_rdma_map_cachep;

