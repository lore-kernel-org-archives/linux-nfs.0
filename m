Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD29EC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8195221773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="G5I1kPQh"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727764AbfDXNkH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:40:07 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:40879 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727335AbfDXNkG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:40:06 -0400
Received: by mail-it1-f195.google.com with SMTP id k64so6187675itb.5;
        Wed, 24 Apr 2019 06:40:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=qQRkK7kxKawAquMIXUqmKwXdS3YSEbNs0xvo7j46p8w=;
        b=G5I1kPQhxYT+b2ixd7ygmA28nkUZ3Gr4Km+mPumgkrtoC9zyynPNIP1h6AyV2kSLXK
         OBPwUzqmHIJpnnWDc4O3Cv/T48hK6bgmo0PgFeRzS43nzs+6bKIGC2W+9cm5asgEJbGL
         rQe1J68uSvHJpKyfv3z1oc85IwGePzG4MSRaeuByTCV4wzdQdkWs0uq3Cg5B8vcFjHw/
         p5QIJ6ImR3pIlVBD70o/t5KyVc9HmSZhTp/1Np720kT+CJOw9gh+6e/i9z9f3I1J7hsP
         TuUsyTGRCmH9p1t18WVHXrgUyB5aZiW0/tfzikL5BzKB/BnzRe4PUiFtCfdW9Cl8pNbg
         SIKA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=qQRkK7kxKawAquMIXUqmKwXdS3YSEbNs0xvo7j46p8w=;
        b=EAWUtPb9TsZIP9tYj9HxglyT0BhRWHvNTUoCFHx/gfUX5r/GqExxoHzIgtZ+8WxA8r
         TstlTPsnyQpvNlkcIiJ/eV82BsMW62Twcz43pubqBrYHLPxn1Uj8IZiWBEdNN1vFD273
         fMA897hrhVgoT66l8l3zV8cgUGm6y1dtFTPHwMPa0jYo2E7oQ2rJytRvD2sowd5W0nWn
         BajGPfqxzXJqdqslqKHsJ9eVH9XUp9zcfki6uDDQYXBqMKIodaDjpB0UVhSB0g/vaebw
         QyoklwgZVoBbKQJIJKPKbFbdeBDV8Ew2F8aW6Ka/rtgmqM5AAsCt3nVuYF4VB+bwyln0
         36kQ==
X-Gm-Message-State: APjAAAUiaOaiVA9Md1JIK+aXkT2FJ9r09rEZYPrB9cSBgSfQw1Lc/jpF
        3+PjXjUiOVp8iLnDj9eJGO0=
X-Google-Smtp-Source: APXvYqxcaQJ+0StIn5WPJUm5B00aX5qwSOkDJ7vU0VpSF1UGemYl/AA7gSq/dDSX2wxowZRhSyAL9w==
X-Received: by 2002:a02:a0c9:: with SMTP id i9mr7831263jah.135.1556113205648;
        Wed, 24 Apr 2019 06:40:05 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id y22sm6289978ioa.47.2019.04.24.06.40.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:40:05 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODe4Xb011319;
        Wed, 24 Apr 2019 13:40:04 GMT
Subject: [PATCH v3 14/21] xprtrdma: Eliminate rpcrdma_ia::ri_device
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:40:04 -0400
Message-ID: <20190424134004.5077.52654.stgit@manet.1015granger.net>
In-Reply-To: <20190424133516.5077.67283.stgit@manet.1015granger.net>
References: <20190424133516.5077.67283.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up.

Since commit 54cbd6b0c6b9 ("xprtrdma: Delay DMA mapping Send and
Receive buffers"), a pointer to the device is now saved in each
regbuf when it is DMA mapped.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |   17 +++++++++--------
 net/sunrpc/xprtrdma/verbs.c     |   29 +++++++++++++----------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    7 +++----
 3 files changed, 25 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index a2a2e01..7cd2718 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -82,13 +82,13 @@
 
 /**
  * frwr_is_supported - Check if device supports FRWR
- * @ia: interface adapter to check
+ * @device: interface adapter to check
  *
  * Returns true if device supports FRWR, otherwise false
  */
-bool frwr_is_supported(struct rpcrdma_ia *ia)
+bool frwr_is_supported(struct ib_device *device)
 {
-	struct ib_device_attr *attrs = &ia->ri_device->attrs;
+	struct ib_device_attr *attrs = &device->attrs;
 
 	if (!(attrs->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS))
 		goto out_not_supported;
@@ -98,7 +98,7 @@ bool frwr_is_supported(struct rpcrdma_ia *ia)
 
 out_not_supported:
 	pr_info("rpcrdma: 'frwr' mode is not supported by device %s\n",
-		ia->ri_device->name);
+		device->name);
 	return false;
 }
 
