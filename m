Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753065AbcB2ISp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Feb 2016 03:18:45 -0500
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "Theodore Ts'o" <tytso@mit.edu>, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
        Christoph Hellwig <hch@infradead.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH v18 20/22] vfs: Add richacl permission checking
Date: Mon, 29 Feb 2016 09:17:25 +0100
Message-Id: <1456733847-17982-21-git-send-email-agruenba@redhat.com>
In-Reply-To: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hook the richacl permission checking function into the vfs.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/namei.c     | 51 +++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/posix_acl.c |  6 +++---
 2 files changed, 52 insertions(+), 5 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 59b1da0..716c01d 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -35,6 +35,7 @@
 #include <linux/fs_struct.h>
 #include <linux/posix_acl.h>
 #include <linux/hash.h>
+#include <linux/richacl.h>
 #include <asm/uaccess.h>
 
 #include "internal.h"
@@ -255,7 +256,40 @@ void putname(struct filename *name)
 		__putname(name);
 }
 
-static int check_acl(struct inode *inode, int mask)
+static int check_richacl(struct inode *inode, int mask)
+{
+#ifdef CONFIG_FS_RICHACL
+	struct richacl *acl;
+
+	if (mask & MAY_NOT_BLOCK) {
+		acl = get_cached_richacl_rcu(inode);
+		if (!acl)
+			goto no_acl;
+		/* no ->get_richacl() calls in RCU mode... */
+		if (acl == ACL_NOT_CACHED)
+			return -ECHILD;
+		return richacl_permission(inode, acl, mask & ~MAY_NOT_BLOCK);
+	}
+
+	acl = get_richacl(inode);
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
+	if (acl) {
+		int error = richacl_permission(inode, acl, mask);
+		richacl_put(acl);
+		return error;
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
 	struct posix_acl *acl;
@@ -290,11 +324,24 @@ static int acl_permission_check(struct inode *inode, int mask)
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
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index f24646e..7810c6f 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -100,13 +100,13 @@ struct posix_acl *get_acl(struct inode *inode, int type)
 {
 	struct posix_acl *acl;
 
+	if (!IS_POSIXACL(inode))
+		return NULL;
+
 	acl = get_cached_acl(inode, type);
 	if (acl != ACL_NOT_CACHED)
 		return acl;
 
-	if (!IS_POSIXACL(inode))
-		return NULL;
-
 	/*
 	 * A filesystem can force a ACL callback by just never filling the
 	 * ACL cache. But normally you'd fill the cache either at inode
-- 
2.4.3

