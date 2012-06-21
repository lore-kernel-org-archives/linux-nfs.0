Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55816 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932759Ab2FUVvd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jun 2012 17:51:33 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/8] SUNRPC: Don't decode beyond the end of the RPC reply message
Date: Thu, 21 Jun 2012 17:51:21 -0400
Message-Id: <1340315487-18309-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1340315487-18309-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1340315487-18309-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that xdr_inline_decode() will automatically cross into the page
buffers, we need to ensure that it doesn't exceed the total reply
message length.

This patch sets up a counter that tracks the number of words
remaining in the reply message, and ensures that xdr_inline_decode,
xdr_read_pages and xdr_enter_page respect the end of message boundary.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/xdr.h |    1 +
 net/sunrpc/xdr.c           |   18 +++++++++++++++---
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index af70af3..f1e7f88 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -205,6 +205,7 @@ struct xdr_stream {
 	struct kvec *iov;	/* pointer to the current kvec */
 	struct kvec scratch;	/* Scratch buffer */
 	struct page **page_ptr;	/* pointer to the current page */
+	unsigned int nwords;	/* Remaining decode buffer length */
 };
 
 /*
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index fddcccf..14eb048 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -632,6 +632,7 @@ void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
 	xdr->buf = buf;
 	xdr->scratch.iov_base = NULL;
 	xdr->scratch.iov_len = 0;
+	xdr->nwords = XDR_QUADLEN(buf->len);
 	if (buf->head[0].iov_len != 0)
 		xdr_set_iov(xdr, buf->head, p, buf->len);
 	else if (buf->page_len != 0)
@@ -660,12 +661,14 @@ EXPORT_SYMBOL_GPL(xdr_init_decode_pages);
 
 static __be32 * __xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes)
 {
+	unsigned int nwords = XDR_QUADLEN(nbytes);
 	__be32 *p = xdr->p;
-	__be32 *q = p + XDR_QUADLEN(nbytes);
+	__be32 *q = p + nwords;
 
-	if (unlikely(q > xdr->end || q < p))
+	if (unlikely(nwords > xdr->nwords || q > xdr->end || q < p))
 		return NULL;
 	xdr->p = q;
+	xdr->nwords -= nwords;
 	return p;
 }
 
@@ -746,9 +749,16 @@ void xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
 	struct xdr_buf *buf = xdr->buf;
 	struct kvec *iov;
 	ssize_t shift;
+	unsigned int nwords = XDR_QUADLEN(len);
 	unsigned int end;
 	int padding;
 
+	if (xdr->nwords == 0)
+		return;
+	if (nwords > xdr->nwords) {
+		nwords = xdr->nwords;
+		len = nwords << 2;
+	}
 	/* Realign pages to current pointer position */
 	iov  = buf->head;
 	shift = iov->iov_len + (char *)iov->iov_base - (char *)xdr->p;
@@ -758,7 +768,7 @@ void xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
 	/* Truncate page data and move it into the tail */
 	if (buf->page_len > len)
 		xdr_shrink_pagelen(buf, buf->page_len - len);
-	padding = (XDR_QUADLEN(len) << 2) - len;
+	padding = (nwords << 2) - len;
 	xdr->iov = iov = buf->tail;
 	/* Compute remaining message length.  */
 	end = iov->iov_len;
@@ -773,6 +783,7 @@ void xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
 	 */
 	xdr->p = (__be32 *)((char *)iov->iov_base + padding);
 	xdr->end = (__be32 *)((char *)iov->iov_base + end);
+	xdr->nwords = XDR_QUADLEN(end);
 }
 EXPORT_SYMBOL_GPL(xdr_read_pages);
 
@@ -794,6 +805,7 @@ void xdr_enter_page(struct xdr_stream *xdr, unsigned int len)
 	 * set remaining message length.
 	 */
 	xdr_set_page_base(xdr, 0, len);
+	xdr->nwords += XDR_QUADLEN(xdr->buf->page_len);
 }
 EXPORT_SYMBOL_GPL(xdr_enter_page);
 
-- 
1.7.10.2

