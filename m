Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:34521 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754971AbcEBSlQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 14:41:16 -0400
Subject: [PATCH v3 07/20] xprtrdma: Avoid using Write list for small NFS
 READ requests
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 02 May 2016 14:41:14 -0400
Message-ID: <20160502184114.10798.28611.stgit@manet.1015granger.net>
In-Reply-To: <20160502183144.10798.99847.stgit@manet.1015granger.net>
References: <20160502183144.10798.99847.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid the latency and interrupt overhead of registering a Write
chunk when handling NFS READ requests of a few hundred bytes or
less.

This change does not interoperate with Linux NFS/RDMA servers
that do not have commit 9d11b51ce7c1 ('svcrdma: Fix send_reply()
scatter/gather set-up'). Commit 9d11b51ce7c1 was introduced in v4.3,
and is included in 4.2.y, 4.1.y, and 3.18.y.

Oracle bug 22925946 has been filed to request that the above fix
be included in the Oracle Linux UEK4 NFS/RDMA server.

Red Hat bugzillas 1327280 and 1327554 have been filed to request
that RHEL NFS/RDMA server backports include the above fix.

Workaround: Replace the "proto=rdma,port=20049" mount options
with "proto=tcp" until commit 9d11b51ce7c1 is applied to your
NFS server.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
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
 

