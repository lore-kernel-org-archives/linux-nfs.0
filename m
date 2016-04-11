Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35285 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753964AbcDKULB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2016 16:11:01 -0400
Subject: [PATCH v1 06/18] xprtrdma: Update comments in rpcrdma_marshal_req()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 Apr 2016 16:10:58 -0400
Message-ID: <20160411201058.20531.98867.stgit@manet.1015granger.net>
In-Reply-To: <20160411200323.20531.8893.stgit@manet.1015granger.net>
References: <20160411200323.20531.8893.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update documenting comments to reflect code changes over the past
year.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 0105e65..c7c9bbb 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -494,13 +494,10 @@ static void rpcrdma_inline_pullup(struct rpc_rqst *rqst)
  * Marshal a request: the primary job of this routine is to choose
  * the transfer modes. See comments below.
  *
- * Uses multiple RDMA IOVs for a request:
- *  [0] -- RPC RDMA header, which uses memory from the *start* of the
- *         preregistered buffer that already holds the RPC data in
- *         its middle.
- *  [1] -- the RPC header/data, marshaled by RPC and the NFS protocol.
- *  [2] -- optional padding.
- *  [3] -- if padded, header only in [1] and data here.
+ * Prepares up to two IOVs per Call message:
+ *
+ *  [0] -- RPC RDMA header
+ *  [1] -- the RPC header/data
  *
  * Returns zero on success, otherwise a negative errno.
  */
@@ -624,13 +621,6 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 		__func__, transfertypes[wtype], hdrlen, rpclen,
 		headerp, base, rdmab_lkey(req->rl_rdmabuf));
 
-	/*
-	 * initialize send_iov's - normally only two: rdma chunk header and
-	 * single preregistered RPC header buffer, but if padding is present,
-	 * then use a preregistered (and zeroed) pad buffer between the RPC
-	 * header and any write data. In all non-rdma cases, any following
-	 * data has been copied into the RPC header buffer.
-	 */
 	req->rl_send_iov[0].addr = rdmab_addr(req->rl_rdmabuf);
 	req->rl_send_iov[0].length = hdrlen;
 	req->rl_send_iov[0].lkey = rdmab_lkey(req->rl_rdmabuf);

