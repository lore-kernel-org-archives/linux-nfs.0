Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.226
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793880995;
	b=P/f3EKUlV+rGnX91MoaeS0cHexjblzzU+q3sjWL3L67qr7frK+TIY4LDPefp3iHzt28l
	 306ygaGqe3DuA0Nk5SLQPAqvDzTW8FdtWzm/2Jbqe6k40BqAeli6mZSchAdX+uxg8lfG6
	 Aa2WdzbSKUzJviZyLHPE46scLF+rsUyvUXZz3MgpzhNAoqTcdOCP7fgY99CeoGWF/5LrR
	 vWkfPnrfCaDeOLQhYoDX+zlekOJEDnOJDEoyLS4kHE7t8ygNM8xGqBjOh3DkbyxdqYfqO
	 +XY0uPwKAeiMnGwJC8rCCQSbbAHpMBBTqtJC5T8iHXAszkWG4tRqLPS0UFwVDGAY3Tw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793880995;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=FR0CVYf3ZhKJVeeFARswIucyAg2Az0MxrmGaHgkKG9A=;
	b=3AKY5iDJieOGhwfYwqyQAkvlZHMDLPlJ9AFpIFKz+kDE6zCIwMMwHMhuJDJhlWq5OlS3
	 AzUEec6aSu8SP0aukP1jk/wA7EFkDQZdcp7ZrEnKZhLGYlHLFEMHRLmTz/SRE/MWINPCP
	 qvXrTWdnQgFWTD4PSwZXcUgDspNzjwZvzBTid9ZIvSs10xy+bL97BwO+k5wlLI0I36ZhX
	 mvqHkg4Y7nsKWHBO3f9Y/yv7lhiR9n82aLEpdmP6gAEQi9+gEMCKL1Xmp+tpEVzV7eUPp
	 9yDS99R4SyjsTk8uVZPKoLQCRIbwEtuZKFebnZQ8Z96NDWBo1azxiUo0NPHBiSE1jtA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=utH8JaMi;
	arc=none smtp.remote-ip=113.46.200.226
Received: from canpmsgout11.his.huawei.com (canpmsgout11.his.huawei.com [113.46.200.226])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5EB6606A333;
	Thu,  5 Nov 2026 12:16:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E5EB6606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=utH8JaMi
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=FR0CVYf3ZhKJVeeFARswIucyAg2Az0MxrmGaHgkKG9A=;
	b=utH8JaMiyhTZVRegagDy91k3MFeZKma0NdXqPJsP7ADZk80bU/drUK0NzsODGxKUwqnkMzob2
	pPCvHVAGoCmO7NPCp6N+ypjj/2TxqerkP31Up2gfK1Q5ATg+UxR9PMrfmsEPv7KKeOTzEKk8kXe
	vjZsdefqW5TWz+A5vg8uzDk=
Received: from mail.maildlp.com (unknown [172.19.162.92])
	by canpmsgout11.his.huawei.com (SkyGuard) with ESMTPS id 4jL1W46MTrzKm6Y;
	Thu,  5 Nov 2026 20:16:16 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id 38FC040565;
	Thu,  5 Nov 2026 20:16:23 +0800 (CST)
