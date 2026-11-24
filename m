Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.216
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795485201;
	b=xt9kS1x1qD6msjuWl/l1/ZAwkXQmErLwMTE4sUWb+nYuKAR3c2KGr84UGkA2wAHv3Lwr
	 HEzQl1QpkgRzvcZ2ZLp0cg05nnS8Om+bOtxSNvawhCjDdy9M8kEB0ocARSXmJW84cqGgj
	 QKOzVcDDH6+Jt4zk6eLNNn4zBe0ZPpWk0oCwFrA5O3g5DGcSwkvhNNQOyMJpKcU6yuWln
	 h2Zt+EbfDbnYYSTSZUDt9NLOdITorPIdKQ3ZKmWzK2NhTRCvNVs672rPvdnAXOofhZxEv
	 2uDVhqXpai3t8CvyCccNNKcCLH4bya/7/WhIfHf40CYmalTiIcLDUw+s9WqfBuKjf+A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795485201;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=LEHCIVoE30K/qbjPwLweWuSiq1DHY9MAhn/v2cmmdQc=;
	b=XkOcjHiLZUDsW/X1j8SdlVwi4G2sItt3f9TvrvgKYNkp6UdYLEZVlbFddgFlCDDpPu9f
	 in2DHLyzlDUD9WvJVehsHnn8hQ0V/4MbDBRAugRmXnz2Ic2MN41nYaTOGzfvARLe5yX3l
	 p74Qza2c7D2JaCG1nzxqg3ZS6RpmZMqORTSv82uivS+LY9U9qDCOjaIJbniQdo6sOd+Xo
	 a9LzzWhY5HVoz90ttSoPgnxONxfs9QAQ754HNBZCD+81QDB8+i6+qSQ5gAY6r3DW8fQ1R
	 yT8sGAhYl7b3lhvTUFdodUPKEyvwBFUssEx6h9tAzomyZOYRskpwItrpiXVJpXjYclA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=Sy3nGYbL;
	arc=none smtp.remote-ip=113.46.200.216
Received: from canpmsgout01.his.huawei.com (canpmsgout01.his.huawei.com [113.46.200.216])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B7A76606A322;
	Tue, 24 Nov 2026 01:53:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B7A76606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=Sy3nGYbL
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=LEHCIVoE30K/qbjPwLweWuSiq1DHY9MAhn/v2cmmdQc=;
	b=Sy3nGYbL7gFL2+LvUToyCI2XNJ6S9MxrEGhSLL0QfxG/Vhd33K2OnQOKPHz4jZqrGZDBoQkfz
	krPhxZNu/DWLRHIXtrRnJCRGzekatHXWmbGirqsr+rHgGyX07FcT7/GSr8mZ3+t4jE8wiSBmAOi
	pdeF2+dMgZWwJB31R6UKCpU=
Received: from mail.maildlp.com (unknown [172.19.162.140])
	by canpmsgout01.his.huawei.com (SkyGuard) with ESMTPS id 4jYQmY54fVz1T4kX;
	Tue, 24 Nov 2026 09:52:29 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id 8986320333;
	Tue, 24 Nov 2026 09:53:17 +0800 (CST)
