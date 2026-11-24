Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.218
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795485201;
	b=OoIvHPCeALIgUcgr1VwC2vVgdSGHS3e80T0QPDRX6L5Rmfn7hktwxaht9rG4ImhRvcfw
	 CIiff0skpjTyrkRVvmhalfngwFHaVvhv3jlgtKRTP/30rlv/kZrg5j+KgMe/Kjz5asQyM
	 Ul7y/c4rs2wvlSkmNUhRZDm5vwjP30ECLoWT9Z15hOjvK5b6C50tWdSNJnLmgaD6QD073
	 jVs88NNO6v1EqgcBOZw2suGo8boNyCp5xBOiT3ujmG+iv55x98wPTezVFbIajg6qX0EDt
	 4nrBJ6Svc3xbnLk8Cy2MNs6cA1iEE1YxZqeUkcvlqdEjzhpGZM0hTnoCdJcc/fRv2+Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795485201;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=pzXP1xvuChIRpzUx7yKxvOtXSYT/dGX/q2L9jIUScxo=;
	b=HJu5G5DhjNNmDhp6sx9LUTjwnkG7mLo2jWaMqkQaEfPDg1AO1oplzw55RkmqBp9SWO14
	 7gbiO9NhR2aii0+34S5RqJ6f6HNK+5Jvn/V1F75lNcdbpfFOuyRQ/KaRKPUO0Y4O2tSUa
	 /eGjuuEMCVlzvK87PU0eHLfsgBggicr7uhh3Veqvod78A7BYbHwnmnxJhBdHIkFlv8jJP
	 UYNqDIRpFvL6di417LrVqOj9vGYOJfcYoF0oS9fXU6wYeBNdPRiTWAGJDbZ7Njgy143VA
	 K7cKtE6f5WadJWt4ZsuGICeiAh9YYjmIcyfRtCn5pzvUVm70QS4DfVDhLCuOIAUmf7g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=nTPGpw89;
	arc=none smtp.remote-ip=113.46.200.218
Received: from canpmsgout03.his.huawei.com (canpmsgout03.his.huawei.com [113.46.200.218])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 91312606A31E;
	Tue, 24 Nov 2026 01:53:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 91312606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=nTPGpw89
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=pzXP1xvuChIRpzUx7yKxvOtXSYT/dGX/q2L9jIUScxo=;
	b=nTPGpw89Ed9Z/NuLYQ0MN2TukdSVoK86R+hxLAe7Qh8Ye1Wbne3QuyTNpz/jAOls/003cbtcO
	LfOeFjB/0ElSz16ukC2R8lkd3OLs/LFv1U/E95GuDHGhgIgaoQGYopP+RKkyqql9WkdERWjqXVz
	byc9d7QQY38u5wlKcrZ/43g=
Received: from mail.maildlp.com (unknown [172.19.163.0])
	by canpmsgout03.his.huawei.com (SkyGuard) with ESMTPS id 4jYQmJ3D8HzpSvq;
	Tue, 24 Nov 2026 09:52:16 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id 7397740561;
	Tue, 24 Nov 2026 09:53:16 +0800 (CST)
