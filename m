Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:32884 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626AbcDKUKw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2016 16:10:52 -0400
Subject: [PATCH v1 05/18] xprtrdma: Avoid using Write list for small NFS
 READ requests
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 Apr 2016 16:10:50 -0400
Message-ID: <20160411201050.20531.53651.stgit@manet.1015granger.net>
In-Reply-To: <20160411200323.20531.8893.stgit@manet.1015granger.net>
References: <20160411200323.20531.8893.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid the latency and interrupt overhead of registering a Write
chunk when handling NFS READ requests of a few hundred bytes or
less.

This change does not interoperate with Linux NFS/RDMA servers
that do not have commit 9d11b51ce7c1 ('svcrdma: Fix send_reply()
scatter/gather set-up').

$ git describe 9d11b51ce7c1
v4.2-rc3-10-g9d11b51

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 205b81b..0105e65 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -539,15 +539,16 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	/*
 	 * Chunks needed for results?
 	 *
-	 * o Read ops return data as write chunk(s), header as inline.
 	 * o If the expected result is under the inline threshold, all ops
 	 *   return as inline.
+	 * o Large read ops return data as write chunk(s), header as
+	 *   inline.
 	 * o Large non-read ops return as a single reply chunk.
 	 */
-	if (rqst->rq_rcv_buf.flags & XDRBUF_READ)
-		wtype = rpcrdma_writech;
-	else if (rpcrdma_results_inline(r_xprt, rqst))
+	if (rpcrdma_results_inline(r_xprt, rqst))
 		wtype = rpcrdma_noch;
+	else if (rqst->rq_rcv_buf.flags & XDRBUF_READ)
+		wtype = rpcrdma_writech;
 	else
 		wtype = rpcrdma_replych;
 

