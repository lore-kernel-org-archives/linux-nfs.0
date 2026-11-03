Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.219
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793674904;
	b=Z3cEuwZlYTzcQnWr6iOMV7qfNzNHl8BAZzh0QRsHys+x6B3kjMF7ye5cOhR1tERDtiZa
	 JEzoTg5gqpOtK4MM2vVUGu8rr0oECCqPJ1WC15DcnQRSwHDgk9Z7Xv0dshSCJ2RrUZTK4
	 2F0dw97L4LitagTVpVG9lnng491dV14oxScSiSnWePWtZhdDKo2M2yV6iRI+C1EP5vf8B
	 0AhRGmPoRdlokmbz8R98JdY+Iq3ICOy3jsaahG0/2MoEPXkoooqXMrgrPEYDMHa631/EZ
	 JLBSJzH8+ueK4+EzorFSuG4oyGEfU0Y8kmjNenVupHEJaoGox9+JCcYaOyhaFQLBwOQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793674904;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=kIwTw4lYIB5MWsOEzSta9fxTnlqIytVjc6n1kXnGQ2U=;
	b=wSUcQWJxb6MuE3DVVvBczhOxbmkiAFnviZD3aAf5q1axsQxqJYPSecDubGlyQA2FTrvw
	 +zJWHrn93uJ2RSvLONzwxM2bvqYOBzX9dmokCdOgrSAG9VS68aCHZL2hsaKq4NOD5+ZSm
	 4vwApRlaautqOxyQ6EQFZw5KuU7/oMnBB/aGummwsbo7xrQ6EUPm3ZeFw0gEXvTR9+6kv
	 yyjof6ibi1TZpxIQxaEeiyawvsIBPptdvK5rN07SVIMxEi8iMj4zjsBtAHnWs/esuUOTe
	 ZLwmgDtd6cytjILAiKO6NRM6c7cGkoVk2XCs96P1cx9sMI4lsab7gcE/N3i1UphBmMA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=kSVQzPXZ;
	arc=none smtp.remote-ip=113.46.200.219
Received: from canpmsgout04.his.huawei.com (canpmsgout04.his.huawei.com [113.46.200.219])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49639606A326;
	Tue,  3 Nov 2026 03:01:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 49639606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=kSVQzPXZ
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=kIwTw4lYIB5MWsOEzSta9fxTnlqIytVjc6n1kXnGQ2U=;
	b=kSVQzPXZPfWeYp0bWFg0eYL1fZJWeqW1M/KsQsgN/4zDkjIjvMDX0noruLwR0+rNusqVgDZgj
	lqSh2fRZk53kceVgSPv64nkWdA3pD/KrPrdyYZsVuTPuUHzvlNLT8ntVF8FvXa3gwcrTtgtzBoC
	MKQXOgHin3tLKn1XUbODnhc=
Received: from mail.maildlp.com (unknown [172.19.163.104])
	by canpmsgout04.his.huawei.com (SkyGuard) with ESMTPS id 4jJYHy5FFDz1prKx;
	Tue,  3 Nov 2026 11:01:34 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id 8D1204056E;
	Tue,  3 Nov 2026 11:01:38 +0800 (CST)
