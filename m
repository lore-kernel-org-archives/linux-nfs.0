Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42758 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754773AbdA0NcY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 27 Jan 2017 08:32:24 -0500
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        lustre-devel@lists.lustre.org, v9fs-developer@lists.sourceforge.net
Subject: [PATCH v4 1/2] iov_iter: allow iov_iter_get_pages_alloc to allocate more pages per call
Date: Fri, 27 Jan 2017 08:24:50 -0500
Message-Id: <20170127132451.6601-2-jlayton@redhat.com>
In-Reply-To: <20170127132451.6601-1-jlayton@redhat.com>
References: <1485434106.6547.1.camel@poochiereds.net>
 <20170127132451.6601-1-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, iov_iter_get_pages_alloc will only ever operate on the first
vector that iterate_all_kinds hands back. Most of the callers however
would like to have as long a set of pages as possible, to allow for
fewer, but larger I/Os.

When the previous vector ends on a page boundary and the current one
begins on one, we can continue to add more pages.

Change the function to first scan the iov_iter to see how long an
array of pages we could create from the current position up to the
maxsize passed in. Then, allocate an array that large and start
filling in that many pages.

The main impetus for this patch is to rip out a swath of code in ceph
that tries to do this but that doesn't handle ITER_BVEC correctly.

NFS also uses this function and this also allows the client to do larger
I/Os when userland passes down an array of page-aligned iovecs in an
O_DIRECT request. This should also make splice writes into an O_DIRECT
file on NFS use larger I/Os, since that's now done by passing down an
ITER_BVEC representing the data to be written.

I believe the other callers (lustre and 9p) may also benefit from this
change, but I don't have a great way to verify that.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 lib/iov_iter.c | 180 +++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 151 insertions(+), 29 deletions(-)

diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index e68604ae3ced..e3bcb927429f 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -1005,48 +1005,170 @@ static ssize_t pipe_get_pages_alloc(struct iov_iter *i,
 	return n;
 }
 
-ssize_t iov_iter_get_pages_alloc(struct iov_iter *i,
-		   struct page ***pages, size_t maxsize,
-		   size_t *start)
+/**
+ * iov_iter_pvec_size - find length of page aligned iovecs in iov_iter
+ * @i: iov_iter to in which to find the size
+ * @maxsize: maximum size to return
+ * @npages: return pointer for how many pages this I/O will span
+ *
+ * Some filesystems can stitch together multiple iovecs into a single page
+ * vector when both the previous tail and current base are page aligned. This
+ * function determines how much of the remaining iov_iter can be stuffed into
+ * a single pagevec, up to the provided maxsize value.
+ *
+ * It also calculates how many pages this I/O will span and returns that value
+ * in npages.
+ */
+static size_t iov_iter_pvec_size(const struct iov_iter *i, size_t maxsize,
+				 int *npages)
 {
-	struct page **p;
+	size_t size = min(iov_iter_count(i), maxsize);
+	size_t pv_size = 0;
+	size_t start = 0;
+	bool contig = false, first = true;
 
-	if (maxsize > i->count)
-		maxsize = i->count;
+	if (!size)
+		return 0;
 
+	/* Pipes are naturally aligned for this */
 	if (unlikely(i->type & ITER_PIPE))
-		return pipe_get_pages_alloc(i, pages, maxsize, start);
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
+			if (first)
+				start = ((unsigned long)v.iov_base & (PAGE_SIZE - 1));
+			pv_size += v.iov_len;
+			first = false;
+			contig = PAGE_ALIGNED(v.iov_base + v.iov_len);
+		 }; 0;
+		 }),
+		({
+		 if (first || (contig && v.bv_offset == 0)) {
+			if (first)
+				start = v.bv_offset;
+			pv_size += v.bv_len;
+			first = false;
+			contig = PAGE_ALIGNED(v.bv_offset + v.bv_len);
+		 }
+		 }),
+		({
+		 if (first || (contig && PAGE_ALIGNED(v.iov_base))) {
+			if (first)
+				start = ((unsigned long)v.iov_base & (PAGE_SIZE - 1));
+			pv_size += v.iov_len;
+			first = false;
+			contig = PAGE_ALIGNED(v.iov_base + v.iov_len);
+		 }
+		 }))
+	*npages = DIV_ROUND_UP(pv_size + start, PAGE_SIZE);
+	return pv_size;
+}
+
+ssize_t iov_iter_get_pages_alloc(struct iov_iter *i,
+		   struct page ***ppages, size_t maxsize,
+		   size_t *pstart)
+{
+	struct page **p, **pc;
+	size_t start = 0;
+	ssize_t len = 0;
+	int npages = 0, res = 0;
+	bool first = true;
+
+	if (unlikely(i->type & ITER_PIPE))
+		return pipe_get_pages_alloc(i, ppages, maxsize, pstart);
+
+	maxsize = iov_iter_pvec_size(i, maxsize, &npages);
+	p = get_pages_array(npages);
+	if (!p)
+		return -ENOMEM;
+
+	pc = p;
 	iterate_all_kinds(i, maxsize, v, ({
 		unsigned long addr = (unsigned long)v.iov_base;
-		size_t len = v.iov_len + (*start = addr & (PAGE_SIZE - 1));
+		size_t slen = v.iov_len;
+		size_t sstart = 0;
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
+			sstart = start;
+			first = false;
 		}
-		*pages = p;
-		return (res == n ? len : res * PAGE_SIZE) - *start;
+
+		n = DIV_ROUND_UP(slen, PAGE_SIZE);
+		if (pc + n > p + npages) {
+			/*
+			 * Eek! Something changed between when we initially
+			 * measured for the page array and now. Maybe a
+			 * userland memory scribble? We haven't overrun
+			 * anything at this point, so we can safely just
+			 * return what we have, if we have gotten anything.
+			 * If this is the first pass, then just return EFAULT.
+			 */
+			if (first)
+				res = -EFAULT;
+			goto out;
+		}
+		addr &= ~(PAGE_SIZE - 1);
+		res = get_user_pages_fast(addr, n,
+					  (i->type & WRITE) != WRITE, pc);
+		if (unlikely(res < 0))
+			goto out;
+		len += (res == n ? slen : res * PAGE_SIZE) - sstart;
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
+		if (pc > p + npages) {
+			/*
+			 * Should we return an error here?  This should never
+			 * happen as kernel callers had better not muck with
+			 * the array while we're iterating over it.
+			 *
+			 * At this point, we haven't overrun anything so we
+			 * can just return what we have gotten so far. Still,
+			 * it looks like something is wrong, so pop a warning
+			 * here.
+			 */
+			WARN_ONCE(true, "%s: array overrun (%p > %p + %d)\n",
+					__func__, pc, p, npages);
+			goto out;
+		}
+
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

