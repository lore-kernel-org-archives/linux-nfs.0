Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.226
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795485202;
	b=NNoBpEfe/L5DrsZ83aB+jA53iYhPeSFPd38sbRiZpf5vp2jJrvGWYPrYrn4aDv5ohO1H
	 f7375irn9xAFnDyGKZS8wIlHm6AkyIcuqWab6zi2W5qmsh+X3S15sO+JvoZcMyHlQEZyi
	 HZTox+Tm3EC7/w1kkJ2jwqM0xe8GvYV6coiolzcI5CBpbnItdH31B9+bUC1djEdEwzd11
	 n165jG7wtkTAOQ+q47QWLD7Iu4a9gpN1XPbvFIumFo/G9e+nUWIGaNrqmA250eoyZOcmi
	 Ojwwjpfs55kp2OwEebRGPxYl1DEs+CtnK+S0RwI/8xoV+2zUS4t2QLYbw+1hV864TZg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795485202;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=zAqFGycKt+sXzoK2zBRu2dD4BEPGTNT00Ykt9AWpuqA=;
	b=x0kaFU88L7TWsAw2myIdAeAZzeTPWTNKEjpNCqSeHJD0so+dEEFx6uo7G4zUQkgz2iIr
	 YLwdE80LgAnNrBdvWdTcr5isdtu7G1a3kKQIqiS3l9St79+rmR2SU0IjpvcCsIQJziyza
	 INMHjtLvud9ufthlWfZQjsf7/Hi8prcnm/GxNVEPv3oxQPDXDKTXjiLxF6OrUgPVJttCu
	 +7/JkpKpPWIsNZB/JclEZ1p/bUBuwPU27nYZ2z0bkHgspVHLGzvMAFOlwJ+Lr5LFsYEhz
	 GS4dzcFN1rmmD4W3Z5iish/5xkkJdssPFmawygUWz8B58zCmRVDb/w2Fc62srU6DlVQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=hhgyZDNK;
	arc=none smtp.remote-ip=113.46.200.226
Received: from canpmsgout11.his.huawei.com (canpmsgout11.his.huawei.com [113.46.200.226])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0E16A606A326;
	Tue, 24 Nov 2026 01:53:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0E16A606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=hhgyZDNK
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=zAqFGycKt+sXzoK2zBRu2dD4BEPGTNT00Ykt9AWpuqA=;
	b=hhgyZDNKEM9lw6LZoIwsmGiAQobKIUlUv650fE/iMX3OAu54kQYI6+CHXFzayuaOD/J8MyH49
	Cg2Wc1sFo8MdzGa+ljtYvY+Wpv2jC9AnQrCN3ILIdLge4tBn0cmvnEqOC+IvTQZ+IXLfBWmy4gl
	gJnh8s1Sr0qY5xTzoKrBx8s=
Received: from mail.maildlp.com (unknown [172.19.163.163])
	by canpmsgout11.his.huawei.com (SkyGuard) with ESMTPS id 4jYQn85S8yzKm4Z;
	Tue, 24 Nov 2026 09:53:00 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id A0CAB40563;
	Tue, 24 Nov 2026 09:53:18 +0800 (CST)
