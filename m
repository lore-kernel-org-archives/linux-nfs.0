Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:34450 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648AbcEBSk7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 14:40:59 -0400
Subject: [PATCH v3 05/20] xprtrdma: Limit number of RDMA segments in
 RPC-over-RDMA headers
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 02 May 2016 14:40:56 -0400
Message-ID: <20160502184056.10798.9002.stgit@manet.1015granger.net>
In-Reply-To: <20160502183144.10798.99847.stgit@manet.1015granger.net>
References: <20160502183144.10798.99847.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Send buffer space is shared between the RPC-over-RDMA header and
an RPC message. A large RPC-over-RDMA header means less space is
available for the associated RPC message, which then has to be
moved via an RDMA Read or Write.

As more segments are added to the chunk lists, the header increases
in size.  Typical modern hardware needs only a few segments to
convey the maximum payload size, but some devices and registration
modes may need a lot of segments to convey data payload. Sometimes
so many are needed that the remaining space in the Send buffer is
not enough for the RPC message. Sending such a message usually
fails.

To ensure a transport can always make forward progress, cap the
number of RDMA segments that are allowed in chunk lists. This
prevents less-capable devices and memory registrations from
consuming a large portion of the Send buffer by reducing the
maximum data payload that can be conveyed with such devices.

For now I choose an arbitrary maximum of 8 RDMA segments. This
allows a maximum size RPC-over-RDMA header to fit nicely in the
current 1024 byte inline threshold with over 700 bytes remaining
for an inline RPC message.

The current maximum data payload of NFS READ or WRITE requests is
one megabyte. To convey that payload on a client with 4KB pages,
each chunk segment would need to handle 32 or more data pages. This
is well within the capabilities of FMR. For physical registration,
the maximum payload size on platforms with 4KB pages is reduced to
32KB.

For FRWR, a device's maximum page list depth would need to be at
least 34 to support the maximum 1MB payload. A device with a smaller
maximum page list depth means the maximum data payload is reduced
when using that device.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |    2 +-
 net/sunrpc/xprtrdma/frwr_ops.c     |    2 +-
 net/sunrpc/xprtrdma/physical_ops.c |    2 +-
 net/sunrpc/xprtrdma/verbs.c        |   22 ----------------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |   21 ++++++++++++++++++++-
 5 files changed, 23 insertions(+), 26 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index b289e10..4aeb104 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -48,7 +48,7 @@ static size_t
 fmr_op_maxpages(struct rpcrdma_xprt *r_xprt)
 {
 	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
-		     rpcrdma_max_segments(r_xprt) * RPCRDMA_MAX_FMR_SGES);
+		     RPCRDMA_MAX_HDR_SEGS * RPCRDMA_MAX_FMR_SGES);
 }
 
 static int
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index c250924..2f37598 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -243,7 +243,7 @@ frwr_op_maxpages(struct rpcrdma_xprt *r_xprt)
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
 	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
-		     rpcrdma_max_segments(r_xprt) * ia->ri_max_frmr_depth);
+		     RPCRDMA_MAX_HDR_SEGS * ia->ri_max_frmr_depth);
 }
 
 static void
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index 481b9b6..e16ed54 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -47,7 +47,7 @@ static size_t
 physical_op_maxpages(struct rpcrdma_xprt *r_xprt)
 {
 	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
-		     rpcrdma_max_segments(r_xprt));
+		     RPCRDMA_MAX_HDR_SEGS);
 }
 
 static int
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index f5ed9f9..9f8d6c1 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1271,25 +1271,3 @@ out_rc:
 	rpcrdma_recv_buffer_put(rep);
 	return rc;
 }
-
-/* How many chunk list items fit within our inline buffers?
- */
-unsigned int
-rpcrdma_max_segments(struct rpcrdma_xprt *r_xprt)
-{
-	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
-	int bytes, segments;
-
-	bytes = min_t(unsigned int, cdata->inline_wsize, cdata->inline_rsize);
-	bytes -= RPCRDMA_HDRLEN_MIN;
-	if (bytes < sizeof(struct rpcrdma_segment) * 2) {
-		pr_warn("RPC:       %s: inline threshold too small\n",
-			__func__);
-		return 0;
-	}
-
-	segments = 1 << (fls(bytes / sizeof(struct rpcrdma_segment)) - 1);
-	dprintk("RPC:       %s: max chunk list size = %d segments\n",
-		__func__, segments);
-	return segments;
-}
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 7723e5f..0028748 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -144,6 +144,26 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
 
 #define RPCRDMA_DEF_GFP		(GFP_NOIO | __GFP_NOWARN)
 
+/* To ensure a transport can always make forward progress,
+ * the number of RDMA segments allowed in header chunk lists
+ * is capped at 8. This prevents less-capable devices and
+ * memory registrations from overrunning the Send buffer
+ * while building chunk lists.
+ *
+ * Elements of the Read list take up more room than the
+ * Write list or Reply chunk. 8 read segments means the Read
+ * list (or Write list or Reply chunk) cannot consume more
+ * than
+ *
+ * ((8 + 2) * read segment size) + 1 XDR words, or 244 bytes.
+ *
+ * And the fixed part of the header is another 24 bytes.
+ *
+ * The smallest inline threshold is 1024 bytes, ensuring that
+ * at least 750 bytes are available for RPC messages.
+ */
+#define RPCRDMA_MAX_HDR_SEGS	(8)
+
 /*
  * struct rpcrdma_rep -- this structure encapsulates state required to recv
  * and complete a reply, asychronously. It needs several pieces of
@@ -456,7 +476,6 @@ struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(struct rpcrdma_ia *,
 void rpcrdma_free_regbuf(struct rpcrdma_ia *,
 			 struct rpcrdma_regbuf *);
 
-unsigned int rpcrdma_max_segments(struct rpcrdma_xprt *);
 int rpcrdma_ep_post_extra_recv(struct rpcrdma_xprt *, unsigned int);
 
 int frwr_alloc_recovery_wq(void);

