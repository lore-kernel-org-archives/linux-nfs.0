Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.216
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793674905;
	b=fsowTaAAAWJc/ET+SSc76wbHJqhmRBzzFHhox4f/yyXVbkEw/QyX0wmjIDXwHgs+8N2m
	 amCglYgPt8GFfnKGHqti/gBFDHraiBxh+N9MXNYyhYCWyLfRcJ6mj+XIV4hf1sjS4Gm56
	 kQk6h9cJ4wbBNyN0g2+hjjDM1fxjqagawTxb4HzdxUwdHfVTcmJefvHb+n5z7v+1CJONd
	 duGOMnCfJ7YWSi6Dw+TCROATcnXkUN/EuFLVS6J2bp0ezLxqzFSAs0qNUVnTHEP9pIeBT
	 PT6fASOolrQjuBN0uiQDCYmnSAjAKGcNFVzmZmUXvwWJCT1Xr4hla1Kh/unovFT91mA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793674905;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=CUqEUnKXjfRj9VD0h9+0LVtQFP2zO/t/r0iBKuXT7H4=;
	b=5R+3Dul5jjIBtoUdha727w3cBfHHTi4BPW6b8zkItldX5gUtcAp8BDsWhsvbczoR81zK
	 7Oq2e4BK5w8uuBL0LL09BmkZspVxLBdUZcCPDQrZeue4cak7gEEWir8VPzM9wlzJIjKxv
	 d2dGMwnGfDfEOnyNyLK7r5zOSBVGL88FqwszEtSCxQ2mUMNK/tt1SlnZYkDaTa+j0G0rk
	 /OyZ4NzaOZXJviNbdWtu9mKBsqmETxHtkfisrmO1ap0EiFIzMkWuc4MCpzg0dRO1QfdDh
	 UYVOdkgdqIYXE7oiRiuLvPTgWhf6wnyJonrh7mjWcc1/ORCuFT2qqlMxktVEeECOaGA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	arc=none smtp.remote-ip=113.46.200.216
Received: from canpmsgout01.his.huawei.com (canpmsgout01.his.huawei.com [113.46.200.216])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0979D606A329;
	Tue,  3 Nov 2026 03:01:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0979D606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=CUqEUnKXjfRj9VD0h9+0LVtQFP2zO/t/r0iBKuXT7H4=;
	b=inzlCOSziLJHXP7sEwio7Hyt+L1cwMRvwNQkc/lGk5nVvlmQ7PijNqs6n6IxCRSq7NfHxTnQ+
	ureO40iLkkMomTsuh2tdSestNXy0iw7NFErwIQy9b0afNo1nGoJTi7Hb3c8hZw4oUonFuQnm1P9
	GX/cAYol6xeNlM0WPqqyecY=
Received: from mail.maildlp.com (unknown [172.19.163.0])
	by canpmsgout01.his.huawei.com (SkyGuard) with ESMTPS id 4jJYHj66DWz1T4Md;
	Tue,  3 Nov 2026 11:01:21 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id B511740537;
	Tue,  3 Nov 2026 11:01:39 +0800 (CST)
