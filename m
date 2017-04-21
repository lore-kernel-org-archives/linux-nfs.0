Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:64144 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034939AbdDUDos (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Apr 2017 23:44:48 -0400
From: Ross Zwisler <ross.zwisler@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>,
        linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Alexey Kuznetsov <kuznet@virtuozzo.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@lst.de>,
        Dan Williams <dan.j.williams@intel.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Latchesar Ionkov <lucho@ionkov.net>,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>,
        Ron Minnich <rminnich@sandia.gov>,
        samba-technical@lists.samba.org, Steve French <sfrench@samba.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        v9fs-developer@lists.sourceforge.net
Subject: [PATCH 2/2] dax: fix data corruption due to stale mmap reads
Date: Thu, 20 Apr 2017 21:44:37 -0600
Message-Id: <20170421034437.4359-2-ross.zwisler@linux.intel.com>
In-Reply-To: <20170421034437.4359-1-ross.zwisler@linux.intel.com>
References: <20170420191446.GA21694@linux.intel.com>
 <20170421034437.4359-1-ross.zwisler@linux.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Users of DAX can suffer data corruption from stale mmap reads via the
following sequence:

- open an mmap over a 2MiB hole

- read from a 2MiB hole, faulting in a 2MiB zero page

- write to the hole with write(3p).  The write succeeds but we incorrectly
  leave the 2MiB zero page mapping intact.

- via the mmap, read the data that was just written.  Since the zero page
  mapping is still intact we read back zeroes instead of the new data.

We fix this by unconditionally calling invalidate_inode_pages2_range() in
dax_iomap_actor() for new block allocations, and by enhancing
__dax_invalidate_mapping_entry() so that it properly unmaps the DAX entry
being removed from the radix tree.

This is based on an initial patch from Jan Kara.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Fixes: c6dcf52c23d2 ("mm: Invalidate DAX radix tree entries only if appropriate")
Reported-by: Jan Kara <jack@suse.cz>
Cc: <stable@vger.kernel.org>    [4.10+]
---
 fs/dax.c | 26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 166504c..3f445d5 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -468,23 +468,35 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 					  pgoff_t index, bool trunc)
 {
 	int ret = 0;
-	void *entry;
+	void *entry, **slot;
 	struct radix_tree_root *page_tree = &mapping->page_tree;
 
 	spin_lock_irq(&mapping->tree_lock);
-	entry = get_unlocked_mapping_entry(mapping, index, NULL);
+	entry = get_unlocked_mapping_entry(mapping, index, &slot);
 	if (!entry || !radix_tree_exceptional_entry(entry))
 		goto out;
 	if (!trunc &&
 	    (radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_DIRTY) ||
 	     radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE)))
 		goto out;
+
+	/*
+	 * Make sure 'entry' remains valid while we drop mapping->tree_lock to
+	 * do the unmap_mapping_range() call.
+	 */
+	entry = lock_slot(mapping, slot);
+	spin_unlock_irq(&mapping->tree_lock);
+
+	unmap_mapping_range(mapping, (loff_t)index << PAGE_SHIFT,
+			(loff_t)PAGE_SIZE << dax_radix_order(entry), 0);
+
+	spin_lock_irq(&mapping->tree_lock);
 	radix_tree_delete(page_tree, index);
 	mapping->nrexceptional--;
 	ret = 1;
 out:
-	put_unlocked_mapping_entry(mapping, index, entry);
 	spin_unlock_irq(&mapping->tree_lock);
+	dax_wake_mapping_entry_waiter(mapping, index, entry, true);
 	return ret;
 }
 /*
@@ -999,11 +1011,11 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		return -EIO;
 
 	/*
-	 * Write can allocate block for an area which has a hole page mapped
-	 * into page tables. We have to tear down these mappings so that data
-	 * written by write(2) is visible in mmap.
+	 * Write can allocate block for an area which has a hole page or zero
+	 * PMD entry in the radix tree.  We have to tear down these mappings so
+	 * that data written by write(2) is visible in mmap.
 	 */
-	if ((iomap->flags & IOMAP_F_NEW) && inode->i_mapping->nrpages) {
+	if (iomap->flags & IOMAP_F_NEW) {
 		invalidate_inode_pages2_range(inode->i_mapping,
 					      pos >> PAGE_SHIFT,
 					      (end - 1) >> PAGE_SHIFT);
-- 
2.9.3

