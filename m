Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:60509 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbaKWErX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Nov 2014 23:47:23 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so7490737pab.34
        for <linux-nfs@vger.kernel.org>; Sat, 22 Nov 2014 20:47:23 -0800 (PST)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id 1sm3290109pdw.87.2014.11.22.20.47.21
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Nov 2014 20:47:22 -0800 (PST)
From: roy.qing.li@gmail.com
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfs: replace nfs_add_stats with nfs_inc_stats when add one
Date: Sun, 23 Nov 2014 12:47:17 +0800
Message-Id: <1416718037-20914-1-git-send-email-roy.qing.li@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 fs/nfs/read.c  | 2 +-
 fs/nfs/write.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index beff276..c91a479 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -269,7 +269,7 @@ int nfs_readpage(struct file *file, struct page *page)
 	dprintk("NFS: nfs_readpage (%p %ld@%lu)\n",
 		page, PAGE_CACHE_SIZE, page_file_index(page));
 	nfs_inc_stats(inode, NFSIOS_VFSREADPAGE);
-	nfs_add_stats(inode, NFSIOS_READPAGES, 1);
+	nfs_inc_stats(inode, NFSIOS_READPAGES);
 
 	/*
 	 * Try to flush any pending writes to the file..
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1249384..605c3bd 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -575,7 +575,7 @@ static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, st
 	int ret;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
-	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
+	nfs_inc_stats(inode, NFSIOS_WRITEPAGES);
 
 	nfs_pageio_cond_complete(pgio, page_file_index(page));
 	ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE);
-- 
2.1.0

