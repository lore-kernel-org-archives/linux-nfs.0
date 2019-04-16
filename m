Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7E05C10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9B633217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q23G4rju"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728938AbfDPNia (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:38:30 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:53223 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726751AbfDPNi3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:38:29 -0400
Received: by mail-it1-f194.google.com with SMTP id x132so32996718itf.2;
        Tue, 16 Apr 2019 06:38:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=GP1mIxTDOqwa3qqtKIKFKEHNt5kxez4W95OPIp6y9CE=;
        b=Q23G4rjuCVT73gg7JMvKaK/RZv5uZg9AdmoS5SzMpwUfZPcBZ1xHdPk5UvzSrwkbXf
         bKNVPNBvyygAlEPsFOZ+3N5F1WCrWxTXgRx2hOqFMJP2XFxw7h63Xmw70XFGYjOgMPYI
         mtWHw5Dag+J4C2p8Ll+AURVUkgpYpfUh43SFEEZ2X4ob1tdRZ9smY954UHpDCOD0Wh/j
         6RoGWrmJbDzeTT8kZQmRH8KU0gx6DS7X5poKGWcZl/9ToYMBTIUHrDTejgY+/6xmI2rh
         /IjN4F6JDSZRg6MMZnCU87vyzu2RTHqAAJDgi+cGCCgd1p8AZwX9UH8IZ1x59un6oFDv
         9W1A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=GP1mIxTDOqwa3qqtKIKFKEHNt5kxez4W95OPIp6y9CE=;
        b=I7fQU3Vo4+KI3zpYQuPlMctRT2PTFqwk8JHpr8YQ2IIDQFRKXbpN2S1imPrssDIUoI
         aNkOlZXikJM8KAEw89v7+AnsnJDW1YCzNMd3X+3NlWdUS28NDN5bXL7CwXVo+UsQmrEq
         fkwE26DUM5kud4QccY3t22NgFc5vKwFAldfrnSY/DcVMmxShYqCEK3APla7d5DzskdIo
         bnymKTyuxT60OFIDGC62rGfb0SD5zRJKhkeVDW8Pe24tR0cZs23jm55lTA/X9hHt6Gp4
         qEy7cmqwTSIjp/+qxZnd2PPw2D6IstN5Gj/MLVcgLyfDfh2igJsV5AV2ltHH9NZJn8Ah
         nUxw==
X-Gm-Message-State: APjAAAX9YifkOggPaZS0ymLJ7sukafqNXxo/I7U6e9Fgh2CgktyvBdg3
        Y29wCiBVky5oFj5tF3TI5AhQ72C0
X-Google-Smtp-Source: APXvYqyyFp6oIjvRigh6LLE81h5hLWoL05ayHgr4uQbbwP1qiwYnzDljFl2bWMPTzviyso4h8Qf82Q==
X-Received: by 2002:a24:16cf:: with SMTP id a198mr25399602ita.33.1555421908509;
        Tue, 16 Apr 2019 06:38:28 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id v187sm1670809ita.0.2019.04.16.06.38.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:38:28 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDcRs8021250;
        Tue, 16 Apr 2019 13:38:27 GMT
Subject: [PATCH v2 18/21] xprtrdma: Eliminate struct
 rpcrdma_create_data_internal
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:38:27 -0400
Message-ID: <20190416133827.23113.81946.stgit@manet.1015granger.net>
In-Reply-To: <20190416133156.23113.91846.stgit@manet.1015granger.net>
References: <20190416133156.23113.91846.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up.

Move the remaining field in rpcrdma_create_data_internal so the
structure can be removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |   21 +++++++----------
 net/sunrpc/xprtrdma/transport.c |   27 +++-------------------
 net/sunrpc/xprtrdma/verbs.c     |   47 +++++++++++++++++++++++----------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   21 ++++-------------
 4 files changed, 46 insertions(+), 70 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 7cd2718..1d369b6 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -194,12 +194,11 @@ int frwr_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr)
  * frwr_open - Prepare an endpoint for use with FRWR
  * @ia: interface adapter this endpoint will use
  * @ep: endpoint to prepare