Received: from huawei.com (10.50.85.128) by whupemk300014.china.huawei.com
 (7.152.185.8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Tue, 24 Nov
 2026 09:53:16 +0800
From: Li Xiasong <lixiasong1@huawei.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<stable@vger.kernel.org>, <yuehaibing@huawei.com>,
	<zhangchangzhong@huawei.com>, <weiyongjun1@huawei.com>
Subject: [PATCH v3 2/3] rpcrdma: Serialize removal callbacks with unregister
Date: Tue, 24 Nov 2026 10:18:41 +0800
Message-ID: <20261124021842.130141-3-lixiasong1@huawei.com>
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

The device removal walk does not pin notification owners, so unregister
can remove and free an owner before its callback is invoked. Run short
removal callbacks under the device mutex and serialize unregister with
that mutex.

Pin the server transport with kref_get_unless_zero() and close it outside
the mutex using svc_xprt_close(). This avoids recursive unregister while
preserving direct deletion of idle transports if a pool loses its last
worker. Wake both SQ waitqueues before dropping the reference, and let
zero-ref transports finish their existing final-release path.

Pin the client transport during its callback and release the reference
outside the mutex, since the final xprt_put can wait for a connect
worker that needs the mutex.

Fixes: 7e86845a0346 ("rpcrdma: Implement generic device removal")
Signed-off-by: Li Xiasong <lixiasong1@huawei.com>
---
 include/linux/sunrpc/rdma_rn.h           | 27 +++++++++++++--
 net/sunrpc/xprtrdma/ib_client.c          | 43 +++++++++++++++++++-----
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 24 +++++++++++--
 net/sunrpc/xprtrdma/verbs.c              | 22 ++++++++++--
 4 files changed, 101 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/rdma_rn.h b/include/linux/sunrpc/rdma_rn.h
index 7d032ca057af..2861122bfd7a 100644
--- a/include/linux/sunrpc/rdma_rn.h
+++ b/include/linux/sunrpc/rdma_rn.h
@@ -9,16 +9,37 @@
 #include <rdma/ib_verbs.h>
 
 /**
- * rpcrdma_notification - request removal notification
+ * struct rpcrdma_notification_release - cleanup after a removal callback
+ * @release: optional cleanup to invoke outside the device mutex
+ * @data: independently owned argument passed to @release
+ *
+ * Initialized to zero before rn_done(). The callback may pass an independent
+ * reference to @release, which runs after the device mutex is dropped. The
+ * hook owns that reference and may drop it on its last use of @data, even if
+ * that frees the object before the hook returns. Neither @release nor @data
+ * may depend on the notification remaining registered or its owner staying
+ * alive beyond the lifetime guaranteed by the reference.
+ */
+struct rpcrdma_notification_release {
+	void			(*release)(void *data);
+	void			*data;
+};
+
+/**
+ * struct rpcrdma_notification - request removal notification
+ * @rn_done: device removal callback
+ * @rn_index: index of this notification in the device's XArray
  */
 struct rpcrdma_notification {
-	void			(*rn_done)(struct rpcrdma_notification *rn);
+	void			(*rn_done)(struct rpcrdma_notification *rn,
+					   struct rpcrdma_notification_release *release);
 	u32			rn_index;
 };
 
 int rpcrdma_rn_register(struct ib_device *device,
 			struct rpcrdma_notification *rn,
-			void (*done)(struct rpcrdma_notification *rn));
+			void (*done)(struct rpcrdma_notification *rn,
+				     struct rpcrdma_notification_release *release));
 void rpcrdma_rn_unregister(struct ib_device *device,
 			   struct rpcrdma_notification *rn);
 int rpcrdma_ib_client_register(void);
diff --git a/net/sunrpc/xprtrdma/ib_client.c b/net/sunrpc/xprtrdma/ib_client.c
index 23fbaf406a22..c44cbbad63ca 100644
--- a/net/sunrpc/xprtrdma/ib_client.c
+++ b/net/sunrpc/xprtrdma/ib_client.c
@@ -31,8 +31,8 @@ struct rpcrdma_device {
 
 static struct ib_client rpcrdma_ib_client;
 /*
- * Serialize registration with the removal transition and client-data teardown.
- * Invoke rn_done callbacks and wait for completion outside this mutex.
+ * Serialize registration, notification callbacks, unregister and client-data
+ * teardown. Reference release and completion waits run outside this mutex.
  */
 static DEFINE_MUTEX(rpcrdma_device_mutex);
 
@@ -54,6 +54,14 @@ static struct rpcrdma_device *rpcrdma_get_client_data(struct ib_device *device)
  * @rn: notification object that wishes to be notified
  * @done: callback to notify caller of device removal
  *
+ * @done runs under rpcrdma_device_mutex, serialized with unregister. It must
+ * not sleep or call the registration interfaces. The owner must unregister
+ * before freeing @rn or any resources accessed by @done.
+ *
+ * @done may return an independently owned reference in the zero-initialized
+ * &struct rpcrdma_notification_release. Its release callback runs outside
+ * the mutex and must not access @rn or unpinned owner resources.
+ *
  * Returns zero on success. The callback in rn_done is guaranteed
  * to be invoked when the device is removed, unless this notification
  * is unregistered first.
@@ -68,7 +76,8 @@ static struct rpcrdma_device *rpcrdma_get_client_data(struct ib_device *device)
  */
 int rpcrdma_rn_register(struct ib_device *device,
 			struct rpcrdma_notification *rn,
-			void (*done)(struct rpcrdma_notification *rn))
+			void (*done)(struct rpcrdma_notification *rn,
+				     struct rpcrdma_notification_release *release))
 {
 	struct rpcrdma_device *rd;
 	unsigned int noio_flags;
@@ -120,14 +129,22 @@ static void rpcrdma_rn_release(struct kref *kref)
  * It is safe to call this on an @rn whose registration never
  * completed or failed; rn_done == NULL is treated as
  * never-registered and the call is a no-op.
+ * Upon return, rn_done() is not running and cannot start for @rn.
+ * Resources used by rn_done() must remain valid until this returns.
+ * This does not wait for the independent release hook, which may still
+ * run or start after this returns.
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
@@ -141,12 +158,14 @@ void rpcrdma_rn_unregister(struct ib_device *device,
 	 * rd_kref.
 	 */
 	if (!rn->rn_done)
-		return;
+		goto out_unlock;
 	rn->rn_done = NULL;
 
 	trace_rpcrdma_client_unregister(device, rn);
 	xa_erase(&rd->rd_xa, rn->rn_index);
 	kref_put(&rd->rd_kref, rpcrdma_rn_release);
+out_unlock:
+	mutex_unlock(&rpcrdma_device_mutex);
 }
 
 /**
@@ -195,9 +214,17 @@ static void rpcrdma_remove_one(struct ib_device *device,
 
 	mutex_lock(&rpcrdma_device_mutex);
 	set_bit(RPCRDMA_RD_F_REMOVING, &rd->rd_flags);
+	xa_for_each(&rd->rd_xa, index, rn) {
+		struct rpcrdma_notification_release release = {};
+
+		rn->rn_done(rn, &release);
+		if (!release.release)
+			continue;
+		mutex_unlock(&rpcrdma_device_mutex);
+		release.release(release.data);
+		mutex_lock(&rpcrdma_device_mutex);
+	}
 	mutex_unlock(&rpcrdma_device_mutex);
-	xa_for_each(&rd->rd_xa, index, rn)
-		rn->rn_done(rn);
 
 	/*
 	 * Wait only if there are still outstanding notification
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index f949601b2144..003a9259a51a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -43,6 +43,7 @@
  */
 
 #include <linux/interrupt.h>
+#include <linux/kref.h>
 #include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
@@ -414,14 +415,33 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 	return &cma_xprt->sc_xprt;
 }
 
