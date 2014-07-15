Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:57950 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbaGOOU7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 10:20:59 -0400
Subject: [PATCH v3 05/21] xprtrdma: On disconnect, don't ignore pending CQEs
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 15 Jul 2014 10:20:56 -0400
Message-ID: <20140715142056.8908.73636.stgit@manet.1015granger.net>
In-Reply-To: <20140715142020.8908.80969.stgit@manet.1015granger.net>
References: <20140715142020.8908.80969.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xprtrdma is currently throwing away queued completions during
a reconnect. RPC replies posted just before connection loss, or
successful completions that change the state of an FRMR, can be
missed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/verbs.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 0d5187d..7fd457e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -310,6 +310,13 @@ rpcrdma_recvcq_upcall(struct ib_cq *cq, void *cq_context)
 	rpcrdma_recvcq_poll(cq, ep);
 }
 
+static void
+rpcrdma_flush_cqs(struct rpcrdma_ep *ep)
+{
+	rpcrdma_recvcq_upcall(ep->rep_attr.recv_cq, ep);
+	rpcrdma_sendcq_upcall(ep->rep_attr.send_cq, ep);
+}
+
 #ifdef RPC_DEBUG
 static const char * const conn[] = {
 	"address resolved",
@@ -872,9 +879,7 @@ retry:
 		if (rc && rc != -ENOTCONN)
 			dprintk("RPC:       %s: rpcrdma_ep_disconnect"
 				" status %i\n", __func__, rc);
-
-		rpcrdma_clean_cq(ep->rep_attr.recv_cq);
-		rpcrdma_clean_cq(ep->rep_attr.send_cq);
+		rpcrdma_flush_cqs(ep);
 
 		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
 		id = rpcrdma_create_id(xprt, ia,
@@ -985,8 +990,7 @@ rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 {
 	int rc;
 
-	rpcrdma_clean_cq(ep->rep_attr.recv_cq);
-	rpcrdma_clean_cq(ep->rep_attr.send_cq);
+	rpcrdma_flush_cqs(ep);
 	rc = rdma_disconnect(ia->ri_id);
 	if (!rc) {
 		/* returns without wait if not connected */

