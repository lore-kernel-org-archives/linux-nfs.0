From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 01/11] sunrpc: fix leak on error on socket xprt setup
Date: Tue,  9 Mar 2010 19:28:06 -0500
Message-ID: <1268180896-30921-2-git-send-email-bfields@citi.umich.edu>
References: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42172 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755692Ab0CJA0v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 19:26:51 -0500
In-Reply-To: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also collect exit code together while we're at it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xprtsock.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7124129..a91f0a4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2333,6 +2333,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
+	struct rpc_xprt *ret;
 
 	xprt = xs_setup_xprt(args, xprt_udp_slot_table_entries);
 	if (IS_ERR(xprt))
@@ -2371,8 +2372,8 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 		xs_format_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP6);
 		break;
 	default:
-		kfree(xprt);
-		return ERR_PTR(-EAFNOSUPPORT);
+		ret = ERR_PTR(-EAFNOSUPPORT);
+		goto out_err;
 	}
 
 	if (xprt_bound(xprt))
@@ -2387,10 +2388,11 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
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
@@ -2409,6 +2411,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
+	struct rpc_xprt *ret;
 
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
@@ -2445,8 +2448,8 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 		xs_format_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
 		break;
 	default:
-		kfree(xprt);
-		return ERR_PTR(-EAFNOSUPPORT);
+		ret = ERR_PTR(-EAFNOSUPPORT);
+		goto out_err;
 	}
 
 	if (xprt_bound(xprt))
@@ -2462,10 +2465,11 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 
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
@@ -2479,6 +2483,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
 	struct svc_sock *bc_sock;
+	struct rpc_xprt *ret;
 
 	if (!args->bc_xprt)
 		ERR_PTR(-EINVAL);
@@ -2522,8 +2527,8 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 				   RPCBIND_NETID_TCP6);
 		break;
 	default:
-		kfree(xprt);
-		return ERR_PTR(-EAFNOSUPPORT);
+		ret = ERR_PTR(-EAFNOSUPPORT);
+		goto out_err;
 	}
 
 	if (xprt_bound(xprt))
@@ -2545,9 +2550,11 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 
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
1.6.3.3

