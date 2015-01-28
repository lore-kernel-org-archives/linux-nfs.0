Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx142.netapp.com ([216.240.21.19]:44857 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761530AbbA1Un6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 15:43:58 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 3/6] SUNRPC: Add the ability to expand holes in data pages
Date: Wed, 28 Jan 2015 15:43:47 -0500
Message-ID: <1422477830-28090-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1422477830-28090-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1422477830-28090-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds the ability to "read a hole" into a set of XDR data
pages by taking the following steps:

1) Shift all data after the current xdr->p to the right, possibly into
   the tail,
2) Zero the specified range, and
3) Update xdr->p to point beyond the hole.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 include/linux/sunrpc/xdr.h |   1 +
 net/sunrpc/xdr.c           | 104 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 105 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 70c6b92..81c5a3f 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -229,6 +229,7 @@ extern __be32 *xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes);
 extern unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
+extern size_t xdr_expand_hole(struct xdr_stream *, size_t, size_t);
 
 #endif /* __KERNEL__ */
 
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index b1c4ffb..f71e227 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -219,6 +219,40 @@ _shift_data_right_pages(struct page **pages, size_t pgto_base,
 	} while ((len -= copy) != 0);
 }
 
+static void
+_shift_data_right_tail(struct xdr_buf *buf, size_t pgfrom_base, size_t len)
+{
+	struct kvec *tail = buf->tail;
+
+	/* Make room for new data. */
+	if (tail->iov_len > 0)
+		memmove((char *)tail->iov_base + len, tail->iov_base, len);
+
+	_copy_from_pages((char *)tail->iov_base,
+			 buf->pages,
+			 buf->page_base + pgfrom_base,
+			 len);
+
+	tail->iov_len += len;
+}
+
+static void
+_shift_data_right(struct xdr_buf *buf, size_t to, size_t from, size_t len)
+{
+	size_t shift = len;
+
+	if ((to + len) > buf->page_len) {
+		shift = (to + len) - buf->page_len;
+		_shift_data_right_tail(buf, (from + len) - shift, shift);
+		shift = len - shift;
+	}
+
+	_shift_data_right_pages(buf->pages,
+				buf->page_base + to,
+				buf->page_base + from,
+				shift);
+}
+
 /**
  * _copy_to_pages
  * @pages: array of pages
@@ -304,6 +338,38 @@ _copy_from_pages(char *p, struct page **pages, size_t pgbase, size_t len)
 EXPORT_SYMBOL_GPL(_copy_from_pages);
 
 /**
+ * _zero_data_pages
+ * @pages: array of pages
+ * @pgbase: beginning page vector address
+ * @len: length
+ */
+static void
+_zero_data_pages(struct page **pages, size_t pgbase, size_t len)
+{
+	struct page **page;
+	char *vpage;
+	size_t zero;
+
+	page = pages + (pgbase >> PAGE_CACHE_SHIFT);
+	pgbase &= ~PAGE_CACHE_MASK;
+
+	do {
+		zero = len;
+		if (pgbase + zero > PAGE_SIZE)
+			zero = PAGE_SIZE - pgbase;
+
+		vpage = kmap_atomic(*page);
+		memset(vpage + pgbase, 0, zero);
+		flush_dcache_page(*page);
+		kunmap_atomic(vpage);
+
+		page++;
+		pgbase = 0;
+
+	} while ((len -= zero) != 0);
+}
+
+/**
  * xdr_shrink_bufhead
  * @buf: xdr_buf
  * @len: bytes to remove from buf->head[0]
@@ -445,6 +511,24 @@ unsigned int xdr_stream_pos(const struct xdr_stream *xdr)
 EXPORT_SYMBOL_GPL(xdr_stream_pos);
 
 /**
+ * xdr_page_pos - Return the current offset from the start of the xdr->buf->pages
+ * @xdr: pointer to struct xdr_stream
+ */
+static size_t xdr_page_pos(const struct xdr_stream *xdr)
+{
+	unsigned int offset;
+	unsigned int base = xdr->buf->page_len;
+	void *kaddr = xdr->buf->tail->iov_base;;
+
+	if (xdr->page_ptr) {
+		base   = (xdr->page_ptr - xdr->buf->pages) * PAGE_SIZE;
+		kaddr  = page_address(*xdr->page_ptr);
+	}
+	offset = xdr->p - (__be32 *)kaddr;
+	return base + (offset * sizeof(__be32));
+}
+
+/**
  * xdr_init_encode - Initialize a struct xdr_stream for sending data.
  * @xdr: pointer to xdr_stream struct
  * @buf: pointer to XDR buffer in which to encode data
@@ -976,6 +1060,26 @@ unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
 }
 EXPORT_SYMBOL_GPL(xdr_read_pages);
 
+size_t xdr_expand_hole(struct xdr_stream *xdr, size_t offset, size_t length)
+{
+	struct xdr_buf *buf = xdr->buf;
+	size_t from = 0;
+
+	if ((offset + length) > buf->page_len)
+		length = buf->page_len - offset;
+
+	if (offset == 0)
+		xdr_align_pages(xdr, xdr->nwords << 2);
+	else
+		from = xdr_page_pos(xdr);
+
+	_shift_data_right(buf, offset + length, from, xdr->nwords << 2);
+	_zero_data_pages(buf->pages, buf->page_base + offset, length);
+	xdr_set_page(xdr, offset + length);
+	return length;
+}
+EXPORT_SYMBOL_GPL(xdr_expand_hole);
+
 /**
  * xdr_enter_page - decode data from the XDR page
  * @xdr: pointer to xdr_stream struct
-- 
2.2.2

