Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:44129 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932738AbbCPVR6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Mar 2015 17:17:58 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v3 4/5] SUNRPC: Add the ability to shift data to a specific offset
Date: Mon, 16 Mar 2015 17:17:45 -0400
Message-ID: <1426540666-31896-5-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1426540666-31896-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1426540666-31896-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Expanding holes tends to put the data content a few bytes to the right
of where we want it.  This patch implements a left-shift operation to
line everything up properly.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 include/linux/sunrpc/xdr.h |   1 +
 net/sunrpc/xdr.c           | 132 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 133 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 81c5a3f..3670bf6 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -230,6 +230,7 @@ extern unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
 extern size_t xdr_expand_hole(struct xdr_stream *, size_t, size_t);
+extern uint64_t xdr_align_data(struct xdr_stream *, uint64_t, uint64_t);
 
 #endif /* __KERNEL__ */
 
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index be154e7..38efc8f 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -16,6 +16,9 @@
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/msg_prot.h>
 
+static void _copy_to_pages(struct page **, size_t, const char *, size_t);
+
+
 /*
  * XDR functions for basic NFS types
  */
@@ -253,6 +256,117 @@ _shift_data_right(struct xdr_buf *buf, size_t to, size_t from, size_t len)
 				shift);
 }
 
+
+/**
+ * _shift_data_left_pages
+ * @pages: vector of pages containing both the source and dest memory area.
+ * @pgto_base: page vector address of destination
+ * @pgfrom_base: page vector address of source
+ * @len: number of bytes to copy
+ *
+ * Note: the addresses pgto_base and pgfrom_base are both calculated in
+ *       the same way:
+ *            if a memory area starts at byte 'base' in page 'pages[i]',
+ *            then its address is given as (i << PAGE_CACHE_SHIFT) + base
+ * Alse note: pgto_base must be < pgfrom_base, but the memory areas
+ * 	they point to may overlap.
+ */
+static void
+_shift_data_left_pages(struct page **pages, size_t pgto_base,
+			size_t pgfrom_base, size_t len)
+{
+	struct page **pgfrom, **pgto;
+	char *vfrom, *vto;
+	size_t copy;
+
+	BUG_ON(pgfrom_base <= pgto_base);
+
+	pgto = pages + (pgto_base >> PAGE_CACHE_SHIFT);
+	pgfrom = pages + (pgfrom_base >> PAGE_CACHE_SHIFT);
+
+	pgto_base = pgto_base % PAGE_CACHE_SIZE;
+	pgfrom_base = pgfrom_base % PAGE_CACHE_SIZE;
+
+	do {
+		if (pgto_base >= PAGE_CACHE_SIZE) {
+			pgto_base = 0;
+			pgto++;
+		}
+		if (pgfrom_base >= PAGE_CACHE_SIZE){
+			pgfrom_base = 0;
+			pgfrom++;
+		}
+
+		copy = len;
+		if (copy > (PAGE_CACHE_SIZE - pgto_base))
+			copy = PAGE_CACHE_SIZE - pgto_base;
+		if (copy > (PAGE_CACHE_SIZE - pgfrom_base))
+			copy = PAGE_CACHE_SIZE - pgfrom_base;
+
+		if (pgto_base == 131056)
+			break;
+
+		vto = kmap_atomic(*pgto);
+		if (*pgto != *pgfrom) {
+			vfrom = kmap_atomic(*pgfrom);
+			memcpy(vto + pgto_base, vfrom + pgfrom_base, copy);
+			kunmap_atomic(vfrom);
+		} else
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
+static void
+_shift_data_left_tail(struct xdr_buf *buf, size_t pgto_base,
+		      size_t tail_from, size_t len)
+{
+	struct kvec *tail = buf->tail;
+	size_t shift = len;
+
+	if (len == 0)
+		return;
+	if (pgto_base + len > buf->page_len)
+		shift = buf->page_len - pgto_base;
+
+	_copy_to_pages(buf->pages,
+			buf->page_base + pgto_base,
+			(char *)(tail->iov_base + tail_from),
+			shift);
+
+	memmove((char *)tail->iov_base, tail->iov_base + tail_from + shift, shift);
+	tail->iov_len -= (tail_from + shift);
+}
+
+static void
+_shift_data_left(struct xdr_buf *buf, size_t to, size_t from, size_t len)
+{
+	size_t shift = len;
+
+	if (from < buf->page_len) {
+		shift = min(len, buf->page_len - from);
+		_shift_data_left_pages(buf->pages,
+					buf->page_base + to,
+					buf->page_base + from,
+					shift);
+		to += shift;
+		from += shift;
+		shift = len - shift;
+	}
+
+	if (shift == 0)
+		return;
+	if (from >= buf->page_len)
+		from -= buf->page_len;
+
+	_shift_data_left_tail(buf, to, from, shift);
+}
+
 /**
  * _copy_to_pages
  * @pages: array of pages
@@ -1075,6 +1189,24 @@ size_t xdr_expand_hole(struct xdr_stream *xdr, size_t offset, size_t length)
 }
 EXPORT_SYMBOL_GPL(xdr_expand_hole);
 
+uint64_t xdr_align_data(struct xdr_stream *xdr, uint64_t offset, uint64_t length)
+{
+	struct xdr_buf *buf = xdr->buf;
+
+	if (offset + length > buf->page_len)
+		length = buf->page_len - offset;
+
+	if (offset == 0)
+		xdr_align_pages(xdr, xdr->nwords << 2);
+	else
+		_shift_data_left(buf, offset, xdr_page_pos(xdr), xdr->nwords << 2);
+
+	xdr->nwords -= XDR_QUADLEN(length);
+	xdr_set_page(xdr, offset + length);
+	return length;
+}
+EXPORT_SYMBOL_GPL(xdr_align_data);
+
 /**
  * xdr_enter_page - decode data from the XDR page
  * @xdr: pointer to xdr_stream struct
-- 
2.3.3

