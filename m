Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.217
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792758234;
	b=yfNdhnOnvUq7TJX4/otyTRpbF6nTQCYlw3RNzxgwAl2y11Pp+NeGMZD4hLIpBZvFWeZu
	 ZwmnaKMpwlj6yN7KUU8tP8ffTP+/DDlXmT+RpjFtK7hKG/w3oAplVrhO78qtj4jroGEIl
	 UFbDg8QMmn+/eJY4jpjd2Uxw+YIhZ94cIy/o7PZVzOObUMR/osGT+GxMIhwIrvU2N55Sa
	 Cgow3I9Uza7isfuv6OKm2j5OZLolMguFke1vpL3gRN6tOyxRIV0PCfUAqYJxaD0Gsy/ZC
	 75KSMDfrCUqyAMpZX0yaLbREL4M4GMYAyBknrDCmnb8BFyguXr9+9fQZCeErcb56aiw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792758234;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=iAeXz7OjiAqm59M3LReE5optzvKxikP8fCiO7kzrdQc=;
	b=SzMozoyouy1o6R9sbv//T/PRzzIbCrP30BC+4n3fwKjqvbgfSLe3QKonVVqaerniFAs3
	 K2he5PEdaSFau846NqOELtWuhbLakyNwcCBz6jndVzI5gyNHjOaKIoj48WfoiYfHQLOy0
	 p9lWlbd2vFrZVQFGFX0JvQf+eT/jTfSKX4d5+doJe97/cR3q0foeMeQ67f7pLbtZxR6ww
	 bSdgHURT+kfRdm9j327uFQjJw6znQThHcvc8rYStFhAOjm9GG2BzSXayVJQ36ukemUQxy
	 kEEtKvj3YOGZeIPyo54a3a8+DXyzMt/v9DKRhGT+fIG+lF6OzcB7PpSJOtT+HN8zKFA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=EpSV6h2Y;
	arc=none smtp.remote-ip=113.46.200.217
Received: from canpmsgout02.his.huawei.com (canpmsgout02.his.huawei.com [113.46.200.217])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4A292606A31A;
	Fri, 23 Oct 2026 12:23:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4A292606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=EpSV6h2Y
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=iAeXz7OjiAqm59M3LReE5optzvKxikP8fCiO7kzrdQc=;
	b=EpSV6h2Y19HXutPR7BwMhrYHoGPVbM5RBy9ZuUbpmP6tJHL6u4j9IFaFnvTi+bknyShndgvdH
	PMR8V8BERctKFBiVvMRpxD4w6b/VqeGu0RP6Ub1NZezP8BwRcDa3yBShcTsBsFxZ0c1n9eS1Wwy
	9UeiSanmN90PSODesSbStzw=
Received: from mail.maildlp.com (unknown [172.19.163.104])
	by canpmsgout02.his.huawei.com (SkyGuard) with ESMTPS id 4jB2Hg4bNtzcZyB;
	Fri, 23 Oct 2026 20:23:43 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id 72A6E4058E;
	Fri, 23 Oct 2026 20:23:48 +0800 (CST)
Received: from huawei.com (10.50.85.128) by whupemk300014.china.huawei.com
 (7.152.185.8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Fri, 23 Oct
 2026 20:23:47 +0800
From: Li Xiasong <lixiasong1@huawei.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<stable@vger.kernel.org>, <yuehaibing@huawei.com>,
	<zhangchangzhong@huawei.com>, <weiyongjun1@huawei.com>
Subject: [PATCH 2/3] rpcrdma: Pin notifications during removal callbacks
Date: Fri, 23 Oct 2026 20:50:32 +0800
Message-ID: <20261023125033.528835-3-lixiasong1@huawei.com>
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

rpcrdma_remove_one() obtains notification pointers from rd_xa and
invokes their callbacks without preventing a concurrent unregister from
freeing the object that embeds the notification. The XArray internal RCU
protection keeps its nodes valid, but does not extend the lifetime of
stored objects.

Add get and put operations to each notification. Acquire a reference
while holding rpcrdma_device_mutex, then drop the mutex around the
callback and release the reference afterwards. Serialize unregister
with the same mutex so either removal pins the object first or unregister
removes it before the walk can find it.

Use kref_get_unless_zero() so a notification whose owner has already
entered its final release is skipped. The removal path then waits for
that owner to unregister and release the rpcrdma_device reference.

Fixes: 7e86845a0346 ("rpcrdma: Implement generic device removal")
Signed-off-by: Li Xiasong <lixiasong1@huawei.com>
---
 include/linux/sunrpc/rdma_rn.h           |  6 ++++-
 net/sunrpc/xprtrdma/ib_client.c          | 34 +++++++++++++++++++-----
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 19 ++++++++++++-
 net/sunrpc/xprtrdma/verbs.c              | 21 ++++++++++++++-
 4 files changed, 71 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/rdma_rn.h b/include/linux/sunrpc/rdma_rn.h
index 7d032ca057af..6122af607120 100644
--- a/include/linux/sunrpc/rdma_rn.h
+++ b/include/linux/sunrpc/rdma_rn.h
@@ -13,12 +13,16 @@
  */
 struct rpcrdma_notification {
 	void			(*rn_done)(struct rpcrdma_notification *rn);
+	bool			(*rn_get)(struct rpcrdma_notification *rn);
+	void			(*rn_put)(struct rpcrdma_notification *rn);
 	u32			rn_index;
 };
 
 int rpcrdma_rn_register(struct ib_device *device,
 			struct rpcrdma_notification *rn,
-			void (*done)(struct rpcrdma_notification *rn));
+			void (*done)(struct rpcrdma_notification *rn),
+			bool (*get)(struct rpcrdma_notification *rn),
+			void (*put)(struct rpcrdma_notification *rn));
 void rpcrdma_rn_unregister(struct ib_device *device,
 			   struct rpcrdma_notification *rn);
 int rpcrdma_ib_client_register(void);
