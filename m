Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:34902 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbaIGPeV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Sep 2014 11:34:21 -0400
Received: from [50.247.105.171] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XQeTs-0005mq-1W
	for linux-nfs@vger.kernel.org; Sun, 07 Sep 2014 15:34:20 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfs: setattr can only change regular file sizes
Date: Sun,  7 Sep 2014 08:36:40 -0700
Message-Id: <1410104201-32517-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The VFS never calls setattr with ATTR_SIZE on anything but regular
files.  Remove the if check and turn it into an assert similar to
what some other file systems do.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/inode.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 577a36f..141c9f4 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -505,7 +505,9 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 		attr->ia_valid &= ~ATTR_MODE;
 
 	if (attr->ia_valid & ATTR_SIZE) {
-		if (!S_ISREG(inode->i_mode) || attr->ia_size == i_size_read(inode))
+		BUG_ON(!S_ISREG(inode->i_mode));
+
+		if (attr->ia_size == i_size_read(inode))
 			attr->ia_valid &= ~ATTR_SIZE;
 	}
 
-- 
1.9.1

