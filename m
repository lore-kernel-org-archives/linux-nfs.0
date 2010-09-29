Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39283 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755008Ab0I2MC4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Sep 2010 08:02:56 -0400
Message-ID: <4CA32AE3.6080508@parallels.com>
Date: Wed, 29 Sep 2010 16:02:43 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 1/9] sunrpc: Factor out rpc_xprt allocation
References: <4CA32AB4.2090808@parallels.com>
In-Reply-To: <4CA32AB4.2090808@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/linux/sunrpc/xprt.h     |    1 +
 net/sunrpc/xprt.c               |   22 ++++++++++++++++++++++
 net/sunrpc/xprtrdma/transport.c |   13 ++-----------
 net/sunrpc/xprtsock.c           |   15 +++------------
 4 files changed, 28 insertions(+), 23 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index ff5a77b..00f6e3f 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -280,6 +280,7 @@ void			xprt_release_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_release(struct rpc_task *task);
 struct rpc_xprt *	xprt_get(struct rpc_xprt *xprt);
 void			xprt_put(struct rpc_xprt *xprt);
+struct rpc_xprt *	xprt_alloc(int size, int max_req);
 
 static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *p)
 {
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 970fb00..26cbe21 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -962,6 +962,28 @@ static void xprt_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *req)
 	spin_unlock(&xprt->reserve_lock);
 }
 
+struct rpc_xprt *xprt_alloc(int size, int max_req)
+{
+	struct rpc_xprt *xprt;
+
+	xprt = kzalloc(size, GFP_KERNEL);
+	if (xprt == NULL)
+		goto out;
+
+	xprt->max_reqs = max_req;
+	xprt->slot = kcalloc(max_req, sizeof(struct rpc_rqst), GFP_KERNEL);
+	if (xprt->slot == NULL)
+		goto out_free;
+
+	return xprt;
+
+out_free:
+	kfree(xprt);
+out:
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(xprt_alloc);
+
 /**
  * xprt_reserve - allocate an RPC request slot
  * @task: RPC task requesting a slot allocation
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index a85e866..9d77bf2 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -285,23 +285,14 @@ xprt_setup_rdma(struct xprt_create *args)
 		return ERR_PTR(-EBADF);
 	}
 
-	xprt = kzalloc(sizeof(struct rpcrdma_xprt), GFP_KERNEL);
+	xprt = xprt_alloc(sizeof(struct rpcrdma_xprt),
+			xprt_rdma_slot_table_entries);
 	if (xprt == NULL) {
 		dprintk("RPC:       %s: couldn't allocate rpcrdma_xprt\n",
 			__func__);
 		return ERR_PTR(-ENOMEM);
 	}
 
-	xprt->max_reqs = xprt_rdma_slot_table_entries;
-	xprt->slot = kcalloc(xprt->max_reqs,
-				sizeof(struct rpc_rqst), GFP_KERNEL);
-	if (xprt->slot == NULL) {
-		dprintk("RPC:       %s: couldn't allocate %d slots\n",
-			__func__, xprt->max_reqs);
-		kfree(xprt);
-		return ERR_PTR(-ENOMEM);
-	}
-
 	/* 60 second timeout, no retries */
 	xprt->timeout = &xprt_rdma_default_timeout;
 	xprt->bind_timeout = (60U * HZ);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b6309db..a7a7638 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2273,23 +2273,14 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 		return ERR_PTR(-EBADF);
 	}
 
-	new = kzalloc(sizeof(*new), GFP_KERNEL);
-	if (new == NULL) {
+	xprt = xprt_alloc(sizeof(*new), slot_table_size);
+	if (xprt == NULL) {
 		dprintk("RPC:       xs_setup_xprt: couldn't allocate "
 				"rpc_xprt\n");
 		return ERR_PTR(-ENOMEM);
 	}
-	xprt = &new->xprt;
-
-	xprt->max_reqs = slot_table_size;
-	xprt->slot = kcalloc(xprt->max_reqs, sizeof(struct rpc_rqst), GFP_KERNEL);
-	if (xprt->slot == NULL) {
-		kfree(xprt);
-		dprintk("RPC:       xs_setup_xprt: couldn't allocate slot "
-				"table\n");
-		return ERR_PTR(-ENOMEM);
-	}
 
+	new = container_of(xprt, struct sock_xprt, xprt);
 	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
 	xprt->addrlen = args->addrlen;
 	if (args->srcaddr)
-- 
1.5.5.6

