Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35315 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755000AbcFTQNN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 12:13:13 -0400
Subject: [PATCH v3 18/25] xprtrdma: rpcrdma_inline_fixup() overruns the
 receive page list
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 20 Jun 2016 12:11:02 -0400
Message-ID: <20160620161102.10809.4770.stgit@manet.1015granger.net>
In-Reply-To: <20160620155751.10809.22262.stgit@manet.1015granger.net>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
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
index f60d229..e3560c2 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -773,12 +773,17 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
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
@@ -788,7 +793,8 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 			kunmap_atomic(destp);
 			srcp += curlen;
 			copy_len -= curlen;
-			if (copy_len == 0)
+			pagelist_len -= curlen;
+			if (!pagelist_len)
 				break;
 			page_base = 0;
 		}

