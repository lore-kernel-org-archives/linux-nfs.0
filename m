From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Add helper routines for fixing up page alignment on xdr_buf
Date: Thu, 12 Dec 2002 13:16:04 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15864.32260.972037.782551@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18MSGc-0000Iz-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Dec 2002 04:16:38 -0800
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


In order to speed up NFS reads, we attempt to copy directly from
skbuffs into the pagecache pages. As we cannot do XDR decoding in the
soft interrupts, we attempt to estimate the size of the RPC header (+
attributes,...) that will precede the actual data that goes in the
pagecache. If we get the estimate wrong, the XDR decode routines
perform a realignment of the data into the pagecache.

In the existing code, we do a multi-page kmap() from the xdr_buf into
an iovec array, in order to do the shift.

The following patch adds tools for doing the realigment without going
through the iovec array (and without having to do the deadlock-prone
multi-page kmap()).

It also adds the 2 helper routines xdr_read_pages()/xdr_write_pages()
which will be needed for NFSv4 reads/writes in order to add pre/post
operation GETATTR calls.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.51-02-nfsv4_xdr2/include/linux/sunrpc/xdr.h linux-2.5.51-03-xdr_shift/include/linux/sunrpc/xdr.h
--- linux-2.5.51-02-nfsv4_xdr2/include/linux/sunrpc/xdr.h	2002-11-22 01:51:31.000000000 +0100
+++ linux-2.5.51-03-xdr_shift/include/linux/sunrpc/xdr.h	2002-12-10 11:04:42.000000000 +0100
@@ -211,6 +211,10 @@
 	return p;
 }
 
+extern void xdr_write_pages(struct xdr_stream *xdr, struct page **pages,
+		unsigned int base, unsigned int len);
+extern void xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
+
 /*
  * Initialize an xdr_stream for decoding data.
  */
diff -u --recursive --new-file linux-2.5.51-02-nfsv4_xdr2/net/sunrpc/sunrpc_syms.c linux-2.5.51-03-xdr_shift/net/sunrpc/sunrpc_syms.c
--- linux-2.5.51-02-nfsv4_xdr2/net/sunrpc/sunrpc_syms.c	2002-11-09 02:51:52.000000000 +0100
+++ linux-2.5.51-03-xdr_shift/net/sunrpc/sunrpc_syms.c	2002-12-10 11:04:42.000000000 +0100
@@ -120,6 +120,8 @@
 EXPORT_SYMBOL(xdr_encode_pages);
 EXPORT_SYMBOL(xdr_inline_pages);
 EXPORT_SYMBOL(xdr_shift_buf);
+EXPORT_SYMBOL(xdr_write_pages);
+EXPORT_SYMBOL(xdr_read_pages);
 
 /* Debugging symbols */
 #ifdef RPC_DEBUG
diff -u --recursive --new-file linux-2.5.51-02-nfsv4_xdr2/net/sunrpc/xdr.c linux-2.5.51-03-xdr_shift/net/sunrpc/xdr.c
--- linux-2.5.51-02-nfsv4_xdr2/net/sunrpc/xdr.c	2002-11-01 22:50:09.000000000 +0100
+++ linux-2.5.51-03-xdr_shift/net/sunrpc/xdr.c	2002-12-10 15:17:14.000000000 +0100
@@ -141,7 +141,6 @@
 	xdr->len += len;
 }
 
