Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26285 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932791Ab2FUVvi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jun 2012 17:51:38 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 8/8] SUNRPC: Clean up xdr_read_pages and xdr_enter_page
Date: Thu, 21 Jun 2012 17:51:27 -0400
Message-Id: <1340315487-18309-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1340315487-18309-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1340315487-18309-1-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-2-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-3-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-4-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-5-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-6-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the page alignment code into a separate helper.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xdr.c |   48 ++++++++++++++++++++++++++++++------------------
 1 file changed, 30 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 9e21927..5440fc4 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -745,6 +745,30 @@ __be32 * xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes)
 }
 EXPORT_SYMBOL_GPL(xdr_inline_decode);
 
+static unsigned int xdr_align_pages(struct xdr_stream *xdr, unsigned int len)
+{
+	struct xdr_buf *buf = xdr->buf;
+	struct kvec *iov;
+	unsigned int nwords = XDR_QUADLEN(len);
+	unsigned int cur = xdr_stream_pos(xdr);
+
+	if (xdr->nwords == 0)
+		return 0;
+	if (nwords > xdr->nwords) {
+		nwords = xdr->nwords;
+		len = nwords << 2;
+	}
+	/* Realign pages to current pointer position */
+	iov  = buf->head;
+	if (cur < iov->iov_len)
+		xdr_shrink_bufhead(buf, iov->iov_len - cur);
+
+	/* Truncate page data and move it into the tail */
+	if (buf->page_len > len)
+		xdr_shrink_pagelen(buf, buf->page_len - len);
+	return len;
+}
+
 /**
  * xdr_read_pages - Ensure page-based XDR data to decode is aligned at current pointer position
  * @xdr: pointer to xdr_stream struct
@@ -761,26 +785,14 @@ unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
 	struct xdr_buf *buf = xdr->buf;
 	struct kvec *iov;
 	ssize_t shift;
-	unsigned int nwords = XDR_QUADLEN(len);
 	unsigned int end;
 	int padding;
 
-	if (xdr->nwords == 0)
+	len = xdr_align_pages(xdr, len);
+	if (len == 0)
 		return 0;
-	if (nwords > xdr->nwords) {
-		nwords = xdr->nwords;
-		len = nwords << 2;
-	}
-	/* Realign pages to current pointer position */
-	iov  = buf->head;
-	shift = iov->iov_len + (char *)iov->iov_base - (char *)xdr->p;
-	if (shift > 0)
-		xdr_shrink_bufhead(buf, shift);
 
-	/* Truncate page data and move it into the tail */
-	if (buf->page_len > len)
-		xdr_shrink_pagelen(buf, buf->page_len - len);
-	padding = (nwords << 2) - len;
+	padding = (XDR_QUADLEN(len) << 2) - len;
 	xdr->iov = iov = buf->tail;
 	/* Compute remaining message length.  */
 	end = iov->iov_len;
@@ -812,13 +824,13 @@ EXPORT_SYMBOL_GPL(xdr_read_pages);
  */
 void xdr_enter_page(struct xdr_stream *xdr, unsigned int len)
 {
-	len = xdr_read_pages(xdr, len);
+	len = xdr_align_pages(xdr, len);
 	/*
 	 * Position current pointer at beginning of tail, and
 	 * set remaining message length.
 	 */
-	xdr_set_page_base(xdr, 0, len);
-	xdr->nwords += XDR_QUADLEN(xdr->buf->page_len);
+	if (len != 0)
+		xdr_set_page_base(xdr, 0, len);
 }
 EXPORT_SYMBOL_GPL(xdr_enter_page);
 
-- 
1.7.10.2