Received: from huawei.com (10.50.85.128) by whupemk300014.china.huawei.com
 (7.152.185.8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Tue, 24 Nov
 2026 09:53:15 +0800
From: Li Xiasong <lixiasong1@huawei.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<stable@vger.kernel.org>, <yuehaibing@huawei.com>,
	<zhangchangzhong@huawei.com>, <weiyongjun1@huawei.com>
Subject: [PATCH v3 1/3] rpcrdma: Serialize notification registration with device removal
Date: Tue, 24 Nov 2026 10:18:40 +0800
Message-ID: <20261124021842.130141-2-lixiasong1@huawei.com>
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

Registration can race with device removal between the client-data
lookup, the removing-state check, XArray publication and device
reference acquisition. Serialize these operations and client-data
teardown with a module-wide mutex, keeping callbacks and completion
waits outside it.

Enter a NOIO allocation scope before taking the mutex to prevent reclaim
from waiting for RPC I/O on a transport whose reconnect needs the same
mutex.

Fixes: 7e86845a0346 ("rpcrdma: Implement generic device removal")
Signed-off-by: Li Xiasong <lixiasong1@huawei.com>
---
 net/sunrpc/xprtrdma/ib_client.c | 47 +++++++++++++++++++++++++--------
 1 file changed, 36 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/ib_client.c b/net/sunrpc/xprtrdma/ib_client.c
index 188f7a13397f..23fbaf406a22 100644
--- a/net/sunrpc/xprtrdma/ib_client.c
+++ b/net/sunrpc/xprtrdma/ib_client.c
@@ -9,6 +9,8 @@
 #include <linux/types.h>
 #include <linux/kref.h>
 #include <linux/completion.h>
+#include <linux/mutex.h>
+#include <linux/sched/mm.h>
 
 #include <linux/sunrpc/svc_rdma.h>
 #include <linux/sunrpc/rdma_rn.h>
@@ -28,6 +30,11 @@ struct rpcrdma_device {
 #define RPCRDMA_RD_F_REMOVING	(0)
 
 static struct ib_client rpcrdma_ib_client;
+/*
+ * Serialize registration with the removal transition and client-data teardown.
+ * Invoke rn_done callbacks and wait for completion outside this mutex.
+ */
+static DEFINE_MUTEX(rpcrdma_device_mutex);
 
 /*
  * Listeners have no associated device, so we never register them.
@@ -56,33 +63,44 @@ static struct rpcrdma_device *rpcrdma_get_client_data(struct ib_device *device)
  * cleared again if xa_alloc fails), so the @rn may safely be
  * passed to rpcrdma_rn_unregister() without a separate
  * registered/unregistered flag in the caller.
+ *
+ * Context: May sleep. Takes rpcrdma_device_mutex in a NOIO allocation scope.
  */
 int rpcrdma_rn_register(struct ib_device *device,
 			struct rpcrdma_notification *rn,
 			void (*done)(struct rpcrdma_notification *rn))
 {
-	struct rpcrdma_device *rd = rpcrdma_get_client_data(device);
+	struct rpcrdma_device *rd;
+	unsigned int noio_flags;
+	int ret = -ENETUNREACH;
 
+	/* Reclaim must not wait for RPC I/O on a transport whose reconnect
+	 * needs this mutex to register its notification.
+	 */
+	noio_flags = memalloc_noio_save();
+	mutex_lock(&rpcrdma_device_mutex);
+	rd = rpcrdma_get_client_data(device);
 	if (!rd || test_bit(RPCRDMA_RD_F_REMOVING, &rd->rd_flags))
-		return -ENETUNREACH;
+		goto out_unlock;
 
 	/*
-	 * Arm rn_done before xa_alloc() publishes @rn: once @rn is
-	 * visible in rd_xa, a concurrent rpcrdma_remove_one() can
-	 * call rn->rn_done(), so the pointer must already be set.
-	 *
-	 * Restore NULL if xa_alloc() fails. rn_done doubles as the
-	 * registration sentinel for rpcrdma_rn_unregister(); a stale
-	 * value would unregister an @rn that was never inserted.
+	 * The removal walk cannot see @rn until registration drops the
+	 * device mutex. Clear rn_done if xa_alloc() fails so unregister
+	 * does not treat @rn as registered.
 	 */
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
+	memalloc_noio_restore(noio_flags);
+	return ret;
 }
 
 static void rpcrdma_rn_release(struct kref *kref)
@@ -163,6 +181,8 @@ static int rpcrdma_add_one(struct ib_device *device)
  *
  * Upon return, all transports associated with @device have divested
  * themselves from IB hardware resources.
+ *
+ * Context: May sleep. Takes rpcrdma_device_mutex.
  */
 static void rpcrdma_remove_one(struct ib_device *device,
 			       void *client_data)
@@ -173,7 +193,9 @@ static void rpcrdma_remove_one(struct ib_device *device,
 
 	trace_rpcrdma_client_remove_one(device);
 
+	mutex_lock(&rpcrdma_device_mutex);
 	set_bit(RPCRDMA_RD_F_REMOVING, &rd->rd_flags);
+	mutex_unlock(&rpcrdma_device_mutex);
 	xa_for_each(&rd->rd_xa, index, rn)
 		rn->rn_done(rn);
 
@@ -187,8 +209,11 @@ static void rpcrdma_remove_one(struct ib_device *device,
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