Received: from huawei.com (10.50.85.128) by whupemk300014.china.huawei.com
 (7.152.185.8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Tue, 24 Nov
 2026 09:53:17 +0800
From: Li Xiasong <lixiasong1@huawei.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<stable@vger.kernel.org>, <yuehaibing@huawei.com>,
	<zhangchangzhong@huawei.com>, <weiyongjun1@huawei.com>
Subject: [PATCH v3 3/3] xprtrdma: Wake connect worker on device removal
Date: Tue, 24 Nov 2026 10:18:42 +0800
Message-ID: <20261124021842.130141-4-lixiasong1@huawei.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20261124021842.130141-1-lixiasong1@huawei.com>
References: <20261124021842.130141-1-lixiasong1@huawei.com>
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

Set -ENODEV and wake pending connects on removal. Give -ENODEV
precedence over other failures so late CM events cannot mask device
removal. Force established connections to disconnect and use atomic
transitions to prevent late ESTABLISHED events from overwriting errors.
Handle REJECTED with an atomic status update. Wake the connect worker
if the connection is still pending, or force an established connection
to disconnect without relying on CQ flushes.

The final endpoint put can free id->context before rdma_destroy_id()
synchronizes with CM callbacks. Destroy the CM ID in the endpoint
destructor before freeing its context to close this window. Remove the
CM callback get/put pairs so final puts occur outside CM callbacks.
Initialize the connect waitqueue before notification registration.

If transport pinning fails, fail and wake a pending connect under the
device mutex before skipping the notification. The final transport put
can be waiting for that worker to release XPRT_LOCKED.

Translate -ENODEV from the connection status to -ENOTCONN so pending
RPCs retry on a hard mount when the device disappears during setup.

Fixes: 3f4eb9ff9234 ("xprtrdma: Handle device removal outside of the CM event handler")
Signed-off-by: Li Xiasong <lixiasong1@huawei.com>
---
 net/sunrpc/xprtrdma/transport.c |   2 +-
 net/sunrpc/xprtrdma/verbs.c     | 120 ++++++++++++++++++++------------
 2 files changed, 75 insertions(+), 47 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index e38637c2ec78..88bf9c9d9cf5 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -488,7 +488,7 @@ xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 	WARN_ON_ONCE(!xprt_lock_connect(xprt, task, r_xprt));
 
 	delay = 0;
-	if (ep && ep->re_connect_status != 0) {
+	if (ep && READ_ONCE(ep->re_connect_status)) {
 		delay = xprt_reconnect_delay(xprt);
 		xprt_reconnect_backoff(xprt, RPCRDMA_INIT_REEST_TO);
 	}
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b8dfdabd8a5a..1f2a3cea073f 100644
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
@@ -124,6 +124,23 @@ void rpcrdma_force_disconnect(struct rpcrdma_ep *ep)
 		xprt_force_disconnect(ep->re_xprt);
 }
 
+/* Device removal takes precedence over other connection failures. */
+static void rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, int status,
+				  bool force_disconnect)
+{
+	int old = READ_ONCE(ep->re_connect_status);
+
+	do {
+		if (old == -ENODEV || (old < 0 && status != -ENODEV))
+			return;
+	} while (!try_cmpxchg(&ep->re_connect_status, &old, status));
+
+	if (!old)
+		wake_up_all(&ep->re_connect_wait);
+	else if (old == 1 && force_disconnect)
+		rpcrdma_force_disconnect(ep);
+}
+
 /**
  * rpcrdma_flush_disconnect - Disconnect on flushed completion
  * @r_xprt: transport to disconnect
@@ -222,13 +239,14 @@ static void rpcrdma_update_cm_private(struct rpcrdma_ep *ep,
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
 
@@ -247,41 +265,32 @@ rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 		complete(&ep->re_done);
 		return 0;
 	case RDMA_CM_EVENT_ADDR_CHANGE:
-		switch (xchg(&ep->re_connect_status, -ENODEV)) {
-		case 0:
-			goto wake_connect_worker;
-		case 1:
-			/* The later DISCONNECTED event balances the
-			 * ESTABLISHED get; do not put here.
-			 */
-			rpcrdma_force_disconnect(ep);
-			return 0;
-		}
+		rpcrdma_ep_disconnect(ep, -ENODEV, true);
 		return 0;
 	case RDMA_CM_EVENT_ESTABLISHED:
-		rpcrdma_ep_get(ep);
-		ep->re_connect_status = 1;
+		if (READ_ONCE(ep->re_connect_status))
+			return 0;
 		rpcrdma_update_cm_private(ep, &event->param.conn);
+		if (cmpxchg(&ep->re_connect_status, 0, 1))
+			return 0;
 		trace_xprtrdma_inline_thresh(ep);
 		wake_up_all(&ep->re_connect_wait);
-		break;
+		return 0;
 	case RDMA_CM_EVENT_CONNECT_ERROR:
-		ep->re_connect_status = -ENOTCONN;
-		goto wake_connect_worker;
+		rpcrdma_ep_disconnect(ep, -ENOTCONN, true);
+		return 0;
 	case RDMA_CM_EVENT_UNREACHABLE:
-		ep->re_connect_status = -ENETUNREACH;
-		goto wake_connect_worker;
+		rpcrdma_ep_disconnect(ep, -ENETUNREACH, true);
+		return 0;
 	case RDMA_CM_EVENT_REJECTED:
-		ep->re_connect_status = -ECONNREFUSED;
+		status = -ECONNREFUSED;
 		if (event->status == IB_CM_REJ_STALE_CONN)
-			ep->re_connect_status = -ENOTCONN;
-wake_connect_worker:
-		wake_up_all(&ep->re_connect_wait);
+			status = -ENOTCONN;
+		rpcrdma_ep_disconnect(ep, status, true);
 		return 0;
 	case RDMA_CM_EVENT_DISCONNECTED:
-		ep->re_connect_status = -ECONNABORTED;
-		rpcrdma_force_disconnect(ep);
-		return rpcrdma_ep_put(ep);
+		rpcrdma_ep_disconnect(ep, -ECONNABORTED, true);
+		return 0;
 	default:
 		break;
 	}
