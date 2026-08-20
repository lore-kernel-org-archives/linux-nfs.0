Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA29A4734C0;
	Thu, 20 Aug 2026 19:34:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787254450; cv=none; b=mpliajV4zamGoBELY2LLv1+JVLgaU26TmJJiii/FZ/1FGEDFQejE0GZPGzjQ6THjUqBuWgzC9KTuc8UFcZZrpgP0ovCs3+B/Rtryux6zC4HQrd2iFGiHLv4ufvUhW0LE4NoATLtM1ypPQgQuPDEphyPSQ4VsvorViZjPIBVPKJs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787254450; c=relaxed/simple;
	bh=tOOgypxGFpbsd2maQfCxTl7AzpPdlKdMjXMjvS5RTJE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bMsMhtF9VwjuG7C/3pNQJwbCjsjdYRwJoMgK9WXz01lX6+CaV6AXhfj8AElHN10FBosGRtCParwzduOqQf7dN66ksn1963WGg0tmAjazhKiedJPeylG8OA/H8Xty0KGtm1n96amXjH/OMshTCumKWf7opwzzwdhaqSJcZ3dYMtk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=c0JOFDjn; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="c0JOFDjn"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=z1vvnVo1qN72SUUfR1JNLXgFtnDutTVMaAZGTKbqCPk=; b=c0JOFDjnq5+Q3iuUmyoZ/KXCC/
	0dp/pEOPqaxq681nb8dhxypup5ezuM0vnxiMcxGmY4OFP8fWY2yyJqvx/rp6xuk/AuRT/Dd4OBIk3
	zkrbV7TkD+j2Xvx3d83NE75fnefLTo7KvhhXTeQlUkJEH8KmpIYcLno3JO+/Q2Ro7UBR32K3AERO5
	Qvh+FkwGEeSdmlfQNEaTFPyvJ/wEPf/HNfbB6hhFzfsMeJeBLbWpNy1JAdWNoBCg1lFhf7LbgzJLx
	28ROfB3JkhRlbVxV9M6QbPOQ8WpJ7e8t4Eifi2SNjELqznhL011t2n9mAPNtbb7teYNStDhOvLKV2
	DqD0iRVw==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wx8WH-0000000GALl-1nPQ;
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
Subject: [PATCH 7/7] Remove folio_launder()
Date: Thu, 20 Aug 2026 20:33:40 +0100
Message-ID: <20260820193343.3852967-8-willy@infradead.org>
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

When we do direct I/O, we need to evict any page cache that overlaps
the range in the file.  First we write back any dirty folios in the
range, then we lock each folio and remove it from the CPU page tables.
This leaves a wide window for userspace to re-dirty the folio by storing
to a shared writable mmap.

Many filesystems respond to this situation by failing the call to
release_folio(), but some try to writeback the dirty folio again, formerly
in their release_folio() method and now in their launder_folio() method.

Remove this inconsistency between filesystems by checking
whether the folio is dirty in the VFS and failing the call to
folio_unmap_invalidate().  Since we hold the folio locked and unmapped
at this time, there is no way to dirty the folio after this point.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 Documentation/filesystems/locking.rst |  8 --------
 Documentation/filesystems/vfs.rst     |  6 ------
 include/linux/fs.h                    |  1 -
 mm/truncate.c                         | 15 ++-------------
 4 files changed, 2 insertions(+), 28 deletions(-)

diff --git a/Documentation/filesystems/locking.rst b/Documentation/filesystems/locking.rst
index 08d01bc62c31..fd11f5c5d91e 100644
--- a/Documentation/filesystems/locking.rst
+++ b/Documentation/filesystems/locking.rst
@@ -261,7 +261,6 @@ prototypes::
 	int (*direct_IO)(struct kiocb *, struct iov_iter *iter);
 	int (*migrate_folio)(struct address_space *, struct folio *dst,
 			struct folio *src, enum migrate_mode);
-	int (*launder_folio)(struct folio *);
 	bool (*is_partially_uptodate)(struct folio *, size_t from, size_t count);
 	int (*error_remove_folio)(struct address_space *, struct folio *);
 	int (*swap_activate)(struct swap_info_struct *sis, struct file *f, sector_t *span)
