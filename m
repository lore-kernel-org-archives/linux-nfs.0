Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f179.google.com ([209.85.192.179]:64786 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098AbaLTDSn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2014 22:18:43 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so2328905pdb.24
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2014 19:18:43 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v2 1/5] iov_iter: add ITER_BVEC helpers
Date: Fri, 19 Dec 2014 19:18:25 -0800
Message-Id: <9523f2373dd40ac35760f3fb926a81a321fa4139.1419044605.git.osandov@osandov.com>
In-Reply-To: <cover.1419044605.git.osandov@osandov.com>
References: <cover.1419044605.git.osandov@osandov.com>
In-Reply-To: <cover.1419044605.git.osandov@osandov.com>
References: <cover.1419044605.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add iov_iter_is_bvec and iov_iter_bvec and convert callers.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 fs/splice.c         |  7 ++-----
 include/linux/uio.h |  7 +++++++
 mm/iov_iter.c       | 12 ++++++++++++
 mm/page_io.c        | 14 +++++---------
 4 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index 75c6058..7c7176f 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1006,11 +1006,8 @@ iter_file_splice_write(struct pipe_inode_info *pipe, struct file *out,
 		}
 
 		/* ... iov_iter */
-		from.type = ITER_BVEC | WRITE;
-		from.bvec = array;
-		from.nr_segs = n;
-		from.count = sd.total_len - left;
-		from.iov_offset = 0;
+		iov_iter_bvec(&from, ITER_BVEC | WRITE, array, n,
+			      sd.total_len - left);
 
 		/* ... and iocb */
 		init_sync_kiocb(&kiocb, out);
diff --git a/include/linux/uio.h b/include/linux/uio.h
index 1c5e453..23bb5e4 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -63,6 +63,11 @@ static inline struct iovec iov_iter_iovec(const struct iov_iter *iter)
 	};
 }
 
+static inline int iov_iter_is_bvec(const struct iov_iter *iter)
+{
+	return (iter->type & ITER_BVEC) != 0;
+}
+
 #define iov_for_each(iov, iter, start)				\
 	if (!((start).type & ITER_BVEC))			\
 	for (iter = (start);					\
@@ -90,6 +95,8 @@ void iov_iter_init(struct iov_iter *i, int direction, const struct iovec *iov,
 			unsigned long nr_segs, size_t count);
 void iov_iter_kvec(struct iov_iter *i, int direction, const struct kvec *iov,
 			unsigned long nr_segs, size_t count);
+void iov_iter_bvec(struct iov_iter *i, int direction, const struct bio_vec *bv,
+		   unsigned long nr_segs, size_t count);
 ssize_t iov_iter_get_pages(struct iov_iter *i, struct page **pages,
 			size_t maxsize, unsigned maxpages, size_t *start);
 ssize_t iov_iter_get_pages_alloc(struct iov_iter *i, struct page ***pages,
diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index a1599ca..c975bc4 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -513,6 +513,18 @@ void iov_iter_kvec(struct iov_iter *i, int direction,
 }
 EXPORT_SYMBOL(iov_iter_kvec);
 
+void iov_iter_bvec(struct iov_iter *i, int direction, const struct bio_vec *bv,
+		   unsigned long nr_segs, size_t count)
+{
+	BUG_ON(!(direction & ITER_BVEC));
+	i->type = direction;
+	i->bvec = bv;
+	i->nr_segs = nr_segs;
+	i->iov_offset = 0;
+	i->count = count;
+}
+EXPORT_SYMBOL(iov_iter_bvec);
+
 unsigned long iov_iter_alignment(const struct iov_iter *i)
 {
 	unsigned long res = 0;
diff --git a/mm/page_io.c b/mm/page_io.c
index 955db8b..532a39b 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -264,18 +264,14 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 		struct kiocb kiocb;
 		struct file *swap_file = sis->swap_file;
 		struct address_space *mapping = swap_file->f_mapping;
+		struct iov_iter from;
 		struct bio_vec bv = {
 			.bv_page = page,
-			.bv_len  = PAGE_SIZE,
-			.bv_offset = 0
+			.bv_len = PAGE_SIZE,
+			.bv_offset = 0,
 		};
-		struct iov_iter from = {
-			.type = ITER_BVEC | WRITE,
-			.count = PAGE_SIZE,
-			.iov_offset = 0,
-			.nr_segs = 1,
-		};
-		from.bvec = &bv;	/* older gcc versions are broken */
+
+		iov_iter_bvec(&from, ITER_BVEC | WRITE, &bv, 1, PAGE_SIZE);
 
 		init_sync_kiocb(&kiocb, swap_file);
 		kiocb.ki_pos = page_file_offset(page);
-- 
2.2.1

