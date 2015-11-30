Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33310 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550AbbK3WP2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Nov 2015 17:15:28 -0500
Subject: [PATCH v2 11/11] xprtrdma: Revert commit e7104a2a9606 ('xprtrdma:
 Cap req_cqinit').
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Nov 2015 17:15:26 -0500
Message-ID: <20151130221526.12235.35195.stgit@manet.1015granger.net>
In-Reply-To: <20151130221349.12235.29565.stgit@manet.1015granger.net>
References: <20151130221349.12235.29565.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The root of the problem was that sends (especially unsignalled
FASTREG and LOCAL_INV Work Requests) were not properly flow-
controlled, which allowed a send queue overrun.

Now that the RPC/RDMA reply handler waits for invalidation to
complete, the send queue is properly flow-controlled. Thus this
limit is no longer necessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |    6 ++----
 net/sunrpc/xprtrdma/xprt_rdma.h |    6 ------
 2 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index d9c2097..daff5e7 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -616,10 +616,8 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 
 	/* set trigger for requesting send completion */
 	ep->rep_cqinit = ep->rep_attr.cap.max_send_wr/2 - 1;
-	if (ep->rep_cqinit > RPCRDMA_MAX_UNSIGNALED_SENDS)
-		ep->rep_cqinit = RPCRDMA_MAX_UNSIGNALED_SENDS;
-	else if (ep->rep_cqinit <= 2)
-		ep->rep_cqinit = 0;
+	if (ep->rep_cqinit <= 2)
+		ep->rep_cqinit = 0;	/* always signal? */
 	INIT_CQCOUNT(ep);
 	init_waitqueue_head(&ep->rep_connect_wait);
 	INIT_DELAYED_WORK(&ep->rep_connect_worker, rpcrdma_connect_worker);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 6726cb3..6a9e627 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -88,12 +88,6 @@ struct rpcrdma_ep {
 	struct delayed_work	rep_connect_worker;
 };
 
-/*
- * Force a signaled SEND Work Request every so often,
- * in case the provider needs to do some housekeeping.
- */
-#define RPCRDMA_MAX_UNSIGNALED_SENDS	(32)
-
 #define INIT_CQCOUNT(ep) atomic_set(&(ep)->rep_cqcount, (ep)->rep_cqinit)
 #define DECR_CQCOUNT(ep) atomic_sub_return(1, &(ep)->rep_cqcount)
 

