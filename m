Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38539 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757380AbaEKUw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:52:56 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 13/43] rpc: xdr_truncate_encode
Date: Sun, 11 May 2014 16:52:18 -0400
Message-Id: <1399841568-19716-14-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This will be used in the server side in a few cases:
	- when certain operations (read, readdir, readlink) fail after
	  encoding a partial response.
	- when we run out of space after encoding a partial response.
	- in readlink, where we initially reserve PAGE_SIZE bytes for
	  data, then truncate to the actual size.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/xdr.h |    1 +
 net/sunrpc/xdr.c           |   67 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 15f9204..e7bb2e3 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -215,6 +215,7 @@ typedef int	(*kxdrdproc_t)(void *rqstp, struct xdr_stream *xdr, void *obj);
 
 extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
 extern __be32 *xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes);
+extern void xdr_truncate_encode(struct xdr_stream *xdr, size_t len);
 extern void xdr_write_pages(struct xdr_stream *xdr, struct page **pages,
 		unsigned int base, unsigned int len);
 extern unsigned int xdr_stream_pos(const struct xdr_stream *xdr);
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index dd97ba3..8ae8ee7 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -509,6 +509,73 @@ __be32 * xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes)
 EXPORT_SYMBOL_GPL(xdr_reserve_space);
 
 /**
+ * xdr_truncate_encode - truncate an encode buffer
+ * @xdr: pointer to xdr_stream
+ * @len: new length of buffer
+ *
+ * Truncates the xdr stream, so that xdr->buf->len == len,
+ * and xdr->p points at offset len from the start of the buffer, and
+ * head, tail, and page lengths are adjusted to correspond.
+ *
+ * If this means moving xdr->p to a different buffer, we assume that
+ * that the end pointer should be set to the end of the current page,
+ * except in the case of the head buffer when we assume the head
+ * buffer's current length represents the end of the available buffer.
+ *
+ * This is *not* safe to use on a buffer that already has inlined page
+ * cache pages (as in a zero-copy server read reply), except for the
+ * simple case of truncating from one position in the tail to another.
+ *
+ */
+void xdr_truncate_encode(struct xdr_stream *xdr, size_t len)
+{
+	struct xdr_buf *buf = xdr->buf;
+	struct kvec *head = buf->head;
+	struct kvec *tail = buf->tail;
+	int fraglen;
+	int new, old;
+
+	if (len > buf->len) {
+		WARN_ON_ONCE(1);
+		return;
+	}
+
+	fraglen = min_t(int, buf->len - len, tail->iov_len);
+	tail->iov_len -= fraglen;
+	buf->len -= fraglen;
+	if (tail->iov_len && buf->len == len) {
+		xdr->p = tail->iov_base + tail->iov_len;
+		/* xdr->end, xdr->iov should be set already */
+		return;
+	}
+	WARN_ON_ONCE(fraglen);
+	fraglen = min_t(int, buf->len - len, buf->page_len);
+	buf->page_len -= fraglen;
+	buf->len -= fraglen;
+
+	new = buf->page_base + buf->page_len;
+	old = new + fraglen;
+	xdr->page_ptr -= (old >> PAGE_SHIFT) - (new >> PAGE_SHIFT);
+
+	if (buf->page_len && buf->len == len) {
+		xdr->p = page_address(*xdr->page_ptr);
+		xdr->end = (void *)xdr->p + PAGE_SIZE;
+		xdr->p = (void *)xdr->p + (new % PAGE_SIZE);
+		/* xdr->iov should already be NULL */
+		return;
+	}
+	if (fraglen)
+		xdr->end = head->iov_base + head->iov_len;
+	/* (otherwise assume xdr->end is already set) */
+	head->iov_len = len;
+	buf->len = len;
+	xdr->p = head->iov_base + head->iov_len;
+	xdr->iov = buf->head;
+	xdr->page_ptr -= 1;
+}
+EXPORT_SYMBOL(xdr_truncate_encode);
+
+/**
  * xdr_write_pages - Insert a list of pages into an XDR buffer for sending
  * @xdr: pointer to xdr_stream
  * @pages: list of pages
-- 
1.7.9.5

