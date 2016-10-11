Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38148 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754085AbcJKMwg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Oct 2016 08:52:36 -0400
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
Subject: [PATCH v27 18/21] vfs: Add richacl permission checking
Date: Tue, 11 Oct 2016 14:50:53 +0200
Message-Id: <1476190256-1677-19-git-send-email-agruenba@redhat.com>
In-Reply-To: <1476190256-1677-1-git-send-email-agruenba@redhat.com>
References: <1476190256-1677-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hook the richacl permission checking function into the vfs.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 52 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 7b8e00d7..9808154c 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -34,6 +34,7 @@
 #include <linux/device_cgroup.h>
 #include <linux/fs_struct.h>
 #include <linux/posix_acl.h>
+#include <linux/richacl.h>
 #include <linux/hash.h>
 #include <linux/bitops.h>
 #include <linux/init_task.h>
@@ -257,7 +258,43 @@ void putname(struct filename *name)
 		__putname(name);
 }
 
-static int check_acl(struct inode *inode, int mask)
+static int check_richacl(struct inode *inode, int mask)
+{
+#ifdef CONFIG_FS_RICHACL
+	if (mask & MAY_NOT_BLOCK) {
+		struct base_acl *base_acl;
+
+		base_acl = rcu_dereference(inode->i_acl);
+		if (!base_acl)
+			goto no_acl;
+		/* no ->get_richacl() calls in RCU mode... */
+		if (is_uncached_acl(base_acl))
+			return -ECHILD;
+		return richacl_permission(inode, richacl(base_acl),
+					  mask & ~MAY_NOT_BLOCK);
+	} else {
+		struct richacl *acl;
+
+		acl = get_richacl(inode);
+		if (IS_ERR(acl))
+			return PTR_ERR(acl);
+		if (acl) {
+			int error = richacl_permission(inode, acl, mask);
+			richacl_put(acl);
+			return error;
+		}
+	}
+no_acl:
+#endif
+	if (mask & (MAY_DELETE_SELF | MAY_TAKE_OWNERSHIP |
+		    MAY_CHMOD | MAY_SET_TIMES)) {
+		/* File permission bits cannot grant this. */
+		return -EACCES;
+	}
+	return -EAGAIN;
+}
+
+static int check_posix_acl(struct inode *inode, int mask)
 {
 #ifdef CONFIG_FS_POSIX_ACL
 	if (mask & MAY_NOT_BLOCK) {
@@ -295,11 +332,24 @@ static int acl_permission_check(struct inode *inode, int mask)
 {
 	unsigned int mode = inode->i_mode;
 
+	/*
+	 * With POSIX ACLs, the (mode & S_IRWXU) bits exactly match the owner
+	 * permissions, and we can skip checking posix acls for the owner.
+	 * With richacls, the owner may be granted fewer permissions than the
+	 * mode bits seem to suggest (for example, append but not write), and
+	 * we always need to check the richacl.
+	 */
+
+	if (IS_RICHACL(inode)) {
+		int error = check_richacl(inode, mask);
+		if (error != -EAGAIN)
+			return error;
+	}
 	if (likely(uid_eq(current_fsuid(), inode->i_uid)))
 		mode >>= 6;
 	else {
 		if (IS_POSIXACL(inode) && (mode & S_IRWXG)) {
-			int error = check_acl(inode, mask);
+			int error = check_posix_acl(inode, mask);
 			if (error != -EAGAIN)
 				return error;
 		}
-- 
2.7.4

