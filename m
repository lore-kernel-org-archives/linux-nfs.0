Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:31011 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624AbaLQWfb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2014 17:35:31 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] SUNRPC: Add the ability to zero out data pages
Date: Wed, 17 Dec 2014 17:35:25 -0500
Message-ID: <1418855726-14262-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1418855726-14262-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1418855726-14262-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds the ability to "read a hole" into a set of XDR data
pages attached to a specific request.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 include/linux/sunrpc/xdr.h |  1 +
 net/sunrpc/xdr.c           | 45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 70c6b92..3ec52d2 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -229,6 +229,7 @@ extern __be32 *xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes);
 extern unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
+extern uint64_t xdr_read_hole(struct xdr_stream *, uint64_t);
 
 #endif /* __KERNEL__ */
 
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 290af97..722f526 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -220,6 +220,38 @@ _shift_data_right_pages(struct page **pages, size_t pgto_base,
 }
 
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
  * _copy_to_pages
  * @pages: array of pages
  * @pgbase: page vector address of destination
@@ -970,6 +1002,19 @@ unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
 }
 EXPORT_SYMBOL_GPL(xdr_read_pages);
 
+uint64_t xdr_read_hole(struct xdr_stream *xdr, uint64_t length)
+{
+	struct xdr_buf *buf = xdr->buf;
+
+	if (length > buf->page_len)
+		length = buf->page_len;
+
+	xdr_align_pages(xdr, length);
+	_zero_data_pages(buf->pages, buf->page_base, length);
+	return length;
+}
+EXPORT_SYMBOL_GPL(xdr_read_hole);
+
 /**
  * xdr_enter_page - decode data from the XDR page
  * @xdr: pointer to xdr_stream struct
-- 
2.1.3