Received: from huawei.com (10.50.85.128) by whupemk300014.china.huawei.com
 (7.152.185.8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Tue, 3 Nov
 2026 11:01:37 +0800
From: Li Xiasong <lixiasong1@huawei.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<stable@vger.kernel.org>, <yuehaibing@huawei.com>,
	<zhangchangzhong@huawei.com>, <weiyongjun1@huawei.com>
Subject: [PATCH v2 1/3] rpcrdma: Serialize notification registration with device removal
Date: Tue, 3 Nov 2026 11:27:56 +0800
Message-ID: <20261103032758.1302493-2-lixiasong1@huawei.com>
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

rpcrdma_rn_register() checks RPCRDMA_RD_F_REMOVING before publishing the
notification and taking a reference on the rpcrdma_device. Nothing
serializes these operations with rpcrdma_remove_one(). Device removal
can therefore free the private data after the check but before xa_alloc()
or kref_get(), resulting in a use-after-free. It can also finish its
notification walk before a new registration is published, leaving the
removal path waiting for a registrant that was never notified.

Use a module-wide mutex to protect the client-data lookup, removal-state
check, notification publication and reference acquisition against the
transition to REMOVING. Clear client-data under the same mutex before
destroying the XArray and freeing the private data, so a later lookup
cannot return a stale pointer. Keep notification callbacks and completion
waits outside the critical sections.

Fixes: 7e86845a0346 ("rpcrdma: Implement generic device removal")
Signed-off-by: Li Xiasong <lixiasong1@huawei.com>
---
 net/sunrpc/xprtrdma/ib_client.c | 30 ++++++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/ib_client.c b/net/sunrpc/xprtrdma/ib_client.c
index 188f7a13397f..23ab1dfcb230 100644
--- a/net/sunrpc/xprtrdma/ib_client.c
+++ b/net/sunrpc/xprtrdma/ib_client.c
@@ -9,6 +9,7 @@
 #include <linux/types.h>
 #include <linux/kref.h>
 #include <linux/completion.h>
+#include <linux/mutex.h>
 
 #include <linux/sunrpc/svc_rdma.h>
 #include <linux/sunrpc/rdma_rn.h>
@@ -28,6 +29,11 @@ struct rpcrdma_device {
 #define RPCRDMA_RD_F_REMOVING	(0)
 
 static struct ib_client rpcrdma_ib_client;
+/*
+ * Serialize registration with the removal transition and client-data teardown.
+ * Invoke rn_done callbacks and wait for completion outside this mutex.
+ */
+static DEFINE_MUTEX(rpcrdma_device_mutex);
 
 /*
  * Listeners have no associated device, so we never register them.
@@ -56,15 +62,20 @@ static struct rpcrdma_device *rpcrdma_get_client_data(struct ib_device *device)
  * cleared again if xa_alloc fails), so the @rn may safely be
  * passed to rpcrdma_rn_unregister() without a separate
  * registered/unregistered flag in the caller.
+ *
+ * Context: May sleep. Takes rpcrdma_device_mutex.
  */
 int rpcrdma_rn_register(struct ib_device *device,
 			struct rpcrdma_notification *rn,
 			void (*done)(struct rpcrdma_notification *rn))
 {
-	struct rpcrdma_device *rd = rpcrdma_get_client_data(device);
+	struct rpcrdma_device *rd;
+	int ret = -ENETUNREACH;
 
+	mutex_lock(&rpcrdma_device_mutex);
+	rd = rpcrdma_get_client_data(device);
 	if (!rd || test_bit(RPCRDMA_RD_F_REMOVING, &rd->rd_flags))
-		return -ENETUNREACH;
+		goto out_unlock;
 
 	/*
 	 * Arm rn_done before xa_alloc() publishes @rn: once @rn is
@@ -78,11 +89,15 @@ int rpcrdma_rn_register(struct ib_device *device,
 	rn->rn_done = done;
 	if (xa_alloc(&rd->rd_xa, &rn->rn_index, rn, xa_limit_32b, GFP_KERNEL) < 0) {
 		rn->rn_done = NULL;
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto out_unlock;
 	}
 	kref_get(&rd->rd_kref);
 	trace_rpcrdma_client_register(device, rn);
-	return 0;
+	ret = 0;
+out_unlock:
+	mutex_unlock(&rpcrdma_device_mutex);
+	return ret;
 }
 
 static void rpcrdma_rn_release(struct kref *kref)
@@ -163,6 +178,8 @@ static int rpcrdma_add_one(struct ib_device *device)
  *
  * Upon return, all transports associated with @device have divested
  * themselves from IB hardware resources.
+ *
+ * Context: May sleep. Takes rpcrdma_device_mutex.
  */
 static void rpcrdma_remove_one(struct ib_device *device,
 			       void *client_data)
@@ -173,7 +190,9 @@ static void rpcrdma_remove_one(struct ib_device *device,
 
 	trace_rpcrdma_client_remove_one(device);
 
+	mutex_lock(&rpcrdma_device_mutex);
 	set_bit(RPCRDMA_RD_F_REMOVING, &rd->rd_flags);
+	mutex_unlock(&rpcrdma_device_mutex);
 	xa_for_each(&rd->rd_xa, index, rn)
 		rn->rn_done(rn);
 
@@ -187,8 +206,11 @@ static void rpcrdma_remove_one(struct ib_device *device,
 	}
 
 	trace_rpcrdma_client_remove_one_done(device);
+	mutex_lock(&rpcrdma_device_mutex);
+	ib_set_client_data(device, &rpcrdma_ib_client, NULL);
 	xa_destroy(&rd->rd_xa);
 	kfree(rd);
+	mutex_unlock(&rpcrdma_device_mutex);
 }
 
 static struct ib_client rpcrdma_ib_client = {
-- 
2.34.1

