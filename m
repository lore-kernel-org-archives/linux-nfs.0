Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:9279 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753353Ab0I2MDZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Sep 2010 08:03:25 -0400
Message-ID: <4CA32B01.9000004@parallels.com>
Date: Wed, 29 Sep 2010 16:03:13 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 2/9] sunrpc: Factor out rpc_xprt freeing
References: <4CA32AB4.2090808@parallels.com>
In-Reply-To: <4CA32AB4.2090808@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/linux/sunrpc/xprt.h     |    1 +
 net/sunrpc/xprt.c               |    7 +++++++
 net/sunrpc/xprtrdma/transport.c |    7 ++-----
 net/sunrpc/xprtsock.c           |   12 ++++--------
 4 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 00f6e3f..af4b560 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -281,6 +281,7 @@ void			xprt_release(struct rpc_task *task);
 struct rpc_xprt *	xprt_get(struct rpc_xprt *xprt);
 void			xprt_put(struct rpc_xprt *xprt);
 struct rpc_xprt *	xprt_alloc(int size, int max_req);
+void			xprt_free(struct rpc_xprt *);
 
 static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *p)
 {
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 26cbe21..0637340 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -984,6 +984,13 @@ out:
 }
 EXPORT_SYMBOL_GPL(xprt_alloc);
 
+void xprt_free(struct rpc_xprt *xprt)
+{
+	kfree(xprt->slot);
+	kfree(xprt);
+}
+EXPORT_SYMBOL_GPL(xprt_free);
+
 /**
  * xprt_reserve - allocate an RPC request slot
  * @task: RPC task requesting a slot allocation
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 9d77bf2..0f7a1b9 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -251,9 +251,7 @@ xprt_rdma_destroy(struct rpc_xprt *xprt)
 
 	xprt_rdma_free_addresses(xprt);
 
-	kfree(xprt->slot);
-	xprt->slot = NULL;
-	kfree(xprt);
+	xprt_free(xprt);
 
 	dprintk("RPC:       %s: returning\n", __func__);
 
@@ -401,8 +399,7 @@ out3:
 out2:
 	rpcrdma_ia_close(&new_xprt->rx_ia);
 out1:
-	kfree(xprt->slot);
-	kfree(xprt);
+	xprt_free(xprt);
 	return ERR_PTR(rc);
 }
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index a7a7638..b1e36ec 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -774,8 +774,7 @@ static void xs_destroy(struct rpc_xprt *xprt)
 
 	xs_close(xprt);
 	xs_free_peer_addresses(xprt);
-	kfree(xprt->slot);
-	kfree(xprt);
+	xprt_free(xprt);
 	module_put(THIS_MODULE);
 }
 
@@ -2362,8 +2361,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 		return xprt;
 	ret = ERR_PTR(-EINVAL);
 out_err:
-	kfree(xprt->slot);
-	kfree(xprt);
+	xprt_free(xprt);
 	return ret;
 }
 
@@ -2438,8 +2436,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 		return xprt;
 	ret = ERR_PTR(-EINVAL);
 out_err:
-	kfree(xprt->slot);
-	kfree(xprt);
+	xprt_free(xprt);
 	return ret;
 }
 
@@ -2519,8 +2516,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 		return xprt;
 	ret = ERR_PTR(-EINVAL);
 out_err:
-	kfree(xprt->slot);
-	kfree(xprt);
+	xprt_free(xprt);
 	return ret;
 }
 
-- 
1.5.5.6

