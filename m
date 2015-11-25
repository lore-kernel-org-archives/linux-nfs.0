Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:34711 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbbKYSuu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2015 13:50:50 -0500
Received: by qgeb1 with SMTP id b1so39088206qge.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2015 10:50:49 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@Primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: ensure that attrcache is revalidated after a SETATTR
Date: Wed, 25 Nov 2015 13:50:45 -0500
Message-Id: <1448477445-17853-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we get no post-op attributes back from a SETATTR operation, then no
attributes will of course be updated during the call to
nfs_update_inode.

We know however that the attributes are invalid at that point, since we
just changed some of them. At the very least, the ctime will be bogus.
If we get no post-op attributes back on the call, mark the attrcache
invalid to reflect that fact.

Reviewed-by: Steve French <steve.french@primarydata.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/inode.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index ffdf9b9e88ab..31b0a52223a7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -618,7 +618,10 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr,
 		nfs_inc_stats(inode, NFSIOS_SETATTRTRUNC);
 		nfs_vmtruncate(inode, attr->ia_size);
 	}
-	nfs_update_inode(inode, fattr);
+	if (fattr->valid)
+		nfs_update_inode(inode, fattr);
+	else
+		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
 	spin_unlock(&inode->i_lock);
 }
 EXPORT_SYMBOL_GPL(nfs_setattr_update_inode);
-- 
2.4.3

