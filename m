Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.227
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792758234;
	b=VQvZNXYbqc+ZHDSACkz5JPc++LUn977VhKoW7bd0lUXWjrbojodUC2cvYEK/bZYfzwd3
	 aDZprcvoToo3VYeb73ZVGz6adc3uLtpFnl2Vsf+UOuR93+qc7FSegzbt/eAuG2WkqVr81
	 OpDoJTZPyhPPvFBKcaVdm2t2BZ2aQ/Dc9DlwjEYzPEfz+QJGq7ARwCn0LSw7GjlsgH2zL
	 360e3CergeJzuFVWrA6cDT9XQDSWoRH78IFMdd/wrpYrcZ1o1QbDpDjOcnKunb49Ky92o
	 OrHc6wylz09cUzBgnJx+a2Exw4GfvCBXr3Y1yektdCm8CwXnE4uTlJO0My2OQrS6n5Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792758234;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=REv/d4lAWN3CGSu3GJjlOiLw27vQpCyhET+ePW3KO1Y=;
	b=MYAdLv8OzxgVUcFPXyphzUmb9TJKy6lRxzJZEd9lM0xjXVNPF5P2YDMm78zI/0Z1MRyC
	 TXWqGrt6V+os7n57p+r0tp8SE37M3jOuQUY1bECvXxGiFE5tJj2cDWWvn4eUooUOGwoE2
	 RePF5agZfwD58YfyouQbZ15u0V0mI69KcpnnoQIIX1wiIlFna5Ciokfoyh21BiHNzkDcg
	 Ia1CapeDVykFF53xUMarE1qom+EYroJhWmkYMCA7UBv0FH7L8FeH3TMT7O2U046dViDiD
	 hIUx/YKi0v1aIJMTWfKsXgkkNU93GgGzQuwF3GVky9DzRlnj5CjHr/Kv15mzXWZSsYw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=hVQU9cx+;
	arc=none smtp.remote-ip=113.46.200.227
Received: from canpmsgout12.his.huawei.com (canpmsgout12.his.huawei.com [113.46.200.227])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D07CD606A31E;
	Fri, 23 Oct 2026 12:23:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D07CD606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=hVQU9cx+
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=REv/d4lAWN3CGSu3GJjlOiLw27vQpCyhET+ePW3KO1Y=;
	b=hVQU9cx+Rc0P8lJG23NyO+I9+3X5GD15uxRyjqWb4CA9TKKetMhTbE3CLO3xb0/SjMZcjEZwq
	/yhqjcFH8/lxF36DRB5EWXp48x8cSFTZfy4L/vpKZ8dNStLX8SIJJND+Gz/XKluy+D6p/QS3bkR
	McTygQEahB1RGHdYD5LBZ6c=
Received: from mail.maildlp.com (unknown [172.19.163.127])
	by canpmsgout12.his.huawei.com (SkyGuard) with ESMTPS id 4jB2Hr3XdPznTb6;
	Fri, 23 Oct 2026 20:23:52 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id 941CB40572;
	Fri, 23 Oct 2026 20:23:49 +0800 (CST)
