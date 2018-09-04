Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:45707 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726999AbeIEBd0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:26 -0400
Received: by mail-io0-f196.google.com with SMTP id e12-v6so4197106iok.12
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:34 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.33
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:33 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 31/34] SUNRPC: Turn off throttling of RPC slots for TCP sockets
Date: Tue,  4 Sep 2018 17:05:46 -0400
Message-Id: <20180904210549.81673-32-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-31-trond.myklebust@hammerspace.com>
References: <20180904210549.81673-1-trond.myklebust@hammerspace.com>
 <20180904210549.81673-2-trond.myklebust@hammerspace.com>
 <20180904210549.81673-3-trond.myklebust@hammerspace.com>
 <20180904210549.81673-4-trond.myklebust@hammerspace.com>
 <20180904210549.81673-5-trond.myklebust@hammerspace.com>
 <20180904210549.81673-6-trond.myklebust@hammerspace.com>
 <20180904210549.81673-7-trond.myklebust@hammerspace.com>
 <20180904210549.81673-8-trond.myklebust@hammerspace.com>
 <20180904210549.81673-9-trond.myklebust@hammerspace.com>
 <20180904210549.81673-10-trond.myklebust@hammerspace.com>
 <20180904210549.81673-11-trond.myklebust@hammerspace.com>
 <20180904210549.81673-12-trond.myklebust@hammerspace.com>
 <20180904210549.81673-13-trond.myklebust@hammerspace.com>
 <20180904210549.81673-14-trond.myklebust@hammerspace.com>
 <20180904210549.81673-15-trond.myklebust@hammerspace.com>
 <20180904210549.81673-16-trond.myklebust@hammerspace.com>
 <20180904210549.81673-17-trond.myklebust@hammerspace.com>
 <20180904210549.81673-18-trond.myklebust@hammerspace.com>
 <20180904210549.81673-19-trond.myklebust@hammerspace.com>
 <20180904210549.81673-20-trond.myklebust@hammerspace.com>
 <20180904210549.81673-21-trond.myklebust@hammerspace.com>
 <20180904210549.81673-22-trond.myklebust@hammerspace.com>
 <20180904210549.81673-23-trond.myklebust@hammerspace.com>
 <20180904210549.81673-24-trond.myklebust@hammerspace.com>
 <20180904210549.81673-25-trond.myklebust@hammerspace.com>
 <20180904210549.81673-26-trond.myklebust@hammerspace.com>
 <20180904210549.81673-27-trond.myklebust@hammerspace.com>
 <20180904210549.81673-28-trond.myklebust@hammerspace.com>
 <20180904210549.81673-29-trond.myklebust@hammerspace.com>
 <20180904210549.81673-30-trond.myklebust@hammerspace.com>
 <20180904210549.81673-31-trond.myklebust@hammerspace.com>
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
index 5dd64bdb28cd..d623bebab4f9 100644
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
index bd818b97cb09..4068d0ea3a21 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1325,20 +1325,6 @@ void xprt_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task)
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