diff --git a/net/sunrpc/xprtrdma/ib_client.c b/net/sunrpc/xprtrdma/ib_client.c
index acd5db729539..651ed6637000 100644
--- a/net/sunrpc/xprtrdma/ib_client.c
+++ b/net/sunrpc/xprtrdma/ib_client.c
@@ -48,6 +48,8 @@ static struct rpcrdma_device *rpcrdma_get_client_data(struct ib_device *device)
  * @device: device to monitor
  * @rn: notification object that wishes to be notified
  * @done: callback to notify caller of device removal
+ * @get: callback to acquire a notification object reference
+ * @put: callback to release a notification object reference
  *
  * Returns zero on success. The callback in rn_done is guaranteed
  * to be invoked when the device is removed, unless this notification
@@ -61,7 +63,9 @@ static struct rpcrdma_device *rpcrdma_get_client_data(struct ib_device *device)
  */
 int rpcrdma_rn_register(struct ib_device *device,
 			struct rpcrdma_notification *rn,
-			void (*done)(struct rpcrdma_notification *rn))
+			void (*done)(struct rpcrdma_notification *rn),
+			bool (*get)(struct rpcrdma_notification *rn),
+			void (*put)(struct rpcrdma_notification *rn))
 {
 	struct rpcrdma_device *rd;
 	int ret = -ENETUNREACH;
@@ -81,8 +85,12 @@ int rpcrdma_rn_register(struct ib_device *device,
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
@@ -115,10 +123,12 @@ static void rpcrdma_rn_release(struct kref *kref)
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
@@ -132,12 +142,16 @@ void rpcrdma_rn_unregister(struct ib_device *device,
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
@@ -178,15 +192,23 @@ static void rpcrdma_remove_one(struct ib_device *device,
 {
 	struct rpcrdma_device *rd = client_data;
 	struct rpcrdma_notification *rn;
+	void (*done)(struct rpcrdma_notification *rn);
 	unsigned long index;
 
 	trace_rpcrdma_client_remove_one(device);
 
 	mutex_lock(&rpcrdma_device_mutex);
 	set_bit(RPCRDMA_RD_F_REMOVING, &rd->rd_flags);
+	xa_for_each(&rd->rd_xa, index, rn) {
+		if (!rn->rn_get(rn))
+			continue;
+		done = rn->rn_done;
+		mutex_unlock(&rpcrdma_device_mutex);
+		done(rn);
+		rn->rn_put(rn);
+		mutex_lock(&rpcrdma_device_mutex);
+	}
 	mutex_unlock(&rpcrdma_device_mutex);
-	xa_for_each(&rd->rd_xa, index, rn)
-		rn->rn_done(rn);
 
 	/*
 	 * Wait only if there are still outstanding notification
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 927269598ac2..93beef3a2c69 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -424,6 +424,22 @@ static void svc_rdma_xprt_done(struct rpcrdma_notification *rn)
 	svc_xprt_close(&rdma->sc_xprt);
 }
 
+static bool svc_rdma_xprt_get(struct rpcrdma_notification *rn)
+{
+	struct svcxprt_rdma *rdma = container_of(rn, struct svcxprt_rdma,
+						 sc_rn);
+
+	return kref_get_unless_zero(&rdma->sc_xprt.xpt_ref);
+}
+
+static void svc_rdma_xprt_put(struct rpcrdma_notification *rn)
+{
+	struct svcxprt_rdma *rdma = container_of(rn, struct svcxprt_rdma,
+						 sc_rn);
+
+	svc_xprt_put(&rdma->sc_xprt);
+}
+
 /*
  * This is the xpo_recvfrom function for listening endpoints. Its
  * purpose is to accept incoming connections. The CMA callback handler
@@ -464,7 +480,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	dev = newxprt->sc_cm_id->device;
 	newxprt->sc_port_num = newxprt->sc_cm_id->port_num;
 
-	if (rpcrdma_rn_register(dev, &newxprt->sc_rn, svc_rdma_xprt_done))
+	if (rpcrdma_rn_register(dev, &newxprt->sc_rn, svc_rdma_xprt_done,
+				svc_rdma_xprt_get, svc_rdma_xprt_put))
 		goto errout;
 
 	newxprt->sc_max_req_size = svcrdma_max_req_size;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index be335eed329d..9b00e71c80a7 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -297,6 +297,22 @@ static void rpcrdma_ep_removal_done(struct rpcrdma_notification *rn)
 	xprt_force_disconnect(ep->re_xprt);
 }
 
+static bool rpcrdma_ep_removal_get(struct rpcrdma_notification *rn)
+{
+	struct rpcrdma_ep *ep = container_of(rn, struct rpcrdma_ep, re_rn);
+
+	return kref_get_unless_zero(&ep->re_kref);
+}
+
+static void rpcrdma_ep_removal_put(struct rpcrdma_notification *rn)
+{
+	struct rpcrdma_ep *ep = container_of(rn, struct rpcrdma_ep, re_rn);
+	struct rdma_cm_id *id = ep->re_id;
+
+	if (rpcrdma_ep_put(ep))
+		rdma_destroy_id(id);
+}
+
 static struct rdma_cm_id *rpcrdma_create_id(struct rpcrdma_xprt *r_xprt,
 					    struct rpcrdma_ep *ep)
 {
@@ -337,7 +353,10 @@ static struct rdma_cm_id *rpcrdma_create_id(struct rpcrdma_xprt *r_xprt,
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

