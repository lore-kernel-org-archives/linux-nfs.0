Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35430 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686AbbJKXBo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Oct 2015 19:01:44 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Cc: Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH v10 22/46] xfs: Fix error path in xfs_get_acl
Date: Mon, 12 Oct 2015 00:58:33 +0200
Message-Id: <1444604337-17651-23-git-send-email-andreas.gruenbacher@gmail.com>
In-Reply-To: <1444604337-17651-1-git-send-email-andreas.gruenbacher@gmail.com>
References: <1444604337-17651-1-git-send-email-andreas.gruenbacher@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruenba@redhat.com>

Error codes from xfs_attr_get other than -ENOATTR were not properly
reported.  Fix that, and clean the code up somewhat.

In addition, the declaration of struct xfs_inode in xfs_acl.h isn't needed.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/xfs/xfs_acl.c | 19 +++++++------------
 fs/xfs/xfs_acl.h |  1 -
 2 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/fs/xfs/xfs_acl.c b/fs/xfs/xfs_acl.c
index 4b64167..0f4ee92 100644
--- a/fs/xfs/xfs_acl.c
+++ b/fs/xfs/xfs_acl.c
@@ -122,7 +122,7 @@ struct posix_acl *
 xfs_get_acl(struct inode *inode, int type)
 {
 	struct xfs_inode *ip = XFS_I(inode);
-	struct posix_acl *acl = NULL;
+	struct posix_acl *acl;
 	struct xfs_acl *xfs_acl;
 	unsigned char *ea_name;
 	int error;
@@ -158,18 +158,13 @@ xfs_get_acl(struct inode *inode, int type)
 		 * cache entry, for any other error assume it is transient and
 		 * leave the cache entry as ACL_NOT_CACHED.
 		 */
-		if (error == -ENOATTR)
-			goto out_update_cache;
-		goto out;
-	}
+		acl = (error == -ENOATTR) ? NULL : ERR_PTR(error);
+	} else
+		acl = xfs_acl_from_disk(xfs_acl,
+					XFS_ACL_MAX_ENTRIES(ip->i_mount));
 
-	acl = xfs_acl_from_disk(xfs_acl, XFS_ACL_MAX_ENTRIES(ip->i_mount));
-	if (IS_ERR(acl))
-		goto out;
-
-out_update_cache:
-	set_cached_acl(inode, type, acl);
-out:
+	if (!IS_ERR(acl))
+		set_cached_acl(inode, type, acl);
 	kmem_free(xfs_acl);
 	return acl;
 }
diff --git a/fs/xfs/xfs_acl.h b/fs/xfs/xfs_acl.h
index 3841b07..9ee0a0d 100644
--- a/fs/xfs/xfs_acl.h
+++ b/fs/xfs/xfs_acl.h
@@ -20,7 +20,6 @@
 
 struct inode;
 struct posix_acl;
-struct xfs_inode;
 
 #ifdef CONFIG_XFS_POSIX_ACL
 extern struct posix_acl *xfs_get_acl(struct inode *inode, int type);
-- 
2.5.0

