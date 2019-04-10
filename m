Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11AE9C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:08:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BCC662075B
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:08:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sRJ4uJJZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726763AbfDJUIL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 16:08:11 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:35175 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726023AbfDJUIL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 16:08:11 -0400
Received: by mail-it1-f196.google.com with SMTP id w15so5647372itc.0;
        Wed, 10 Apr 2019 13:08:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=2B4t4YCsR+yArv8qDOcoC34qwqmzqQ4HPQwsB/nZZ8I=;
        b=sRJ4uJJZPkfGJ/3ZeK027ik2duVxNpg8HJr9ZSAzJKGRhhqa3T/V1Pzx6bi/qeph9q
         dZRUw4BnF80znaohw9fn8PcktXhNHqNUsQbCUCRkG2XOzHkGq3SpK2Y1sUq17byfsuVX
         sFGkrlUzeXiq/+484beWEZyHbNye9ks1hDnyC4ln6NOPiAhvE1XGEMp8R+fnIlfQ+Nge
         cVZdkTiQeWVHascNIt4vPOds3VW6yxycVhrizTojuVFZylJZzJ4v1/lAjONEwU+g+34l
         I6v1eU1GBkf1jpdjAUL7BHN2hNLr7IYjYODJCnC3t3JDadAP0AeB9I9GkgLXkwOR+gcJ
         E3qw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=2B4t4YCsR+yArv8qDOcoC34qwqmzqQ4HPQwsB/nZZ8I=;
        b=lwI5F808or5VUbXRgMue1oZtB3WG6OFr3g7BAdtiYjyx2hBd5hP4T8H9RGZa0fnVta
         En3iTCA8VYr16Ceku26lTbectCACrJaRsD/TOI5dh3TNfi2i0iy6OtATEY2GvWukFEqW
         g3brsQaYhpIaXDQxDjQ8VD4LOKNoe4nRCJcG2TGwMlJ4nMGyvHam8qL+UqPdR7bIxn5V
         qxKmsg/En2HL5CMZSxVwrDVrwfdtK23EyPx9KBLXRuRkxIoaVXqfL+zudiPArzxAXui9
         pPPUaubLJ+znlEM591kURIeBf23aEUcmrsWzWqrI7tMLodwYipPe9JOLEquU2om30puK
         T/Rw==
X-Gm-Message-State: APjAAAX3+dyt6mCc5x/wt8G9evbAa4iG+lEoU9SUv1qso/AWIouyCqPK
        DFk2dg2HMjcA6zZQW8JqhiUS9OJ0
X-Google-Smtp-Source: APXvYqxD6ZJ8zcxpbWoTjXNrjr0hW4wQek7Zg0SarEdilW37+uOdNcefAw9XRq/RhA0Mp3kvvifvJQ==
X-Received: by 2002:a24:6fc7:: with SMTP id x190mr4470884itb.46.1554926889117;
        Wed, 10 Apr 2019 13:08:09 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id w6sm13841823iom.22.2019.04.10.13.08.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 13:08:08 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3AK87PV004558;
        Wed, 10 Apr 2019 20:08:07 GMT
Subject: [PATCH v1 18/19] xprtrdma: Aggregate the inline settings in struct
 rpcrdma_ep
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 10 Apr 2019 16:08:07 -0400
Message-ID: <20190410200807.11522.59400.stgit@manet.1015granger.net>
In-Reply-To: <20190410200446.11522.21145.stgit@manet.1015granger.net>
References: <20190410200446.11522.21145.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up.

The inline settings are actually a characteristic of the endpoint,
and not related to the device. They are also modified after the
transport instance is created, so they do not belong in the cdata
structure either.

Lastly, let's use names that are more natural to RDMA than to NFS:
inline_write -> inline_send and inline_read -> inline_recv. The
/proc files retain their names to avoid breaking user space.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    6 +++---
 net/sunrpc/xprtrdma/rpc_rdma.c    |   34 +++++++++++++++++++---------------
 net/sunrpc/xprtrdma/transport.c   |    4 +---
 net/sunrpc/xprtrdma/verbs.c       |   24 +++++++++++++-----------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    9 +++++----
 5 files changed, 41 insertions(+), 36 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index ae51ef6..ce98659 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -44,10 +44,10 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 size_t xprt_rdma_bc_maxpayload(struct rpc_xprt *xprt)
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
-	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
+	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
 	size_t maxmsg;
 
-	maxmsg = min_t(unsigned int, cdata->inline_rsize, cdata->inline_wsize);
+	maxmsg = min_t(unsigned int, ep->rep_inline_send, ep->rep_inline_recv);
 	maxmsg = min_t(unsigned int, maxmsg, PAGE_SIZE);
 	return maxmsg - RPCRDMA_HDRLEN_MIN;
 }
