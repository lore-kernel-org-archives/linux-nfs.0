Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:34903 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbaIGPeY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Sep 2014 11:34:24 -0400
Received: from [50.247.105.171] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XQeTu-0005mv-VM
	for linux-nfs@vger.kernel.org; Sun, 07 Sep 2014 15:34:23 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfs: update time staps on truncate
Date: Sun,  7 Sep 2014 08:36:41 -0700
Message-Id: <1410104201-32517-2-git-send-email-hch@lst.de>
In-Reply-To: <1410104201-32517-1-git-send-email-hch@lst.de>
References: <1410104201-32517-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The VFS handles attributes on truncate in a strange way, fix NFS to
properly update timestamps on truncate().

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/inode.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 141c9f4..97bc485 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -507,8 +507,20 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 	if (attr->ia_valid & ATTR_SIZE) {
 		BUG_ON(!S_ISREG(inode->i_mode));
 
+		/*
+		 * Calling conventions are a little "unconventional" for
+		 * truncate:
+		 *  - for truncate() the VFS does not set ATTR_CTIME and
+		 *    ATTR_MTIME, but we still need need to update the time
+		 *    stamps if we change the file size.
+		 *  - for ftruncate() the VFS sets ATTR_CTIME and ATTR_MTIME,
+		 *    and we always need to change the time stamp, even if
+		 *    the size does not change.
+		 */
 		if (attr->ia_size == i_size_read(inode))
 			attr->ia_valid &= ~ATTR_SIZE;
+		else if (!(attr->ia_valid & (ATTR_CTIME | ATTR_MTIME)))
+			attr->ia_valid |= ATTR_CTIME | ATTR_MTIME;
 	}
 
 	/* Optimization: if the end result is no change, don't RPC */
-- 
1.9.1

