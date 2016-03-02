Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40124 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755560AbcCBQgA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Mar 2016 11:36:00 -0500
Received: from chello080109146114.tirol.surfer.at ([80.109.146.114] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.85 #2 (Red Hat Linux))
	id 1ab9kk-00027x-9I
	for linux-nfs@vger.kernel.org; Wed, 02 Mar 2016 16:35:58 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfs: remove nfs_inode_dio_wait
Date: Wed,  2 Mar 2016 17:35:55 +0100
Message-Id: <1456936555-22602-2-git-send-email-hch@lst.de>
In-Reply-To: <1456936555-22602-1-git-send-email-hch@lst.de>
References: <1456936555-22602-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just call inode_dio_wait directly instead of through a pointless wrapper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/file.c     | 4 ++--
 fs/nfs/inode.c    | 2 +-
 fs/nfs/internal.h | 4 ----
 3 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index cdf8621..89bf093 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -272,7 +272,7 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 
 	trace_nfs_fsync_enter(inode);
 
-	nfs_inode_dio_wait(inode);
+	inode_dio_wait(inode);
 	do {
 		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
 		if (ret != 0)
@@ -370,7 +370,7 @@ start:
 	/*
 	 * Wait for O_DIRECT to complete
 	 */
-	nfs_inode_dio_wait(mapping->host);
+	inode_dio_wait(mapping->host);
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 86faecf..33d18c4 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -141,7 +141,7 @@ void nfs_evict_inode(struct inode *inode)
 
 int nfs_sync_inode(struct inode *inode)
 {
-	nfs_inode_dio_wait(inode);
+	inode_dio_wait(inode);
 	return nfs_wb_all(inode);
 }
 EXPORT_SYMBOL_GPL(nfs_sync_inode);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c41c5f5..565f813 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -515,10 +515,6 @@ extern int nfs_sillyrename(struct inode *dir, struct dentry *dentry);
 /* direct.c */
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 			      struct nfs_direct_req *dreq);
-static inline void nfs_inode_dio_wait(struct inode *inode)
-{
-	inode_dio_wait(inode);
-}
 extern ssize_t nfs_dreq_bytes_left(struct nfs_direct_req *dreq);
 
 /* nfs4proc.c */
-- 
2.1.4