-
 /*
  * Realign the iovec if the server missed out some reply elements
  * (such as post-op attributes,...)
@@ -318,13 +317,308 @@
 		copy_actor(desc, (char *)xdr->tail[0].iov_base + base, len);
 }
 
+
+/*
+ * Helper routines for doing 'memmove' like operations on a struct xdr_buf
+ *
+ * _shift_data_right_pages
+ * @pages: vector of pages containing both the source and dest memory area.
+ * @pgto_base: page vector address of destination
+ * @pgfrom_base: page vector address of source
+ * @len: number of bytes to copy
+ *
+ * Note: the addresses pgto_base and pgfrom_base are both calculated in
+ *       the same way:
+ *            if a memory area starts at byte 'base' in page 'pages[i]',
+ *            then its address is given as (i << PAGE_CACHE_SHIFT) + base
+ * Also note: pgfrom_base must be < pgto_base, but the memory areas
+ * 	they point to may overlap.
+ */
+static void
+_shift_data_right_pages(struct page **pages, size_t pgto_base,
+		size_t pgfrom_base, size_t len)
+{
+	struct page **pgfrom, **pgto;
+	char *vfrom, *vto;
+	size_t copy;
+
+	BUG_ON(pgto_base <= pgfrom_base);
+
+	pgto_base += len;
+	pgfrom_base += len;
+
+	pgto = pages + (pgto_base >> PAGE_CACHE_SHIFT);
+	pgfrom = pages + (pgfrom_base >> PAGE_CACHE_SHIFT);
+
+	pgto_base &= ~PAGE_CACHE_MASK;
+	pgfrom_base &= ~PAGE_CACHE_MASK;
+
+	do {
+		/* Are any pointers crossing a page boundary? */
+		if (pgto_base == 0) {
+			pgto_base = PAGE_CACHE_SIZE;
+			pgto--;
+		}
+		if (pgfrom_base == 0) {
+			pgfrom_base = PAGE_CACHE_SIZE;
+			pgfrom--;
+		}
+
+		copy = len;
+		if (copy > pgto_base)
+			copy = pgto_base;
+		if (copy > pgfrom_base)
+			copy = pgfrom_base;
+		pgto_base -= copy;
+		pgfrom_base -= copy;
+
+		vto = kmap_atomic(*pgto, KM_USER0);
+		vfrom = kmap_atomic(*pgfrom, KM_USER1);
+		memmove(vto + pgto_base, vfrom + pgfrom_base, copy);
+		kunmap_atomic(vfrom, KM_USER1);
+		kunmap_atomic(vto, KM_USER0);
+
+	} while ((len -= copy) != 0);
+}
+
+/*
+ * _copy_to_pages
+ * @pages: array of pages
+ * @pgbase: page vector address of destination
+ * @p: pointer to source data
+ * @len: length
+ *
+ * Copies data from an arbitrary memory location into an array of pages
+ * The copy is assumed to be non-overlapping.
+ */
+static void
+_copy_to_pages(struct page **pages, size_t pgbase, const char *p, size_t len)
+{
+	struct page **pgto;
+	char *vto;
+	size_t copy;
+
+	pgto = pages + (pgbase >> PAGE_CACHE_SHIFT);
+	pgbase &= ~PAGE_CACHE_MASK;
+
+	do {
+		copy = PAGE_CACHE_SIZE - pgbase;
+		if (copy > len)
+			copy = len;
+
+		vto = kmap_atomic(*pgto, KM_USER0);
+		memcpy(vto + pgbase, p, copy);
+		kunmap_atomic(vto, KM_USER0);
+
+		pgbase += copy;
+		if (pgbase == PAGE_CACHE_SIZE) {
+			pgbase = 0;
+			pgto++;
+		}
+		p += copy;
+
+	} while ((len -= copy) != 0);
+}
+
+/*
+ * _copy_from_pages
+ * @p: pointer to destination
+ * @pages: array of pages
+ * @pgbase: offset of source data
+ * @len: length
+ *
+ * Copies data into an arbitrary memory location from an array of pages
+ * The copy is assumed to be non-overlapping.
+ */
+static void
+_copy_from_pages(char *p, struct page **pages, size_t pgbase, size_t len)
+{
+	struct page **pgfrom;
+	char *vfrom;
+	size_t copy;
+
+	pgfrom = pages + (pgbase >> PAGE_CACHE_SHIFT);
+	pgbase &= ~PAGE_CACHE_MASK;
+
+	do {
+		copy = PAGE_CACHE_SIZE - pgbase;
+		if (copy > len)
+			copy = len;
+
+		vfrom = kmap_atomic(*pgfrom, KM_USER0);
+		memcpy(p, vfrom + pgbase, copy);
+		kunmap_atomic(vfrom, KM_USER0);
+
+		pgbase += copy;
+		if (pgbase == PAGE_CACHE_SIZE) {
+			pgbase = 0;
+			pgfrom++;
+		}
+		p += copy;
+
+	} while ((len -= copy) != 0);
+}
+
+/*
+ * xdr_shrink_bufhead
+ * @buf: xdr_buf
+ * @len: bytes to remove from buf->head[0]
+ *
+ * Shrinks XDR buffer's header iovec buf->head[0] by 
+ * 'len' bytes. The extra data is not lost, but is instead
+ * moved into the inlined pages and/or the tail.
+ */
 void