-static void svc_rdma_xprt_done(struct rpcrdma_notification *rn)
+/* Run outside rpcrdma_device_mutex: close and the final put can unregister. */
+static void svc_rdma_xprt_close(void *data)
+{
+	struct svc_xprt *xprt = data;
+	struct svcxprt_rdma *rdma = container_of(xprt, struct svcxprt_rdma,
+						 sc_xprt);
+
+	/* Idle transports must close even if a pool loses its last worker. */
+	svc_xprt_close(xprt);
+	wake_up_all(&rdma->sc_sq_ticket_wait);
+	wake_up_all(&rdma->sc_send_wait);
+	svc_xprt_put(xprt);
+}
+
+static void svc_rdma_xprt_done(struct rpcrdma_notification *rn,
+			       struct rpcrdma_notification_release *release)
 {
 	struct svcxprt_rdma *rdma = container_of(rn, struct svcxprt_rdma,
 						 sc_rn);
 	struct rdma_cm_id *id = rdma->sc_cm_id;
 
 	trace_svcrdma_device_removal(id);
-	svc_xprt_close(&rdma->sc_xprt);
+	/* A zero refcount means svc_rdma_free() is already unregistering. */
+	if (!kref_get_unless_zero(&rdma->sc_xprt.xpt_ref))
+		return;
+	release->release = svc_rdma_xprt_close;
+	release->data = &rdma->sc_xprt;
 }
 
 /*
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 620afff79eff..b8dfdabd8a5a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -289,12 +289,30 @@ rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 	return 0;
 }
 
-static void rpcrdma_ep_removal_done(struct rpcrdma_notification *rn)
+/* Drop the reference acquired by rpcrdma_ep_removal_done() outside the mutex. */
+static void rpcrdma_xprt_removal_put(void *data)
+{
+	xprt_put(data);
+}
+
+static void rpcrdma_ep_removal_done(struct rpcrdma_notification *rn,
+				    struct rpcrdma_notification_release *release)
 {
 	struct rpcrdma_ep *ep = container_of(rn, struct rpcrdma_ep, re_rn);
+	struct rpc_xprt *xprt;
 
 	trace_xprtrdma_device_removal(ep->re_id);
-	xprt_force_disconnect(ep->re_xprt);
+	/*
+	 * Pin the transport while the removal callback runs. Release the
+	 * reference outside rpcrdma_device_mutex: a final xprt_put() can wait
+	 * for the connect worker, which may need the mutex to unregister.
+	 */
+	xprt = xprt_get(ep->re_xprt);
+	if (!xprt)
+		return;
+	release->release = rpcrdma_xprt_removal_put;
+	release->data = xprt;
+	rpcrdma_force_disconnect(ep);
 }
 
 static struct rdma_cm_id *rpcrdma_create_id(struct rpcrdma_xprt *r_xprt,
-- 
2.34.1

