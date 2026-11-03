Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.222
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793674910;
	b=xPj6eT2HUKSz4rRIQdtifRmNOR5TUegd03JkUNNUyh6nyLIHI88UMYRsgNfALVne2G+n
	 FKzsNMogU9M1NhgWTjHer6WGAF+IEqpm8+hR8pys2pKYaTxw+WCZkAeqIL5f5K7uow563
	 4LPAsaMr8i9Wrp6oc86KahvDn1Qkurn12H9yNuW3PAJZz3UTMtFCYiQPnZ/kWh5YAEfXi
	 IE596R7UjF8/Mum2RWSu6BLjMuob97JrcO7r16nRIR/RZpDYYph9kipdvDVrE8t+sn9+a
	 atFyo0v1a+k+26J0wnZet9xrmWaWtRS+zcFRAAphjvYQOvdgx7vDJl4EGNewCKyfewg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793674910;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=kswPp5nOFTs/jrVO5aL8A+ifgGVop+dANpq7tVswyRY=;
	b=YcpP6j8vVGVt0teKpQnkLR9DQl3XXyvw5E63Q04x7G/SD7j7ZkEQRd1+9RbyLj74bmPU
	 kjXxTkAk3HAc1Ph3o4N10DKJyMOXvip4GM8gbyqi8WbNpB50PO1J2Lz33sYuoxp4BOgj8
	 W+BeF7oPAkLrJ61UTgkC816udpz5yYnUFRlMQqh+QDCyBPXkDNOGQ6bJAaJlFBF2V7oTx
	 Z455my6Tg+BtzTJtKfEDrSmRlcDxftT/d0qOsmO5WlujKlEOTiafnE891eSIDf2xDZ012
	 hTayeIWQcWtCRcD5LcjPoTI4PfG1GbjyPfw7qyaEuW1WsVWogSja/HcIN0UDXdfC37w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=G0+CpO5Z;
	arc=none smtp.remote-ip=113.46.200.222
Received: from canpmsgout07.his.huawei.com (canpmsgout07.his.huawei.com [113.46.200.222])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C120A606A32E;
	Tue,  3 Nov 2026 03:01:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C120A606A32E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=G0+CpO5Z
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=kswPp5nOFTs/jrVO5aL8A+ifgGVop+dANpq7tVswyRY=;
	b=G0+CpO5ZuKyol9Io8zDyi7Lk21KuNv5OJbL0NFLYWHdpOEt19rSm+M2AvthCfjE5UbgaK/hPn
	88cwnnxfrVogk+4gkW6l98hrn0hmn6AOGo2ot03Q0EoW7g/P+L3Nod/Rj5zf6whVNcz0H2vQtV/
	5EDkESnXmS5JatWMZllG12c=
Received: from mail.maildlp.com (unknown [172.19.162.92])
	by canpmsgout07.his.huawei.com (SkyGuard) with ESMTPS id 4jJYHt61VCzLlTG;
	Tue,  3 Nov 2026 11:01:30 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id DB21A40586;
	Tue,  3 Nov 2026 11:01:40 +0800 (CST)
