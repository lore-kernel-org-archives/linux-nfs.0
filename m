Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34091 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755967AbcFGTru (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 15:47:50 -0400
Subject: [PATCH v1 11/20] xprtrdma: rpcrdma_inline_fixup() overruns the
 receive page list
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Jun 2016 15:47:48 -0400
Message-ID: <20160607194748.18401.36529.stgit@manet.1015granger.net>
In-Reply-To: <20160607194001.18401.88592.stgit@manet.1015granger.net>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the remaining length of an incoming reply is longer than the
XDR buf's page_len, switch over to the tail iovec instead of
copying more than page_len bytes into the page list.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index b3d5a72..67cd3bc 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -776,12 +776,17 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 	page_base &= ~PAGE_MASK;
 
 	if (copy_len && rqst->rq_rcv_buf.page_len) {
-		npages = PAGE_ALIGN(page_base +
-			rqst->rq_rcv_buf.page_len) >> PAGE_SHIFT;
+		int pagelist_len;
+
+		pagelist_len = rqst->rq_rcv_buf.page_len;
+		if (pagelist_len > copy_len)
+			pagelist_len = copy_len;
+		npages = PAGE_ALIGN(page_base + pagelist_len) >> PAGE_SHIFT;
 		for (; i < npages; i++) {
 			curlen = PAGE_SIZE - page_base;
-			if (curlen > copy_len)
-				curlen = copy_len;
+			if (curlen > pagelist_len)
+				curlen = pagelist_len;
+
 			dprintk("RPC:       %s: page %d"
 				" srcp 0x%p len %d curlen %d\n",
 				__func__, i, srcp, copy_len, curlen);
@@ -791,7 +796,8 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 			kunmap_atomic(destp);
 			srcp += curlen;
 			copy_len -= curlen;
-			if (copy_len == 0)
+			pagelist_len -= curlen;
+			if (!pagelist_len)
 				break;
 			page_base = 0;
 		}

