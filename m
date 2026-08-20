Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DBA0023C516;
	Thu, 20 Aug 2026 19:33:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787254441; cv=none; b=F6rKxBQ999/mE3rOCGEtCFkSh2k4yAvP/OJnzwm2KoNjFjWtvTG0ScCo/CpB8ObfMIuF1X2MPFsVGXmlVUs/EESkBQry+8OMPlzAN77qaW0O58Ty6RIIB6M/33PjxJmw1hsOFblHOyO4Y2Db/Og0RKgNAfNjKJeaTnsS9fJhoZQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787254441; c=relaxed/simple;
	bh=P607L1URuTqiQARHGi1pEaY+BLIc6hazOcrA7VebeZ8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=f2g7/3VzzzCXwigCb+fMToV1ulxsT++Tby3lEvxDA4+7DSqc52Z3D9h20mxRrxv6SaXIuFiengvmBr94+OJGWbBvV+gkjZZMUNEZLFwHTCR9HjQgbOnJMKIgXjjF5I4bhhxn1m67wm5RX2NBZIiL+3gWrYVODXKM41sryxYjURI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=W2uuzkXM; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="W2uuzkXM"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=aVvnP14Vi0dW0rUtBUB2gwZufKNU6mHScoh2VRLGywk=; b=W2uuzkXMybJUSbnzLQsqYhvn8Y
	dBDJxLUfmEgBvoQ90UeVVJlK71eSm3W08wFIh9Y3RZ3JkApXAQe5WRIDpKG5ZHU12JjpznfGx0PaP
	BLA/sQAijbZBtf2kmOhIWSP3HQIwcGLfa8f0QJnr4VIx5PyahrMq3pj2zcHBWXfUYZs6DtOygxtI7
	18keX0dU6QI4DTrjfmld6fV4AQsRWjCRPaqlfUQA4867zcwrlFqlvfKabHhq3xMUQlchMzEOCn6XO
	GhivnZbeTM4u9HGBvxexZg1ElMMFbBglOOnqvJk5FBl7Cm1TDnHDIsIZMBj0RNqdYajEZXne0DOFw
	BExOtdVg==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wx8WH-0000000GALf-0JJm;
	Thu, 20 Aug 2026 19:33:45 +0000
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
Subject: [PATCH 4/7] nfs: Use filemap_invalidate_pages()
Date: Thu, 20 Aug 2026 20:33:37 +0100
Message-ID: <20260820193343.3852967-5-willy@infradead.org>
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

nfs relies on invalidate_inode_pages2() / invalidate_inode_pages2_range()
doing writeback by calling nfs_launder_folio().  While this works, it is
inefficient as each folio is written back and waited for individually.
Far better to call filemap_invalidate_pages() which will do a bulk write
first, then remove the page cache.

With this done, nfs_launder_folio() no longer needs to exist so delete it.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/nfs/dir.c       |  7 ++++---
 fs/nfs/direct.c    |  5 ++---
 fs/nfs/file.c      | 24 ------------------------
 fs/nfs/inode.c     |  5 +++--
 fs/nfs/nfs42proc.c |  3 +--
 fs/nfs/nfstrace.h  |  1 -
 6 files changed, 10 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index c7caffb31935..265471ef5dae 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1035,7 +1035,8 @@ static int find_and_lock_cache_page(struct nfs_readdir_descriptor *desc)
 			nfs_readdir_folio_unlock_and_put_cached(desc);
 			trace_nfs_readdir_cache_fill_done(inode, res);
 			if (res == -EBADCOOKIE || res == -ENOTSYNC) {
-				invalidate_inode_pages2(desc->file->f_mapping);
+				filemap_invalidate_pages(desc->file->f_mapping,
+						0, OFFSET_MAX);
 				nfs_readdir_rewind_search(desc);
 				trace_nfs_readdir_invalidate_cache_range(
 					inode, 0, MAX_LFS_FILESIZE);
@@ -1050,8 +1051,8 @@ static int find_and_lock_cache_page(struct nfs_readdir_descriptor *desc)
 		    memcmp(nfsi->cookieverf, verf, sizeof(nfsi->cookieverf))) {
 			memcpy(nfsi->cookieverf, verf,
 			       sizeof(nfsi->cookieverf));
-			invalidate_inode_pages2_range(desc->file->f_mapping, 1,
-						      -1);
+			filemap_invalidate_pages(desc->file->f_mapping,
+					PAGE_SIZE, -1);
 			trace_nfs_readdir_invalidate_cache_range(
 				inode, 1, MAX_LFS_FILESIZE);
 		}
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e626c72495e6..56ad855b9027 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -1019,7 +1019,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
 
 	pos = iocb->ki_pos;
