Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33221 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751743AbdBGQ6W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 11:58:22 -0500
Subject: [PATCH v3 1/7] svcrdma: Another sendto chunk list parsing update
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Feb 2017 11:58:15 -0500
Message-ID: <20170207165815.14422.77348.stgit@klimt.1015granger.net>
In-Reply-To: <20170207165131.14422.47088.stgit@klimt.1015granger.net>
References: <20170207165131.14422.47088.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 5fdca6531434 ("svcrdma: Renovate sendto chunk list parsing")
missed a spot. svc_rdma_xdr_get_reply_hdr_len() also assumes the
Write list has only one Write chunk. There's no harm in making this
code more general.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/rpc_rdma.h        |    9 ++++++
 include/linux/sunrpc/svc_rdma.h        |    2 +
 net/sunrpc/xprtrdma/svc_rdma_marshal.c |   49 +++++++++++++++++---------------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c  |    3 +-
 4 files changed, 38 insertions(+), 25 deletions(-)

diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
index cfda6ad..245fc59 100644
--- a/include/linux/sunrpc/rpc_rdma.h
+++ b/include/linux/sunrpc/rpc_rdma.h
@@ -110,6 +110,15 @@ struct rpcrdma_msg {
 };
 
 /*
+ * XDR sizes, in quads
+ */
+enum {
+	rpcrdma_fixed_maxsz	= 4,
+	rpcrdma_segment_maxsz	= 4,
+	rpcrdma_readchunk_maxsz	= 2 + rpcrdma_segment_maxsz,
+};
+
+/*
  * Smallest RPC/RDMA header: rm_xid through rm_type, then rm_nochunks
  */
 #define RPCRDMA_HDRLEN_MIN	(sizeof(__be32) * 7)
diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 757fb96..551c518 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -218,7 +218,7 @@ extern void svc_rdma_xdr_encode_reply_header(struct svcxprt_rdma *,
 					     struct rpcrdma_msg *,
 					     struct rpcrdma_msg *,
 					     enum rpcrdma_proc);
-extern int svc_rdma_xdr_get_reply_hdr_len(struct rpcrdma_msg *);
+extern unsigned int svc_rdma_xdr_get_reply_hdr_len(__be32 *rdma_resp);
 
 /* svc_rdma_recvfrom.c */
 extern int svc_rdma_recvfrom(struct svc_rqst *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index 0ba9887..4e72034 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -260,32 +260,35 @@ int svc_rdma_xdr_encode_error(struct svcxprt_rdma *xprt,
 	return (int)((unsigned long)va - (unsigned long)startp);
 }
 
-int svc_rdma_xdr_get_reply_hdr_len(struct rpcrdma_msg *rmsgp)
+/**
+ * svc_rdma_xdr_get_reply_hdr_length - Get length of Reply transport header
+ * @rdma_resp: buffer containing Reply transport header
+ *
+ * Returns length of transport header, in bytes.
+ */
+unsigned int svc_rdma_xdr_get_reply_hdr_len(__be32 *rdma_resp)
 {
-	struct rpcrdma_write_array *wr_ary;
+	unsigned int nsegs;
+	__be32 *p;
 
-	/* There is no read-list in a reply */
+	p = rdma_resp;
 
-	/* skip write list */
-	wr_ary = (struct rpcrdma_write_array *)
-		&rmsgp->rm_body.rm_chunks[1];
-	if (wr_ary->wc_discrim)
-		wr_ary = (struct rpcrdma_write_array *)
-			&wr_ary->wc_array[be32_to_cpu(wr_ary->wc_nchunks)].
-			wc_target.rs_length;
-	else
-		wr_ary = (struct rpcrdma_write_array *)
-			&wr_ary->wc_nchunks;
-
-	/* skip reply array */
-	if (wr_ary->wc_discrim)
-		wr_ary = (struct rpcrdma_write_array *)
-			&wr_ary->wc_array[be32_to_cpu(wr_ary->wc_nchunks)];
-	else
-		wr_ary = (struct rpcrdma_write_array *)
-			&wr_ary->wc_nchunks;
-
-	return (unsigned long) wr_ary - (unsigned long) rmsgp;
+	/* RPC-over-RDMA V1 replies never have a Read list. */
+	p += rpcrdma_fixed_maxsz + 1;
+
+	/* Skip Write list. */
+	while (*p++ != xdr_zero) {
+		nsegs = be32_to_cpup(p++);
+		p += nsegs * rpcrdma_segment_maxsz;
+	}
+
+	/* Skip Reply chunk. */
+	if (*p++ != xdr_zero) {
+		nsegs = be32_to_cpup(p++);
+		p += nsegs * rpcrdma_segment_maxsz;
+	}
+
+	return (unsigned long)p - (unsigned long)rdma_resp;
 }
 
 void svc_rdma_xdr_encode_write_list(struct rpcrdma_msg *rmsgp, int chunks)
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index ad4d286..ba76f1617 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -476,7 +476,8 @@ static int send_reply(struct svcxprt_rdma *rdma,
 
 	/* Prepare the SGE for the RPCRDMA Header */
 	ctxt->sge[0].lkey = rdma->sc_pd->local_dma_lkey;
-	ctxt->sge[0].length = svc_rdma_xdr_get_reply_hdr_len(rdma_resp);
+	ctxt->sge[0].length =
+	    svc_rdma_xdr_get_reply_hdr_len((__be32 *)rdma_resp);
 	ctxt->sge[0].addr =
 	    ib_dma_map_page(rdma->sc_cm_id->device, page, 0,
 			    ctxt->sge[0].length, DMA_TO_DEVICE);

