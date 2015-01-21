Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:34323 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754269AbbAUQCs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2015 11:02:48 -0500
Subject: [PATCH v3 06/20] xprtrdma: Remove rpcrdma_ep::rep_ia
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 21 Jan 2015 11:02:46 -0500
Message-ID: <20150121160246.17297.78702.stgit@manet.1015granger.net>
In-Reply-To: <20150121155303.17297.47423.stgit@manet.1015granger.net>
References: <20150121155303.17297.47423.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: This field is not used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/verbs.c     |    1 -
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
 2 files changed, 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 56f705d..56e14b3 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -825,7 +825,6 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	else if (ep->rep_cqinit <= 2)
 		ep->rep_cqinit = 0;
 	INIT_CQCOUNT(ep);
-	ep->rep_ia = ia;
 	init_waitqueue_head(&ep->rep_connect_wait);
 	INIT_DELAYED_WORK(&ep->rep_connect_worker, rpcrdma_connect_worker);
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 9a7aab3..5160a84 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -83,7 +83,6 @@ struct rpcrdma_ep {
 	atomic_t		rep_cqcount;
 	int			rep_cqinit;
 	int			rep_connected;
-	struct rpcrdma_ia	*rep_ia;
 	struct ib_qp_init_attr	rep_attr;
 	wait_queue_head_t 	rep_connect_wait;
 	struct ib_sge		rep_pad;	/* holds zeroed pad */

