Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.216
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792758234;
	b=XQoceLn755tdCNa88toehDj/v+9rl9Gbx+5v2pdhg8l/29fQkUMnAMFkxmbcUKy4XjwY
	 w3YnVgiLtOLeiOICVufN4B0QAWvKjQq5nYZM8Gi2HyV9jhUQiN1XGt8sUJEKZOdSoJWLA
	 JsqbEXMP6Bsr+opP8Tyu3zmPqe7aNsyKDB5n9FXfo91e6zZQBl2ZoKN/wsOy9VBeNKD0k
	 F4RlR2fjJSB5UOHyCqITwZOsx516f8jkms+6kM/+rmqzOgH48n9heXPSk/LWUQ6ORSyPt
	 34Et/n2g1K9EhZ3AEdLnYAoYanorhDFFfw+jxeS5qm2sTNp30tMEorPwEoSAzhk5GFA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792758234;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=IDwsudFjq8zPgLTHcKW9eOQxRNwNB2HryEoG7263A1A=;
	b=1k7rRv/on0zyX64JiARgnfv6IUNfPLHoloxktOpkB0Hj6kOtOmTOsvW1FdduRTYrLxJN
	 bOg4pkOfxZ7NiDPM09sdccfbfjb5XPQc7vNdBQnFFNi5qSDzG7JtNZpESvlTkIOumafLq
	 Z+2TAqaJfEG9TofqPQWM0Ylht1Kqr0yd6y1049G7Tkvdb/eF7PPZxvYOuClIoN04Fpszm
	 W7b/JRwjy/jC1lrmcHSFU3Cy+XnzzebwGHlMt6H8XAYGmy3+4ANyQnK8G5PaABmO7n7jP
	 Xhl8i9QEH+p5yrQfPTk2PyQQYbWy9n1EnkxaUS2uLY61Aa4JSVrr03tTFqo+nZ4KRqw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=gAuYR3hA;
	arc=none smtp.remote-ip=113.46.200.216
Received: from canpmsgout01.his.huawei.com (canpmsgout01.his.huawei.com [113.46.200.216])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ADC96606A31B;
	Fri, 23 Oct 2026 12:23:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org ADC96606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=gAuYR3hA
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=IDwsudFjq8zPgLTHcKW9eOQxRNwNB2HryEoG7263A1A=;
	b=gAuYR3hAryTEVfBm9FrEAgjgKjFo7We2okmunUkhe2/hQNW4f4uIutIQzgBE+KDYs5/ZyBaOz
	wwqJoWCdQ+tc6ok43vUe5+KorImS7VMQlpGbkKz9xwdIydFWiUqA4q1MbhJDigT6RmK4kGSfYWX
	JhroGoMUyHsjfc12cHoG98E=
Received: from mail.maildlp.com (unknown [172.19.162.197])
	by canpmsgout01.his.huawei.com (SkyGuard) with ESMTPS id 4jB2Hh4kpnz1T4G4;
	Fri, 23 Oct 2026 20:23:44 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id 5A53D40579;
	Fri, 23 Oct 2026 20:23:47 +0800 (CST)
Received: from huawei.com (10.50.85.128) by whupemk300014.china.huawei.com
 (7.152.185.8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Fri, 23 Oct
 2026 20:23:46 +0800
From: Li Xiasong <lixiasong1@huawei.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<stable@vger.kernel.org>, <yuehaibing@huawei.com>,
	<zhangchangzhong@huawei.com>, <weiyongjun1@huawei.com>
Subject: [PATCH 1/3] rpcrdma: Serialize notification registration with device removal
Date: Fri, 23 Oct 2026 20:50:31 +0800
Message-ID: <20261023125033.528835-2-lixiasong1@huawei.com>
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
 net/sunrpc/xprtrdma/ib_client.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/ib_client.c b/net/sunrpc/xprtrdma/ib_client.c
index 188f7a13397f..acd5db729539 100644
--- a/net/sunrpc/xprtrdma/ib_client.c
+++ b/net/sunrpc/xprtrdma/ib_client.c
@@ -9,6 +9,7 @@
 #include <linux/types.h>
 #include <linux/kref.h>
 #include <linux/completion.h>
+#include <linux/mutex.h>
 
 #include <linux/sunrpc/svc_rdma.h>
 #include <linux/sunrpc/rdma_rn.h>
@@ -28,6 +29,7 @@ struct rpcrdma_device {
 #define RPCRDMA_RD_F_REMOVING	(0)
 
 static struct ib_client rpcrdma_ib_client;
+static DEFINE_MUTEX(rpcrdma_device_mutex);
 
 /*
  * Listeners have no associated device, so we never register them.
@@ -61,10 +63,13 @@ int rpcrdma_rn_register(struct ib_device *device,
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
@@ -78,11 +83,15 @@ int rpcrdma_rn_register(struct ib_device *device,
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
@@ -173,7 +182,9 @@ static void rpcrdma_remove_one(struct ib_device *device,
 
 	trace_rpcrdma_client_remove_one(device);
 
+	mutex_lock(&rpcrdma_device_mutex);
 	set_bit(RPCRDMA_RD_F_REMOVING, &rd->rd_flags);
+	mutex_unlock(&rpcrdma_device_mutex);
 	xa_for_each(&rd->rd_xa, index, rn)
 		rn->rn_done(rn);
 
@@ -187,8 +198,11 @@ static void rpcrdma_remove_one(struct ib_device *device,
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

