Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38601 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757711AbaEKUxC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:53:02 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 27/43] rpc: define xdr_restrict_buflen
Date: Sun, 11 May 2014 16:52:32 -0400
Message-Id: <1399841568-19716-28-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

With this xdr_reserve_space can help us enforce various limits.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/xdr.h |    1 +
 net/sunrpc/xdr.c           |   29 +++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index b23d69f..70c6b92 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -217,6 +217,7 @@ extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32
 extern __be32 *xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes);
 extern void xdr_commit_encode(struct xdr_stream *xdr);
 extern void xdr_truncate_encode(struct xdr_stream *xdr, size_t len);
+extern int xdr_restrict_buflen(struct xdr_stream *xdr, int newbuflen);
 extern void xdr_write_pages(struct xdr_stream *xdr, struct page **pages,
 		unsigned int base, unsigned int len);
 extern unsigned int xdr_stream_pos(const struct xdr_stream *xdr);
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index e65d6b6..f97e3df 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -650,6 +650,35 @@ void xdr_truncate_encode(struct xdr_stream *xdr, size_t len)
 EXPORT_SYMBOL(xdr_truncate_encode);
 
 /**
+ * xdr_restrict_buflen - decrease available buffer space
+ * @xdr: pointer to xdr_stream
+ * @newbuflen: new maximum number of bytes available
+ *
+ * Adjust our idea of how much space is available in the buffer.
+ * If we've already used too much space in the buffer, returns -1.
+ * If the available space is already smaller than newbuflen, returns 0
+ * and does nothing.  Otherwise, adjusts xdr->buf->buflen to newbuflen
+ * and ensures xdr->end is set at most offset newbuflen from the start
+ * of the buffer.
+ */
+int xdr_restrict_buflen(struct xdr_stream *xdr, int newbuflen)
+{
+	struct xdr_buf *buf = xdr->buf;
+	int left_in_this_buf = (void *)xdr->end - (void *)xdr->p;
+	int end_offset = buf->len + left_in_this_buf;
+
+	if (newbuflen < 0 || newbuflen < buf->len)
+		return -1;
+	if (newbuflen > buf->buflen)
+		return 0;
+	if (newbuflen < end_offset)
+		xdr->end = (void *)xdr->end + newbuflen - end_offset;
+	buf->buflen = newbuflen;
+	return 0;
+}
+EXPORT_SYMBOL(xdr_restrict_buflen);
+
+/**
  * xdr_write_pages - Insert a list of pages into an XDR buffer for sending
  * @xdr: pointer to xdr_stream
  * @pages: list of pages
-- 
1.7.9.5

