Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:57476 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310AbaFWWjo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 18:39:44 -0400
Subject: [PATCH v1 05/13] xprtrdma: Don't drain CQs on transport disconnect
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Jun 2014 18:39:42 -0400
Message-ID: <20140623223942.1634.89063.stgit@manet.1015granger.net>
In-Reply-To: <20140623223201.1634.83888.stgit@manet.1015granger.net>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CQs are not destroyed until unmount. By draining CQs on transport
disconnect, successful completions that can change the r.frmr.state
field can be missed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3c7f904..451e100 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -873,9 +873,6 @@ retry:
 			dprintk("RPC:       %s: rpcrdma_ep_disconnect"
 				" status %i\n", __func__, rc);
 
-		rpcrdma_clean_cq(ep->rep_attr.recv_cq);
-		rpcrdma_clean_cq(ep->rep_attr.send_cq);
-
 		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
 		id = rpcrdma_create_id(xprt, ia,
 				(struct sockaddr *)&xprt->rx_data.addr);
@@ -985,8 +982,6 @@ rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 {
 	int rc;
 
-	rpcrdma_clean_cq(ep->rep_attr.recv_cq);
-	rpcrdma_clean_cq(ep->rep_attr.send_cq);
 	rc = rdma_disconnect(ia->ri_id);
 	if (!rc) {
 		/* returns without wait if not connected */

