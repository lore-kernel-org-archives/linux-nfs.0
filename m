Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:36451 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbbEDQTW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 12:19:22 -0400
Received: by qku63 with SMTP id 63so87966335qku.3
        for <linux-nfs@vger.kernel.org>; Mon, 04 May 2015 09:19:22 -0700 (PDT)
Received: from klimt.1015granger.net ([2604:8800:100:81fc:be5f:f4ff:fed6:c3ba])
        by mx.google.com with ESMTPSA id j63sm10178796qga.12.2015.05.04.09.19.20
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 09:19:21 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 5/8] svcrdma: Keep rpcrdma_msg fields in network byte-order
To: linux-nfs@vger.kernel.org
Date: Mon, 04 May 2015 12:19:19 -0400
Message-ID: <20150504161919.16870.628.stgit@klimt.1015granger.net>
In-Reply-To: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
References: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fields in struct rpcrdma_msg are __be32. Don't byte-swap these
fields when decoding RPC calls and then swap them back for the
reply. For the most part, they can be left alone.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_rdma.h          |    2 -
 net/sunrpc/xprtrdma/svc_rdma_marshal.c   |   84 ++++++++++++++----------------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    2 -
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 -
 4 files changed, 42 insertions(+), 48 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 8ad9b6d..c03ca0a 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -184,7 +184,7 @@ struct svcxprt_rdma {
 extern int svc_rdma_xdr_decode_req(struct rpcrdma_msg **, struct svc_rqst *);
 extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
 				     struct rpcrdma_msg *,
-				     enum rpcrdma_errcode, u32 *);
+				     enum rpcrdma_errcode, __be32 *);
 extern void svc_rdma_xdr_encode_write_list(struct rpcrdma_msg *, int);
 extern void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *, int);
 extern void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *, int,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index 45e22c9..e2fca76 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -50,12 +50,12 @@
 /*
  * Decodes a read chunk list. The expected format is as follows:
  *    descrim  : xdr_one
- *    position : u32 offset into XDR stream
- *    handle   : u32 RKEY
+ *    position : __be32 offset into XDR stream
+ *    handle   : __be32 RKEY
  *    . . .
  *  end-of-list: xdr_zero
  */
-static u32 *decode_read_list(u32 *va, u32 *vaend)
+static __be32 *decode_read_list(__be32 *va, __be32 *vaend)
 {
 	struct rpcrdma_read_chunk *ch = (struct rpcrdma_read_chunk *)va;
 
@@ -67,20 +67,20 @@ static u32 *decode_read_list(u32 *va, u32 *vaend)
 		}
 		ch++;
 	}
-	return (u32 *)&ch->rc_position;
+	return &ch->rc_position;
 }
 
 /*
  * Decodes a write chunk list. The expected format is as follows:
  *    descrim  : xdr_one
  *    nchunks  : <count>
- *       handle   : u32 RKEY              ---+
- *       length   : u32 <len of segment>     |
+ *       handle   : __be32 RKEY           ---+
+ *       length   : __be32 <len of segment>  |
  *       offset   : remove va                + <count>
  *       . . .                               |
  *                                        ---+
  */
-static u32 *decode_write_list(u32 *va, u32 *vaend)
+static __be32 *decode_write_list(__be32 *va, __be32 *vaend)
 {
 	unsigned long start, end;
 	int nchunks;
@@ -90,14 +90,14 @@ static u32 *decode_write_list(u32 *va, u32 *vaend)
 
 	/* Check for not write-array */
 	if (ary->wc_discrim == xdr_zero)
-		return (u32 *)&ary->wc_nchunks;
+		return &ary->wc_nchunks;
 
 	if ((unsigned long)ary + sizeof(struct rpcrdma_write_array) >
 	    (unsigned long)vaend) {
 		dprintk("svcrdma: ary=%p, vaend=%p\n", ary, vaend);
 		return NULL;
 	}
-	nchunks = ntohl(ary->wc_nchunks);
+	nchunks = be32_to_cpu(ary->wc_nchunks);
 
 	start = (unsigned long)&ary->wc_array[0];
 	end = (unsigned long)vaend;
@@ -112,10 +112,10 @@ static u32 *decode_write_list(u32 *va, u32 *vaend)
 	 * rs_length is the 2nd 4B field in wc_target and taking its
 	 * address skips the list terminator
 	 */
-	return (u32 *)&ary->wc_array[nchunks].wc_target.rs_length;
+	return &ary->wc_array[nchunks].wc_target.rs_length;
 }
 