Received: from huawei.com (10.50.85.128) by whupemk300014.china.huawei.com
 (7.152.185.8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Tue, 3 Nov
 2026 11:01:38 +0800
From: Li Xiasong <lixiasong1@huawei.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<stable@vger.kernel.org>, <yuehaibing@huawei.com>,
	<zhangchangzhong@huawei.com>, <weiyongjun1@huawei.com>
Subject: [PATCH v2 2/3] rpcrdma: Pin notifications during removal callbacks
Date: Tue, 3 Nov 2026 11:27:57 +0800
Message-ID: <20261103032758.1302493-3-lixiasong1@huawei.com>
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

rpcrdma_remove_one() can race with unregister and invoke a notification
callback after its owner is freed. XArray RCU does not pin stored objects.

Pin notification owners under rpcrdma_device_mutex and serialize
unregister with the same lock. Also pin client RPC transports. Skip
owners in final release with kref_get_unless_zero().

Invoke rn_done and release references outside the mutex. Track references
separately so partial acquisition can be unwound without accessing freed
owners or waiting for XPRT_LOCKED under the device mutex.

Fixes: 7e86845a0346 ("rpcrdma: Implement generic device removal")
Signed-off-by: Li Xiasong <lixiasong1@huawei.com>
---
 include/linux/sunrpc/rdma_rn.h           | 29 ++++++++++++-
 net/sunrpc/xprtrdma/ib_client.c          | 54 +++++++++++++++++++++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 21 ++++++++-
 net/sunrpc/xprtrdma/verbs.c              | 34 ++++++++++++++-
 4 files changed, 128 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/rdma_rn.h b/include/linux/sunrpc/rdma_rn.h
index 7d032ca057af..1b3e0989b3a5 100644
--- a/include/linux/sunrpc/rdma_rn.h
+++ b/include/linux/sunrpc/rdma_rn.h
@@ -8,17 +8,42 @@
 
 #include <rdma/ib_verbs.h>
 
+struct rpc_xprt;
+
+/**
+ * struct rpcrdma_notification_ref - references acquired for a notification
+ * @rr_owner: pinned notification owner, or NULL if not acquired
+ * @rr_xprt: optional RPC transport reference, or NULL if not acquired
+ *
+ * The record is initialized to zero before rn_get(). Record all acquired
+ * references here, including on partial failure, for release by rn_put().
+ */
+struct rpcrdma_notification_ref {
+	void			*rr_owner;
+	struct rpc_xprt		*rr_xprt;
+};
+
 /**
- * rpcrdma_notification - request removal notification
+ * struct rpcrdma_notification - request removal notification
+ * @rn_done: device removal callback
+ * @rn_get: acquire references as described in rpcrdma_rn_register()
+ * @rn_put: release references as described in rpcrdma_rn_register()
+ * @rn_index: index of this notification in the device's XArray
  */
 struct rpcrdma_notification {
 	void			(*rn_done)(struct rpcrdma_notification *rn);
+	bool			(*rn_get)(struct rpcrdma_notification *rn,
+					  struct rpcrdma_notification_ref *ref);
+	void			(*rn_put)(struct rpcrdma_notification_ref *ref);
 	u32			rn_index;
 };
 
 int rpcrdma_rn_register(struct ib_device *device,
 			struct rpcrdma_notification *rn,
-			void (*done)(struct rpcrdma_notification *rn));
+			void (*done)(struct rpcrdma_notification *rn),
+			bool (*get)(struct rpcrdma_notification *rn,
+				    struct rpcrdma_notification_ref *ref),
+			void (*put)(struct rpcrdma_notification_ref *ref));
 void rpcrdma_rn_unregister(struct ib_device *device,
 			   struct rpcrdma_notification *rn);
 int rpcrdma_ib_client_register(void);
diff --git a/net/sunrpc/xprtrdma/ib_client.c b/net/sunrpc/xprtrdma/ib_client.c
index 23ab1dfcb230..6fa72996209a 100644
--- a/net/sunrpc/xprtrdma/ib_client.c
+++ b/net/sunrpc/xprtrdma/ib_client.c
@@ -52,6 +52,18 @@ static struct rpcrdma_device *rpcrdma_get_client_data(struct ib_device *device)
  * @device: device to monitor
  * @rn: notification object that wishes to be notified
  * @done: callback to notify caller of device removal
+ * @get: callback to acquire a notification object reference
+ * @put: callback to release references acquired by @get
+ *
+ * @get runs under rpcrdma_device_mutex. On success, it must pin both
+ * the object embedding @rn and its registration until the returned
+ * reference is released. The owner must not call rpcrdma_rn_unregister()
+ * while that pin is held. @get must record all acquired references,
+ * including on partial failure, in &struct rpcrdma_notification_ref.
+ *
+ * @get returns true if @done can be invoked. @put releases any acquired
+ * references outside rpcrdma_device_mutex, even if @get returns false,
+ * and must not access an unpinned @rn.
  *
  * Returns zero on success. The callback in rn_done is guaranteed
  * to be invoked when the device is removed, unless this notification
