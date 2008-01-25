From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 032/112] SUNRPC: Fix an unnecessary implicit type cast in
	rpcrdma_count_chunks()
Date: Fri, 25 Jan 2008 11:37:32 -0500
Message-ID: <20080125163731.31887.65775.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14334 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754397AbYAYQ7q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:46 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxdsw010119
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:45 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Nit: rl_nchunks is an unsigned integer, so pass it into
rpcrdma_count_chunks() via an unsigned integer argument.  This eliminates
a harmless mixed sign comparison in rpcrdma_count_chunks()

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 4f87d91..770b9ab 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -552,7 +552,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
  * RDMA'd by server. See map at rpcrdma_create_chunks()! :-)
  */
 static int
-rpcrdma_count_chunks(struct rpcrdma_rep *rep, int max, int wrchunk, __be32 **iptrp)
+rpcrdma_count_chunks(struct rpcrdma_rep *rep, unsigned int max, int wrchunk, __be32 **iptrp)
 {
 	unsigned int i, total_len;
 	struct rpcrdma_write_chunk *cur_wchunk;
