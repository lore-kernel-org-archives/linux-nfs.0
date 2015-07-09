Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:35499 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753668AbbGIUmk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 16:42:40 -0400
Subject: [PATCH v1 06/12] xprtrdma: Always provide a write list when sending
 NFS READ
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 09 Jul 2015 16:42:37 -0400
Message-ID: <20150709204237.26247.297.stgit@manet.1015granger.net>
In-Reply-To: <20150709203242.26247.4848.stgit@manet.1015granger.net>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
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
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   21 ++++-----------------
 1 file changed, 4 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 8cf9402..e569da4 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -427,28 +427,15 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
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
 

