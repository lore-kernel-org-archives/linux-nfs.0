Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:50825 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbaHUPF3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 11:05:29 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKTvb-0007jC-Qy
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 15:05:28 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: update time staps on truncate
Date: Thu, 21 Aug 2014 10:07:47 -0500
Message-Id: <1408633667-24177-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The VFS handles attributes on truncate in a strange way, fix NFS to handle
it properly by copying a small code sniplet from XFS.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/inode.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 577a36f..5bbd991 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -505,8 +505,28 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 		attr->ia_valid &= ~ATTR_MODE;
 
 	if (attr->ia_valid & ATTR_SIZE) {
-		if (!S_ISREG(inode->i_mode) || attr->ia_size == i_size_read(inode))
+		if (!S_ISREG(inode->i_mode) ||
+		    attr->ia_size == i_size_read(inode))
 			attr->ia_valid &= ~ATTR_SIZE;
+
+		/*
+		 * Only change the c/mtime if we are changing the size or we
+		 * are explicitly asked to change it.  This handles the
+		 * semantic difference between truncate() and ftruncate() as
+		 * implemented in the VFS.
+		 *
+		 * The regular truncate() case without ATTR_CTIME and
+		 * ATTR_MTIME is a special case where we need to update the
+		 * times despite not having these flags set.  For all other
+		 * operations the VFS set these flags explicitly if it wants
+		 * a timestamp update.
+		 */
+		if (attr->ia_size != i_size_read(inode) &&
+		    !(attr->ia_valid & (ATTR_CTIME | ATTR_MTIME))) {
+			attr->ia_ctime = attr->ia_mtime =
+				current_fs_time(inode->i_sb);
+			attr->ia_valid |= ATTR_CTIME | ATTR_MTIME;
+		}
 	}
 
 	/* Optimization: if the end result is no change, don't RPC */
-- 
1.9.1

