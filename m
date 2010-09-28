Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19197 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755515Ab0I1PSe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Sep 2010 11:18:34 -0400
Message-ID: <4CA2073F.6070805@parallels.com>
Date: Tue, 28 Sep 2010 19:18:23 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 7/7] sunrpc: Tag rpc_xprt with net
References: <4CA20651.4070605@parallels.com>
In-Reply-To: <4CA20651.4070605@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The net is known from the xprt_create and this tagging will also
give un the context in the conntection workers where real sockets
are created.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/linux/sunrpc/xprt.h     |    3 ++-
 net/sunrpc/xprtrdma/transport.c |    2 +-
 net/sunrpc/xprtsock.c           |    6 ++++--
 3 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index c4f9315..89d10d2 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -224,6 +224,7 @@ struct rpc_xprt {
 					bklog_u;	/* backlog queue utilization */
 	} stat;
 
+	struct net		*xprt_net;
 	const char		*address_strings[RPC_DISPLAY_MAX];
 };
 
@@ -281,7 +282,7 @@ void			xprt_release_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_release(struct rpc_task *task);
 struct rpc_xprt *	xprt_get(struct rpc_xprt *xprt);
 void			xprt_put(struct rpc_xprt *xprt);
-struct rpc_xprt *	xprt_alloc(int size, int max_req);
+struct rpc_xprt *	xprt_alloc(struct net *net, int size, int max_req);
 void			xprt_free(struct rpc_xprt *);
 
 static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *p)
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 0f7a1b9..2da32b4 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -283,7 +283,7 @@ xprt_setup_rdma(struct xprt_create *args)
 		return ERR_PTR(-EBADF);
 	}
 
-	xprt = xprt_alloc(sizeof(struct rpcrdma_xprt),
+	xprt = xprt_alloc(args->net, sizeof(struct rpcrdma_xprt),
 			xprt_rdma_slot_table_entries);
 	if (xprt == NULL) {
 		dprintk("RPC:       %s: couldn't allocate rpcrdma_xprt\n",
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 77cb595..dbac32e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -759,7 +759,7 @@ static void xs_tcp_close(struct rpc_xprt *xprt)
 		xs_tcp_shutdown(xprt);
 }
 
-struct rpc_xprt *xprt_alloc(int size, int max_req)
+struct rpc_xprt *xprt_alloc(struct net *net, int size, int max_req)
 {
 	struct rpc_xprt *xprt;
 
@@ -772,6 +772,7 @@ struct rpc_xprt *xprt_alloc(int size, int max_req)
 	if (xprt->slot == NULL)
 		goto out_free;
 
+	xprt->xprt_net = get_net(net);
 	return xprt;
 
 out_free:
@@ -783,6 +784,7 @@ EXPORT_SYMBOL_GPL(xprt_alloc);
 
 void xprt_free(struct rpc_xprt *xprt)
 {
+	put_net(xprt->xprt_net);
 	kfree(xprt->slot);
 	kfree(xprt);
 }
@@ -2301,7 +2303,7 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 		return ERR_PTR(-EBADF);
 	}
 
-	xprt = xprt_alloc(sizeof(*new), slot_table_size);
+	xprt = xprt_alloc(args->net, sizeof(*new), slot_table_size);
 	if (xprt == NULL) {
 		dprintk("RPC:       xs_setup_xprt: couldn't allocate "
 				"rpc_xprt\n");
-- 
1.5.5.6

