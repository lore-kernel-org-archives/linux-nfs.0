Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:40346 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285Ab0I0KGg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 06:06:36 -0400
Message-ID: <4CA06CA0.6060606@parallels.com>
Date: Mon, 27 Sep 2010 14:06:24 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 1/8] sunrpc: Factor out rpc_xprt freeing
References: <4CA06C7A.5060307@parallels.com>
In-Reply-To: <4CA06C7A.5060307@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprtsock.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b6309db..98d4b7b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -759,6 +759,8 @@ static void xs_tcp_close(struct rpc_xprt *xprt)
 		xs_tcp_shutdown(xprt);
 }
 
+static void xs_free_xprt(struct rpc_xprt *xprt);
+
 /**
  * xs_destroy - prepare to shutdown a transport
  * @xprt: doomed transport
@@ -774,8 +776,7 @@ static void xs_destroy(struct rpc_xprt *xprt)
 
 	xs_close(xprt);
 	xs_free_peer_addresses(xprt);
-	kfree(xprt->slot);
-	kfree(xprt);
+	xs_free_xprt(xprt);
 	module_put(THIS_MODULE);
 }
 
@@ -2298,6 +2299,12 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	return xprt;
 }
 
+static void xs_free_xprt(struct rpc_xprt *xprt)
+{
+	kfree(xprt->slot);
+	kfree(xprt);
+}
+
 static const struct rpc_timeout xs_udp_default_timeout = {
 	.to_initval = 5 * HZ,
 	.to_maxval = 30 * HZ,
@@ -2371,8 +2378,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 		return xprt;
 	ret = ERR_PTR(-EINVAL);
 out_err:
-	kfree(xprt->slot);
-	kfree(xprt);
+	xs_free_xprt(xprt);
 	return ret;
 }
 
@@ -2447,8 +2453,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 		return xprt;
 	ret = ERR_PTR(-EINVAL);
 out_err:
-	kfree(xprt->slot);
-	kfree(xprt);
+	xs_free_xprt(xprt);
 	return ret;
 }
 
@@ -2528,8 +2533,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 		return xprt;
 	ret = ERR_PTR(-EINVAL);
 out_err:
-	kfree(xprt->slot);
-	kfree(xprt);
+	xs_free_xprt(xprt);
 	return ret;
 }
 
-- 
1.5.5.6