@@ -67,7 +79,10 @@ static struct rpcrdma_device *rpcrdma_get_client_data(struct ib_device *device)
  */
 int rpcrdma_rn_register(struct ib_device *device,
 			struct rpcrdma_notification *rn,
-			void (*done)(struct rpcrdma_notification *rn))
+			void (*done)(struct rpcrdma_notification *rn),
+			bool (*get)(struct rpcrdma_notification *rn,
+				    struct rpcrdma_notification_ref *ref),
+			void (*put)(struct rpcrdma_notification_ref *ref))
 {
 	struct rpcrdma_device *rd;
 	int ret = -ENETUNREACH;
@@ -87,8 +102,12 @@ int rpcrdma_rn_register(struct ib_device *device,
 	 * value would unregister an @rn that was never inserted.
 	 */
 	rn->rn_done = done;
+	rn->rn_get = get;
+	rn->rn_put = put;
 	if (xa_alloc(&rd->rd_xa, &rn->rn_index, rn, xa_limit_32b, GFP_KERNEL) < 0) {
 		rn->rn_done = NULL;
+		rn->rn_get = NULL;
+		rn->rn_put = NULL;
 		ret = -ENOMEM;
 		goto out_unlock;
 	}
@@ -117,14 +136,18 @@ static void rpcrdma_rn_release(struct kref *kref)
  * It is safe to call this on an @rn whose registration never
  * completed or failed; rn_done == NULL is treated as
  * never-registered and the call is a no-op.
+ *
+ * Context: May sleep. Takes rpcrdma_device_mutex.
  */
 void rpcrdma_rn_unregister(struct ib_device *device,
 			   struct rpcrdma_notification *rn)
 {
-	struct rpcrdma_device *rd = rpcrdma_get_client_data(device);
+	struct rpcrdma_device *rd;
 
+	mutex_lock(&rpcrdma_device_mutex);
+	rd = rpcrdma_get_client_data(device);
 	if (!rd)
-		return;
+		goto out_unlock;
 
 	/*
 	 * rn_done is the registration sentinel: rpcrdma_rn_register
@@ -138,12 +161,16 @@ void rpcrdma_rn_unregister(struct ib_device *device,
 	 * rd_kref.
 	 */
 	if (!rn->rn_done)
-		return;
+		goto out_unlock;
 	rn->rn_done = NULL;
+	rn->rn_get = NULL;
+	rn->rn_put = NULL;
 
 	trace_rpcrdma_client_unregister(device, rn);
 	xa_erase(&rd->rd_xa, rn->rn_index);
 	kref_put(&rd->rd_kref, rpcrdma_rn_release);
+out_unlock:
+	mutex_unlock(&rpcrdma_device_mutex);
 }
 
 /**
@@ -186,15 +213,30 @@ static void rpcrdma_remove_one(struct ib_device *device,
 {
 	struct rpcrdma_device *rd = client_data;
 	struct rpcrdma_notification *rn;
+	void (*done)(struct rpcrdma_notification *rn);
+	void (*put)(struct rpcrdma_notification_ref *ref);
 	unsigned long index;
 
 	trace_rpcrdma_client_remove_one(device);
 
 	mutex_lock(&rpcrdma_device_mutex);
 	set_bit(RPCRDMA_RD_F_REMOVING, &rd->rd_flags);
+	xa_for_each(&rd->rd_xa, index, rn) {
+		struct rpcrdma_notification_ref ref = {};
+		bool notify;
+
+		notify = rn->rn_get(rn, &ref);
+		if (!ref.rr_owner && !ref.rr_xprt)
+			continue;
+		done = notify ? rn->rn_done : NULL;
+		put = rn->rn_put;
+		mutex_unlock(&rpcrdma_device_mutex);
+		if (done)
+			done(rn);
+		put(&ref);
+		mutex_lock(&rpcrdma_device_mutex);
+	}
 	mutex_unlock(&rpcrdma_device_mutex);
-	xa_for_each(&rd->rd_xa, index, rn)
-		rn->rn_done(rn);
 
 	/*
 	 * Wait only if there are still outstanding notification
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index f949601b2144..ff3545570859 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -424,6 +424,24 @@ static void svc_rdma_xprt_done(struct rpcrdma_notification *rn)
 	svc_xprt_close(&rdma->sc_xprt);
 }
 
+static void svc_rdma_xprt_put(struct rpcrdma_notification_ref *ref)
+{
+	if (ref->rr_owner)
+		svc_xprt_put(ref->rr_owner);
+}
+
+static bool svc_rdma_xprt_get(struct rpcrdma_notification *rn,
+			      struct rpcrdma_notification_ref *ref)
+{
+	struct svcxprt_rdma *rdma = container_of(rn, struct svcxprt_rdma,
+						 sc_rn);
+
+	if (!kref_get_unless_zero(&rdma->sc_xprt.xpt_ref))
+		return false;
+	ref->rr_owner = &rdma->sc_xprt;
+	return true;
+}
+
 /*
  * This is the xpo_recvfrom function for listening endpoints. Its
  * purpose is to accept incoming connections. The CMA callback handler
@@ -464,7 +482,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	dev = newxprt->sc_cm_id->device;
 	newxprt->sc_port_num = newxprt->sc_cm_id->port_num;
 
-	if (rpcrdma_rn_register(dev, &newxprt->sc_rn, svc_rdma_xprt_done))
+	if (rpcrdma_rn_register(dev, &newxprt->sc_rn, svc_rdma_xprt_done,
+				svc_rdma_xprt_get, svc_rdma_xprt_put))
 		goto errout;
 
 	newxprt->sc_max_req_size = svcrdma_max_req_size;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 54957295a631..69d1796bb4f3 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -297,6 +297,35 @@ static void rpcrdma_ep_removal_done(struct rpcrdma_notification *rn)
 	xprt_force_disconnect(ep->re_xprt);
 }
 
+static void rpcrdma_ep_removal_put(struct rpcrdma_notification_ref *ref)
+{
+	struct rpcrdma_ep *ep = ref->rr_owner;
+	struct rpc_xprt *xprt = ref->rr_xprt;
+
+	if (ep) {
+		struct rdma_cm_id *id = ep->re_id;
+
+		if (rpcrdma_ep_put(ep))
+			rdma_destroy_id(id);
+	}
+	xprt_put(xprt);
+}
+
+static bool rpcrdma_ep_removal_get(struct rpcrdma_notification *rn,
+				   struct rpcrdma_notification_ref *ref)
+{
+	struct rpcrdma_ep *ep = container_of(rn, struct rpcrdma_ep, re_rn);
+	struct rpc_xprt *xprt = ep->re_xprt;
+
+	if (!xprt_get(xprt))
+		return false;
+	ref->rr_xprt = xprt;
+	if (!kref_get_unless_zero(&ep->re_kref))
+		return false;
+	ref->rr_owner = ep;
+	return true;
+}
+
 static struct rdma_cm_id *rpcrdma_create_id(struct rpcrdma_xprt *r_xprt,
 					    struct rpcrdma_ep *ep)
 {
@@ -337,7 +366,10 @@ static struct rdma_cm_id *rpcrdma_create_id(struct rpcrdma_xprt *r_xprt,
 		goto out;
 
 	ep->re_id = id;
-	rc = rpcrdma_rn_register(id->device, &ep->re_rn, rpcrdma_ep_removal_done);
+	rc = rpcrdma_rn_register(id->device, &ep->re_rn,
+				 rpcrdma_ep_removal_done,
+				 rpcrdma_ep_removal_get,
+				 rpcrdma_ep_removal_put);
 	if (rc)
 		goto out;
 
-- 
2.34.1

