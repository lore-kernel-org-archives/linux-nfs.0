Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6FE7F23C516;
	Thu, 20 Aug 2026 19:33:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787254436; cv=none; b=EUVvKiB1SoDJYQAhxj/M+mOTH7sxUeF+B+uMZ2te4ipwfg7ZNYH1t3wFbywWBi+fd6FmAhIAsy2EnYZNZgQt4At34ucO78mKc3rrfvKifLPwfO9IfQ6Dy7b+FP1vzZht/qbUp+zdW2s114ddtUG+4RQH9cmAN8kkY+1u+pmUSIA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787254436; c=relaxed/simple;
	bh=ZWzRCDHxAkKAgS5ohhVXUP7gK0blzU1+ph1SNVLxHyw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=BTnhSq7fX0tFCpBMKr8wZQkW9I+uHs1VnWJQoA3BXJ7dJORgN9gc40C++IXP8xt3hfPnNr9KQeC+03hYbMrE8uelaUYW6ZnKQ+YTPradR9yAzFSKdNX+ObYv2CrVBpuCTDOowBf5+LaHzrYU9qOauMaPz3ros02P5FjuIvt0BuY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=ci/czsF4; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ci/czsF4"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=fs0htD/cjU9OCu4C2Kg80p/TbNt8/mTbG6p2Ku/lBdI=; b=ci/czsF4/zM1GNnaf9XI2rrb85
	zzjZAV2v4GTFkP1N4XCj1DpxbCJjSEvQ/M2ZQy1eO1/lU1o+tZngjUMJz0YSlUA2Xou0jPXfa5TLK
	wBex/0pkUn3IFVsl4Vc0aFxnOElaJemGvFvUf56KowyPrEnj9OfROaE150VqiEWoe4KUuu7sZ187D
	Thd8UR61BfasYAqAQ7I26DSCPfQ8fCFTT/ip0VAyM64bNb4jvh0+6BpVJZVa0pryEYMZeHYkycasx
	UcVgoQAjcUDBhn4cIOHxrH/u1M6owTxLlCEoRxQfvRC0vg2wg7qWNfo+sAUsdLyL+2zpjdivzJCWg
	N5YvhS2A==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wx8WG-0000000GALd-459O;
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
Subject: [PATCH 3/7] btrfs: Use filemap_invalidate_pages()
Date: Thu, 20 Aug 2026 20:33:36 +0100
Message-ID: <20260820193343.3852967-4-willy@infradead.org>
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

btrfs relies on invalidate_inode_pages2() /
invalidate_inode_pages2_range() doing writeback by calling
btrfs_launder_folio().  While this works, it is inefficient as each
folio is written back and waited for individually.  Far better to call
filemap_invalidate_pages() which will do a bulk write first, then remove
the page cache.

With this done, btrfs_launder_folio() no longer needs to exist so
delete it.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/btrfs/direct-io.c        |  2 +-
 fs/btrfs/disk-io.c          | 11 +++++++----
 fs/btrfs/free-space-cache.c |  4 ++--
 fs/btrfs/inode.c            | 12 ++----------
 fs/btrfs/volumes.c          |  4 ++--
 5 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/fs/btrfs/direct-io.c b/fs/btrfs/direct-io.c