-static u32 *decode_reply_array(u32 *va, u32 *vaend)
+static __be32 *decode_reply_array(__be32 *va, __be32 *vaend)
 {
 	unsigned long start, end;
 	int nchunks;
@@ -124,14 +124,14 @@ static u32 *decode_reply_array(u32 *va, u32 *vaend)
 
 	/* Check for no reply-array */
 	if (ary->wc_discrim == xdr_zero)
-		return (u32 *)&ary->wc_nchunks;
+		return &ary->wc_nchunks;
 
 	if ((unsigned long)ary + sizeof(struct rpcrdma_write_array) >
 	    (unsigned long)vaend) {
 		dprintk("svcrdma: ary=%p, vaend=%p\n", ary, vaend);
 		return NULL;
 	}
-	nchunks = ntohl(ary->wc_nchunks);
+	nchunks = be32_to_cpu(ary->wc_nchunks);
 
 	start = (unsigned long)&ary->wc_array[0];
 	end = (unsigned long)vaend;
@@ -142,15 +142,14 @@ static u32 *decode_reply_array(u32 *va, u32 *vaend)
 			ary, nchunks, vaend);
 		return NULL;
 	}
-	return (u32 *)&ary->wc_array[nchunks];
+	return (__be32 *)&ary->wc_array[nchunks];
 }
 
 int svc_rdma_xdr_decode_req(struct rpcrdma_msg **rdma_req,
 			    struct svc_rqst *rqstp)
 {
 	struct rpcrdma_msg *rmsgp = NULL;
-	u32 *va;
-	u32 *vaend;
+	__be32 *va, *vaend;
 	u32 hdr_len;
 
 	rmsgp = (struct rpcrdma_msg *)rqstp->rq_arg.head[0].iov_base;
@@ -162,22 +161,17 @@ int svc_rdma_xdr_decode_req(struct rpcrdma_msg **rdma_req,
 		return -EINVAL;
 	}
 
-	/* Decode the header */
-	rmsgp->rm_xid = ntohl(rmsgp->rm_xid);
-	rmsgp->rm_vers = ntohl(rmsgp->rm_vers);
-	rmsgp->rm_credit = ntohl(rmsgp->rm_credit);
-	rmsgp->rm_type = ntohl(rmsgp->rm_type);
-
-	if (rmsgp->rm_vers != RPCRDMA_VERSION)
+	if (rmsgp->rm_vers != rpcrdma_version)
 		return -ENOSYS;
 
 	/* Pull in the extra for the padded case and bump our pointer */
-	if (rmsgp->rm_type == RDMA_MSGP) {
+	if (rmsgp->rm_type == rdma_msgp) {
 		int hdrlen;
+
 		rmsgp->rm_body.rm_padded.rm_align =
-			ntohl(rmsgp->rm_body.rm_padded.rm_align);
+			be32_to_cpu(rmsgp->rm_body.rm_padded.rm_align);
 		rmsgp->rm_body.rm_padded.rm_thresh =
-			ntohl(rmsgp->rm_body.rm_padded.rm_thresh);
+			be32_to_cpu(rmsgp->rm_body.rm_padded.rm_thresh);
 
 		va = &rmsgp->rm_body.rm_padded.rm_pempty[4];
 		rqstp->rq_arg.head[0].iov_base = va;
@@ -192,7 +186,7 @@ int svc_rdma_xdr_decode_req(struct rpcrdma_msg **rdma_req,
 	 * chunk list and a reply chunk list.
 	 */
 	va = &rmsgp->rm_body.rm_chunks[0];
-	vaend = (u32 *)((unsigned long)rmsgp + rqstp->rq_arg.len);
+	vaend = (__be32 *)((unsigned long)rmsgp + rqstp->rq_arg.len);
 	va = decode_read_list(va, vaend);
 	if (!va)
 		return -EINVAL;
@@ -213,18 +207,18 @@ int svc_rdma_xdr_decode_req(struct rpcrdma_msg **rdma_req,
 
 int svc_rdma_xdr_encode_error(struct svcxprt_rdma *xprt,
 			      struct rpcrdma_msg *rmsgp,
-			      enum rpcrdma_errcode err, u32 *va)
+			      enum rpcrdma_errcode err, __be32 *va)
 {
-	u32 *startp = va;
+	__be32 *startp = va;
 
-	*va++ = htonl(rmsgp->rm_xid);
-	*va++ = htonl(rmsgp->rm_vers);
-	*va++ = htonl(xprt->sc_max_requests);
-	*va++ = htonl(RDMA_ERROR);
-	*va++ = htonl(err);
+	*va++ = rmsgp->rm_xid;
+	*va++ = rmsgp->rm_vers;
+	*va++ = cpu_to_be32(xprt->sc_max_requests);
+	*va++ = rdma_error;
+	*va++ = cpu_to_be32(err);
 	if (err == ERR_VERS) {
-		*va++ = htonl(RPCRDMA_VERSION);
-		*va++ = htonl(RPCRDMA_VERSION);
+		*va++ = rpcrdma_version;
+		*va++ = rpcrdma_version;
 	}
 
 	return (int)((unsigned long)va - (unsigned long)startp);
@@ -241,7 +235,7 @@ int svc_rdma_xdr_get_reply_hdr_len(struct rpcrdma_msg *rmsgp)
 		&rmsgp->rm_body.rm_chunks[1];
 	if (wr_ary->wc_discrim)
 		wr_ary = (struct rpcrdma_write_array *)
-			&wr_ary->wc_array[ntohl(wr_ary->wc_nchunks)].
+			&wr_ary->wc_array[be32_to_cpu(wr_ary->wc_nchunks)].
 			wc_target.rs_length;
 	else
 		wr_ary = (struct rpcrdma_write_array *)
@@ -250,7 +244,7 @@ int svc_rdma_xdr_get_reply_hdr_len(struct rpcrdma_msg *rmsgp)
 	/* skip reply array */
 	if (wr_ary->wc_discrim)
 		wr_ary = (struct rpcrdma_write_array *)
-			&wr_ary->wc_array[ntohl(wr_ary->wc_nchunks)];
+			&wr_ary->wc_array[be32_to_cpu(wr_ary->wc_nchunks)];
 	else
 		wr_ary = (struct rpcrdma_write_array *)
 			&wr_ary->wc_nchunks;
@@ -269,7 +263,7 @@ void svc_rdma_xdr_encode_write_list(struct rpcrdma_msg *rmsgp, int chunks)
 	ary = (struct rpcrdma_write_array *)
 		&rmsgp->rm_body.rm_chunks[1];
 	ary->wc_discrim = xdr_one;
-	ary->wc_nchunks = htonl(chunks);
+	ary->wc_nchunks = cpu_to_be32(chunks);
 
 	/* write-list terminator */
 	ary->wc_array[chunks].wc_target.rs_handle = xdr_zero;
@@ -282,7 +276,7 @@ void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *ary,
 				 int chunks)
 {
 	ary->wc_discrim = xdr_one;
-	ary->wc_nchunks = htonl(chunks);
+	ary->wc_nchunks = cpu_to_be32(chunks);
 }
 
 void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *ary,
@@ -294,7 +288,7 @@ void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *ary,
 	struct rpcrdma_segment *seg = &ary->wc_array[chunk_no].wc_target;
 	seg->rs_handle = rs_handle;
 	seg->rs_offset = rs_offset;
-	seg->rs_length = htonl(write_len);
+	seg->rs_length = cpu_to_be32(write_len);
 }
 
 void svc_rdma_xdr_encode_reply_header(struct svcxprt_rdma *xprt,
@@ -302,10 +296,10 @@ void svc_rdma_xdr_encode_reply_header(struct svcxprt_rdma *xprt,
 				  struct rpcrdma_msg *rdma_resp,
 				  enum rpcrdma_proc rdma_type)
 {
-	rdma_resp->rm_xid = htonl(rdma_argp->rm_xid);
-	rdma_resp->rm_vers = htonl(rdma_argp->rm_vers);
-	rdma_resp->rm_credit = htonl(xprt->sc_max_requests);
-	rdma_resp->rm_type = htonl(rdma_type);
+	rdma_resp->rm_xid = rdma_argp->rm_xid;
+	rdma_resp->rm_vers = rdma_argp->rm_vers;
+	rdma_resp->rm_credit = cpu_to_be32(xprt->sc_max_requests);
+	rdma_resp->rm_type = cpu_to_be32(rdma_type);
 
 	/* Encode <nul> chunks lists */
 	rdma_resp->rm_body.rm_chunks[0] = xdr_zero;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index f9f13a3..ac93ce0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -85,7 +85,7 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
 
 	/* RDMA_NOMSG: RDMA READ data should land just after RDMA RECV data */
 	rmsgp = (struct rpcrdma_msg *)rqstp->rq_arg.head[0].iov_base;
-	if (be32_to_cpu(rmsgp->rm_type) == RDMA_NOMSG)
+	if (rmsgp->rm_type == rdma_nomsg)
 		rqstp->rq_arg.pages = &rqstp->rq_pages[0];
 	else
 		rqstp->rq_arg.pages = &rqstp->rq_pages[1];
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index f609c1c..be08493 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1319,7 +1319,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	struct ib_send_wr err_wr;
 	struct page *p;
 	struct svc_rdma_op_ctxt *ctxt;
-	u32 *va;
+	__be32 *va;
 	int length;
 	int ret;
 