Received: from huawei.com (10.50.85.128) by whupemk300014.china.huawei.com
 (7.152.185.8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Fri, 23 Oct
 2026 20:23:48 +0800
From: Li Xiasong <lixiasong1@huawei.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<stable@vger.kernel.org>, <yuehaibing@huawei.com>,
	<zhangchangzhong@huawei.com>, <weiyongjun1@huawei.com>
Subject: [PATCH 3/3] xprtrdma: Wake connect worker on device removal
Date: Fri, 23 Oct 2026 20:50:33 +0800
Message-ID: <20261023125033.528835-4-lixiasong1@huawei.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20261023125033.528835-1-lixiasong1@huawei.com>
References: <20261023125033.528835-1-lixiasong1@huawei.com>
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
X-ClientProxiedBy: kwepems500001.china.huawei.com (7.221.188.70) To
 whupemk300014.china.huawei.com (7.152.185.8)

The RDMA device removal notification replaced handling of
RDMA_CM_EVENT_DEVICE_REMOVAL in the CM event handler. The removal
callback now only forces the transport to disconnect. If the connect
worker is waiting for re_connect_status to become non-zero, it cannot
release the endpoint until a CM event wakes it.

Set re_connect_status to -ENODEV and wake the connect worker when the
endpoint is not established. For an established endpoint, release its
reference from the first event that changes the connection state. RDMA
CMA does not send a later DISCONNECTED event after entering
RDMA_CM_DEVICE_REMOVAL, and ADDR_CHANGE changes the status before its
DISCONNECTED event arrives. Use atomic state transitions so these paths
release the reference only once.

Return the endpoint put result from ESTABLISHED error paths so CMA can
destroy the CM ID when the last reference is released. Initialize
re_connect_wait before registering the removal notification.

Fixes: 3f4eb9ff9234 ("xprtrdma: Handle device removal outside of the CM event handler")
Signed-off-by: Li Xiasong <lixiasong1@huawei.com>
---
 net/sunrpc/xprtrdma/verbs.c | 41 +++++++++++++++++++++++++++----------
 1 file changed, 30 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 9b00e71c80a7..ff65bb9e28ff 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -229,6 +229,7 @@ static int
 rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 {
 	struct rpcrdma_ep *ep = id->context;
+	int status;
 
 	might_sleep();
 
@@ -251,16 +252,21 @@ rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 		case 0:
 			goto wake_connect_worker;
 		case 1:
-			/* The later DISCONNECTED event balances the
-			 * ESTABLISHED get; do not put here.
-			 */
 			rpcrdma_force_disconnect(ep);
-			return 0;
+			return rpcrdma_ep_put(ep);
 		}
 		return 0;
 	case RDMA_CM_EVENT_ESTABLISHED:
 		rpcrdma_ep_get(ep);
-		ep->re_connect_status = 1;
+		switch (cmpxchg(&ep->re_connect_status, 0, 1)) {
+		case 0:
+			break;
+		case -ENODEV:
+			rpcrdma_force_disconnect(ep);
+			return rpcrdma_ep_put(ep);
+		default:
+			return rpcrdma_ep_put(ep);
+		}
 		rpcrdma_update_cm_private(ep, &event->param.conn);
 		trace_xprtrdma_inline_thresh(ep);
 		wake_up_all(&ep->re_connect_wait);
@@ -279,9 +285,11 @@ rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 		wake_up_all(&ep->re_connect_wait);
 		return 0;
 	case RDMA_CM_EVENT_DISCONNECTED:
-		ep->re_connect_status = -ECONNABORTED;
+		status = xchg(&ep->re_connect_status, -ECONNABORTED);
 		rpcrdma_force_disconnect(ep);
-		return rpcrdma_ep_put(ep);
+		if (status == 1)
+			return rpcrdma_ep_put(ep);
+		return 0;
 	default:
 		break;
 	}
@@ -294,7 +302,18 @@ static void rpcrdma_ep_removal_done(struct rpcrdma_notification *rn)
 	struct rpcrdma_ep *ep = container_of(rn, struct rpcrdma_ep, re_rn);
 
 	trace_xprtrdma_device_removal(ep->re_id);
-	xprt_force_disconnect(ep->re_xprt);
+	switch (xchg(&ep->re_connect_status, -ENODEV)) {
+	case 0:
+		wake_up_all(&ep->re_connect_wait);
+		break;
+	case 1:
+		rpcrdma_force_disconnect(ep);
+		/* DEVICE_REMOVAL prevents a later DISCONNECTED event. */
+		rpcrdma_ep_put(ep);
+		break;
+	default:
+		break;
+	}
 }
 
 static bool rpcrdma_ep_removal_get(struct rpcrdma_notification *rn)
@@ -420,6 +439,7 @@ static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 		return -ENOTCONN;
 	ep->re_xprt = &r_xprt->rx_xprt;
 	kref_init(&ep->re_kref);
+	init_waitqueue_head(&ep->re_connect_wait);
 
 	id = rpcrdma_create_id(r_xprt, ep);
 	if (IS_ERR(id)) {
@@ -447,7 +467,6 @@ static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 
 	ep->re_send_batch = ep->re_max_requests >> 3;
 	ep->re_send_count = ep->re_send_batch;
-	init_waitqueue_head(&ep->re_connect_wait);
 
 	ep->re_attr.send_cq = ib_alloc_cq_any(device, r_xprt,
 					      ep->re_attr.cap.max_send_wr,
@@ -514,8 +533,8 @@ static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 	return 0;
 
 out_destroy:
-	rpcrdma_ep_put(ep);
-	rdma_destroy_id(id);
+	if (rpcrdma_ep_put(ep))
+		rdma_destroy_id(id);
 	return rc;
 }
 
-- 
2.34.1

