Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43396 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626Ab1EVXuy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 19:50:54 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v5 11/38] SUNRPC: introduce xdr_init_decode_pages
Date: Mon, 23 May 2011 02:50:18 +0300
Message-Id: <1306108218-28222-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD99F9B.2040406@panasas.com>
References: <4DD99F9B.2040406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Initialize xdr_stream and xdr_buf using an array of page pointers
and length of buffer.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/dir.c               |    9 ++-------
 fs/nfs/nfs4filelayout.c    |    9 ++-------
 fs/nfs/nfs4filelayoutdev.c |    9 ++-------
 include/linux/sunrpc/xdr.h |    2 ++
 net/sunrpc/xdr.c           |   19 +++++++++++++++++++
 5 files changed, 27 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 7237672..f673a9e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -512,12 +512,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
 				struct page **xdr_pages, struct page *page, unsigned int buflen)
 {
 	struct xdr_stream stream;
-	struct xdr_buf buf = {
-		.pages = xdr_pages,
-		.page_len = buflen,
-		.buflen = buflen,
-		.len = buflen,
-	};
+	struct xdr_buf buf;
 	struct page *scratch;
 	struct nfs_cache_array *array;
 	unsigned int count = 0;
@@ -527,7 +522,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
 	if (scratch == NULL)
 		return -ENOMEM;
 
-	xdr_init_decode(&stream, &buf, NULL);
+	xdr_init_decode_pages(&stream, &buf, xdr_pages, buflen);
 	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
 
 	do {
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index c181a8b..5b3080d 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -509,12 +509,7 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 			 gfp_t gfp_flags)
 {
 	struct xdr_stream stream;
-	struct xdr_buf buf = {
-		.pages =  lgr->layoutp->pages,
-		.page_len =  lgr->layoutp->len,
-		.buflen =  lgr->layoutp->len,
-		.len = lgr->layoutp->len,
-	};
+	struct xdr_buf buf;
 	struct page *scratch;
 	__be32 *p;
 	uint32_t nfl_util;
@@ -526,7 +521,7 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 	if (!scratch)
 		return -ENOMEM;
 
-	xdr_init_decode(&stream, &buf, NULL);
+	xdr_init_decode_pages(&stream, &buf, lgr->layoutp->pages, lgr->layoutp->len);
 	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
 
 	/* 20 = ufl_util (4), first_stripe_index (4), pattern_offset (8),
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 5914659..3b7bf13 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -308,12 +308,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
 	u8 max_stripe_index;
 	struct nfs4_file_layout_dsaddr *dsaddr = NULL;
 	struct xdr_stream stream;
-	struct xdr_buf buf = {
-		.pages = pdev->pages,
-		.page_len = pdev->pglen,
-		.buflen = pdev->pglen,
-		.len = pdev->pglen,
-	};
+	struct xdr_buf buf;
 	struct page *scratch;
 
 	/* set up xdr stream */
@@ -321,7 +316,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
 	if (!scratch)
 		goto out_err;
 
-	xdr_init_decode(&stream, &buf, NULL);
+	xdr_init_decode_pages(&stream, &buf, pdev->pages, pdev->pglen);
 	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
 
 	/* Get the stripe count (number of stripe index) */
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index fc84b7a..a20970e 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -216,6 +216,8 @@ extern __be32 *xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes);
 extern void xdr_write_pages(struct xdr_stream *xdr, struct page **pages,
 		unsigned int base, unsigned int len);
 extern void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
+extern void xdr_init_decode_pages(struct xdr_stream *xdr, struct xdr_buf *buf,
+		struct page **pages, unsigned int len);
 extern void xdr_set_scratch_buffer(struct xdr_stream *xdr, void *buf, size_t buflen);
 extern __be32 *xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes);
 extern void xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 679cd67..f008c14 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -638,6 +638,25 @@ void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
 }
 EXPORT_SYMBOL_GPL(xdr_init_decode);
 
+/**
+ * xdr_init_decode - Initialize an xdr_stream for decoding data.
+ * @xdr: pointer to xdr_stream struct
+ * @buf: pointer to XDR buffer from which to decode data
+ * @pages: list of pages to decode into
+ * @len: length in bytes of buffer in pages
+ */
+void xdr_init_decode_pages(struct xdr_stream *xdr, struct xdr_buf *buf,
+			   struct page **pages, unsigned int len)
+{
+	memset(buf, 0, sizeof(*buf));
+	buf->pages =  pages;
+	buf->page_len =  len;
+	buf->buflen =  len;
+	buf->len = len;
+	xdr_init_decode(xdr, buf, NULL);
+}
+EXPORT_SYMBOL_GPL(xdr_init_decode_pages);
+
 static __be32 * __xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes)
 {
 	__be32 *p = xdr->p;
-- 
1.7.3.4

