Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36658 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932224AbcFNTFk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 15:05:40 -0400
Received: by mail-io0-f195.google.com with SMTP id o127so397750iod.3
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 12:05:40 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/12] NFS: Kill NFS_INO_NFS_INO_FLUSHING: it is a performance killer
Date: Tue, 14 Jun 2016 15:05:07 -0400
Message-Id: <1465931115-30784-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
References: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

filemap_datawrite() and friends already deal just fine with livelock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c          |  8 --------
 fs/nfs/nfstrace.h      |  1 -
 fs/nfs/write.c         | 11 -----------
 include/linux/nfs_fs.h |  1 -
 4 files changed, 21 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 2d39d9f9da7d..29d7477a62e8 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -360,14 +360,6 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 
 start:
 	/*
-	 * Prevent starvation issues if someone is doing a consistency
-	 * sync-to-disk
-	 */
-	ret = wait_on_bit_action(&NFS_I(mapping->host)->flags, NFS_INO_FLUSHING,
-				 nfs_wait_bit_killable, TASK_KILLABLE);
-	if (ret)
-		return ret;
-	/*
 	 * Wait for O_DIRECT to complete
 	 */
 	inode_dio_wait(mapping->host);
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index 0b9e5cc9a747..fe80a1c26340 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -37,7 +37,6 @@
 			{ 1 << NFS_INO_ADVISE_RDPLUS, "ADVISE_RDPLUS" }, \
 			{ 1 << NFS_INO_STALE, "STALE" }, \
 			{ 1 << NFS_INO_INVALIDATING, "INVALIDATING" }, \
-			{ 1 << NFS_INO_FLUSHING, "FLUSHING" }, \
 			{ 1 << NFS_INO_FSCACHE, "FSCACHE" }, \
 			{ 1 << NFS_INO_LAYOUTCOMMIT, "NEED_LAYOUTCOMMIT" }, \
 			{ 1 << NFS_INO_LAYOUTCOMMITTING, "LAYOUTCOMMIT" })
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e1c74d3db64d..980d44f3a84c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -657,16 +657,9 @@ static int nfs_writepages_callback(struct page *page, struct writeback_control *
 int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
-	unsigned long *bitlock = &NFS_I(inode)->flags;
 	struct nfs_pageio_descriptor pgio;
 	int err;
 
-	/* Stop dirtying of new pages while we sync */
-	err = wait_on_bit_lock_action(bitlock, NFS_INO_FLUSHING,
-			nfs_wait_bit_killable, TASK_KILLABLE);
-	if (err)
-		goto out_err;
-
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGES);
 
 	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc), false,
@@ -674,10 +667,6 @@ int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 	err = write_cache_pages(mapping, wbc, nfs_writepages_callback, &pgio);
 	nfs_pageio_complete(&pgio);
 
-	clear_bit_unlock(NFS_INO_FLUSHING, bitlock);
-	smp_mb__after_atomic();
-	wake_up_bit(bitlock, NFS_INO_FLUSHING);
-
 	if (err < 0)
 		goto out_err;
 	err = pgio.pg_error;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index d71278c3c5bd..120dd04b553c 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -205,7 +205,6 @@ struct nfs_inode {
 #define NFS_INO_STALE		(1)		/* possible stale inode */
 #define NFS_INO_ACL_LRU_SET	(2)		/* Inode is on the LRU list */
 #define NFS_INO_INVALIDATING	(3)		/* inode is being invalidated */
-#define NFS_INO_FLUSHING	(4)		/* inode is flushing out data */
 #define NFS_INO_FSCACHE		(5)		/* inode can be cached by FS-Cache */
 #define NFS_INO_FSCACHE_LOCK	(6)		/* FS-Cache cookie management lock */
 #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
-- 
2.5.5

