Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18375 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756332AbaAFV5S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 16:57:18 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>
Subject: [PATCH 2/3] SUNRPC: This patch adds functions for shifting page data
Date: Mon, 6 Jan 2014 16:57:12 -0500
Message-ID: <1389045433-22990-3-git-send-email-Anna.Schumaker@netapp.com>
In-Reply-To: <1389045433-22990-1-git-send-email-Anna.Schumaker@netapp.com>
References: <1389045433-22990-1-git-send-email-Anna.Schumaker@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Encoding a hole followed by data takes up more space than the xdr head
has allocated to it.  As a result, the data segment will already be some
number of bytes on the page (usually 20 in this case), so a shift left
operation is needed to decode data to the right location.

xdr_shift_hole() will be called to insert a hole into the page data
by shifting contents over by some number of bytes and then zeroing the
requested range.

Ideally, I want to use the offset provided by READ_PLUS to place data
exactly where it needs to be.  I have a rough (non-functioning) patch
for this that I want to hack on a little bit more before submitting.
---
 include/linux/sunrpc/xdr.h |   1 +
 net/sunrpc/xdr.c           | 115 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 115 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 15f9204..1deb79b 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -227,6 +227,7 @@ extern unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
 
+extern void xdr_shift_hole(struct xdr_stream *, size_t, size_t);
 #endif /* __KERNEL__ */
 
 #endif /* _SUNRPC_XDR_H_ */
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 1504bb1..96973e3 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -219,6 +219,95 @@ _shift_data_right_pages(struct page **pages, size_t pgto_base,
 	} while ((len -= copy) != 0);
 }
 
+/*
+ * _shift_data_left_pages
+ * @pages: vector of pages containing both the source and dest memory area
+ * @pgto_base: page vector address of destination
+ * @pgfrom_base: page vector address of source
+ * @len: number of bytes to move
+ *
+ * Note: This function does not copy data out of the tail.  It only shifts
+ *       already in the pages.
+ */
+static void
+_shift_data_left_pages(struct page **pages, size_t pgto_base,
+		size_t pgfrom_base, size_t len)
+{
+	struct page **pgfrom, **pgto;
+	char *vto, *vfrom;
+	size_t copy;
+
+	BUG_ON(pgto_base >= pgfrom_base);
+
+	pgto = pages + (pgto_base >> PAGE_CACHE_SHIFT);
+	pgfrom = pages + (pgfrom_base >> PAGE_CACHE_SHIFT);
+
+	do {
+		/* Are any pointers crossing a page boundary? */
+		if (pgto_base == PAGE_SIZE) {
+			pgto_base = 0;
+			pgto++;
+		}
+		if (pgfrom_base == PAGE_SIZE) {
+			pgfrom_base = 0;
+			pgfrom++;
+		}
+
+		copy = len;
+		if (copy > PAGE_SIZE - pgto_base)
+			copy = PAGE_SIZE - pgto_base;
+		if (copy > PAGE_SIZE - pgfrom_base)
+			copy = PAGE_SIZE - pgfrom_base;
+
+		vto = kmap_atomic(*pgto);
+		if (*pgto != *pgfrom) {
+			vfrom = kmap_atomic(*pgfrom);
+			memcpy(vto + pgto_base, vfrom + pgfrom_base, copy);
+			kunmap_atomic(vfrom);
+		};
+		if (*pgto == *pgfrom)
+			memmove(vto + pgto_base, vto + pgfrom_base, copy);
+		flush_dcache_page(*pgto);
+		kunmap_atomic(vto);
+
+		pgto_base += copy;
+		pgfrom_base += copy;
+
+	} while ((len -= copy) != 0);
+}
+
+/**
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
 /**
  * _copy_to_pages
  * @pages: array of pages
@@ -434,6 +523,22 @@ xdr_shift_buf(struct xdr_buf *buf, size_t len)
 }
 EXPORT_SYMBOL_GPL(xdr_shift_buf);
 
+static unsigned int xdr_align_pages(struct xdr_stream *, unsigned int);
+void
+xdr_shift_hole(struct xdr_stream *xdr, size_t offset, size_t length)
+{
+	struct xdr_buf *buf = xdr->buf;
+
+	if (buf->page_len == length)
+		xdr_align_pages(xdr, length);
+	else
+		_shift_data_right_pages(buf->pages, buf->page_base + length,
+				buf->page_base, buf->page_len - length);
+
+	_zero_data_pages(buf->pages, buf->page_base, length);
+}
+EXPORT_SYMBOL_GPL(xdr_shift_hole);
+
 /**
  * xdr_stream_pos - Return the current offset from the start of the xdr_stream
  * @xdr: pointer to struct xdr_stream
@@ -727,6 +832,12 @@ __be32 * xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes)
 }
 EXPORT_SYMBOL_GPL(xdr_inline_decode);
 
+static void xdr_align_pages_left(struct xdr_buf *buf, unsigned int len)
+{
+	_shift_data_left_pages(buf->pages, buf->page_base,
+				buf->page_base + len, buf->page_len - len);
+}
+
 static unsigned int xdr_align_pages(struct xdr_stream *xdr, unsigned int len)
 {
 	struct xdr_buf *buf = xdr->buf;
@@ -741,7 +852,9 @@ static unsigned int xdr_align_pages(struct xdr_stream *xdr, unsigned int len)
 	if (iov->iov_len > cur) {
 		xdr_shrink_bufhead(buf, iov->iov_len - cur);
 		xdr->nwords = XDR_QUADLEN(buf->len - cur);
-	}
+	/* cur points somewhere on the page array */
+	} else if (cur != iov->iov_len)
+		xdr_align_pages_left(buf, cur - iov->iov_len);
 
 	if (nwords > xdr->nwords) {
 		nwords = xdr->nwords;
-- 
1.8.5.2