@@ -131,7 +131,7 @@ void frwr_release_mr(struct rpcrdma_mr *mr)
 
 	if (mr->mr_dir != DMA_NONE) {
 		trace_xprtrdma_mr_unmap(mr);
-		ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
+		ib_dma_unmap_sg(r_xprt->rx_ia.ri_id->device,
 				mr->mr_sg, mr->mr_nents, mr->mr_dir);
 		mr->mr_dir = DMA_NONE;
 	}
@@ -211,7 +211,7 @@ int frwr_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr)
 int frwr_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 	      struct rpcrdma_create_data_internal *cdata)
 {
-	struct ib_device_attr *attrs = &ia->ri_device->attrs;
+	struct ib_device_attr *attrs = &ia->ri_id->device->attrs;
 	int max_qp_wr, depth, delta;
 
 	ia->ri_mrtype = IB_MR_TYPE_MEM_REG;
@@ -253,7 +253,7 @@ int frwr_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 		} while (delta > 0);
 	}
 
-	max_qp_wr = ia->ri_device->attrs.max_qp_wr;
+	max_qp_wr = ia->ri_id->device->attrs.max_qp_wr;
 	max_qp_wr -= RPCRDMA_BACKWARD_WRS;
 	max_qp_wr -= 1;
 	if (max_qp_wr < RPCRDMA_MIN_SLOT_TABLE)
@@ -436,7 +436,8 @@ struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
 	}
 	mr->mr_dir = rpcrdma_data_dir(writing);
 
-	mr->mr_nents = ib_dma_map_sg(ia->ri_device, mr->mr_sg, i, mr->mr_dir);
+	mr->mr_nents =
+		ib_dma_map_sg(ia->ri_id->device, mr->mr_sg, i, mr->mr_dir);
 	if (!mr->mr_nents)
 		goto out_dmamap_err;
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 1ed761a..672993c 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -250,7 +250,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	case RDMA_CM_EVENT_DEVICE_REMOVAL:
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 		pr_info("rpcrdma: removing device %s for %s:%s\n",
-			ia->ri_device->name,
+			ia->ri_id->device->name,
 			rpcrdma_addrstr(r_xprt), rpcrdma_portstr(r_xprt));
 #endif
 		set_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags);
@@ -259,7 +259,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 		wait_for_completion(&ia->ri_remove_done);
 
 		ia->ri_id = NULL;
-		ia->ri_device = NULL;
 		/* Return 1 to ensure the core destroys the id. */
 		return 1;
 	case RDMA_CM_EVENT_ESTABLISHED:
@@ -294,7 +293,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 
 	dprintk("RPC:       %s: %s:%s on %s/frwr: %s\n", __func__,
 		rpcrdma_addrstr(r_xprt), rpcrdma_portstr(r_xprt),
-		ia->ri_device->name, rdma_event_msg(event->event));
+		ia->ri_id->device->name, rdma_event_msg(event->event));
 	return 0;
 }
 
@@ -373,9 +372,8 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 		rc = PTR_ERR(ia->ri_id);
 		goto out_err;
 	}
-	ia->ri_device = ia->ri_id->device;
 
-	ia->ri_pd = ib_alloc_pd(ia->ri_device, 0);
+	ia->ri_pd = ib_alloc_pd(ia->ri_id->device, 0);
 	if (IS_ERR(ia->ri_pd)) {
 		rc = PTR_ERR(ia->ri_pd);
 		pr_err("rpcrdma: ib_alloc_pd() returned %d\n", rc);
@@ -384,12 +382,12 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 
 	switch (xprt_rdma_memreg_strategy) {
 	case RPCRDMA_FRWR:
-		if (frwr_is_supported(ia))
+		if (frwr_is_supported(ia->ri_id->device))
 			break;
 		/*FALLTHROUGH*/
 	default:
 		pr_err("rpcrdma: Device %s does not support memreg mode %d\n",
-		       ia->ri_device->name, xprt_rdma_memreg_strategy);
+		       ia->ri_id->device->name, xprt_rdma_memreg_strategy);
 		rc = -EINVAL;
 		goto out_err;
 	}
@@ -471,7 +469,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 		rdma_destroy_id(ia->ri_id);
 	}
 	ia->ri_id = NULL;
-	ia->ri_device = NULL;
 
 	/* If the pd is still busy, xprtrdma missed freeing a resource */
 	if (ia->ri_pd && !IS_ERR(ia->ri_pd))