Received: from huawei.com (10.50.85.128) by whupemk300014.china.huawei.com
 (7.152.185.8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Tue, 3 Nov
 2026 11:01:39 +0800
From: Li Xiasong <lixiasong1@huawei.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<stable@vger.kernel.org>, <yuehaibing@huawei.com>,
	<zhangchangzhong@huawei.com>, <weiyongjun1@huawei.com>
Subject: [PATCH v2 3/3] xprtrdma: Wake connect worker on device removal
Date: Tue, 3 Nov 2026 11:27:58 +0800
Message-ID: <20261103032758.1302493-4-lixiasong1@huawei.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20261103032758.1302493-1-lixiasong1@huawei.com>
References: <20261103032758.1302493-1-lixiasong1@huawei.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: kwepems200001.china.huawei.com (7.221.188.67) To
 whupemk300014.china.huawei.com (7.152.185.8)

Device removal only forces a transport disconnect, leaving a connect
worker asleep while re_connect_status is zero and blocking endpoint
cleanup.

Set -ENODEV and wake pending connects on removal. Force established
connections to disconnect and use atomic transitions to prevent late
ESTABLISHED events from overwriting errors. Handle REJECTED after
establishment with an atomic status update and forced disconnect, retaining
its errno and unconditional wakeup without relying on CQ flushes.

The final endpoint put can free id->context before rdma_destroy_id()
synchronizes with CM callbacks. Destroy the CM ID in the endpoint
destructor before freeing its context to close this window. Remove the
CM callback get/put pairs so final puts occur outside CM callbacks.
Initialize the connect waitqueue before notification registration.

If transport pinning fails, fail and wake a pending connect under the
device mutex before skipping the notification. The final transport put
can be waiting for that worker to release XPRT_LOCKED.

Fixes: 3f4eb9ff9234 ("xprtrdma: Handle device removal outside of the CM event handler")
Signed-off-by: Li Xiasong <lixiasong1@huawei.com>
---
 net/sunrpc/xprtrdma/verbs.c | 94 ++++++++++++++++++++++---------------
 1 file changed, 56 insertions(+), 38 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 69d1796bb4f3..9eec462cffd9 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -75,7 +75,7 @@ static void rpcrdma_reps_unmap(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_mrs_create(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_mrs_destroy(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_ep_get(struct rpcrdma_ep *ep);
-static int rpcrdma_ep_put(struct rpcrdma_ep *ep);
+static void rpcrdma_ep_put(struct rpcrdma_ep *ep);
 static struct rpcrdma_regbuf *
 rpcrdma_regbuf_alloc_node(size_t size, enum dma_data_direction direction,
 			  int node);
@@ -124,6 +124,20 @@ void rpcrdma_force_disconnect(struct rpcrdma_ep *ep)
 		xprt_force_disconnect(ep->re_xprt);
 }
 
+static void rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, int status)
+{
+	switch (cmpxchg(&ep->re_connect_status, 0, status)) {
+	case 0:
+		wake_up_all(&ep->re_connect_wait);
+		break;
+	case 1:
+		rpcrdma_force_disconnect(ep);
+		break;
+	default:
+		break;
+	}
+}
+
 /**
  * rpcrdma_flush_disconnect - Disconnect on flushed completion
  * @r_xprt: transport to disconnect
@@ -222,13 +236,14 @@ static void rpcrdma_update_cm_private(struct rpcrdma_ep *ep,
  * @id: rdma_cm_id on which an event has occurred
  * @event: details of the event
  *
- * Called with @id's mutex held. Returns 1 if caller should
- * destroy @id, otherwise 0.
+ * Called with @id's mutex held. Always returns 0: the endpoint owner
+ * destroys @id and waits for these callbacks before freeing @id's context.
  */
 static int
 rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 {
 	struct rpcrdma_ep *ep = id->context;
+	int status;
 
 	might_sleep();
 
@@ -247,20 +262,18 @@ rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 		complete(&ep->re_done);
 		return 0;
 	case RDMA_CM_EVENT_ADDR_CHANGE:
-		switch (xchg(&ep->re_connect_status, -ENODEV)) {
+		rpcrdma_ep_disconnect(ep, -ENODEV);
+		return 0;
+	case RDMA_CM_EVENT_ESTABLISHED:
+		switch (cmpxchg(&ep->re_connect_status, 0, 1)) {
 		case 0:
-			goto wake_connect_worker;
-		case 1:
-			/* The later DISCONNECTED event balances the
-			 * ESTABLISHED get; do not put here.
-			 */
+			break;
+		case -ENODEV:
 			rpcrdma_force_disconnect(ep);
 			return 0;
+		default:
+			return 0;
 		}
-		return 0;
-	case RDMA_CM_EVENT_ESTABLISHED:
-		rpcrdma_ep_get(ep);
-		ep->re_connect_status = 1;
 		rpcrdma_update_cm_private(ep, &event->param.conn);
 		trace_xprtrdma_inline_thresh(ep);
 		wake_up_all(&ep->re_connect_wait);
@@ -269,19 +282,21 @@ rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 		ep->re_connect_status = -ENOTCONN;
 		goto wake_connect_worker;
 	case RDMA_CM_EVENT_UNREACHABLE:
-		ep->re_connect_status = -ENETUNREACH;
-		goto wake_connect_worker;
+		rpcrdma_ep_disconnect(ep, -ENETUNREACH);
+		return 0;
 	case RDMA_CM_EVENT_REJECTED:
-		ep->re_connect_status = -ECONNREFUSED;
+		status = -ECONNREFUSED;
 		if (event->status == IB_CM_REJ_STALE_CONN)
-			ep->re_connect_status = -ENOTCONN;
+			status = -ENOTCONN;
+		if (xchg(&ep->re_connect_status, status) == 1)
+			rpcrdma_force_disconnect(ep);
 wake_connect_worker:
 		wake_up_all(&ep->re_connect_wait);
 		return 0;
 	case RDMA_CM_EVENT_DISCONNECTED:
-		ep->re_connect_status = -ECONNABORTED;
+		xchg(&ep->re_connect_status, -ECONNABORTED);
 		rpcrdma_force_disconnect(ep);
-		return rpcrdma_ep_put(ep);
+		return 0;
 	default:
 		break;
 	}
@@ -294,7 +309,7 @@ static void rpcrdma_ep_removal_done(struct rpcrdma_notification *rn)
 	struct rpcrdma_ep *ep = container_of(rn, struct rpcrdma_ep, re_rn);
 
 	trace_xprtrdma_device_removal(ep->re_id);
-	xprt_force_disconnect(ep->re_xprt);
+	rpcrdma_ep_disconnect(ep, -ENODEV);
 }
 
 static void rpcrdma_ep_removal_put(struct rpcrdma_notification_ref *ref)
@@ -302,12 +317,8 @@ static void rpcrdma_ep_removal_put(struct rpcrdma_notification_ref *ref)
 	struct rpcrdma_ep *ep = ref->rr_owner;
 	struct rpc_xprt *xprt = ref->rr_xprt;
 
-	if (ep) {
-		struct rdma_cm_id *id = ep->re_id;
-
-		if (rpcrdma_ep_put(ep))
-			rdma_destroy_id(id);
-	}
+	if (ep)
+		rpcrdma_ep_put(ep);
 	xprt_put(xprt);
 }
 
@@ -317,8 +328,15 @@ static bool rpcrdma_ep_removal_get(struct rpcrdma_notification *rn,
 	struct rpcrdma_ep *ep = container_of(rn, struct rpcrdma_ep, re_rn);
 	struct rpc_xprt *xprt = ep->re_xprt;
 
-	if (!xprt_get(xprt))
+	if (!xprt_get(xprt)) {
+		/* The final xprt_put() can be waiting for the connect worker's
+		 * XPRT_LOCKED bit. The device mutex protects @ep until
+		 * unregister. Wake pending connects without using the transport.
+		 */
+		if (cmpxchg(&ep->re_connect_status, 0, -ENODEV) == 0)
+			wake_up_all(&ep->re_connect_wait);
 		return false;
+	}
 	ref->rr_xprt = xprt;
 	if (!kref_get_unless_zero(&ep->re_kref))
 		return false;
@@ -383,6 +401,7 @@ static struct rdma_cm_id *rpcrdma_create_id(struct rpcrdma_xprt *r_xprt,
 static void rpcrdma_ep_destroy(struct kref *kref)
 {
 	struct rpcrdma_ep *ep = container_of(kref, struct rpcrdma_ep, re_kref);
+	struct ib_device *device = ep->re_id->device;
 
 	if (ep->re_id->qp) {
 		rdma_destroy_qp(ep->re_id);
@@ -400,7 +419,11 @@ static void rpcrdma_ep_destroy(struct kref *kref)
 		ib_dealloc_pd(ep->re_pd);
 	ep->re_pd = NULL;
 
-	rpcrdma_rn_unregister(ep->re_id->device, &ep->re_rn);
+	/* All puts occur outside CM callbacks. Fence both queued and running
+	 * callbacks before freeing the context, even if no connection formed.
+	 */
+	rdma_destroy_id(ep->re_id);
+	rpcrdma_rn_unregister(device, &ep->re_rn);
 
 	kfree(ep);
 	module_put(THIS_MODULE);
@@ -411,13 +434,10 @@ static noinline void rpcrdma_ep_get(struct rpcrdma_ep *ep)
 	kref_get(&ep->re_kref);
 }
 
-/* Returns:
- *     %0 if @ep still has a positive kref count, or
- *     %1 if @ep was destroyed successfully.
- */
-static noinline int rpcrdma_ep_put(struct rpcrdma_ep *ep)
+/* Must not be called from an RDMA CM event handler. */
+static noinline void rpcrdma_ep_put(struct rpcrdma_ep *ep)
 {
-	return kref_put(&ep->re_kref, rpcrdma_ep_destroy);
+	kref_put(&ep->re_kref, rpcrdma_ep_destroy);
 }
 
 static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
@@ -433,6 +453,7 @@ static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 		return -ENOTCONN;
 	ep->re_xprt = &r_xprt->rx_xprt;
 	kref_init(&ep->re_kref);
+	init_waitqueue_head(&ep->re_connect_wait);
 
 	id = rpcrdma_create_id(r_xprt, ep);
 	if (IS_ERR(id)) {
@@ -460,7 +481,6 @@ static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 
 	ep->re_send_batch = ep->re_max_requests >> 3;
 	ep->re_send_count = ep->re_send_batch;
-	init_waitqueue_head(&ep->re_connect_wait);
 
 	ep->re_attr.send_cq = ib_alloc_cq_any(device, r_xprt,
 					      ep->re_attr.cap.max_send_wr,
@@ -528,7 +548,6 @@ static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 
 out_destroy:
 	rpcrdma_ep_put(ep);
-	rdma_destroy_id(id);
 	return rc;
 }
 
@@ -632,8 +651,7 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
 	rpcrdma_reqs_reset(r_xprt);
 	rpcrdma_mrs_destroy(r_xprt);
 
-	if (rpcrdma_ep_put(ep))
-		rdma_destroy_id(id);
+	rpcrdma_ep_put(ep);
 
 	r_xprt->rx_ep = NULL;
 }
-- 
2.34.1

