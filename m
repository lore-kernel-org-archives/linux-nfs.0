Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54582 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751585AbdAYNcI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 25 Jan 2017 08:32:08 -0500
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        lustre-devel@lists.lustre.org, v9fs-developer@lists.sourceforge.net
Subject: [PATCH v3 2/2] ceph: switch DIO code to use iov_iter_get_pages_alloc
Date: Wed, 25 Jan 2017 08:32:05 -0500
Message-Id: <20170125133205.21704-3-jlayton@redhat.com>
In-Reply-To: <20170125133205.21704-1-jlayton@redhat.com>
References: <20170124212327.14517-1-jlayton@redhat.com>
 <20170125133205.21704-1-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xfstest generic/095 triggers soft lockups in kcephfs. It uses fio to
drive some I/O via vmsplice ane splice. Ceph then ends up trying to
access an ITER_BVEC type iov_iter as a ITER_IOVEC one. That causes it to
pick up a wrong offset and get stuck in an infinite loop while trying to
populate the page array. dio_get_pagev_size has a similar problem.

Now that iov_iter_get_pages_alloc doesn't stop after the first vector in
the array, we can just call it instead and dump the old code that tried
to do the same thing.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/ceph/file.c | 75 +++-------------------------------------------------------
 1 file changed, 3 insertions(+), 72 deletions(-)

diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 045d30d26624..0ce79f1eabbc 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -35,75 +35,6 @@
  */
 
 /*
- * Calculate the length sum of direct io vectors that can
- * be combined into one page vector.
- */
-static size_t dio_get_pagev_size(const struct iov_iter *it)
-{
-    const struct iovec *iov = it->iov;
-    const struct iovec *iovend = iov + it->nr_segs;
-    size_t size;
-
-    size = iov->iov_len - it->iov_offset;
-    /*
-     * An iov can be page vectored when both the current tail
-     * and the next base are page aligned.
-     */
-    while (PAGE_ALIGNED((iov->iov_base + iov->iov_len)) &&
-           (++iov < iovend && PAGE_ALIGNED((iov->iov_base)))) {
-        size += iov->iov_len;
-    }
-    dout("dio_get_pagevlen len = %zu\n", size);
-    return size;
-}
-
-/*
- * Allocate a page vector based on (@it, @nbytes).
- * The return value is the tuple describing a page vector,
- * that is (@pages, @page_align, @num_pages).
- */
-static struct page **
-dio_get_pages_alloc(const struct iov_iter *it, size_t nbytes,
-		    size_t *page_align, int *num_pages)
-{
-	struct iov_iter tmp_it = *it;
-	size_t align;
-	struct page **pages;
-	int ret = 0, idx, npages;
-
-	align = (unsigned long)(it->iov->iov_base + it->iov_offset) &
-		(PAGE_SIZE - 1);
-	npages = calc_pages_for(align, nbytes);
-	pages = kmalloc(sizeof(*pages) * npages, GFP_KERNEL);
-	if (!pages) {
-		pages = vmalloc(sizeof(*pages) * npages);
-		if (!pages)
-			return ERR_PTR(-ENOMEM);
-	}
-
-	for (idx = 0; idx < npages; ) {
-		size_t start;
-		ret = iov_iter_get_pages(&tmp_it, pages + idx, nbytes,
-					 npages - idx, &start);
-		if (ret < 0)
-			goto fail;
-
-		iov_iter_advance(&tmp_it, ret);
-		nbytes -= ret;
-		idx += (ret + start + PAGE_SIZE - 1) / PAGE_SIZE;
-	}
-
-	BUG_ON(nbytes != 0);
-	*num_pages = npages;
-	*page_align = align;
-	dout("dio_get_pages_alloc: got %d pages align %zu\n", npages, align);
-	return pages;
-fail:
-	ceph_put_page_vector(pages, idx, false);
-	return ERR_PTR(ret);
-}
-
-/*
  * Prepare an open request.  Preallocate ceph_cap to avoid an
  * inopportune ENOMEM later.
  */
@@ -923,7 +854,7 @@ ceph_direct_read_write(struct kiocb *iocb, struct iov_iter *iter,
 	}
 
 	while (iov_iter_count(iter) > 0) {
-		u64 size = dio_get_pagev_size(iter);
+		u64 size = iov_iter_count(iter);
 		size_t start = 0;
 		ssize_t len;
 
@@ -943,13 +874,13 @@ ceph_direct_read_write(struct kiocb *iocb, struct iov_iter *iter,
 			break;
 		}
 
-		len = size;
-		pages = dio_get_pages_alloc(iter, len, &start, &num_pages);
+		len = iov_iter_get_pages_alloc(iter, &pages, size, &start);
 		if (IS_ERR(pages)) {
 			ceph_osdc_put_request(req);
 			ret = PTR_ERR(pages);
 			break;
 		}
+		num_pages = DIV_ROUND_UP(len, PAGE_SIZE);
 
 		/*
 		 * To simplify error handling, allow AIO when IO within i_size
-- 
2.9.3

