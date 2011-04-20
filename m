Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57222 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab1DTR3D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 13:29:03 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC 22/27] sunrpc: New xdr_rewind_stream()
Date: Wed, 20 Apr 2011 20:29:01 +0300
Message-Id: <1303320541-21787-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DAF0DE1.6020609@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

In a long encoded xdr stream, we might run out of allocated xdr space.
In some situations it is possibly to reset the xdr buffer to a previuos
good state and send a parial list, which is better then just BUGing as
today or completely failing the xdr.

* define such API that can move the xdr pointer to a good known
  state before the failed encoding.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/xdr.h |    1 +
 net/sunrpc/xdr.c           |   21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index fc84b7a..bf17e38 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -213,6 +213,7 @@ typedef int	(*kxdrdproc_t)(void *rqstp, struct xdr_stream *xdr, void *obj);
 
 extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
 extern __be32 *xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes);
+extern __be32 *xdr_rewind_stream(struct xdr_stream *xdr, __be32 *q);
 extern void xdr_write_pages(struct xdr_stream *xdr, struct page **pages,
 		unsigned int base, unsigned int len);
 extern void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 679cd67..3e0d79e 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -518,6 +518,27 @@ __be32 * xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes)
 EXPORT_SYMBOL_GPL(xdr_reserve_space);
 
 /**
+ * xdr_rewind_stream - rewind a stream back to some checkpoint
+ * @xdr: pointer to xdr_stream
+ * @q: some checkpoint at historical place of @xdr
+ *
+ * Restors an xdr stream to some historical point. @q must be
+ * a logical xdr point in the past that was sampled by @q = @xdr->p.
+ */
+__be32 *xdr_rewind_stream(struct xdr_stream *xdr, __be32 *q)
+{
+	size_t nbytes = (xdr->p - q) << 2;
+
+	BUG_ON(xdr->p < q);
+	BUG_ON(nbytes > xdr->iov->iov_len || nbytes > xdr->buf->len);
+	xdr->p = q;
+	xdr->iov->iov_len -= nbytes;
+	xdr->buf->len -= nbytes;
+	return q;
+}
+EXPORT_SYMBOL_GPL(xdr_rewind_stream);
+
+/**
  * xdr_write_pages - Insert a list of pages into an XDR buffer for sending
  * @xdr: pointer to xdr_stream
  * @pages: list of pages
-- 
1.7.3.4

