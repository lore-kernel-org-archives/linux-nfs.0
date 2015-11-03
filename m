Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39004 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754178AbbKCPUQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2015 10:20:16 -0500
From: Andreas Gruenbacher <agruenba@redhat.com>
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
Subject: [PATCH v13 23/51] xfs: Make xfs_set_mode non-static
Date: Tue,  3 Nov 2015 16:16:59 +0100
Message-Id: <1446563847-14005-24-git-send-email-agruenba@redhat.com>
In-Reply-To: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
References: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make xfs_set_mode non-static and move it from xfs_acl.c into xfs_inode.c.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/xfs/xfs_acl.c   | 18 ------------------
 fs/xfs/xfs_inode.c | 24 ++++++++++++++++++++++++
 fs/xfs/xfs_inode.h |  2 ++
 3 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/fs/xfs/xfs_acl.c b/fs/xfs/xfs_acl.c
index e87fd3f..7b03383 100644
--- a/fs/xfs/xfs_acl.c
+++ b/fs/xfs/xfs_acl.c
@@ -232,24 +232,6 @@ __xfs_set_acl(struct inode *inode, int type, struct posix_acl *acl)
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
index dc40a6d..644fa04 100644
--- a/fs/xfs/xfs_inode.c
+++ b/fs/xfs/xfs_inode.c
@@ -3587,3 +3587,27 @@ xfs_iflush_int(
 corrupt_out:
 	return -EFSCORRUPTED;
 }
+
+/*
+ * Set an inode's file mode.
+ *
+ * Called when updating an inode's file mode as part of setting an ACL only.
+ * The VFS goes through the setattr inode operation instead.
+ */
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

