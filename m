Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:59075 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753264Ab0CQG0X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Mar 2010 02:26:23 -0400
Date: Wed, 17 Mar 2010 17:26:08 +1100
From: Nick Piggin <npiggin@suse.de>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [patch] nfs: use add_to_page_cache_lru, use __page_cache_alloc
Message-ID: <20100317062608.GD2869@laptop>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

nfs: use add_to_page_cache_lru, use __page_cache_alloc

Pagecache pages should be allocated with __page_cache_alloc, so they
obey pagecache memory policies.

add_to_page_cache_lru is exported, so it should be used. Benefits over
using a private pagevec: neater code, 128 bytes fewer stack used, percpu
lru ordering is preserved, and finally don't need to flush pagevec
before returning so batching may be shared with other LRU insertions.

Signed-off-by: Nick Piggin <npiggin@suse.de>:
---
 fs/nfs/dir.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

Index: linux-2.6/fs/nfs/dir.c
===================================================================
--- linux-2.6.orig/fs/nfs/dir.c
+++ linux-2.6/fs/nfs/dir.c
@@ -29,7 +29,6 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
 #include <linux/pagemap.h>
-#include <linux/pagevec.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
 #include <linux/sched.h>
@@ -1473,7 +1472,6 @@ static int nfs_unlink(struct inode *dir,
  */
 static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 {
-	struct pagevec lru_pvec;
 	struct page *page;
 	char *kaddr;
 	struct iattr attr;
@@ -1489,7 +1487,7 @@ static int nfs_symlink(struct inode *dir
 	attr.ia_mode = S_IFLNK | S_IRWXUGO;
 	attr.ia_valid = ATTR_MODE;
 
-	page = alloc_page(GFP_HIGHUSER);
+	page = __page_cache_alloc(GFP_HIGHUSER);
 	if (!page)
 		return -ENOMEM;
 
@@ -1513,11 +1511,8 @@ static int nfs_symlink(struct inode *dir
 	 * No big deal if we can't add this page to the page cache here.
 	 * READLINK will get the missing page from the server if needed.
 	 */
-	pagevec_init(&lru_pvec, 0);
-	if (!add_to_page_cache(page, dentry->d_inode->i_mapping, 0,
+	if (!add_to_page_cache_lru(page, dentry->d_inode->i_mapping, 0,
 							GFP_KERNEL)) {
-		pagevec_add(&lru_pvec, page);
-		pagevec_lru_add_file(&lru_pvec);
 		SetPageUptodate(page);
 		unlock_page(page);
 	} else
