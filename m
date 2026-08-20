Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E142B3BD629;
	Thu, 20 Aug 2026 19:34:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787254456; cv=none; b=F+5BuWzSGe0Bz5DdFuIsPSRg8dDb5zNaAGnRwLhx1W8nXgjRBNvX/7r+aGRT65dlW8/+PNb5sN6oHRWuVIb0NLBkX+3N3Is/utLqC7X1F69vUN8bps6z2EhiN5A88NIzpEnduL4OfJvgLnRvGZDqiAYw9/PzozY8ItLboYdEzLs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787254456; c=relaxed/simple;
	bh=PPm9uq/wE8Bplmg2Mf/B1FzyAjzt9Ki/NO5SjSeXWvA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Sk4xYxSx1LKMJNo+sTBk7mx9cyWu1DmhczZrFLbm7ZWi74nmwN+ESewaQn70E6wk377ZVpdxavufY8L2xL/C6q4KFzpdWrpgtTDfmkLg356/Z+XwCV+qVVvIPP+YXgiVT+ym3N64BytuQ507GDQUtOKWAxv8MCr7nROb3oiHHqY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=XrQL0Q3p; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="XrQL0Q3p"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=4VKTMcP0i+1jQJg4IREBIQusP9YVDXmuicUrrJXB4D8=; b=XrQL0Q3prpwN0Fz1aYd6dOfMWI
	LVshGosyccqaZefpoTfBiI9z6sVc8R3ffIEQQB9xciXOZQtNNSfaKM3X5hav2VYB4EC1HLAkZkPwY
	57iIuaXGxcr937gqukmvi7qWNtlhKSoNx4DLx2O2useD5TQ6YmtUddqLdUreRp8MapKXTVxZQ510+
	G10LMv1PL8CjikpQWI734Yn8tnopaRH+22zS8wQ23Pp85wcdFgsMsZx9gAB+Ev0b8RSdI5Jr/so9A
	bWH/RdqWJwqWzeD6r3ohD6MJQKzIKXnVAOz97q+yQwjynkniCOJ8Ts0pw1UJzcqVdOG4RgQDwrXf5
	ZbZx0ccA==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wx8WG-0000000GALX-2xrk;
	Thu, 20 Aug 2026 19:33:44 +0000
From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
To: Christian Brauner <brauner@kernel.org>
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	Chris Mason <clm@fb.com>,
	David Sterba <dsterba@suse.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-block@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	fuse-devel@lists.linux.dev,
	linux-nfs@vger.kernel.org,
	devel@lists.orangefs.org,
	Pavel Begunkov <asml.silence@gmail.com>
Subject: [PATCH 1/7] filemap: Export filemap_invalidate_pages() to modules
Date: Thu, 20 Aug 2026 20:33:34 +0100
Message-ID: <20260820193343.3852967-2-willy@infradead.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260820193343.3852967-1-willy@infradead.org>
References: <20260820193343.3852967-1-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This is a better API for filesystems to use than
invalidate_inode_pages2() / invalidate_inode_pages2_range().
However, the 'nowait' argument is unnecessary for them.  It's also
wrongly implemented as it will call invalidate_inode_pages2_range()
even after filemap_range_has_page() returns false.

Move the filemap_range_has_page() call into the two existing callers
and add kernel-doc.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 block/ioctl.c           | 14 ++++++++++----
 include/linux/pagemap.h |  2 +-
 mm/filemap.c            | 42 +++++++++++++++++++++++++++--------------
 3 files changed, 39 insertions(+), 19 deletions(-)

diff --git a/block/ioctl.c b/block/ioctl.c
index 3d4ea1537457..db5238b817b4 100644
--- a/block/ioctl.c
+++ b/block/ioctl.c
@@ -908,10 +908,16 @@ static int blkdev_cmd_discard(struct io_uring_cmd *cmd,
 	if (err)
 		return err;
 
-	err = filemap_invalidate_pages(bdev->bd_mapping, start,
-					start + len - 1, nowait);
-	if (err)
-		return err;
+	if (nowait) {
+		if (filemap_range_has_page(bdev->bd_mapping, start,
+					start + len - 1))
+			return -EAGAIN;
+	} else {
+		err = filemap_invalidate_pages(bdev->bd_mapping, start,
+					start + len - 1);
+		if (err)
+			return err;
+	}
 
 	while (true) {
 		bio = blk_alloc_discard_bio(bdev, &sector, &nr_sects, gfp);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 2c3718d592d6..ed99c8ab196a 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -33,7 +33,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 int kiocb_invalidate_pages(struct kiocb *iocb, size_t count);
 void kiocb_invalidate_post_direct_write(struct kiocb *iocb, size_t count);
 int filemap_invalidate_pages(struct address_space *mapping,
-			     loff_t pos, loff_t end, bool nowait);
+		loff_t pos, loff_t end);
 
 int write_inode_now(struct inode *, int sync);
 int filemap_fdatawrite(struct address_space *);
diff --git a/mm/filemap.c b/mm/filemap.c
index d721986d5f46..fedb521d773f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2911,20 +2911,27 @@ int kiocb_write_and_wait(struct kiocb *iocb, size_t count)
 }
 EXPORT_SYMBOL_GPL(kiocb_write_and_wait);
 
+/**
+ * filemap_invalidate_pages - Invalidate pages from the page cache
+ * @mapping: Address space to invalidate
+ * @pos: First byte to invalidate
+ * @end: Last byte (inclusive) to invalidate
+ *
+ * Invalidates the folios containing @pos and @end from the page cache
+ * (as well as all folios between them), so may remove more pages from
+ * the page cache than you ask for.
+ *
+ * Context: May sleep.  Caller may wish to hold mapping_invalidate_lock to
+ * prevent new pages being instantiated in this range.
+ * Return: 0 on success or negative errno.
+ */
 int filemap_invalidate_pages(struct address_space *mapping,
-			     loff_t pos, loff_t end, bool nowait)
+		loff_t pos, loff_t end)
 {
-	int ret;
+	int ret = filemap_write_and_wait_range(mapping, pos, end);
 
-	if (nowait) {
-		/* we could block if there are any pages in the range */
-		if (filemap_range_has_page(mapping, pos, end))
-			return -EAGAIN;
-	} else {
-		ret = filemap_write_and_wait_range(mapping, pos, end);
-		if (ret)
-			return ret;
-	}
+	if (ret)
+		return ret;
 
 	/*
 	 * After a write we want buffered reads to be sure to go to disk to get
@@ -2935,14 +2942,21 @@ int filemap_invalidate_pages(struct address_space *mapping,
 	return invalidate_inode_pages2_range(mapping, pos >> PAGE_SHIFT,
 					     end >> PAGE_SHIFT);
 }
+EXPORT_SYMBOL_GPL(filemap_invalidate_pages);
 
 int kiocb_invalidate_pages(struct kiocb *iocb, size_t count)
 {
 	struct address_space *mapping = iocb->ki_filp->f_mapping;
+	loff_t end = iocb->ki_pos + count - 1;
+
+	if (iocb->ki_flags & IOCB_NOWAIT) {
+		/* we could block if there are any pages in the range */
+		if (filemap_range_has_page(mapping, iocb->ki_pos, end))
+			return -EAGAIN;
+		return 0;
+	}
 
-	return filemap_invalidate_pages(mapping, iocb->ki_pos,
-					iocb->ki_pos + count - 1,
-					iocb->ki_flags & IOCB_NOWAIT);
+	return filemap_invalidate_pages(mapping, iocb->ki_pos, end);
 }
 EXPORT_SYMBOL_GPL(kiocb_invalidate_pages);
 
-- 
2.47.3

