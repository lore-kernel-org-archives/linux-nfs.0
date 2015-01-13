Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:58276 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbbAMQC5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:02:57 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 03/10] svcrdma: Clean up read chunk counting
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Tue, 13 Jan 2015 11:02:54 -0500
Message-ID: <20150113160254.8118.51796.stgit@klimt.1015granger.net>
In-Reply-To: <20150113155904.8118.57718.stgit@klimt.1015granger.net>
References: <20150113155904.8118.57718.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The byte_count argument is not used, and the function is called
only from one place.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_rdma.h         |    2 --
 net/sunrpc/xprtrdma/svc_rdma_marshal.c  |   16 ----------------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   15 ++++++++++++---
 3 files changed, 12 insertions(+), 21 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 975da75..2280325 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -178,8 +178,6 @@ struct svcxprt_rdma {
 #define RPCRDMA_MAX_REQ_SIZE    4096
 
 /* svc_rdma_marshal.c */
-extern void svc_rdma_rcl_chunk_counts(struct rpcrdma_read_chunk *,
-				      int *, int *);
 extern int svc_rdma_xdr_decode_req(struct rpcrdma_msg **, struct svc_rqst *);
 extern int svc_rdma_xdr_decode_deferred_req(struct svc_rqst *);
 extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index 65b1462..b681855 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -71,22 +71,6 @@ static u32 *decode_read_list(u32 *va, u32 *vaend)
 }
 
 /*
- * Determine number of chunks and total bytes in chunk list. The chunk
- * list has already been verified to fit within the RPCRDMA header.
- */
-void svc_rdma_rcl_chunk_counts(struct rpcrdma_read_chunk *ch,
-			       int *ch_count, int *byte_count)
-{
-	/* compute the number of bytes represented by read chunks */
-	*byte_count = 0;
-	*ch_count = 0;
-	for (; ch->rc_discrim != 0; ch++) {
-		*byte_count = *byte_count + ntohl(ch->rc_target.rs_length);
-		*ch_count = *ch_count + 1;
-	}
-}
-
-/*
  * Decodes a write chunk list. The expected format is as follows:
  *    descrim  : xdr_one
  *    nchunks  : <count>
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 2c67de0..b3b7bb8 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -365,12 +365,22 @@ static int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 	return ret;
 }
 
+static unsigned int
+rdma_rcl_chunk_count(struct rpcrdma_read_chunk *ch)
+{
+	unsigned int count;
+
+	for (count = 0; ch->rc_discrim != xdr_zero; ch++)
+		count++;
+	return count;
+}
+
 static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 			    struct rpcrdma_msg *rmsgp,
 			    struct svc_rqst *rqstp,
 			    struct svc_rdma_op_ctxt *head)
 {
-	int page_no, ch_count, ret;
+	int page_no, ret;
 	struct rpcrdma_read_chunk *ch;
 	u32 page_offset, byte_count;
 	u64 rs_offset;
@@ -381,8 +391,7 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 	if (!ch)
 		return 0;
 
-	svc_rdma_rcl_chunk_counts(ch, &ch_count, &byte_count);
-	if (ch_count > RPCSVC_MAXPAGES)
+	if (rdma_rcl_chunk_count(ch) > RPCSVC_MAXPAGES)
 		return -EINVAL;
 
 	/* The request is completed when the RDMA_READs complete. The

