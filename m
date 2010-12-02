Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28482 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756546Ab0LBDIP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 22:08:15 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>,
        Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: [PATCH v3 2/3] Call the filesystem back whenever a page is removed from the page cache
Date: Wed,  1 Dec 2010 22:08:04 -0500
Message-Id: <1291259285-26803-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1291259285-26803-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1291259285-26803-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291259285-26803-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <AANLkTinpvMJsC2XMUyDTaAdozFBLkcdde5_V57Jx-Z4w@mail.gmail.com>
References: <AANLkTinpvMJsC2XMUyDTaAdozFBLkcdde5_V57Jx-Z4w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Linus Torvalds <torvalds@linux-foundation.org>

NFS needs to be able to release objects that are stored in the page
cache once the page itself is no longer visible from the page cache.

This patch adds a callback to the address space operations that allows
filesystems to perform page cleanups once the page has been removed
from the page cache.

Original patch by: Linus Torvalds <torvalds@linux-foundation.org>
[trondmy: cover the cases of invalidate_inode_pages2() and
          truncate_inode_pages()]
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 Documentation/filesystems/Locking |    7 ++++++-
 Documentation/filesystems/vfs.txt |    7 +++++++
 include/linux/fs.h                |    1 +
 mm/truncate.c                     |    8 ++++++++
 mm/vmscan.c                       |   11 +++++++++++
 5 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index a91f308..b6426f1 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -173,12 +173,13 @@ prototypes:
 	sector_t (*bmap)(struct address_space *, sector_t);
 	int (*invalidatepage) (struct page *, unsigned long);
 	int (*releasepage) (struct page *, int);
+	void (*freepage)(struct page *);
 	int (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs);
 	int (*launder_page) (struct page *);
 
 locking rules:
-	All except set_page_dirty may block
+	All except set_page_dirty and freepage may block
 
 			BKL	PageLocked(page)	i_mutex
 writepage:		no	yes, unlocks (see below)
@@ -193,6 +194,7 @@ perform_write:		no	n/a			yes
 bmap:			no
 invalidatepage:		no	yes
 releasepage:		no	yes
+freepage:		no	yes
 direct_IO:		no
 launder_page:		no	yes
 
@@ -288,6 +290,9 @@ buffers from the page in preparation for freeing it.  It returns zero to
 indicate that the buffers are (or may be) freeable.  If ->releasepage is zero,
 the kernel assumes that the fs has no private interest in the buffers.
 
+	->freepage() is called when the kernel is done dropping the page
+from the page cache.
+
 	->launder_page() may be called prior to releasing a page if
 it is still found to be dirty. It returns zero if the page was successfully
 cleaned, or an error value if not. Note that in order to prevent the page
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index ed7e5ef..3b14a55 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -534,6 +534,7 @@ struct address_space_operations {
 	sector_t (*bmap)(struct address_space *, sector_t);
 	int (*invalidatepage) (struct page *, unsigned long);
 	int (*releasepage) (struct page *, int);
+	void (*freepage)(struct page *);
 	ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs);
 	struct page* (*get_xip_page)(struct address_space *, sector_t,
@@ -679,6 +680,12 @@ struct address_space_operations {
         need to ensure this.  Possibly it can clear the PageUptodate
         bit if it cannot free private data yet.
 
+  freepage: freepage is called once the page is no longer visible in
+        the page cache in order to allow the cleanup of any private
+	data. Since it may be called by the memory reclaimer, it
+	should not assume that the original address_space mapping still
+	exists, and it should not block.
+
   direct_IO: called by the generic read/write routines to perform
         direct_IO - that is IO requests which bypass the page cache
         and transfer data directly between the storage and the
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c9e06cc..090f0ea 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -602,6 +602,7 @@ struct address_space_operations {
 	sector_t (*bmap)(struct address_space *, sector_t);
 	void (*invalidatepage) (struct page *, unsigned long);
 	int (*releasepage) (struct page *, gfp_t);
+	void (*freepage)(struct page *);
 	ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs);
 	int (*get_xip_mem)(struct address_space *, pgoff_t, int,
diff --git a/mm/truncate.c b/mm/truncate.c
index ba887bf..76ab2a8 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -108,6 +108,10 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 	clear_page_mlock(page);
 	remove_from_page_cache(page);
 	ClearPageMappedToDisk(page);
+
+	if (mapping->a_ops->freepage)
+		mapping->a_ops->freepage(page);
+
 	page_cache_release(page);	/* pagecache ref */
 	return 0;
 }
@@ -390,6 +394,10 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	__remove_from_page_cache(page);
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
+
+	if (mapping->a_ops->freepage)
+		mapping->a_ops->freepage(page);
+
 	page_cache_release(page);	/* pagecache ref */
 	return 1;
 failed:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d31d7ce..9e218e7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -454,6 +454,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
+	preempt_disable();
 	spin_lock_irq(&mapping->tree_lock);
 	/*
 	 * The non racy check for a busy page.
@@ -492,10 +493,19 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
 		swp_entry_t swap = { .val = page_private(page) };
 		__delete_from_swap_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
+		preempt_enable();
 		swapcache_free(swap, page);
 	} else {
+		void (*freepage)(struct page *);
+
+		freepage = mapping->a_ops->freepage;
+
 		__remove_from_page_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
+		if (freepage != NULL)
+			freepage(page);
+		preempt_enable();
+
 		mem_cgroup_uncharge_cache_page(page);
 	}
 
@@ -503,6 +513,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
 
 cannot_free:
 	spin_unlock_irq(&mapping->tree_lock);
+	preempt_enable();
 	return 0;
 }
 
-- 
1.7.3.2

