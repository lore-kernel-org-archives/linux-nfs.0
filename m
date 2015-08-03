Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:34638 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754753AbbHCREL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Aug 2015 13:04:11 -0400
Subject: [PATCH v4 10/16] xprtrdma: Don't provide a reply chunk when
 expecting a short reply
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 03 Aug 2015 13:04:08 -0400
Message-ID: <20150803170408.9115.58172.stgit@manet.1015granger.net>
In-Reply-To: <20150803165807.9115.23842.stgit@manet.1015granger.net>
References: <20150803165807.9115.23842.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently Linux always offers a reply chunk, even when the reply
can be sent inline (ie. is smaller than 1KB).

On the client, registering a memory region can be expensive. A
server may choose not to use the reply chunk, wasting the cost of
the registration.

This is a change only for RPC replies smaller than 1KB which the
server constructs in the RPC reply send buffer. Because the elements
of the reply must be XDR encoded, a copy-free data transfer has no
benefit in this case.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Tested-by: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index e7cf976..62150ae 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -420,7 +420,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	 *
 	 * o Read ops return data as write chunk(s), header as inline.
 	 * o If the expected result is under the inline threshold, all ops
-	 *   return as inline (but see later).
+	 *   return as inline.
 	 * o Large non-read ops return as a single reply chunk.
 	 */
 	if (rqst->rq_rcv_buf.flags & XDRBUF_READ)
@@ -476,17 +476,6 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 		headerp->rm_body.rm_nochunks.rm_empty[2] = xdr_zero;
 		/* new length after pullup */
 		rpclen = rqst->rq_svec[0].iov_len;
-		/* Currently we try to not actually use read inline.
-		 * Reply chunks have the desirable property that
-		 * they land, packed, directly in the target buffers
-		 * without headers, so they require no fixup. The
-		 * additional RDMA Write op sends the same amount
-		 * of data, streams on-the-wire and adds no overhead
-		 * on receive. Therefore, we request a reply chunk
-		 * for non-writes wherever feasible and efficient.
-		 */
-		if (wtype == rpcrdma_noch)
-			wtype = rpcrdma_replych;
 	}
 
 	if (rtype != rpcrdma_noch) {

