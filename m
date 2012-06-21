Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55816 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932209Ab2FUVve (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jun 2012 17:51:34 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/8] SUNRPC: xdr_read_pages should return the amount of XDR encoded page data
Date: Thu, 21 Jun 2012 17:51:22 -0400
Message-Id: <1340315487-18309-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1340315487-18309-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1340315487-18309-1-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Callers of xdr_read_pages() will want to know exactly how much XDR
data is encoded in the pages after the data realignment.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/xdr.h |    2 +-
 net/sunrpc/xdr.c           |    9 ++++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index f1e7f88..2489bce1 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -223,7 +223,7 @@ extern void xdr_init_decode_pages(struct xdr_stream *xdr, struct xdr_buf *buf,
 		struct page **pages, unsigned int len);
 extern void xdr_set_scratch_buffer(struct xdr_stream *xdr, void *buf, size_t buflen);
 extern __be32 *xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes);
-extern void xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
+extern unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
 
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 14eb048..05d0920 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -743,8 +743,10 @@ EXPORT_SYMBOL_GPL(xdr_inline_decode);
  * Moves data beyond the current pointer position from the XDR head[] buffer
  * into the page list. Any data that lies beyond current position + "len"
  * bytes is moved into the XDR tail[].
+ *
+ * Returns the number of XDR encoded bytes now contained in the pages
  */
-void xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
+unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
 {
 	struct xdr_buf *buf = xdr->buf;
 	struct kvec *iov;
@@ -754,7 +756,7 @@ void xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
 	int padding;
 
 	if (xdr->nwords == 0)
-		return;
+		return 0;
 	if (nwords > xdr->nwords) {
 		nwords = xdr->nwords;
 		len = nwords << 2;
@@ -784,6 +786,7 @@ void xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
 	xdr->p = (__be32 *)((char *)iov->iov_base + padding);
 	xdr->end = (__be32 *)((char *)iov->iov_base + end);
 	xdr->nwords = XDR_QUADLEN(end);
+	return len;
 }
 EXPORT_SYMBOL_GPL(xdr_read_pages);
 
@@ -799,7 +802,7 @@ EXPORT_SYMBOL_GPL(xdr_read_pages);
  */
 void xdr_enter_page(struct xdr_stream *xdr, unsigned int len)
 {
-	xdr_read_pages(xdr, len);
+	len = xdr_read_pages(xdr, len);
 	/*
 	 * Position current pointer at beginning of tail, and
 	 * set remaining message length.
-- 
1.7.10.2

