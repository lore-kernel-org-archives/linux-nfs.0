Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:32781 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295AbbGTTDw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 15:03:52 -0400
Subject: [PATCH v3 09/15] xprtrdma: Always provide a write list when sending
 NFS READ
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 20 Jul 2015 15:03:49 -0400
Message-ID: <20150720190349.10997.53285.stgit@manet.1015granger.net>
In-Reply-To: <20150720185624.10997.51574.stgit@manet.1015granger.net>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client has been setting up a reply chunk for NFS READs that are
smaller than the inline threshold. This is not efficient: both the
server and client CPUs have to copy the reply's data payload into
and out of the memory region that is then transferred via RDMA.

Using the write list, the data payload is moved by the device and no
extra data copying is necessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Devesh Sharma <devesh.sharma@avagotech.com>
Reviewed-By: Sagi Grimberg <sagig@mellanox.com>
Tested-by: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   21 ++++-----------------
 1 file changed, 4 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 950b654..e7cf976 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -418,28 +418,15 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	/*
 	 * Chunks needed for results?
 	 *
+	 * o Read ops return data as write chunk(s), header as inline.
 	 * o If the expected result is under the inline threshold, all ops
 	 *   return as inline (but see later).
 	 * o Large non-read ops return as a single reply chunk.
-	 * o Large read ops return data as write chunk(s), header as inline.
-	 *
-	 * Note: the NFS code sending down multiple result segments implies
-	 * the op is one of read, readdir[plus], readlink or NFSv4 getacl.
-	 */
-
-	/*
-	 * This code can handle read chunks, write chunks OR reply
-	 * chunks -- only one type. If the request is too big to fit
-	 * inline, then we will choose read chunks. If the request is
-	 * a READ, then use write chunks to separate the file data
-	 * into pages; otherwise use reply chunks.
 	 */
-	if (rpcrdma_results_inline(rqst))
-		wtype = rpcrdma_noch;
-	else if (rqst->rq_rcv_buf.page_len == 0)
-		wtype = rpcrdma_replych;
-	else if (rqst->rq_rcv_buf.flags & XDRBUF_READ)
+	if (rqst->rq_rcv_buf.flags & XDRBUF_READ)
 		wtype = rpcrdma_writech;
+	else if (rpcrdma_results_inline(rqst))
+		wtype = rpcrdma_noch;
 	else
 		wtype = rpcrdma_replych;
 

