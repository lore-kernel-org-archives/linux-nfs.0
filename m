Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:34448 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195AbbHCRCx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Aug 2015 13:02:53 -0400
Subject: [PATCH v4 02/16] xprtrdma: Raise maximum payload size to one
 megabyte
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 03 Aug 2015 13:02:50 -0400
Message-ID: <20150803170250.9115.64462.stgit@manet.1015granger.net>
In-Reply-To: <20150803165807.9115.23842.stgit@manet.1015granger.net>
References: <20150803165807.9115.23842.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The point of larger rsize and wsize is to reduce the per-byte cost
of memory registration and deregistration. Modern HCAs can typically
handle a megabyte or more with a single registration operation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Devesh Sharma <devesh.sharma@avagotech.com>
Reviewed-By: Sagi Grimberg <sagig@mellanox.com>
Tested-by: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/xprt_rdma.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index f49dd8b..abee472 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -165,8 +165,7 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
  * struct rpcrdma_buffer. N is the max number of outstanding requests.
  */
 
-/* temporary static scatter/gather max */
-#define RPCRDMA_MAX_DATA_SEGS	(64)	/* max scatter/gather */
+#define RPCRDMA_MAX_DATA_SEGS	((1 * 1024 * 1024) / PAGE_SIZE)
 #define RPCRDMA_MAX_SEGS 	(RPCRDMA_MAX_DATA_SEGS + 2) /* head+tail = 2 */
 
 struct rpcrdma_buffer;