index 460326d34143..4bb5890d0898 100644
--- a/fs/btrfs/direct-io.c
+++ b/fs/btrfs/direct-io.c
@@ -115,7 +115,7 @@ static int lock_extent_direct(struct inode *inode, u64 lockstart, u64 lockend,
 			/*
 			 * We could trigger writeback for this range (and wait
 			 * for it to complete) and then invalidate the pages for
-			 * this range (through invalidate_inode_pages2_range()),
+			 * this range (through filemap_invalidate_pages()),
 			 * but that can lead us to a deadlock with a concurrent
 			 * call to readahead (a buffered read or a defrag call
 			 * triggered a readahead) on a page lock due to an
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 2f1666d9544e..2cf9189225c9 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -3304,7 +3304,8 @@ static void invalidate_and_check_btree_folios(struct btrfs_fs_info *fs_info)
 	struct extent_buffer *eb;
 	int ret;
 
-	ret = invalidate_inode_pages2(fs_info->btree_inode->i_mapping);
+	ret = filemap_invalidate_pages(fs_info->btree_inode->i_mapping, 0,
+			OFFSET_MAX);
 	if (likely(ret == 0))
 		return;
 
@@ -3339,7 +3340,8 @@ static void invalidate_and_check_btree_folios(struct btrfs_fs_info *fs_info)
 		rcu_read_lock();
 	}
 	rcu_read_unlock();
-	invalidate_inode_pages2(fs_info->btree_inode->i_mapping);
+	filemap_invalidate_pages(fs_info->btree_inode->i_mapping, 0,
+			OFFSET_MAX);
 }
 
 static u32 calc_block_max_order(u32 sectorsize_bits)
@@ -4739,7 +4741,8 @@ static void btrfs_destroy_delalloc_inodes(struct btrfs_root *root)
 			unsigned int nofs_flag;
 
 			nofs_flag = memalloc_nofs_save();
-			invalidate_inode_pages2(inode->i_mapping);
+			filemap_invalidate_pages(inode->i_mapping, 0,
+					OFFSET_MAX);
 			memalloc_nofs_restore(nofs_flag);
 			iput(inode);
 		}
@@ -4837,7 +4840,7 @@ static void btrfs_cleanup_bg_io(struct btrfs_block_group *cache)
 		unsigned int nofs_flag;
 
 		nofs_flag = memalloc_nofs_save();
-		invalidate_inode_pages2(inode->i_mapping);
+		filemap_invalidate_pages(inode->i_mapping, 0, OFFSET_MAX);
 		memalloc_nofs_restore(nofs_flag);
 
 		BTRFS_I(inode)->generation = 0;
diff --git a/fs/btrfs/free-space-cache.c b/fs/btrfs/free-space-cache.c
index e2af75a205ea..a5d5eba2c85d 100644
--- a/fs/btrfs/free-space-cache.c
+++ b/fs/btrfs/free-space-cache.c
@@ -1307,7 +1307,7 @@ static int __btrfs_wait_cache_io(struct btrfs_root *root,
 				io_ctl->entries, io_ctl->bitmaps);
 out:
 	if (ret) {
-		invalidate_inode_pages2(inode->i_mapping);
+		filemap_invalidate_pages(inode->i_mapping, 0, OFFSET_MAX);
 		BTRFS_I(inode)->generation = 0;
 		if (block_group)
 			btrfs_debug(root->fs_info,
@@ -1500,7 +1500,7 @@ static int __btrfs_write_out_cache(struct inode *inode,
 	io_ctl->inode = NULL;
 	io_ctl_free(io_ctl);
 	if (ret) {
-		invalidate_inode_pages2(inode->i_mapping);
+		filemap_invalidate_pages(inode->i_mapping, 0, OFFSET_MAX);
 		BTRFS_I(inode)->generation = 0;
 	}
 	btrfs_update_inode(trans, BTRFS_I(inode));
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 2534cd9284d5..a1bb73f083aa 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -7616,12 +7616,6 @@ static void wait_subpage_spinlock(struct folio *folio)
 	spin_unlock_irq(&bfs->lock);
 }
 
-static int btrfs_launder_folio(struct folio *folio)
-{
-	return btrfs_qgroup_free_data(folio_to_inode(folio), NULL, folio_pos(folio),
-				      folio_size(folio), NULL);
-}
-
 static bool __btrfs_release_folio(struct folio *folio, gfp_t gfp_flags)
 {
 	if (try_release_extent_mapping(folio, gfp_flags)) {
@@ -10027,9 +10021,8 @@ ssize_t btrfs_do_encoded_write(struct kiocb *iocb, struct iov_iter *from,
 		ret = btrfs_wait_ordered_range(inode, start, num_bytes);
 		if (ret)
 			goto out_cb;
-		ret = invalidate_inode_pages2_range(inode->vfs_inode.i_mapping,
-						    start >> PAGE_SHIFT,
-						    end >> PAGE_SHIFT);
+		ret = filemap_invalidate_pages(inode->vfs_inode.i_mapping,
+				start, end);
 		if (ret)
 			goto out_cb;
 		btrfs_lock_extent(io_tree, start, end, &cached_state);
@@ -10782,7 +10775,6 @@ static const struct address_space_operations btrfs_aops = {
 	.writepages	= btrfs_writepages,
 	.readahead	= btrfs_readahead,
 	.invalidate_folio = btrfs_invalidate_folio,
-	.launder_folio	= btrfs_launder_folio,
 	.release_folio	= btrfs_release_folio,
 	.migrate_folio	= btrfs_migrate_folio,
 	.dirty_folio	= btrfs_data_dirty_folio,
diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
index 6eab4cc73ce4..0301465ab87f 100644
--- a/fs/btrfs/volumes.c
+++ b/fs/btrfs/volumes.c
@@ -1370,8 +1370,8 @@ struct btrfs_super_block *btrfs_read_disk_super(struct block_device *bdev,
 		 * Drop the page of the primary superblock, so later read will
 		 * always read from the device.
 		 */
-		invalidate_inode_pages2_range(mapping, bytenr >> PAGE_SHIFT,
-				      (bytenr + BTRFS_SUPER_INFO_SIZE) >> PAGE_SHIFT);
+		filemap_invalidate_pages(mapping, bytenr,
+				bytenr + BTRFS_SUPER_INFO_SIZE - 1);
 	}
 
 	filemap_invalidate_lock_shared(mapping);
-- 
2.47.3