@@ -184,7 +184,7 @@ static struct rpc_rqst *rpcrdma_bc_rqst_get(struct rpcrdma_xprt *r_xprt)
 	if (xprt->bc_alloc_count >= RPCRDMA_BACKWARD_WRS)
 		return NULL;
 
-	size = min_t(size_t, r_xprt->rx_data.inline_rsize, PAGE_SIZE);
+	size = min_t(size_t, r_xprt->rx_ep.rep_inline_recv, PAGE_SIZE);
 	req = rpcrdma_req_create(r_xprt, size, GFP_KERNEL);
 	if (!req)
 		return NULL;
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index fcd29a4..4f0b879 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -105,16 +105,23 @@ static unsigned int rpcrdma_max_reply_header_size(unsigned int maxsegs)
 	return size;
 }
 
+/**
+ * rpcrdma_set_max_header_sizes - Initialize inline payload sizes
+ * @r_xprt: transport instance to initialize
+ *
+ * The max_inline fields contain the maximum size of an RPC message
+ * so the marshaling code doesn't have to repeat this calculation
+ * for every RPC.
+ */
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *r_xprt)
 {
-	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	unsigned int maxsegs = ia->ri_max_segs;
-
-	ia->ri_max_inline_write = cdata->inline_wsize -
-				  rpcrdma_max_call_header_size(maxsegs);
-	ia->ri_max_inline_read = cdata->inline_rsize -
-				 rpcrdma_max_reply_header_size(maxsegs);
+	unsigned int maxsegs = r_xprt->rx_ia.ri_max_segs;
+	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
+
+	ep->rep_max_inline_send =
+		ep->rep_inline_send - rpcrdma_max_call_header_size(maxsegs);
+	ep->rep_max_inline_recv =
+		ep->rep_inline_recv - rpcrdma_max_reply_header_size(maxsegs);
 }
 
 /* The client can send a request inline as long as the RPCRDMA header
@@ -131,7 +138,7 @@ static bool rpcrdma_args_inline(struct rpcrdma_xprt *r_xprt,
 	struct xdr_buf *xdr = &rqst->rq_snd_buf;
 	unsigned int count, remaining, offset;
 
-	if (xdr->len > r_xprt->rx_ia.ri_max_inline_write)
+	if (xdr->len > r_xprt->rx_ep.rep_max_inline_send)
 		return false;
 
 	if (xdr->page_len) {
@@ -159,9 +166,7 @@ static bool rpcrdma_args_inline(struct rpcrdma_xprt *r_xprt,
 static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 				   struct rpc_rqst *rqst)
 {
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-
-	return rqst->rq_rcv_buf.buflen <= ia->ri_max_inline_read;
+	return rqst->rq_rcv_buf.buflen <= r_xprt->rx_ep.rep_max_inline_recv;
 }
 
 /* The client is required to provide a Reply chunk if the maximum
@@ -173,10 +178,9 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 			  const struct rpc_rqst *rqst)
 {
 	const struct xdr_buf *buf = &rqst->rq_rcv_buf;
-	const struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
-	return buf->head[0].iov_len + buf->tail[0].iov_len <
-		ia->ri_max_inline_read;
+	return (buf->head[0].iov_len + buf->tail[0].iov_len) <
+		r_xprt->rx_ep.rep_max_inline_recv;
 }
 
 /* Split @vec on page boundaries into SGEs. FMR registers pages, not
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index f362642..4e5b8fe 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -70,7 +70,7 @@
 
 static unsigned int xprt_rdma_slot_table_entries = RPCRDMA_DEF_SLOT_TABLE;
 unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
-static unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
+unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
 unsigned int xprt_rdma_memreg_strategy		= RPCRDMA_FRWR;
 int xprt_rdma_pad_optimize;
 
@@ -350,8 +350,6 @@
 	xprt_rdma_format_addresses(xprt, sap);
 
 	cdata.max_requests = xprt_rdma_slot_table_entries;
-	cdata.inline_wsize = xprt_rdma_max_inline_write;
-	cdata.inline_rsize = xprt_rdma_max_inline_read;
 
 	/*
 	 * Create new transport instance, which includes initialized
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 9ed5fd8..b419906 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -188,7 +188,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 rpcrdma_update_connect_private(struct rpcrdma_xprt *r_xprt,
 			       struct rdma_conn_param *param)
 {
-	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
 	const struct rpcrdma_connect_private *pmsg = param->private_data;
 	unsigned int rsize, wsize;
 
@@ -205,12 +204,13 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 		wsize = rpcrdma_decode_buffer_size(pmsg->cp_recv_size);
 	}
 
-	if (rsize < cdata->inline_rsize)
-		cdata->inline_rsize = rsize;
-	if (wsize < cdata->inline_wsize)
-		cdata->inline_wsize = wsize;
-	dprintk("RPC:       %s: max send %u, max recv %u\n",
-		__func__, cdata->inline_wsize, cdata->inline_rsize);
+	if (rsize < r_xprt->rx_ep.rep_inline_recv)
+		r_xprt->rx_ep.rep_inline_recv = rsize;
+	if (wsize < r_xprt->rx_ep.rep_inline_send)
+		r_xprt->rx_ep.rep_inline_send = wsize;
+	dprintk("RPC:       %s: max send %u, max recv %u\n", __func__,
+		r_xprt->rx_ep.rep_inline_send,
+		r_xprt->rx_ep.rep_inline_recv);
 	rpcrdma_set_max_header_sizes(r_xprt);
 }
 
@@ -488,6 +488,9 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	unsigned int max_sge;
 	int rc;
 
+	ep->rep_inline_send = xprt_rdma_max_inline_write;
+	ep->rep_inline_recv = xprt_rdma_max_inline_read;
+
 	max_sge = min_t(unsigned int, ia->ri_id->device->attrs.max_send_sge,
 			RPCRDMA_MAX_SEND_SGES);
 	if (max_sge < RPCRDMA_MIN_SEND_SGES) {
@@ -550,8 +553,8 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	pmsg->cp_magic = rpcrdma_cmp_magic;
 	pmsg->cp_version = RPCRDMA_CMP_VERSION;
 	pmsg->cp_flags |= RPCRDMA_CMP_F_SND_W_INV_OK;
-	pmsg->cp_send_size = rpcrdma_encode_buffer_size(cdata->inline_wsize);
-	pmsg->cp_recv_size = rpcrdma_encode_buffer_size(cdata->inline_rsize);
+	pmsg->cp_send_size = rpcrdma_encode_buffer_size(ep->rep_inline_send);
+	pmsg->cp_recv_size = rpcrdma_encode_buffer_size(ep->rep_inline_recv);
 	ep->rep_remote_cma.private_data = pmsg;
 	ep->rep_remote_cma.private_data_len = sizeof(*pmsg);
 
@@ -1045,7 +1048,6 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, size_t size,
 
 static bool rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt, bool temp)
 {
-	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct rpcrdma_rep *rep;
 
@@ -1053,7 +1055,7 @@ static bool rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt, bool temp)
 	if (rep == NULL)
 		goto out;
 
-	rep->rr_rdmabuf = rpcrdma_regbuf_alloc(cdata->inline_rsize,
+	rep->rr_rdmabuf = rpcrdma_regbuf_alloc(r_xprt->rx_ep.rep_inline_recv,
 					       DMA_FROM_DEVICE, GFP_KERNEL);
 	if (!rep->rr_rdmabuf)
 		goto out_free;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c1e265a..9beb7fc 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -71,8 +71,6 @@ struct rpcrdma_ia {
 	int			ri_async_rc;
 	unsigned int		ri_max_segs;
 	unsigned int		ri_max_frwr_depth;
-	unsigned int		ri_max_inline_write;
-	unsigned int		ri_max_inline_read;
 	unsigned int		ri_max_send_sges;
 	bool			ri_implicit_roundup;
 	enum ib_mr_type		ri_mrtype;
@@ -92,11 +90,15 @@ enum {
 struct rpcrdma_ep {
 	unsigned int		rep_send_count;
 	unsigned int		rep_send_batch;
+	unsigned int		rep_max_inline_send;
+	unsigned int		rep_max_inline_recv;
 	int			rep_connected;
 	struct ib_qp_init_attr	rep_attr;
 	wait_queue_head_t 	rep_connect_wait;
 	struct rpcrdma_connect_private	rep_cm_private;
 	struct rdma_conn_param	rep_remote_cma;
+	unsigned int		rep_inline_send;	/* negotiated */
+	unsigned int		rep_inline_recv;	/* negotiated */
 	int			rep_receive_count;
 };
 
@@ -419,8 +421,6 @@ enum {
  */
 struct rpcrdma_create_data_internal {
 	unsigned int	max_requests;	/* max requests (slots) in flight */
-	unsigned int	inline_rsize;	/* max non-rdma read data payload */
-	unsigned int	inline_wsize;	/* max non-rdma write data payload */
 };
 
 /*
@@ -630,6 +630,7 @@ static inline void rpcrdma_set_xdrlen(struct xdr_buf *xdr, size_t len)
 /* RPC/RDMA module init - xprtrdma/transport.c
  */
 extern unsigned int xprt_rdma_max_inline_read;
+extern unsigned int xprt_rdma_max_inline_write;
 void xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap);
 void xprt_rdma_free_addresses(struct rpc_xprt *xprt);
 void xprt_rdma_close(struct rpc_xprt *xprt);

