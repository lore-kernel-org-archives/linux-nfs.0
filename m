From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 031/112] SUNRPC: Prevent mixed sign comparisons in
	rpcrdma_convert_iovs()
Date: Fri, 25 Jan 2008 11:37:31 -0500
Message-ID: <20080125163731.31887.345.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14365 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755453AbYAYRAA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:00 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxsee010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:59 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Keep the type of the buffer position the same during iovec conversion to
reduce the likelihood of unexpected results from comparisons and length
computations.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index ee8de7a..4f87d91 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -83,7 +83,7 @@ static const char transfertypes[][12] = {
  */
 
 static int
-rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, int pos,
+rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 	enum rpcrdma_chunktype type, struct rpcrdma_mr_seg *seg, int nsegs)
 {
 	int len, n = 0, p;
@@ -169,7 +169,7 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_task->tk_xprt);
 	int nsegs, nchunks = 0;
-	int pos;
+	unsigned int pos;
 	struct rpcrdma_mr_seg *seg = req->rl_segments;
 	struct rpcrdma_read_chunk *cur_rchunk = NULL;
 	struct rpcrdma_write_array *warray = NULL;
@@ -213,7 +213,7 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 					(__be32 *)&cur_rchunk->rc_target.rs_offset,
 					seg->mr_base);
 			dprintk("RPC:       %s: read chunk "
-				"elem %d@0x%llx:0x%x pos %d (%s)\n", __func__,
+				"elem %d@0x%llx:0x%x pos %u (%s)\n", __func__,
 				seg->mr_len, (unsigned long long)seg->mr_base,
 				seg->mr_rkey, pos, n < nsegs ? "more" : "last");
 			cur_rchunk++;
