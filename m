Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35967 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751786AbdFHPxS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jun 2017 11:53:18 -0400
Subject: [PATCH v2 12/13] xprtrdma: Replace PAGE_MASK with offset_in_page()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 08 Jun 2017 11:53:16 -0400
Message-ID: <20170608155316.18945.60694.stgit@manet.1015granger.net>
In-Reply-To: <20170608154339.18945.5500.stgit@manet.1015granger.net>
References: <20170608154339.18945.5500.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Reported by: Geliang Tang <geliangtang@gmail.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index b6584ae..ca4d6e4 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -141,7 +141,7 @@ static bool rpcrdma_args_inline(struct rpcrdma_xprt *r_xprt,
 
 	if (xdr->page_len) {
 		remaining = xdr->page_len;
-		offset = xdr->page_base & ~PAGE_MASK;
+		offset = offset_in_page(xdr->page_base);
 		count = 0;
 		while (remaining) {
 			remaining -= min_t(unsigned int,
@@ -222,7 +222,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 	len = xdrbuf->page_len;
 	ppages = xdrbuf->pages + (xdrbuf->page_base >> PAGE_SHIFT);
-	page_base = xdrbuf->page_base & ~PAGE_MASK;
+	page_base = offset_in_page(xdrbuf->page_base);
 	p = 0;
 	while (len && n < RPCRDMA_MAX_SEGS) {
 		if (!ppages[p]) {
@@ -540,7 +540,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 			goto out;
 
 		page = virt_to_page(xdr->tail[0].iov_base);
-		page_base = (unsigned long)xdr->tail[0].iov_base & ~PAGE_MASK;
+		page_base = offset_in_page(xdr->tail[0].iov_base);
 
 		/* If the content in the page list is an odd length,
 		 * xdr_write_pages() has added a pad at the beginning
@@ -557,7 +557,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 */
 	if (xdr->page_len) {
 		ppages = xdr->pages + (xdr->page_base >> PAGE_SHIFT);
-		page_base = xdr->page_base & ~PAGE_MASK;
+		page_base = offset_in_page(xdr->page_base);
 		remaining = xdr->page_len;
 		while (remaining) {
 			sge_no++;
@@ -587,7 +587,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 */
 	if (xdr->tail[0].iov_len) {
 		page = virt_to_page(xdr->tail[0].iov_base);
-		page_base = (unsigned long)xdr->tail[0].iov_base & ~PAGE_MASK;
+		page_base = offset_in_page(xdr->tail[0].iov_base);
 		len = xdr->tail[0].iov_len;
 
 map_tail:
@@ -878,9 +878,9 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	srcp += curlen;
 	copy_len -= curlen;
 
-	page_base = rqst->rq_rcv_buf.page_base;
-	ppages = rqst->rq_rcv_buf.pages + (page_base >> PAGE_SHIFT);
-	page_base &= ~PAGE_MASK;
+	ppages = rqst->rq_rcv_buf.pages +
+		(rqst->rq_rcv_buf.page_base >> PAGE_SHIFT);
+	page_base = offset_in_page(rqst->rq_rcv_buf.page_base);
 	fixup_copy_count = 0;
 	if (copy_len && rqst->rq_rcv_buf.page_len) {
 		int pagelist_len;