@@ -308,11 +317,18 @@ static void rpcrdma_ep_removal_done(struct rpcrdma_notification *rn,
 	 * for the connect worker, which may need the mutex to unregister.
 	 */
 	xprt = xprt_get(ep->re_xprt);
-	if (!xprt)
+	if (!xprt) {
+		/*
+		 * The final xprt_put() can be waiting for the connect worker's
+		 * XPRT_LOCKED bit. The device mutex protects @ep until
+		 * unregister. Wake pending connects without using the transport.
+		 */
+		rpcrdma_ep_disconnect(ep, -ENODEV, false);
 		return;
+	}
 	release->release = rpcrdma_xprt_removal_put;
 	release->data = xprt;
-	rpcrdma_force_disconnect(ep);
+	rpcrdma_ep_disconnect(ep, -ENODEV, true);
 }
 
 static struct rdma_cm_id *rpcrdma_create_id(struct rpcrdma_xprt *r_xprt,
@@ -369,6 +385,7 @@ static struct rdma_cm_id *rpcrdma_create_id(struct rpcrdma_xprt *r_xprt,
 static void rpcrdma_ep_destroy(struct kref *kref)
 {
 	struct rpcrdma_ep *ep = container_of(kref, struct rpcrdma_ep, re_kref);
+	struct ib_device *device = ep->re_id->device;
 
 	if (ep->re_id->qp) {
 		rdma_destroy_qp(ep->re_id);
@@ -386,7 +403,14 @@ static void rpcrdma_ep_destroy(struct kref *kref)
 		ib_dealloc_pd(ep->re_pd);
 	ep->re_pd = NULL;
 
-	rpcrdma_rn_unregister(ep->re_id->device, &ep->re_rn);
+	/* Removal callbacks also access re_id, including from tracepoints. */
+	rpcrdma_rn_unregister(device, &ep->re_rn);
+
+	/*
+	 * All puts occur outside CM callbacks. Fence queued and running
+	 * callbacks before freeing the context, even if no connection formed.
+	 */
+	rdma_destroy_id(ep->re_id);
 
 	kfree(ep);
 	module_put(THIS_MODULE);
@@ -397,13 +421,10 @@ static noinline void rpcrdma_ep_get(struct rpcrdma_ep *ep)
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
@@ -419,6 +440,7 @@ static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 		return -ENOTCONN;
 	ep->re_xprt = &r_xprt->rx_xprt;
 	kref_init(&ep->re_kref);
+	init_waitqueue_head(&ep->re_connect_wait);
 
 	id = rpcrdma_create_id(r_xprt, ep);
 	if (IS_ERR(id)) {
@@ -446,7 +468,6 @@ static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 
 	ep->re_send_batch = ep->re_max_requests >> 3;
 	ep->re_send_count = ep->re_send_batch;
-	init_waitqueue_head(&ep->re_connect_wait);
 
 	ep->re_attr.send_cq = ib_alloc_cq_any(device, r_xprt,
 					      ep->re_attr.cap.max_send_wr,
@@ -514,7 +535,6 @@ static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 
 out_destroy:
 	rpcrdma_ep_put(ep);
-	rdma_destroy_id(id);
 	return rc;
 }
 
@@ -550,12 +570,17 @@ int rpcrdma_xprt_connect(struct rpcrdma_xprt *r_xprt)
 
 	if (xprt->reestablish_timeout < RPCRDMA_INIT_REEST_TO)
 		xprt->reestablish_timeout = RPCRDMA_INIT_REEST_TO;
-	wait_event_interruptible(ep->re_connect_wait,
-				 ep->re_connect_status != 0);
-	if (ep->re_connect_status <= 0) {
-		rc = ep->re_connect_status;
+	rc = wait_event_interruptible(ep->re_connect_wait,
+				      READ_ONCE(ep->re_connect_status));
+	if (rc)
+		goto out;
+	/* The ESTABLISHED cmpxchg publishes the negotiated CM parameters. */
+	rc = smp_load_acquire(&ep->re_connect_status);
+	/* Let pending RPC tasks retry after the device disappears. */
+	if (rc == -ENODEV)
+		rc = -ENOTCONN;
+	if (rc < 0)
 		goto out;
-	}
 
 	rc = rpcrdma_sendctxs_create(r_xprt);
 	if (rc) {
@@ -622,8 +647,11 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
 	rpcrdma_reqs_reset(r_xprt);
 	rpcrdma_mrs_destroy(r_xprt);
 
-	if (rpcrdma_ep_put(ep))
-		rdma_destroy_id(id);
+	/*
+	 * The destructor destroys the CM ID, fencing any callback still
+	 * returning before the endpoint context is freed.
+	 */
+	rpcrdma_ep_put(ep);
 
 	r_xprt->rx_ep = NULL;
 
@@ -920,7 +948,7 @@ void rpcrdma_mrs_refresh(struct rpcrdma_xprt *r_xprt)
 	/* If there is no underlying connection, it's no use
 	 * to wake the refresh worker.
 	 */
-	if (ep->re_connect_status != 1)
+	if (READ_ONCE(ep->re_connect_status) != 1)
 		return;
 	queue_work(system_highpri_wq, &buf->rb_refresh_worker);
 }
-- 
2.34.1

