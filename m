Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f195.google.com ([209.85.222.195]:32993 "EHLO
        mail-qk1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728317AbeIQSbt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:49 -0400
Received: by mail-qk1-f195.google.com with SMTP id z78-v6so8932573qka.0
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:33 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.32
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:32 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 31/44] SUNRPC: Turn off throttling of RPC slots for TCP sockets
Date: Mon, 17 Sep 2018 09:03:22 -0400
Message-Id: <20180917130335.112832-32-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-31-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
 <20180917130335.112832-25-trond.myklebust@hammerspace.com>
 <20180917130335.112832-26-trond.myklebust@hammerspace.com>
 <20180917130335.112832-27-trond.myklebust@hammerspace.com>
 <20180917130335.112832-28-trond.myklebust@hammerspace.com>
 <20180917130335.112832-29-trond.myklebust@hammerspace.com>
 <20180917130335.112832-30-trond.myklebust@hammerspace.com>
 <20180917130335.112832-31-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The theory was that we would need to grab the socket lock anyway, so we
might as well use it to gate the allocation of RPC slots for a TCP
socket.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h |  1 -
 net/sunrpc/xprt.c           | 14 --------------
 net/sunrpc/xprtsock.c       |  2 +-
 3 files changed, 1 insertion(+), 16 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 0d0cc127615e..14c9b4d49fb4 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -343,7 +343,6 @@ int			xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_free_slot(struct rpc_xprt *xprt,
 				       struct rpc_rqst *req);
-void			xprt_lock_and_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task);
 bool			xprt_prepare_transmit(struct rpc_task *task);
 void			xprt_request_enqueue_transmit(struct rpc_task *task);
 void			xprt_request_enqueue_receive(struct rpc_task *task);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a523e59a074e..6bdc10147297 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1428,20 +1428,6 @@ void xprt_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task)
 }
 EXPORT_SYMBOL_GPL(xprt_alloc_slot);
 
-void xprt_lock_and_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task)
-{
-	/* Note: grabbing the xprt_lock_write() ensures that we throttle
-	 * new slot allocation if the transport is congested (i.e. when
-	 * reconnecting a stream transport or when out of socket write
-	 * buffer space).
-	 */
-	if (xprt_lock_write(xprt, task)) {
-		xprt_alloc_slot(xprt, task);
-		xprt_release_write(xprt, task);
-	}
-}
-EXPORT_SYMBOL_GPL(xprt_lock_and_alloc_slot);
-
 void xprt_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *req)
 {
 	spin_lock(&xprt->reserve_lock);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8831e84a058a..f54e8110f4c6 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2809,7 +2809,7 @@ static const struct rpc_xprt_ops xs_udp_ops = {
 static const struct rpc_xprt_ops xs_tcp_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xprt_release_xprt,
-	.alloc_slot		= xprt_lock_and_alloc_slot,
+	.alloc_slot		= xprt_alloc_slot,
 	.free_slot		= xprt_free_slot,
 	.rpcbind		= rpcb_getport_async,
 	.set_port		= xs_set_port,
-- 
2.17.1