@@ -286,7 +285,6 @@ release_folio:		yes
 free_folio:		yes
 direct_IO:
 migrate_folio:		yes (both)
-launder_folio:		yes
 is_partially_uptodate:	yes
 error_remove_folio:	yes
 swap_activate:		no
@@ -344,12 +342,6 @@ try_to_free_buffers().
 ->free_folio() is called when the kernel has dropped the folio
 from the page cache.
 
-->launder_folio() may be called prior to releasing a folio if
-it is still found to be dirty. It returns zero if the folio was successfully
-cleaned, or an error value if not. Note that in order to prevent the folio
-getting mapped back in and redirtied, it needs to be kept locked
-across the entire operation.
-
 ->swap_activate() will be called to prepare the given file for swap.  It
 should perform any validation and preparation necessary to ensure that
 writes can be performed with minimal memory allocation.  It should call
diff --git a/Documentation/filesystems/vfs.rst b/Documentation/filesystems/vfs.rst
index 7c753148af88..bff64713bd09 100644
--- a/Documentation/filesystems/vfs.rst
+++ b/Documentation/filesystems/vfs.rst
@@ -768,7 +768,6 @@ cache in your filesystem.  The following members are defined:
 		ssize_t (*direct_IO)(struct kiocb *, struct iov_iter *iter);
 		int (*migrate_folio)(struct mapping *, struct folio *dst,
 				struct folio *src, enum migrate_mode);
-		int (*launder_folio) (struct folio *);
 
 		bool (*is_partially_uptodate) (struct folio *, size_t from,
 					       size_t count);
@@ -942,11 +941,6 @@ cache in your filesystem.  The following members are defined:
 	folio to this function.  migrate_folio should transfer any private
 	data across and update any references that it has to the folio.
 
-``launder_folio``
-	Called before freeing a folio - it writes back the dirty folio.
-	To prevent redirtying the folio, it is kept locked during the
-	whole operation.
-
 ``is_partially_uptodate``
 	Called by the VM when reading a file through the pagecache when
 	the underlying blocksize is smaller than the size of the folio.
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 50ce731a2b78..e0f4f518fe24 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -428,7 +428,6 @@ struct address_space_operations {
 	 */
 	int (*migrate_folio)(struct address_space *, struct folio *dst,
 			struct folio *src, enum migrate_mode);
-	int (*launder_folio)(struct folio *);
 	bool (*is_partially_uptodate) (struct folio *, size_t from,
 			size_t count);
 	void (*is_dirty_writeback) (struct folio *, bool *dirty, bool *wb);
diff --git a/mm/truncate.c b/mm/truncate.c
index b58ba940be47..7f7d65fa926a 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -603,15 +603,6 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 }
 EXPORT_SYMBOL(invalidate_mapping_pages);
 
-static int folio_launder(struct address_space *mapping, struct folio *folio)
-{
-	if (!folio_test_dirty(folio))
-		return 0;
-	if (folio->mapping != mapping || mapping->a_ops->launder_folio == NULL)
-		return 0;
-	return mapping->a_ops->launder_folio(folio);
-}
-
 /*
  * This is like mapping_evict_folio(), except it ignores the folio's
  * refcount.  We do this because invalidate_inode_pages2() needs stronger
@@ -623,7 +614,6 @@ int folio_unmap_invalidate(struct address_space *mapping, struct folio *folio,
 			   gfp_t gfp)
 {
 	void (*free_folio)(struct folio *);
-	int ret;
 
 	VM_BUG_ON_FOLIO(!folio_test_locked(folio), folio);
 
@@ -631,9 +621,8 @@ int folio_unmap_invalidate(struct address_space *mapping, struct folio *folio,
 		unmap_mapping_folio(folio);
 	BUG_ON(folio_mapped(folio));
 
-	ret = folio_launder(mapping, folio);
-	if (ret)
-		return ret;
+	if (folio_test_dirty(folio))
+		return -EBUSY;
 	if (folio->mapping != mapping)
 		return -EBUSY;
 	if (!filemap_release_folio(folio, gfp))
-- 
2.47.3

