Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34099 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1042996AbdDVBWj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Apr 2017 21:22:39 -0400
From: Geliang Tang <geliangtang@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Chuck Lever <chuck.lever@oracle.com>,
        Sagi Grimberg <sagi@grimberg.me>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] xprtrdma: use offset_in_page() macro
Date: Sat, 22 Apr 2017 09:21:14 +0800
Message-Id: <1b5bf5bd903ad97138a3a86aa6bcb9b2fc142c6e.1492762974.git.geliangtang@gmail.com>
In-Reply-To: <4dbc77ccaaed98b183cf4dba58a4fa325fd65048.1492758503.git.geliangtang@gmail.com>
References: <4dbc77ccaaed98b183cf4dba58a4fa325fd65048.1492758503.git.geliangtang@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use offset_in_page() macro instead of open-coding.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c        | 4 ++--
 net/sunrpc/xprtrdma/svc_rdma_sendto.c | 3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index a044be2..429beea 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -540,7 +540,7 @@ rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 			goto out;
 
 		page = virt_to_page(xdr->tail[0].iov_base);
-		page_base = (unsigned long)xdr->tail[0].iov_base & ~PAGE_MASK;
+		page_base = offset_in_page(xdr->tail[0].iov_base);
 
 		/* If the content in the page list is an odd length,
 		 * xdr_write_pages() has added a pad at the beginning
@@ -587,7 +587,7 @@ rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 	 */
 	if (xdr->tail[0].iov_len) {
 		page = virt_to_page(xdr->tail[0].iov_base);
-		page_base = (unsigned long)xdr->tail[0].iov_base & ~PAGE_MASK;
+		page_base = offset_in_page(xdr->tail[0].iov_base);
 		len = xdr->tail[0].iov_len;
 
 map_tail:
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 1736337..60b3f29 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -306,12 +306,11 @@ static int svc_rdma_dma_map_buf(struct svcxprt_rdma *rdma,
 				unsigned char *base,
 				unsigned int len)
 {
-	unsigned long offset = (unsigned long)base & ~PAGE_MASK;
 	struct ib_device *dev = rdma->sc_cm_id->device;
 	dma_addr_t dma_addr;
 
 	dma_addr = ib_dma_map_page(dev, virt_to_page(base),
-				   offset, len, DMA_TO_DEVICE);
+				   offset_in_page(base), len, DMA_TO_DEVICE);
 	if (ib_dma_mapping_error(dev, dma_addr))
 		return -EIO;
 
-- 
2.9.3

