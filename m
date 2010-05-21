From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] sunrpc: fix leak on error on socket xprt setup
Date: Thu, 20 May 2010 20:25:08 -0400
Message-ID: <20100521002508.GA30928@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48546 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753510Ab0EUAZK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 20:25:10 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Also collect exit code together while we're at it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xprtsock.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

I think I sent this before, but it must have fallen through the cracks.

--b.

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 02fc7f0..8bfb386 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2297,6 +2297,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
+	struct rpc_xprt *ret;
 
 	xprt = xs_setup_xprt(args, xprt_udp_slot_table_entries);
 	if (IS_ERR(xprt))
@@ -2334,8 +2335,8 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 		xs_format_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP6);
 		break;
 	default:
-		kfree(xprt);
-		return ERR_PTR(-EAFNOSUPPORT);
+		ret = ERR_PTR(-EAFNOSUPPORT);
+		goto out_err;
 	}
 
 	if (xprt_bound(xprt))
@@ -2350,10 +2351,11 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
 	if (try_module_get(THIS_MODULE))
 		return xprt;
-
+	ret = ERR_PTR(-EINVAL);
+out_err:
 	kfree(xprt->slot);
 	kfree(xprt);
-	return ERR_PTR(-EINVAL);
+	return ret;
 }
 
 static const struct rpc_timeout xs_tcp_default_timeout = {
@@ -2372,6 +2374,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
+	struct rpc_xprt *ret;
 
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
@@ -2407,8 +2410,8 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 		xs_format_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
 		break;
 	default:
-		kfree(xprt);
-		return ERR_PTR(-EAFNOSUPPORT);
+		ret = ERR_PTR(-EAFNOSUPPORT);
+		goto out_err;
 	}
 
 	if (xprt_bound(xprt))
@@ -2424,10 +2427,11 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 
 	if (try_module_get(THIS_MODULE))
 		return xprt;
-
+	ret = ERR_PTR(-EINVAL);
+out_err:
 	kfree(xprt->slot);
 	kfree(xprt);
-	return ERR_PTR(-EINVAL);
+	return ret;
 }
 
 /**
@@ -2441,6 +2445,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
 	struct svc_sock *bc_sock;
+	struct rpc_xprt *ret;
 
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
@@ -2480,8 +2485,8 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 				   RPCBIND_NETID_TCP6);
 		break;
 	default:
-		kfree(xprt);
-		return ERR_PTR(-EAFNOSUPPORT);
+		ret = ERR_PTR(-EAFNOSUPPORT);
+		goto out_err;
 	}
 
 	if (xprt_bound(xprt))
@@ -2503,9 +2508,11 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 
 	if (try_module_get(THIS_MODULE))
 		return xprt;
+	ret = ERR_PTR(-EINVAL);
+out_err:
 	kfree(xprt->slot);
 	kfree(xprt);
-	return ERR_PTR(-EINVAL);
+	return ret;
 }
 
 static struct xprt_class	xs_udp_transport = {
-- 
1.7.0.4

