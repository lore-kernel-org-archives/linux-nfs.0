Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41728 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955AbcBHULx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Feb 2016 15:11:53 -0500
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: fix nfs_size_to_loff_t
Date: Mon,  8 Feb 2016 21:11:50 +0100
Message-Id: <1454962310-7384-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

See http://www.infradead.org/rpr.html

We support OFFSET_MAX just fine, so don't round down below it.  Also
switch to using min_t to make the helper more readable.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/nfs_fs.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 48e0320..67300f8 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -550,9 +550,7 @@ extern int  nfs_readpage_async(struct nfs_open_context *, struct inode *,
 
 static inline loff_t nfs_size_to_loff_t(__u64 size)
 {
-	if (size > (__u64) OFFSET_MAX - 1)
-		return OFFSET_MAX - 1;
-	return (loff_t) size;
+	return min_t(u64, size, OFFSET_MAX);
 }
 
 static inline ino_t
-- 
2.1.4

