Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35168 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750860AbdAXVXb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jan 2017 16:23:31 -0500
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        lustre-devel@lists.lustre.org, v9fs-developer@lists.sourceforge.net
Subject: [PATCH] iov_iter: allow iov_iter_get_pages_alloc to allocate more pages per call
Date: Tue, 24 Jan 2017 16:23:27 -0500
Message-Id: <20170124212327.14517-1-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, iov_iter_get_pages_alloc will only ever operate on the first
vector that iterate_all_kinds hands back. Many of the callers however
would like to have as long a set of pages as possible, to allow for
fewer, but larger I/Os.

When the previous vector ends on a page boundary and the current one
begins on one, we can continue to add more pages.

Change the function to first scan the iov_iter to see how long an
array of pages we could create from the current position. Then,
allocate an array that large (or up to the maxsize), and fill that
many pages.

This patch would allow us to rip out a chunk of code in ceph that
tries to do the same thing, but doesn't handle it right.

For NFS, this allows the client to do larger I/Os when userland passes
down an array of page-aligned iovecs in an O_DIRECT request. I imagine
this will also make splice writes into an O_DIRECT file more efficient.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 lib/iov_iter.c | 140 +++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 111 insertions(+), 29 deletions(-)

diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index e68604ae3ced..956d17767a3e 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -883,6 +883,58 @@ unsigned long iov_iter_gap_alignment(const struct iov_iter *i)
 }
 EXPORT_SYMBOL(iov_iter_gap_alignment);
 
+/**
+ * iov_iter_pvec_size - find length of page aligned iovecs in iov_iter
+ * @i: iov_iter to in which to find the size
+ *
+ * Some filesystems can stitch together multiple iovecs into a single
+ * page vector when both the previous tail and current base are page
+ * aligned. This function discovers the length that can fit in a single
+ * pagevec and returns it.
+ */
+static size_t iov_iter_pvec_size(const struct iov_iter *i)
+{
+	size_t size = i->count;
+	size_t pv_size = 0;
+	bool contig = false, first = true;
+
+	if (!size)
+		return 0;
+
+	/* Pipes are naturally aligned for this */
+	if (unlikely(i->type & ITER_PIPE))
+		return size;
+
+	/*
+	 * An iov can be page vectored when the current base and previous
+	 * tail are both page aligned. Note that we don't require that the
+	 * initial base in the first iovec also be page aligned.
+	 */
+	iterate_all_kinds(i, size, v,
+		({
+		 if (first || (contig && PAGE_ALIGNED(v.iov_base))) {
+			pv_size += v.iov_len;
+			first = false;
+			contig = PAGE_ALIGNED(v.iov_base + v.iov_len);
+		 }; 0;
+		 }),
+		({
+		 if (first || (contig && v.bv_offset == 0)) {
+			pv_size += v.bv_len;
+			first = false;
+			contig = PAGE_ALIGNED(v.bv_offset + v.bv_len);
+		 }
+		 }),
+		({
+		 if (first || (contig && PAGE_ALIGNED(v.iov_base))) {
+			pv_size += v.iov_len;
+			first = false;
+			contig = PAGE_ALIGNED(v.iov_base + v.iov_len);
+		 }
+		 }))
+	return pv_size;
+}
+
 static inline size_t __pipe_get_pages(struct iov_iter *i,
 				size_t maxsize,
 				struct page **pages,
@@ -1006,47 +1058,77 @@ static ssize_t pipe_get_pages_alloc(struct iov_iter *i,
 }
 
 ssize_t iov_iter_get_pages_alloc(struct iov_iter *i,
-		   struct page ***pages, size_t maxsize,
-		   size_t *start)
+		   struct page ***ppages, size_t maxsize,
+		   size_t *pstart)
 {
-	struct page **p;
-
-	if (maxsize > i->count)
-		maxsize = i->count;
+	struct page **p, **pc;
+	size_t start = 0;
+	ssize_t len = 0;
+	int npages, res = 0;
+	bool first = true;
 
 	if (unlikely(i->type & ITER_PIPE))
-		return pipe_get_pages_alloc(i, pages, maxsize, start);
+		return pipe_get_pages_alloc(i, ppages, maxsize, pstart);
+
+	maxsize = min(iov_iter_pvec_size(i), maxsize);
+	npages = DIV_ROUND_UP(maxsize, PAGE_SIZE);
+	p = get_pages_array(npages);
+	if (!p)
+		return -ENOMEM;
+
+	pc = p;
 	iterate_all_kinds(i, maxsize, v, ({
 		unsigned long addr = (unsigned long)v.iov_base;
-		size_t len = v.iov_len + (*start = addr & (PAGE_SIZE - 1));
+		size_t slen = v.iov_len;
 		int n;
-		int res;
 
-		addr &= ~(PAGE_SIZE - 1);
-		n = DIV_ROUND_UP(len, PAGE_SIZE);
-		p = get_pages_array(n);
-		if (!p)
-			return -ENOMEM;
-		res = get_user_pages_fast(addr, n, (i->type & WRITE) != WRITE, p);
-		if (unlikely(res < 0)) {
-			kvfree(p);
-			return res;
+		if (first) {
+			start = addr & (PAGE_SIZE - 1);
+			slen += start;
+			first = false;
 		}
-		*pages = p;
-		return (res == n ? len : res * PAGE_SIZE) - *start;
+
+		n = DIV_ROUND_UP(slen, PAGE_SIZE);
+		if ((pc + n) > (p + npages)) {
+			/* Did something change the iov array?!? */
+			res = -EFAULT;
+			goto out;
+		}
+		addr &= ~(PAGE_SIZE - 1);
+		res = get_user_pages_fast(addr, n, (i->type & WRITE) != WRITE, pc);
+		if (unlikely(res < 0))
+			goto out;
+		len += (res == n ? slen : res * PAGE_SIZE) - start;
+		pc += res;
 	0;}),({
-		/* can't be more than PAGE_SIZE */
-		*start = v.bv_offset;
-		*pages = p = get_pages_array(1);
-		if (!p)
-			return -ENOMEM;
-		get_page(*p = v.bv_page);
-		return v.bv_len;
+		/* bio_vecs are limited to a single page each */
+		if (first) {
+			start = v.bv_offset;
+			first = false;
+		}
+		get_page(*pc = v.bv_page);
+		len += v.bv_len;
+		++pc;
+		BUG_ON(pc > p + npages);
 	}),({
-		return -EFAULT;
+		/* FIXME: should we handle this case? */
+		res = -EFAULT;
+		goto out;
 	})
 	)
-	return 0;
+out:
+	if (unlikely(res < 0)) {
+		struct page **i;
+
+		for (i = p; i < pc; i++)
+			put_page(*i);
+		kvfree(p);
+		return res;
+	}
+
+	*ppages = p;
+	*pstart = start;
+	return len;
 }
 EXPORT_SYMBOL(iov_iter_get_pages_alloc);
 
-- 
2.9.3

