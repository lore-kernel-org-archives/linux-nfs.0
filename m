Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f49.google.com ([209.85.220.49]:64893 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247AbbAHJS5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 04:18:57 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so10603343pac.8
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jan 2015 01:18:56 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        Omar Sandoval <osandov@osandov.com>
Subject: [PATCH RESEND] nfs: prevent truncate on active swapfile
Date: Thu,  8 Jan 2015 01:18:30 -0800
Message-Id: <fdc56e2887c3ed93f4e6a6e784ee0748c2d13295.1420708562.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Most filesystems prevent truncation of an active swapfile by way of
inode_newsize_ok, called from inode_change_ok. NFS doesn't call either
from nfs_setattr, presumably because most of these checks are expected
to be done server-side. However, the IS_SWAPFILE check can only be done
client-side, and truncating a swapfile can't possibly be good.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
Hi, Trond,

Now that the holidays are over, could you take a look at this? It was
generated against v3.19-rc3.

Thanks!

 fs/nfs/inode.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 4bffe63..9205513 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -506,10 +506,15 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 		attr->ia_valid &= ~ATTR_MODE;
 
 	if (attr->ia_valid & ATTR_SIZE) {
+		loff_t i_size;
+
 		BUG_ON(!S_ISREG(inode->i_mode));
 
-		if (attr->ia_size == i_size_read(inode))
+		i_size = i_size_read(inode);
+		if (attr->ia_size == i_size)
 			attr->ia_valid &= ~ATTR_SIZE;
+		else if (attr->ia_size < i_size && IS_SWAPFILE(inode))
+			return -ETXTBSY;
 	}
 
 	/* Optimization: if the end result is no change, don't RPC */
-- 
2.2.1