- * @cdata: transport parameters
  *
  * On success, sets:
  *	ep->rep_attr.cap.max_send_wr
  *	ep->rep_attr.cap.max_recv_wr
- *	cdata->max_requests
+ *	ep->rep_max_requests
  *	ia->ri_max_segs
  *
  * And these FRWR-related fields:
@@ -208,8 +207,7 @@ int frwr_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr)
  *
  * On failure, a negative errno is returned.
  */
-int frwr_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
-	      struct rpcrdma_create_data_internal *cdata)
+int frwr_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep)
 {
 	struct ib_device_attr *attrs = &ia->ri_id->device->attrs;
 	int max_qp_wr, depth, delta;
@@ -258,19 +256,18 @@ int frwr_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 	max_qp_wr -= 1;
 	if (max_qp_wr < RPCRDMA_MIN_SLOT_TABLE)
 		return -ENOMEM;
-	if (cdata->max_requests > max_qp_wr)
-		cdata->max_requests = max_qp_wr;
-	ep->rep_attr.cap.max_send_wr = cdata->max_requests * depth;
+	if (ep->rep_max_requests > max_qp_wr)
+		ep->rep_max_requests = max_qp_wr;
+	ep->rep_attr.cap.max_send_wr = ep->rep_max_requests * depth;
 	if (ep->rep_attr.cap.max_send_wr > max_qp_wr) {
-		cdata->max_requests = max_qp_wr / depth;
-		if (!cdata->max_requests)
+		ep->rep_max_requests = max_qp_wr / depth;
+		if (!ep->rep_max_requests)
 			return -EINVAL;
-		ep->rep_attr.cap.max_send_wr = cdata->max_requests *
-					       depth;
+		ep->rep_attr.cap.max_send_wr = ep->rep_max_requests * depth;
 	}
 	ep->rep_attr.cap.max_send_wr += RPCRDMA_BACKWARD_WRS;
 	ep->rep_attr.cap.max_send_wr += 1; /* for ib_drain_sq */
-	ep->rep_attr.cap.max_recv_wr = cdata->max_requests;
+	ep->rep_attr.cap.max_recv_wr = ep->rep_max_requests;
 	ep->rep_attr.cap.max_recv_wr += RPCRDMA_BACKWARD_WRS;
 	ep->rep_attr.cap.max_recv_wr += 1; /* for ib_drain_rq */
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 4e5b8fe..f0b13a9 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -68,7 +68,7 @@
  * tunables
  */
 
-static unsigned int xprt_rdma_slot_table_entries = RPCRDMA_DEF_SLOT_TABLE;
+unsigned int xprt_rdma_slot_table_entries = RPCRDMA_DEF_SLOT_TABLE;
 unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
 unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
 unsigned int xprt_rdma_memreg_strategy		= RPCRDMA_FRWR;
@@ -288,7 +288,7 @@
 
 	cancel_delayed_work_sync(&r_xprt->rx_connect_worker);
 
-	rpcrdma_ep_destroy(&r_xprt->rx_ep, &r_xprt->rx_ia);
+	rpcrdma_ep_destroy(r_xprt);
 	rpcrdma_buffer_destroy(&r_xprt->rx_buf);
 	rpcrdma_ia_close(&r_xprt->rx_ia);
 
@@ -311,10 +311,8 @@
 static struct rpc_xprt *
 xprt_setup_rdma(struct xprt_create *args)
 {
-	struct rpcrdma_create_data_internal cdata;
 	struct rpc_xprt *xprt;
 	struct rpcrdma_xprt *new_xprt;
-	struct rpcrdma_ep *new_ep;
 	struct sockaddr *sap;
 	int rc;
 
@@ -349,29 +347,12 @@
 		xprt_set_bound(xprt);
 	xprt_rdma_format_addresses(xprt, sap);
 
-	cdata.max_requests = xprt_rdma_slot_table_entries;
-
-	/*
-	 * Create new transport instance, which includes initialized
-	 *  o ia
-	 *  o endpoint
-	 *  o buffers
-	 */
-
 	new_xprt = rpcx_to_rdmax(xprt);
-
 	rc = rpcrdma_ia_open(new_xprt);
 	if (rc)
 		goto out1;
 
-	/*
-	 * initialize and create ep
-	 */
-	new_xprt->rx_data = cdata;
-	new_ep = &new_xprt->rx_ep;
-
-	rc = rpcrdma_ep_create(&new_xprt->rx_ep,
-				&new_xprt->rx_ia, &new_xprt->rx_data);
+	rc = rpcrdma_ep_create(new_xprt);
 	if (rc)
 		goto out2;
 
@@ -402,7 +383,7 @@
 	rpcrdma_buffer_destroy(&new_xprt->rx_buf);
 	rc = -ENODEV;
 out3:
-	rpcrdma_ep_destroy(new_ep, &new_xprt->rx_ia);
+	rpcrdma_ep_destroy(new_xprt);
 out2:
 	rpcrdma_ia_close(&new_xprt->rx_ia);
 out1:
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 9e24ca5..0d0c335 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -476,18 +476,22 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	ia->ri_pd = NULL;
 }
 
-/*
- * Create unconnected endpoint.
+/**
+ * rpcrdma_ep_create - Create unconnected endpoint
+ * @r_xprt: transport to instantiate
+ *
+ * Returns zero on success, or a negative errno.
  */
-int
-rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
-		  struct rpcrdma_create_data_internal *cdata)
+int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 {
+	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_connect_private *pmsg = &ep->rep_cm_private;
 	struct ib_cq *sendcq, *recvcq;
 	unsigned int max_sge;
 	int rc;
 
+	ep->rep_max_requests = xprt_rdma_slot_table_entries;
 	ep->rep_inline_send = xprt_rdma_max_inline_write;
 	ep->rep_inline_recv = xprt_rdma_max_inline_read;
 
@@ -499,7 +503,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	}
 	ia->ri_max_send_sges = max_sge;
 
