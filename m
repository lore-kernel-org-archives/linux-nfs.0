Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33980 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185AbcFWUBx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2016 16:01:53 -0400
Received: by mail-it0-f68.google.com with SMTP id f6so12796076ith.1
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jun 2016 13:01:53 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 15/17] NFS: Remove redundant waits for O_DIRECT in fsync() and write_begin()
Date: Thu, 23 Jun 2016 16:00:47 -0400
Message-Id: <1466712049-5326-15-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466712049-5326-14-git-send-email-trond.myklebust@primarydata.com>
References: <1466712049-5326-1-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-2-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-3-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-4-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-5-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-6-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-7-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-8-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-9-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-10-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-11-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-12-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-13-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-14-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're now waiting immediately after taking the locks, so waiting
in fsync() and write_begin() is either redundant or potentially
subject to livelock (if not holding the lock).

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 9f8da9e1b23f..0e9b4a068f13 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -276,7 +276,6 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 
 	trace_nfs_fsync_enter(inode);
 
-	inode_dio_wait(inode);
 	do {
 		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
 		if (ret != 0)
@@ -361,11 +360,6 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 		file, mapping->host->i_ino, len, (long long) pos);
 
 start:
-	/*
-	 * Wait for O_DIRECT to complete
-	 */
-	inode_dio_wait(mapping->host);
-
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
-- 
2.7.4

