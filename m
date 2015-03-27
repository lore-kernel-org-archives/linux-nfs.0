Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36577 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753354AbbC0RFR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 13:05:17 -0400
Received: by igbud6 with SMTP id ud6so25958361igb.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 10:05:17 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4: Truncating file opens should also sync O_DIRECT writes
Date: Fri, 27 Mar 2015 13:05:13 -0400
Message-Id: <1427475913-14626-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1427475913-14626-2-git-send-email-trond.myklebust@primarydata.com>
References: <1427475913-14626-1-git-send-email-trond.myklebust@primarydata.com>
 <1427475913-14626-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't just want to sync out buffered writes, but also O_DIRECT ones.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c         | 3 ++-
 fs/nfs/nfs4file.c      | 2 +-
 include/linux/nfs_fs.h | 1 +
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 60f907666697..f1fc0e4c1c02 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -133,11 +133,12 @@ void nfs_evict_inode(struct inode *inode)
 	nfs_clear_inode(inode);
 }
 
-static int nfs_sync_inode(struct inode *inode)
+int nfs_sync_inode(struct inode *inode)
 {
 	nfs_inode_dio_wait(inode);
 	return nfs_wb_all(inode);
 }
+EXPORT_SYMBOL_GPL(nfs_sync_inode);
 
 /**
  * nfs_sync_mapping - helper to flush all mmapped dirty data to disk
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 0de62f7cfebf..8da5409e6f1a 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -59,7 +59,7 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 	if (openflags & O_TRUNC) {
 		attr.ia_valid |= ATTR_SIZE;
 		attr.ia_size = 0;
-		nfs_wb_all(inode);
+		nfs_sync_inode(inode);
 	}
 
 	inode = NFS_PROTO(dir)->open_context(dir, ctx, openflags, &attr, &opened);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index b01ccf371fdc..b638eb6727c6 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -512,6 +512,7 @@ extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned
  * Try to write back everything synchronously (but check the
  * return value!)
  */
+extern int nfs_sync_inode(struct inode *inode);
 extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
-- 
2.1.0