Received: from huawei.com (10.50.85.128) by whupemk300014.china.huawei.com
 (7.152.185.8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Thu, 5 Nov
 2026 20:16:21 +0800
From: Li Xiasong <lixiasong1@huawei.com>
To: <stable@vger.kernel.org>, Chuck Lever <cel@kernel.org>, Anna Schumaker
	<anna@kernel.org>
CC: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
	<tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, Chris Mason
	<clm@meta.com>, <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<yuehaibing@huawei.com>, <zhangchangzhong@huawei.com>,
	<weiyongjun1@huawei.com>
Subject: [RFC PATCH 6.6.y] xprtrdma: Fix endpoint leak after address change and device removal
Date: Thu, 5 Nov 2026 20:42:24 +0800
Message-ID: <20261105124224.4051975-1-lixiasong1@huawei.com>
X-Mailer: git-send-email 2.34.1
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

Commit a562485c359d ("xprtrdma: Fix ep kref imbalance on ADDR_CHANGE")
is the linux-6.6.y backport of af9b65b29af34. It leaves the ESTABLISHED
reference outstanding after ADDR_CHANGE and relies on a subsequent
DISCONNECTED event to release it.

However, linux-6.6.y still handles DEVICE_REMOVAL in the CM event
handler. Consider the following sequence on an established connection:

  ESTABLISHED:    acquire the connection reference, status = 1
  ADDR_CHANGE:    set status = -ENODEV and request asynchronous close
  DEVICE_REMOVAL: observe status = -ENODEV, skip the disconnected path

Before invoking the DEVICE_REMOVAL callback, the CMA sets the CM ID state
to RDMA_CM_DEVICE_REMOVAL. cma_ib_handler() then filters subsequent
IB CM disconnect events. The DEVICE_REMOVAL handler has skipped the
put, and no DISCONNECTED notification is delivered to RPC/RDMA to
release the ESTABLISHED reference.

The drain and owner puts leave one endpoint reference outstanding.
rpcrdma_xprt_disconnect() clears rx_ep without destroying the endpoint
or its CM ID, leaking the endpoint and its remaining RDMA resources.
This can also prevent device removal from completing.

This is a linux-6.6.y-specific backport regression: this branch
combines the updated ADDR_CHANGE handling with the older CM-based
device removal path. Earlier stable branches have not received this
ADDR_CHANGE change, while upstream and stable branches based on
v6.11 or later handle device removal outside the CM event handler.
There is therefore no corresponding upstream commit for this fix.

Track the outstanding ESTABLISHED reference independently of the
connection status. On DEVICE_REMOVAL or DISCONNECTED, clear the
flag before dropping the reference so that it is released at most
once, even if earlier events have changed the connection status.
The flag is initially clear in the zero-initialized endpoint, and
all accesses are serialized by the CM ID's handler mutex.

Fixes: a562485c359d ("xprtrdma: Fix ep kref imbalance on ADDR_CHANGE")
Signed-off-by: Li Xiasong <lixiasong1@huawei.com>
---

This RFC is based on linux-6.6.y at v6.6.161.

The upstream device removal mechanism was introduced by:

  7e86845a0346 ("rpcrdma: Implement generic device removal")
  3f4eb9ff9234 ("xprtrdma: Handle device removal outside of the CM event handler")

I have kept this RFC limited to reference accounting in the existing
linux-6.6.y teardown paths. Backporting the generic mechanism would
also change per-device registration, module initialization and
teardown synchronization, and would require reviewing its dependencies
and follow-up fixes. Keeping the fix local avoids introducing those
additional lifecycle changes into the stable branch.

Would this localized fix be appropriate for linux-6.6.y? I'd appreciate
your feedback on the reference accounting, or any suggestions for a
simpler way to address the regression.

 net/sunrpc/xprtrdma/verbs.c     | 15 ++++++++++-----
 net/sunrpc/xprtrdma/xprt_rdma.h |  2 ++
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4990e37bcdc0..5b5179aa2adf 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -250,17 +250,18 @@ rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 	case RDMA_CM_EVENT_DEVICE_REMOVAL:
 		pr_info("rpcrdma: removing device %s for %pISpc\n",
 			ep->re_id->device->name, sap);
-		switch (xchg(&ep->re_connect_status, -ENODEV)) {
-		case 0: goto wake_connect_worker;
-		case 1: goto disconnected;
-		}
+		if (xchg(&ep->re_connect_status, -ENODEV) == 0)
+			goto wake_connect_worker;
+		/* CMA suppresses subsequent DISCONNECTED events after removal. */
+		if (ep->re_connect_ref)
+			goto disconnected;
 		return 0;
 	case RDMA_CM_EVENT_ADDR_CHANGE:
 		switch (xchg(&ep->re_connect_status, -ENODEV)) {
 		case 0:
 			goto wake_connect_worker;
 		case 1:
-			/* The later DISCONNECTED event balances the
+			/* DISCONNECTED or DEVICE_REMOVAL balances the
 			 * ESTABLISHED get; do not put here.
 			 */
 			rpcrdma_force_disconnect(ep);
@@ -269,6 +270,7 @@ rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 		return 0;
 	case RDMA_CM_EVENT_ESTABLISHED:
 		rpcrdma_ep_get(ep);
+		ep->re_connect_ref = true;
 		ep->re_connect_status = 1;
 		rpcrdma_update_cm_private(ep, &event->param.conn);
 		trace_xprtrdma_inline_thresh(ep);
@@ -291,6 +293,9 @@ rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 		ep->re_connect_status = -ECONNABORTED;
 disconnected:
 		rpcrdma_force_disconnect(ep);
+		if (!ep->re_connect_ref)
+			return 0;
+		ep->re_connect_ref = false;
 		return rpcrdma_ep_put(ep);
 	default:
 		break;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c78734e93c71..4a3ce78bb90c 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -84,6 +84,8 @@ struct rpcrdma_ep {
 	unsigned int		re_max_inline_recv;
 	int			re_async_rc;
 	int			re_connect_status;
+	/* Outstanding ESTABLISHED reference; protected by CM handler mutex */
+	bool			re_connect_ref;
 	atomic_t		re_receiving;
 	atomic_t		re_force_disconnect;
 	struct ib_qp_init_attr	re_attr;
-- 
2.53.0
