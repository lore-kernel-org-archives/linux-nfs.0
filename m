Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33931 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbaAFKYh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jan 2014 05:24:37 -0500
Received: by mail-pa0-f50.google.com with SMTP id kp14so16616675pab.9
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2014 02:24:37 -0800 (PST)
Message-ID: <52CA8460.6030206@gmail.com>
Date: Mon, 06 Jan 2014 18:24:32 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] SUNRPC: fix memory leak of peer addresses in XPRT
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If creating xprt failed after xs_format_peer_addresses,
sunrpc must free those memory of peer addresses in xprt.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/xprtsock.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 25dbfa9..11ceba3 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2725,8 +2725,10 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 		xprt_set_bound(xprt);
 		xs_format_peer_addresses(xprt, "local", RPCBIND_NETID_LOCAL);
 		ret = ERR_PTR(xs_local_setup_socket(transport));
-		if (ret)
+		if (ret) {
+			xs_free_peer_addresses(xprt);
 			goto out_err;
+		}
 		break;
 	default:
 		ret = ERR_PTR(-EAFNOSUPPORT);
@@ -2738,6 +2740,8 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 
 	if (try_module_get(THIS_MODULE))
 		return xprt;
+
+	xs_free_peer_addresses(xprt);
 	ret = ERR_PTR(-EINVAL);
 out_err:
 	xprt_free(xprt);
@@ -2816,6 +2820,8 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
 	if (try_module_get(THIS_MODULE))
 		return xprt;
+
+	xs_free_peer_addresses(xprt);
 	ret = ERR_PTR(-EINVAL);
 out_err:
 	xprt_free(xprt);
@@ -2893,9 +2899,10 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 				xprt->address_strings[RPC_DISPLAY_ADDR],
 				xprt->address_strings[RPC_DISPLAY_PROTO]);
 
-
 	if (try_module_get(THIS_MODULE))
 		return xprt;
+
+	xs_free_peer_addresses(xprt);
 	ret = ERR_PTR(-EINVAL);
 out_err:
 	xprt_free(xprt);
-- 
1.8.4.2
