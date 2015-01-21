Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:53492 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbbAUQE1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2015 11:04:27 -0500
Subject: [PATCH v3 18/20] xprtrdma: Allocate RPC/RDMA receive buffer
 separately from struct rpcrdma_rep
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 21 Jan 2015 11:04:25 -0500
Message-ID: <20150121160425.17297.17345.stgit@manet.1015granger.net>
In-Reply-To: <20150121155303.17297.47423.stgit@manet.1015granger.net>
References: <20150121155303.17297.47423.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rr_base field is currently the buffer where RPC replies land.

An RPC/RDMA reply header lands in this buffer. In some cases an RPC
reply header also lands in this buffer, just after the RPC/RDMA
header.

The inline threshold is an agreed-on size limit for RDMA SEND
operations that pass from server and client. The sum of the
RPC/RDMA reply header size and the RPC reply header size must be
less than this threshold.

The largest RDMA RECV that the client should have to handle is the
size of the inline threshold. The receive buffer should thus be the
size of the inline threshold, and not related to RPCRDMA_MAX_SEGS.

RPC replies received via RDMA WRITE (long replies) are caught in
rq_rcv_buf, which is the second half of the RPC send buffer. Ie,
such replies are not involved in any way with rr_base.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    5 +++--
 net/sunrpc/xprtrdma/verbs.c     |   27 ++++++++++++++-------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   14 ++++++--------
 3 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c1d4a09..02efcaa 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -572,6 +572,7 @@ rpcrdma_count_chunks(struct rpcrdma_rep *rep, unsigned int max, int wrchunk, __b
 {
 	unsigned int i, total_len;
 	struct rpcrdma_write_chunk *cur_wchunk;
+	char *base = (char *)rdmab_to_msg(rep->rr_rdmabuf);
 
 	i = be32_to_cpu(**iptrp);
 	if (i > max)
@@ -599,7 +600,7 @@ rpcrdma_count_chunks(struct rpcrdma_rep *rep, unsigned int max, int wrchunk, __b
 			return -1;
 		cur_wchunk = (struct rpcrdma_write_chunk *) w;
 	}
-	if ((char *) cur_wchunk > rep->rr_base + rep->rr_len)
+	if ((char *)cur_wchunk > base + rep->rr_len)
 		return -1;
 
 	*iptrp = (__be32 *) cur_wchunk;
@@ -753,7 +754,7 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 		dprintk("RPC:       %s: short/invalid reply\n", __func__);
 		goto repost;
 	}
-	headerp = (struct rpcrdma_msg *) rep->rr_base;
+	headerp = rdmab_to_msg(rep->rr_rdmabuf);
 	if (headerp->rm_vers != rpcrdma_version) {
 		dprintk("RPC:       %s: invalid version %d\n",
 			__func__, be32_to_cpu(headerp->rm_vers));
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index c81749b..f58521d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -298,8 +298,9 @@ rpcrdma_recvcq_process_wc(struct ib_wc *wc, struct list_head *sched_list)
 
 	rep->rr_len = wc->byte_len;
 	ib_dma_sync_single_for_cpu(rdmab_to_ia(rep->rr_buffer)->ri_id->device,
-			rep->rr_iov.addr, rep->rr_len, DMA_FROM_DEVICE);
-	prefetch(rep->rr_base);
+				   rdmab_addr(rep->rr_rdmabuf),
+				   rep->rr_len, DMA_FROM_DEVICE);
+	prefetch(rdmab_to_msg(rep->rr_rdmabuf));
 
 out_schedule:
 	list_add_tail(&rep->rr_list, sched_list);
@@ -1092,23 +1093,21 @@ static struct rpcrdma_rep *
 rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
-	size_t rlen = 1 << fls(cdata->inline_rsize +
-			       sizeof(struct rpcrdma_rep));
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_rep *rep;
 	int rc;
 
 	rc = -ENOMEM;
-	rep = kmalloc(rlen, GFP_KERNEL);
+	rep = kzalloc(sizeof(*rep), GFP_KERNEL);
 	if (rep == NULL)
 		goto out;
-	memset(rep, 0, sizeof(*rep));
 
-	rc = rpcrdma_register_internal(ia, rep->rr_base, rlen -
-				       offsetof(struct rpcrdma_rep, rr_base),
-				       &rep->rr_handle, &rep->rr_iov);
-	if (rc)
+	rep->rr_rdmabuf = rpcrdma_alloc_regbuf(ia, cdata->inline_rsize,
+					       GFP_KERNEL);
+	if (IS_ERR(rep->rr_rdmabuf)) {
+		rc = PTR_ERR(rep->rr_rdmabuf);
 		goto out_free;
+	}
 
 	rep->rr_buffer = &r_xprt->rx_buf;
 	return rep;
@@ -1306,7 +1305,7 @@ rpcrdma_destroy_rep(struct rpcrdma_ia *ia, struct rpcrdma_rep *rep)
 	if (!rep)
 		return;
 
-	rpcrdma_deregister_internal(ia, rep->rr_handle, &rep->rr_iov);
+	rpcrdma_free_regbuf(ia, rep->rr_rdmabuf);
 	kfree(rep);
 }
 
@@ -2209,11 +2208,13 @@ rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
 
 	recv_wr.next = NULL;
 	recv_wr.wr_id = (u64) (unsigned long) rep;
-	recv_wr.sg_list = &rep->rr_iov;
+	recv_wr.sg_list = &rep->rr_rdmabuf->rg_iov;
 	recv_wr.num_sge = 1;
 
 	ib_dma_sync_single_for_cpu(ia->ri_id->device,
-		rep->rr_iov.addr, rep->rr_iov.length, DMA_BIDIRECTIONAL);
+				   rdmab_addr(rep->rr_rdmabuf),
+				   rdmab_length(rep->rr_rdmabuf),
+				   DMA_BIDIRECTIONAL);
 
 	rc = ib_post_recv(ia->ri_id->qp, &recv_wr, &recv_wr_fail);
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 84ad863..2b69316 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -180,14 +180,12 @@ enum rpcrdma_chunktype {
 struct rpcrdma_buffer;
 
 struct rpcrdma_rep {
-	unsigned int	rr_len;		/* actual received reply length */
-	struct rpcrdma_buffer *rr_buffer; /* home base for this structure */
-	struct rpc_xprt	*rr_xprt;	/* needed for request/reply matching */
-	void (*rr_func)(struct rpcrdma_rep *);/* called by tasklet in softint */
-	struct list_head rr_list;	/* tasklet list */
-	struct ib_sge	rr_iov;		/* for posting */
-	struct ib_mr	*rr_handle;	/* handle for mem in rr_iov */
-	char	rr_base[MAX_RPCRDMAHDR]; /* minimal inline receive buffer */
+	unsigned int		rr_len;
+	struct rpcrdma_buffer	*rr_buffer;
+	struct rpc_xprt		*rr_xprt;
+	void			(*rr_func)(struct rpcrdma_rep *);
+	struct list_head	rr_list;
+	struct rpcrdma_regbuf	*rr_rdmabuf;
 };
 
 /*

