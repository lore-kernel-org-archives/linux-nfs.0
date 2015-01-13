Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:42940 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbbAMQ0u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:26:50 -0500
Subject: [PATCH v2 15/20] xprtrdma: Add struct rpcrdma_regbuf and helpers
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 13 Jan 2015 11:26:48 -0500
Message-ID: <20150113162648.14086.63963.stgit@manet.1015granger.net>
In-Reply-To: <20150113161440.14086.24801.stgit@manet.1015granger.net>
References: <20150113161440.14086.24801.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are several spots that allocate a buffer via kmalloc (usually
contiguously with another data structure) and then register that
buffer internally. I'd like to split the buffers out of these data
structures to allow the data structures to scale.

Start by adding functions that can kmalloc and register a buffer,
and can manage/preserve the buffer's associated ib_sge and ib_mr
fields.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |   55 +++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h |   43 ++++++++++++++++++++++++++++++
 2 files changed, 98 insertions(+)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 24ea6dd..cdd6aac 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1828,6 +1828,61 @@ rpcrdma_deregister_internal(struct rpcrdma_ia *ia,
 	return rc;
 }
 
+/**
+ * rpcrdma_alloc_regbuf - kmalloc and register memory for SEND/RECV buffers
+ * @ia: controlling rpcrdma_ia
+ * @size: size of buffer to be allocated, in bytes
+ * @flags: GFP flags
+ *
+ * Returns pointer to private header of an area of internally
+ * registered memory, or an ERR_PTR. The registered buffer follows
+ * the end of the private header.
+ *
+ * xprtrdma uses a regbuf for posting an outgoing RDMA SEND, or for
+ * receiving the payload of RDMA RECV operations. regbufs are not
+ * used for RDMA READ/WRITE operations, thus are registered only for
+ * LOCAL access.
+ */
+struct rpcrdma_regbuf *
+rpcrdma_alloc_regbuf(struct rpcrdma_ia *ia, size_t size, gfp_t flags)
+{
+	struct rpcrdma_regbuf *rb;
+	int rc;
+
+	rc = -ENOMEM;
+	rb = kmalloc(sizeof(*rb) + size, flags);
+	if (rb == NULL)
+		goto out;
+
+	rb->rg_size = size;
+	rb->rg_owner = NULL;
+	rc = rpcrdma_register_internal(ia, rb->rg_base, size,
+				       &rb->rg_mr, &rb->rg_iov);
+	if (rc)
+		goto out_free;
+
+	return rb;
+
+out_free:
+	kfree(rb);
+out:
+	return ERR_PTR(rc);
+}
+
+/**
+ * rpcrdma_free_regbuf - deregister and free registered buffer
+ * @ia: controlling rpcrdma_ia
+ * @rb: regbuf to be deregistered and freed
+ */
+void
+rpcrdma_free_regbuf(struct rpcrdma_ia *ia, struct rpcrdma_regbuf *rb)
+{
+	if (rb) {
+		rpcrdma_deregister_internal(ia, rb->rg_mr, &rb->rg_iov);
+		kfree(rb);
+	}
+}
+
 /*
  * Wrappers for chunk registration, shared by read/write chunk code.
  */
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 5c2fac3..36c37c6 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -106,6 +106,44 @@ struct rpcrdma_ep {
 #define INIT_CQCOUNT(ep) atomic_set(&(ep)->rep_cqcount, (ep)->rep_cqinit)
 #define DECR_CQCOUNT(ep) atomic_sub_return(1, &(ep)->rep_cqcount)
 
+/* Registered buffer -- registered kmalloc'd memory for RDMA SEND/RECV
+ *
+ * The below structure appears at the front of a large region of kmalloc'd
+ * memory, which always starts on a good alignment boundary.
+ */
+
+struct rpcrdma_regbuf {
+	size_t			rg_size;
+	struct rpcrdma_req	*rg_owner;
+	struct ib_mr		*rg_mr;
+	struct ib_sge		rg_iov;
+	__be32			rg_base[0] __attribute__ ((aligned(256)));
+};
+
+static inline u64
+rdmab_addr(struct rpcrdma_regbuf *rb)
+{
+	return rb->rg_iov.addr;
+}
+
+static inline u32
+rdmab_length(struct rpcrdma_regbuf *rb)
+{
+	return rb->rg_iov.length;
+}
+
+static inline u32
+rdmab_lkey(struct rpcrdma_regbuf *rb)
+{
+	return rb->rg_iov.lkey;
+}
+
+static inline struct rpcrdma_msg *
+rdmab_to_msg(struct rpcrdma_regbuf *rb)
+{
+	return (struct rpcrdma_msg *)rb->rg_base;
+}
+
 enum rpcrdma_chunktype {
 	rpcrdma_noch = 0,
 	rpcrdma_readch,
@@ -372,6 +410,11 @@ int rpcrdma_register_external(struct rpcrdma_mr_seg *,
 int rpcrdma_deregister_external(struct rpcrdma_mr_seg *,
 				struct rpcrdma_xprt *);
 
+struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(struct rpcrdma_ia *,
+					    size_t, gfp_t);
+void rpcrdma_free_regbuf(struct rpcrdma_ia *,
+			 struct rpcrdma_regbuf *);
+
 /*
  * RPC/RDMA connection management calls - xprtrdma/rpc_rdma.c
  */