-	rc = frwr_open(ia, ep, cdata);
+	rc = frwr_open(ia, ep);
 	if (rc)
 		return rc;
 
@@ -521,7 +525,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 		ep->rep_attr.cap.max_send_sge,
 		ep->rep_attr.cap.max_recv_sge);
 
-	ep->rep_send_batch = cdata->max_requests >> 3;
+	ep->rep_send_batch = ep->rep_max_requests >> 3;
 	ep->rep_send_count = ep->rep_send_batch;
 	init_waitqueue_head(&ep->rep_connect_wait);
 	ep->rep_receive_count = 0;
@@ -584,16 +588,16 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	return rc;
 }
 
-/*
- * rpcrdma_ep_destroy
+/**
+ * rpcrdma_ep_destroy - Disconnect and destroy endpoint.
+ * @r_xprt: transport instance to shut down
  *
- * Disconnect and destroy endpoint. After this, the only
- * valid operations on the ep are to free it (if dynamically
- * allocated) or re-create it.
  */
-void
-rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
+void rpcrdma_ep_destroy(struct rpcrdma_xprt *r_xprt)
 {
+	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+
 	if (ia->ri_id && ia->ri_id->qp) {
 		rpcrdma_ep_disconnect(ep, ia);
 		rdma_destroy_qp(ia->ri_id);
@@ -623,7 +627,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 		goto out1;
 
 	rc = -ENOMEM;
-	err = rpcrdma_ep_create(ep, ia, &r_xprt->rx_data);
+	err = rpcrdma_ep_create(r_xprt);
 	if (err) {
 		pr_err("rpcrdma: rpcrdma_ep_create returned %d\n", err);
 		goto out2;
@@ -640,7 +644,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	return 0;
 
 out3:
-	rpcrdma_ep_destroy(ep, ia);
+	rpcrdma_ep_destroy(r_xprt);
 out2:
 	rpcrdma_ia_close(ia);
 out1:
@@ -1082,14 +1086,19 @@ static bool rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt, bool temp)
 	return false;
 }
 
-int
-rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
+/**
+ * rpcrdma_buffer_create - Create initial set of req/rep objects
+ * @r_xprt: transport instance to (re)initialize
+ *
+ * Returns zero on success, otherwise a negative errno.
+ */
+int rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	int i, rc;
 
 	buf->rb_flags = 0;
-	buf->rb_max_requests = r_xprt->rx_data.max_requests;
+	buf->rb_max_requests = r_xprt->rx_ep.rep_max_requests;
 	buf->rb_bc_srv_max_requests = 0;
 	spin_lock_init(&buf->rb_mrlock);
 	spin_lock_init(&buf->rb_lock);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index edf602a..803f097 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -97,6 +97,7 @@ struct rpcrdma_ep {
 	wait_queue_head_t 	rep_connect_wait;
 	struct rpcrdma_connect_private	rep_cm_private;
 	struct rdma_conn_param	rep_remote_cma;
+	unsigned int		rep_max_requests;	/* set by /proc */
 	unsigned int		rep_inline_send;	/* negotiated */
 	unsigned int		rep_inline_recv;	/* negotiated */
 	int			rep_receive_count;
@@ -414,16 +415,6 @@ enum {
 };
 
 /*
- * Internal structure for transport instance creation. This
- * exists primarily for modularity.
- *
- * This data should be set with mount options
- */
-struct rpcrdma_create_data_internal {
-	unsigned int	max_requests;	/* max requests (slots) in flight */
-};
-
-/*
  * Statistics for RPCRDMA
  */
 struct rpcrdma_stats {
@@ -467,7 +458,6 @@ struct rpcrdma_xprt {
 	struct rpcrdma_ia	rx_ia;
 	struct rpcrdma_ep	rx_ep;
 	struct rpcrdma_buffer	rx_buf;
-	struct rpcrdma_create_data_internal rx_data;
 	struct delayed_work	rx_connect_worker;
 	struct rpcrdma_stats	rx_stats;
 };
@@ -507,9 +497,8 @@ struct rpcrdma_xprt {
 /*
  * Endpoint calls - xprtrdma/verbs.c
  */
-int rpcrdma_ep_create(struct rpcrdma_ep *, struct rpcrdma_ia *,
-				struct rpcrdma_create_data_internal *);
-void rpcrdma_ep_destroy(struct rpcrdma_ep *, struct rpcrdma_ia *);
+int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt);
+void rpcrdma_ep_destroy(struct rpcrdma_xprt *r_xprt);
 int rpcrdma_ep_connect(struct rpcrdma_ep *, struct rpcrdma_ia *);
 void rpcrdma_ep_disconnect(struct rpcrdma_ep *, struct rpcrdma_ia *);
 
@@ -583,8 +572,7 @@ static inline bool rpcrdma_regbuf_dma_map(struct rpcrdma_xprt *r_xprt,
 /* Memory registration calls xprtrdma/frwr_ops.c
  */
 bool frwr_is_supported(struct ib_device *device);
-int frwr_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
-	      struct rpcrdma_create_data_internal *cdata);
+int frwr_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep);
 int frwr_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr);
 void frwr_release_mr(struct rpcrdma_mr *mr);
 size_t frwr_maxpages(struct rpcrdma_xprt *r_xprt);
@@ -630,6 +618,7 @@ static inline void rpcrdma_set_xdrlen(struct xdr_buf *xdr, size_t len)
 
 /* RPC/RDMA module init - xprtrdma/transport.c
  */
+extern unsigned int xprt_rdma_slot_table_entries;
 extern unsigned int xprt_rdma_max_inline_read;
 extern unsigned int xprt_rdma_max_inline_write;
 void xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap);