-xdr_shift_buf(struct xdr_buf *xdr, size_t len)
+xdr_shrink_bufhead(struct xdr_buf *buf, size_t len)
 {
-	struct iovec iov[MAX_IOVEC];
-	unsigned int nr;
+	struct iovec *head, *tail;
+	size_t copy, offs;
+	unsigned int pglen = buf->page_len;
+
+	tail = buf->tail;
+	head = buf->head;
+	BUG_ON (len > head->iov_len);
+
+	/* Shift the tail first */
+	if (tail->iov_len != 0) {
+		if (tail->iov_len > len) {
+			copy = tail->iov_len - len;
+			memmove((char *)tail->iov_base + len,
+					tail->iov_base, copy);
+		}
+		/* Copy from the inlined pages into the tail */
+		copy = len;
+		if (copy > pglen)
+			copy = pglen;
+		offs = len - copy;
+		if (offs >= tail->iov_len)
+			copy = 0;
+		else if (copy > tail->iov_len - offs)
+			copy = tail->iov_len - offs;
+		if (copy != 0)
+			_copy_from_pages((char *)tail->iov_base + offs,
+					buf->pages,
+					buf->page_base + pglen + offs - len,
+					copy);
+		/* Do we also need to copy data from the head into the tail ? */
+		if (len > pglen) {
+			offs = copy = len - pglen;
+			if (copy > tail->iov_len)
+				copy = tail->iov_len;
+			memcpy(tail->iov_base,
+					(char *)head->iov_base +
+					head->iov_len - offs,
+					copy);
+		}
+	}
+	/* Now handle pages */
+	if (pglen != 0) {
+		if (pglen > len)
+			_shift_data_right_pages(buf->pages,
+					buf->page_base + len,
+					buf->page_base,
+					pglen - len);
+		copy = len;
+		if (len > pglen)
+			copy = pglen;
+		_copy_to_pages(buf->pages, buf->page_base,
+				(char *)head->iov_base + head->iov_len - len,
+				copy);
+	}
+	head->iov_len -= len;
+	buf->len -= len;
+}
 
-	nr = xdr_kmap(iov, xdr, 0);
-	xdr_shift_iovec(iov, nr, len);
-	xdr_kunmap(xdr, 0);
+/*
+ * xdr_shrink_pagelen
+ * @buf: xdr_buf
+ * @len: bytes to remove from buf->pages
+ *
+ * Shrinks XDR buffer's page array buf->pages by 
+ * 'len' bytes. The extra data is not lost, but is instead
+ * moved into the tail.
+ */
+void
+xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
+{
+	struct iovec *tail;
+	size_t copy;
+	char *p;
+	unsigned int pglen = buf->page_len;
+
+	tail = buf->tail;
+	BUG_ON (len > pglen);
+
+	/* Shift the tail first */
+	if (tail->iov_len != 0) {
+		p = (char *)tail->iov_base + len;
+		if (tail->iov_len > len) {
+			copy = tail->iov_len - len;
+			memmove(p, tail->iov_base, copy);
+		} else
+			buf->len -= len;
+		/* Copy from the inlined pages into the tail */
+		copy = len;
+		if (copy > tail->iov_len)
+			copy = tail->iov_len;
+		_copy_from_pages((char *)tail->iov_base,
+				buf->pages, buf->page_base + pglen - len,
+				copy);
+	}
+	buf->page_len -= len;
+	buf->len -= len;
+}
+
+void
+xdr_shift_buf(struct xdr_buf *buf, size_t len)
+{
+	xdr_shrink_bufhead(buf, len);
+}
+
+void
+xdr_write_pages(struct xdr_stream *xdr, struct page **pages, unsigned int base,
+		 unsigned int len)
+{
+	struct xdr_buf *buf = xdr->buf;
+	struct iovec *iov = buf->tail;
+	buf->pages = pages;
+	buf->page_base = base;
+	buf->page_len = len;
+
+	iov->iov_base = (char *)xdr->p;
+	iov->iov_len  = 0;
+	xdr->iov = iov;
+
+	if (len & 3) {
+		unsigned int pad = 4 - (len & 3);
+
+		BUG_ON(xdr->p >= xdr->end);
+		iov->iov_base = (char *)xdr->p + (len & 3);
+		iov->iov_len  += pad;
+		len += pad;
+		*xdr->p++ = 0;
+	}
+	buf->len += len;
+}
+
+void
+xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
+{
+	struct xdr_buf *buf = xdr->buf;
+	struct iovec *iov;
+	ssize_t shift;
+
+	/* Realign pages to current pointer position */
+	iov  = buf->head;
+	shift = iov->iov_len + (char *)iov->iov_base - (char *)xdr->p;
+	if (shift > 0)
+		xdr_shrink_bufhead(buf, shift);
+
+	/* Truncate page data and move it into the tail */
+	len = XDR_QUADLEN(len) << 2;
+	if (buf->page_len > len)
+		xdr_shrink_pagelen(buf, buf->page_len - len);
+	xdr->iov = iov = buf->tail;
+	xdr->p = (uint32_t *)iov->iov_base;
+	xdr->end = (uint32_t *)((char *)iov->iov_base + iov->iov_len);
 }


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