@@ -491,7 +488,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	unsigned int max_sge;
 	int rc;
 
-	max_sge = min_t(unsigned int, ia->ri_device->attrs.max_send_sge,
+	max_sge = min_t(unsigned int, ia->ri_id->device->attrs.max_send_sge,
 			RPCRDMA_MAX_SEND_SGES);
 	if (max_sge < RPCRDMA_MIN_SEND_SGES) {
 		pr_warn("rpcrdma: HCA provides only %d send SGEs\n", max_sge);
@@ -526,16 +523,16 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	init_waitqueue_head(&ep->rep_connect_wait);
 	ep->rep_receive_count = 0;
 
-	sendcq = ib_alloc_cq(ia->ri_device, NULL,
+	sendcq = ib_alloc_cq(ia->ri_id->device, NULL,
 			     ep->rep_attr.cap.max_send_wr + 1,
-			     ia->ri_device->num_comp_vectors > 1 ? 1 : 0,
+			     ia->ri_id->device->num_comp_vectors > 1 ? 1 : 0,
 			     IB_POLL_WORKQUEUE);
 	if (IS_ERR(sendcq)) {
 		rc = PTR_ERR(sendcq);
 		goto out1;
 	}
 
-	recvcq = ib_alloc_cq(ia->ri_device, NULL,
+	recvcq = ib_alloc_cq(ia->ri_id->device, NULL,
 			     ep->rep_attr.cap.max_recv_wr + 1,
 			     0, IB_POLL_WORKQUEUE);
 	if (IS_ERR(recvcq)) {
@@ -561,7 +558,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	/* Client offers RDMA Read but does not initiate */
 	ep->rep_remote_cma.initiator_depth = 0;
 	ep->rep_remote_cma.responder_resources =
-		min_t(int, U8_MAX, ia->ri_device->attrs.max_qp_rd_atom);
+		min_t(int, U8_MAX, ia->ri_id->device->attrs.max_qp_rd_atom);
 
 	/* Limit transport retries so client can detect server
 	 * GID changes quickly. RPC layer handles re-establishing
@@ -673,7 +670,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	 */
 	old = id;
 	rc = -ENETUNREACH;
-	if (ia->ri_device != id->device) {
+	if (ia->ri_id->device != id->device) {
 		pr_err("rpcrdma: can't reconnect on different device!\n");
 		goto out_destroy;
 	}
@@ -1296,7 +1293,7 @@ struct rpcrdma_mr *
 
 	if (mr->mr_dir != DMA_NONE) {
 		trace_xprtrdma_mr_unmap(mr);
-		ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
+		ib_dma_unmap_sg(r_xprt->rx_ia.ri_id->device,
 				mr->mr_sg, mr->mr_nents, mr->mr_dir);
 		mr->mr_dir = DMA_NONE;
 	}
@@ -1429,7 +1426,7 @@ bool rpcrdma_regbuf_realloc(struct rpcrdma_regbuf *rb, size_t size, gfp_t flags)
 bool __rpcrdma_regbuf_dma_map(struct rpcrdma_xprt *r_xprt,
 			      struct rpcrdma_regbuf *rb)
 {
-	struct ib_device *device = r_xprt->rx_ia.ri_device;
+	struct ib_device *device = r_xprt->rx_ia.ri_id->device;
 
 	if (rb->rg_direction == DMA_NONE)
 		return false;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index f856393..40912bb 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -66,11 +66,8 @@
  * Interface Adapter -- one per transport instance
  */
 struct rpcrdma_ia {
-	struct ib_device	*ri_device;
 	struct rdma_cm_id 	*ri_id;
 	struct ib_pd		*ri_pd;
-	struct completion	ri_done;
-	struct completion	ri_remove_done;
 	int			ri_async_rc;
 	unsigned int		ri_max_segs;
 	unsigned int		ri_max_frwr_depth;
@@ -80,6 +77,8 @@ struct rpcrdma_ia {
 	bool			ri_implicit_roundup;
 	enum ib_mr_type		ri_mrtype;
 	unsigned long		ri_flags;
+	struct completion	ri_done;
+	struct completion	ri_remove_done;
 };
 
 enum {
@@ -585,7 +584,7 @@ static inline bool rpcrdma_regbuf_dma_map(struct rpcrdma_xprt *r_xprt,
 
 /* Memory registration calls xprtrdma/frwr_ops.c
  */
-bool frwr_is_supported(struct rpcrdma_ia *);
+bool frwr_is_supported(struct ib_device *device);
 int frwr_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 	      struct rpcrdma_create_data_internal *cdata);
 int frwr_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr);

