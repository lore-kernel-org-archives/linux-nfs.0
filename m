Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.polytechnique.org ([129.104.30.34]:49514 "EHLO
	mx1.polytechnique.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933537AbbDPKuH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Apr 2015 06:50:07 -0400
From: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
To: roy.qing.li@gmail.com, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Subject: [PATCH] Revert "nfs: replace nfs_add_stats with nfs_inc_stats when add one"
Date: Thu, 16 Apr 2015 18:48:39 +0800
Message-Id: <1429181319-6163-1-git-send-email-nicolas.iooss_linux@m4x.org>
In-Reply-To: <55115E3C.2030104@m4x.org>
References: <55115E3C.2030104@m4x.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 5a254d08b086d80cbead2ebcee6d2a4b3a15587a.

Since commit 5a254d08b086 ("nfs: replace nfs_add_stats with
nfs_inc_stats when add one"), nfs_readpage and nfs_do_writepage use
nfs_inc_stats to increment NFSIOS_READPAGES and NFSIOS_WRITEPAGES
instead of nfs_add_stats.

However nfs_inc_stats does not do the same thing as nfs_add_stats with
value 1 because these functions work on distinct stats:
nfs_inc_stats increments stats from "enum nfs_stat_eventcounters" (in
server->io_stats->events) and nfs_add_stats those from "enum
nfs_stat_bytecounters" (in server->io_stats->bytes).

Signed-off-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
---

As I haven't got any reply from the message I sent a few weeks ago, I
am now sending a patch.
More details about the reason of this revert can be found in my
previous e-mail, https://lkml.org/lkml/2015/3/24/226.

 fs/nfs/read.c  | 2 +-
 fs/nfs/write.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 568ecf0a880f..848d8b1db4ce 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -284,7 +284,7 @@ int nfs_readpage(struct file *file, struct page *page)
 	dprintk("NFS: nfs_readpage (%p %ld@%lu)\n",
 		page, PAGE_CACHE_SIZE, page_file_index(page));
 	nfs_inc_stats(inode, NFSIOS_VFSREADPAGE);
-	nfs_inc_stats(inode, NFSIOS_READPAGES);
+	nfs_add_stats(inode, NFSIOS_READPAGES, 1);
 
 	/*
 	 * Try to flush any pending writes to the file..
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 759931088094..fae7f97ad34d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -580,7 +580,7 @@ static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, st
 	int ret;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
-	nfs_inc_stats(inode, NFSIOS_WRITEPAGES);
+	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
 
 	nfs_pageio_cond_complete(pgio, page_file_index(page));
 	ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE);
-- 
2.3.5