-	end = (pos + iov_iter_count(iter) - 1) >> PAGE_SHIFT;
+	end = pos + iov_iter_count(iter) - 1;
 
 	task_io_account_write(count);
 
@@ -1060,8 +1060,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 							    FLUSH_COND_STABLE);
 
 		if (mapping->nrpages) {
-			invalidate_inode_pages2_range(mapping,
-						      pos >> PAGE_SHIFT, end);
+			filemap_invalidate_pages(mapping, pos, end);
 		}
 
 		nfs_end_io_direct(inode);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index a0d8f1c1cf10..cfc9c0135845 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -552,29 +552,6 @@ static void nfs_check_dirty_writeback(struct folio *folio,
 		*dirty = true;
 }
 
-/*
- * Attempt to clear the private state associated with a page when an error
- * occurs that requires the cached contents of an inode to be written back or
- * destroyed
- * - Called if either PG_private or fscache is set on the page
- * - Caller holds page lock
- * - Return 0 if successful, -error otherwise
- */
-static int nfs_launder_folio(struct folio *folio)
-{
-	struct inode *inode = folio->mapping->host;
-	int ret;
-
-	dfprintk(PAGECACHE, "NFS: launder_folio(%llu, %llu)\n",
-		inode->i_ino, folio_pos(folio));
-
-	folio_wait_private_2(folio); /* [DEPRECATED] */
-	ret = nfs_wb_folio(inode, folio);
-	trace_nfs_launder_folio_done(inode, folio_pos(folio),
-			folio_size(folio), ret);
-	return ret;
-}
-
 static int nfs_swap_activate(struct swap_info_struct *sis, struct file *file,
 						sector_t *span)
 {
@@ -633,7 +610,6 @@ const struct address_space_operations nfs_file_aops = {
 	.invalidate_folio = nfs_invalidate_folio,
 	.release_folio = nfs_release_folio,
 	.migrate_folio = nfs_migrate_folio,
-	.launder_folio = nfs_launder_folio,
 	.is_dirty_writeback = nfs_check_dirty_writeback,
 	.error_remove_folio = generic_error_remove_folio,
 	.swap_activate = nfs_swap_activate,
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5bcd4027d203..089dd7df1790 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1323,7 +1323,8 @@ void nfs_file_clear_open_context(struct file *filp)
 		 * every page again.
 		 */
 		if (ctx->error < 0)
-			invalidate_inode_pages2(inode->i_mapping);
+			filemap_invalidate_pages(inode->i_mapping, 0,
+					OFFSET_MAX);
 		filp->private_data = NULL;
 		put_nfs_open_context_sync(ctx);
 	}
@@ -1461,7 +1462,7 @@ static int nfs_invalidate_mapping(struct inode *inode, struct address_space *map
 			if (ret < 0)
 				return ret;
 		}
-		ret = invalidate_inode_pages2(mapping);
+		ret = filemap_invalidate_pages(mapping, 0, OFFSET_MAX);
 		if (ret < 0)
 			return ret;
 	}
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index ab86246fc364..8555fd0a7f71 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -395,8 +395,7 @@ static void nfs42_copy_dest_done(struct file *file, loff_t pos, loff_t len,
 	loff_t end = newsize - 1;
 
 	nfs_truncate_last_folio(mapping, oldsize, pos);
-	WARN_ON_ONCE(invalidate_inode_pages2_range(mapping, pos >> PAGE_SHIFT,
-						   end >> PAGE_SHIFT));
+	WARN_ON_ONCE(filemap_invalidate_pages(mapping, pos, end));
 
 	spin_lock(&inode->i_lock);
 	if (newsize > i_size_read(inode))
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index 4ada21f4eebd..7774b86dbd60 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -1069,7 +1069,6 @@ DEFINE_NFS_FOLIO_EVENT(nfs_writeback_folio);
 DEFINE_NFS_FOLIO_EVENT_DONE(nfs_writeback_folio_done);
 
 DEFINE_NFS_FOLIO_EVENT(nfs_invalidate_folio);
-DEFINE_NFS_FOLIO_EVENT_DONE(nfs_launder_folio_done);
 
 DEFINE_NFS_FOLIO_EVENT(nfs_try_to_update_request);
 DEFINE_NFS_FOLIO_EVENT_DONE(nfs_try_to_update_request_done);
-- 
2.47.3

