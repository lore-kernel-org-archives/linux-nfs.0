From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 02/11] sunrpc: take reference to bc_xprt in sunrpc layer
Date: Tue,  9 Mar 2010 19:28:07 -0500
Message-ID: <1268180896-30921-3-git-send-email-bfields@citi.umich.edu>
References: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-2-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42171 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755569Ab0CJA0v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 19:26:51 -0500
In-Reply-To: <1268180896-30921-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently we're requiring whoever holds the reference to a client set up
the on the backchannel to also hold a reference to the forechannel
transport; but this should be the responsibility of the lower level
code.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xprtsock.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index a91f0a4..5adc000 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -792,6 +792,8 @@ static void xs_destroy(struct rpc_xprt *xprt)
 
 	xs_close(xprt);
 	xs_free_peer_addresses(xprt);
+	if (xprt->bc_xprt)
+		svc_xprt_put(xprt->bc_xprt);
 	kfree(xprt->slot);
 	kfree(xprt);
 	module_put(THIS_MODULE);
@@ -2510,6 +2512,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	 * forechannel
 	 */
 	xprt->bc_xprt = args->bc_xprt;
+	svc_xprt_get(xprt->bc_xprt);
 	bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
 	bc_sock->sk_bc_xprt = xprt;
 	transport->sock = bc_sock->sk_sock;
@@ -2552,6 +2555,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 		return xprt;
 	ret = ERR_PTR(-EINVAL);
 out_err:
+	svc_xprt_put(xprt->bc_xprt);
 	kfree(xprt->slot);
 	kfree(xprt);
 	return ret;
-- 
1.6.3.3

