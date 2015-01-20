Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:63224 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448AbbATQba (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jan 2015 11:31:30 -0500
Received: by mail-pa0-f47.google.com with SMTP id lj1so2365182pab.6
        for <linux-nfs@vger.kernel.org>; Tue, 20 Jan 2015 08:31:30 -0800 (PST)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH] nfs: clean up nfs_direct_IO
Date: Wed, 21 Jan 2015 00:20:11 +0800
Message-Id: <1421770811-25358-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This follows up "nfs: fix dio deadlock when O_DIRECT flag is flipped"
and removes the unnecessary CONFIG_NFS_SWAP switch.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/direct.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 1184118..645b777 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -259,18 +259,11 @@ ssize_t nfs_direct_IO(int rw, struct kiocb *iocb, struct iov_iter *iter, loff_t
 	if (!IS_SWAPFILE(inode))
 		return 0;
 
-#ifndef CONFIG_NFS_SWAP
-	dprintk("NFS: nfs_direct_IO (%pD) off/no(%Ld/%lu) EINVAL\n",
-			iocb->ki_filp, (long long) pos, iter->nr_segs);
-
-	return -EINVAL;
-#else
 	VM_BUG_ON(iocb->ki_nbytes != PAGE_SIZE);
 
 	if (rw == READ)
 		return nfs_file_direct_read(iocb, iter, pos);
 	return nfs_file_direct_write(iocb, iter, pos);
-#endif /* CONFIG_NFS_SWAP */
 }
 
 static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
-- 
1.9.1

