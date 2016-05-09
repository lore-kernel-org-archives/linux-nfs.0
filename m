Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752896AbcEIWEN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 May 2016 18:04:13 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Subject: [PATCH v21 10/22] posix_acl: Improve xattr fixup code
Date: Tue, 10 May 2016 00:02:43 +0200
Message-Id: <1462831375-23017-11-git-send-email-agruenba@redhat.com>
In-Reply-To: <1462831375-23017-1-git-send-email-agruenba@redhat.com>
References: <1462831375-23017-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both XATTR_NAME_POSIX_ACL_ACCESS and XATTR_NAME_POSIX_ACL_DEFAULT have
the same XATTR_SYSTEM_PREFIX prefix; don't check for the same prefix
repeatedly.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Reviewed-by: Steve French <steve.french@primarydata.com>
---
 fs/xattr.c | 29 +++++++++++++++++++++++------
 1 file changed, 23 insertions(+), 6 deletions(-)

diff --git a/fs/xattr.c b/fs/xattr.c
index 4861322..c364696 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -295,6 +295,16 @@ out:
 }
 EXPORT_SYMBOL_GPL(vfs_removexattr);
 
+static void
+fix_xattr_from_user(const char *kname, void *kvalue, size_t size)
+{
+	if (strncmp(kname, XATTR_SYSTEM_PREFIX, XATTR_SYSTEM_PREFIX_LEN))
+		return;
+	kname += XATTR_SYSTEM_PREFIX_LEN;
+	if (!strcmp(kname, XATTR_POSIX_ACL_ACCESS) ||
+	    !strcmp(kname, XATTR_POSIX_ACL_DEFAULT))
+		posix_acl_fix_xattr_from_user(kvalue, size);
+}
 
 /*
  * Extended attribute SET operations
@@ -329,9 +339,7 @@ setxattr(struct dentry *d, const char __user *name, const void __user *value,
 			error = -EFAULT;
 			goto out;
 		}
-		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
-		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
-			posix_acl_fix_xattr_from_user(kvalue, size);
+		fix_xattr_from_user(kname, kvalue, size);
 	}
 
 	error = vfs_setxattr(d, kname, kvalue, size, flags);
@@ -396,6 +404,17 @@ SYSCALL_DEFINE5(fsetxattr, int, fd, const char __user *, name,
 	return error;
 }
 
+static void
+fix_xattr_to_user(const char *kname, void *kvalue, size_t size)
+{
+	if (strncmp(kname, XATTR_SYSTEM_PREFIX, XATTR_SYSTEM_PREFIX_LEN))
+		return;
+	kname += XATTR_SYSTEM_PREFIX_LEN;
+	if (!strcmp(kname, XATTR_POSIX_ACL_ACCESS) ||
+	    !strcmp(kname, XATTR_POSIX_ACL_DEFAULT))
+		posix_acl_fix_xattr_to_user(kvalue, size);
+}
+
 /*
  * Extended attribute GET operations
  */
@@ -426,9 +445,7 @@ getxattr(struct dentry *d, const char __user *name, void __user *value,
 
 	error = vfs_getxattr(d, kname, kvalue, size);
 	if (error > 0) {
-		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
-		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
-			posix_acl_fix_xattr_to_user(kvalue, size);
+		fix_xattr_to_user(kname, kvalue, size);
 		if (size && copy_to_user(value, kvalue, error))
 			error = -EFAULT;
 	} else if (error == -ERANGE && size >= XATTR_SIZE_MAX) {
-- 
2.5.5

