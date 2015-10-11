Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932328AbbJKXBv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Oct 2015 19:01:51 -0400
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
Subject: [PATCH v10 23/46] xfs: Make xfs_set_mode non-static
Date: Mon, 12 Oct 2015 00:58:34 +0200
Message-Id: <1444604337-17651-24-git-send-email-andreas.gruenbacher@gmail.com>
In-Reply-To: <1444604337-17651-1-git-send-email-andreas.gruenbacher@gmail.com>
References: <1444604337-17651-1-git-send-email-andreas.gruenbacher@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruenba@redhat.com>

Make xfs_set_mode non-static and move it from xfs_acl.c into xfs_inode.c.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/xfs/xfs_acl.c   | 18 ------------------
 fs/xfs/xfs_inode.c | 18 ++++++++++++++++++
 fs/xfs/xfs_inode.h |  2 ++
 3 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/fs/xfs/xfs_acl.c b/fs/xfs/xfs_acl.c
index 0f4ee92..8929466 100644
--- a/fs/xfs/xfs_acl.c
+++ b/fs/xfs/xfs_acl.c
@@ -226,24 +226,6 @@ __xfs_set_acl(struct inode *inode, int type, struct posix_acl *acl)
 }
 
 static int
-xfs_set_mode(struct inode *inode, umode_t mode)
-{
-	int error = 0;
-
-	if (mode != inode->i_mode) {
-		struct iattr iattr;
-
-		iattr.ia_valid = ATTR_MODE | ATTR_CTIME;
-		iattr.ia_mode = mode;
-		iattr.ia_ctime = current_fs_time(inode->i_sb);
-
-		error = xfs_setattr_nonsize(XFS_I(inode), &iattr, XFS_ATTR_NOACL);
-	}
-
-	return error;
-}
-
-static int
 xfs_acl_exists(struct inode *inode, unsigned char *name)
 {
 	int len = XFS_ACL_MAX_SIZE(XFS_M(inode->i_sb));
diff --git a/fs/xfs/xfs_inode.c b/fs/xfs/xfs_inode.c
index dc40a6d..69148fa 100644
--- a/fs/xfs/xfs_inode.c
+++ b/fs/xfs/xfs_inode.c
@@ -3587,3 +3587,21 @@ xfs_iflush_int(
 corrupt_out:
 	return -EFSCORRUPTED;
 }
+
+int
+xfs_set_mode(struct inode *inode, umode_t mode)
+{
+	int error = 0;
+
+	if (mode != inode->i_mode) {
+		struct iattr iattr;
+
+		iattr.ia_valid = ATTR_MODE | ATTR_CTIME;
+		iattr.ia_mode = mode;
+		iattr.ia_ctime = current_fs_time(inode->i_sb);
+
+		error = xfs_setattr_nonsize(XFS_I(inode), &iattr, XFS_ATTR_NOACL);
+	}
+
+	return error;
+}
diff --git a/fs/xfs/xfs_inode.h b/fs/xfs/xfs_inode.h
index ca9e119..7b22db0 100644
--- a/fs/xfs/xfs_inode.h
+++ b/fs/xfs/xfs_inode.h
@@ -424,6 +424,8 @@ int		xfs_dir_ialloc(struct xfs_trans **, struct xfs_inode *, umode_t,
 int		xfs_droplink(struct xfs_trans *, struct xfs_inode *);
 int		xfs_bumplink(struct xfs_trans *, struct xfs_inode *);
 
+int		xfs_set_mode(struct inode *, umode_t);
+
 /* from xfs_file.c */
 enum xfs_prealloc_flags {
 	XFS_PREALLOC_SET	= (1 << 1),
-- 
2.5.0

