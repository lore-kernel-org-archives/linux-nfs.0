Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:34926 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbbEDQTN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 12:19:13 -0400
Received: by qcbgu10 with SMTP id gu10so33947412qcb.2
        for <linux-nfs@vger.kernel.org>; Mon, 04 May 2015 09:19:12 -0700 (PDT)
Received: from klimt.1015granger.net ([2604:8800:100:81fc:be5f:f4ff:fed6:c3ba])
        by mx.google.com with ESMTPSA id h14sm25198730qhc.46.2015.05.04.09.19.11
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 09:19:11 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 4/8] svcrdma: Remove svc_rdma_xdr_decode_deferred_req()
To: linux-nfs@vger.kernel.org
Date: Mon, 04 May 2015 12:19:10 -0400
Message-ID: <20150504161910.16870.79436.stgit@klimt.1015granger.net>
In-Reply-To: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
References: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svc_rdma_xdr_decode_deferred_req() indexes an array with an
un-byte-swapped value off the wire. Fortunately this function
isn't used anywhere, so simply remove it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_rdma.h        |    1 -
 net/sunrpc/xprtrdma/svc_rdma_marshal.c |   56 --------------------------------
 2 files changed, 0 insertions(+), 57 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index df8edf8..8ad9b6d 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -182,7 +182,6 @@ struct svcxprt_rdma {
 
 /* svc_rdma_marshal.c */
 extern int svc_rdma_xdr_decode_req(struct rpcrdma_msg **, struct svc_rqst *);
-extern int svc_rdma_xdr_decode_deferred_req(struct svc_rqst *);
 extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
 				     struct rpcrdma_msg *,
 				     enum rpcrdma_errcode, u32 *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index b681855..45e22c9 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -211,62 +211,6 @@ int svc_rdma_xdr_decode_req(struct rpcrdma_msg **rdma_req,
 	return hdr_len;
 }
 
-int svc_rdma_xdr_decode_deferred_req(struct svc_rqst *rqstp)
-{
-	struct rpcrdma_msg *rmsgp = NULL;
-	struct rpcrdma_read_chunk *ch;
-	struct rpcrdma_write_array *ary;
-	u32 *va;
-	u32 hdrlen;
-
-	dprintk("svcrdma: processing deferred RDMA header on rqstp=%p\n",
-		rqstp);
-	rmsgp = (struct rpcrdma_msg *)rqstp->rq_arg.head[0].iov_base;
-
-	/* Pull in the extra for the padded case and bump our pointer */
-	if (rmsgp->rm_type == RDMA_MSGP) {
-		va = &rmsgp->rm_body.rm_padded.rm_pempty[4];
-		rqstp->rq_arg.head[0].iov_base = va;
-		hdrlen = (u32)((unsigned long)va - (unsigned long)rmsgp);
-		rqstp->rq_arg.head[0].iov_len -= hdrlen;
-		return hdrlen;
-	}
-
-	/*
-	 * Skip all chunks to find RPC msg. These were previously processed
-	 */
-	va = &rmsgp->rm_body.rm_chunks[0];
-
-	/* Skip read-list */
-	for (ch = (struct rpcrdma_read_chunk *)va;
-	     ch->rc_discrim != xdr_zero; ch++);
-	va = (u32 *)&ch->rc_position;
-
-	/* Skip write-list */
-	ary = (struct rpcrdma_write_array *)va;
-	if (ary->wc_discrim == xdr_zero)
-		va = (u32 *)&ary->wc_nchunks;
-	else
-		/*
-		 * rs_length is the 2nd 4B field in wc_target and taking its
-		 * address skips the list terminator
-		 */
-		va = (u32 *)&ary->wc_array[ary->wc_nchunks].wc_target.rs_length;
-
-	/* Skip reply-array */
-	ary = (struct rpcrdma_write_array *)va;
-	if (ary->wc_discrim == xdr_zero)
-		va = (u32 *)&ary->wc_nchunks;
-	else
-		va = (u32 *)&ary->wc_array[ary->wc_nchunks];
-
-	rqstp->rq_arg.head[0].iov_base = va;
-	hdrlen = (unsigned long)va - (unsigned long)rmsgp;
-	rqstp->rq_arg.head[0].iov_len -= hdrlen;
-
-	return hdrlen;
-}
-
 int svc_rdma_xdr_encode_error(struct svcxprt_rdma *xprt,
 			      struct rpcrdma_msg *rmsgp,
 			      enum rpcrdma_errcode err, u32 *va)

