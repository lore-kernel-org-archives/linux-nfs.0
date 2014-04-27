Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:56983 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557AbaD0QQQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2014 12:16:16 -0400
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 02:16:14 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V1 20/22] vfs: Add richacl permission check
Date: Sun, 27 Apr 2014 21:44:51 +0530
Message-Id: <1398615293-22931-21-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/attr.c               |  6 ++++--
 fs/namei.c              | 13 +++++++++++-
 fs/richacl_base.c       | 54 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h      |  2 +-
 include/linux/richacl.h |  2 ++
 5 files changed, 73 insertions(+), 4 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index e468d4f2dca8..c46f3ed82150 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -15,6 +15,7 @@
 #include <linux/security.h>
 #include <linux/evm.h>
 #include <linux/ima.h>
+#include <linux/richacl.h>
 
 static int richacl_change_ok(struct inode *inode, int mask)
 {
@@ -23,8 +24,9 @@ static int richacl_change_ok(struct inode *inode, int mask)
 
 	if (inode->i_op->permission)
 		return inode->i_op->permission(inode, mask);
-
-	return check_acl(inode, mask);
+	if (inode->i_op->get_richacl)
+		return check_richacl(inode, mask);
+	return -EPERM;
 }
 
 static bool inode_uid_change_ok(struct inode *inode, kuid_t ia_uid)
diff --git a/fs/namei.c b/fs/namei.c
index 06474553c08d..12010e06aedd 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -34,6 +34,7 @@
 #include <linux/device_cgroup.h>
 #include <linux/fs_struct.h>
 #include <linux/posix_acl.h>
+#include <linux/richacl.h>
 #include <asm/uaccess.h>
 
 #include "internal.h"
@@ -249,7 +250,7 @@ void putname(struct filename *name)
 }
 #endif
 
-int check_acl(struct inode *inode, int mask)
+static int check_posix_acl(struct inode *inode, int mask)
 {
 #ifdef CONFIG_FS_POSIX_ACL
 	struct posix_acl *acl;
@@ -277,6 +278,16 @@ int check_acl(struct inode *inode, int mask)
 	return -EAGAIN;
 }
 
+static int check_acl(struct inode *inode, int mask)
+{
+	if (IS_POSIXACL(inode))
+		return check_posix_acl(inode, mask);
+	else if (IS_RICHACL(inode))
+		return check_richacl(inode, mask);
+	else
+		return -EAGAIN;
+}
+
 /*
  * This does the basic permission checking
  */
diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index d3beaacf6b9b..7c42290ae0c4 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -585,3 +585,57 @@ richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
 	return 0;
 }
 EXPORT_SYMBOL_GPL(richacl_equiv_mode);
+
+int check_richacl(struct inode *inode, int want)
+{
+#ifdef CONFIG_FS_RICHACL
+	struct richacl *acl;
+	int richacl_mask = richacl_want_to_mask(want);
+
+	if (want & MAY_NOT_BLOCK) {
+		acl = rcu_dereference(inode->i_richacl);
+		if (!acl)
+			return -EAGAIN;
+		/* no ->get_acl() calls in RCU mode... */
+		if (acl == ACL_NOT_CACHED)
+			return -ECHILD;
+		return richacl_permission(inode, acl, richacl_mask);
+	}
+	return richacl_check_acl(inode, richacl_mask);
+#endif
+	return -EAGAIN;
+}
+
+int richacl_check_acl(struct inode *inode, int richacl_mask)
+{
+
+#ifdef CONFIG_FS_RICHACL
+	struct richacl *acl;
+	acl = get_cached_richacl(inode);
+	/*
+	 * A filesystem can force a ACL callback by just never filling the
+	 * ACL cache. But normally you'd fill the cache either at inode
+	 * instantiation time, or on the first ->get_acl call.
+	 *
+	 * If the filesystem doesn't have a get_acl() function at all, we'll
+	 * just create the negative cache entry.
+	 */
+	if (acl == ACL_NOT_CACHED) {
+		if (inode->i_op->get_acl) {
+			acl = inode->i_op->get_richacl(inode);
+			if (IS_ERR(acl))
+				return PTR_ERR(acl);
+		} else {
+			set_cached_richacl(inode, NULL);
+			return -EAGAIN;
+		}
+	}
+	if (acl) {
+		int error = richacl_permission(inode, acl, richacl_mask);
+		richacl_put(acl);
+		return error;
+	}
+#endif
+	return -EAGAIN;
+}
+EXPORT_SYMBOL_GPL(richacl_check_acl);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 95df64d21e55..77459b6656ac 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1499,6 +1499,7 @@ struct inode_operations {
 	void * (*follow_link) (struct dentry *, struct nameidata *);
 	int (*permission) (struct inode *, int);
 	struct posix_acl * (*get_acl)(struct inode *, int);
+	struct richacl * (*get_richacl)(struct inode *);
 
 	int (*readlink) (struct dentry *, char __user *,int);
 	void (*put_link) (struct dentry *, struct nameidata *, void *);
@@ -2259,7 +2260,6 @@ extern sector_t bmap(struct inode *, sector_t);
 extern int notify_change(struct dentry *, struct iattr *, struct inode **);
 extern int inode_permission(struct inode *, int);
 extern int generic_permission(struct inode *, int);
-extern int check_acl(struct inode *, int);
 
 static inline bool execute_ok(struct inode *inode)
 {
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index a7db341e4ee9..17b58d470798 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -360,6 +360,8 @@ extern int richacl_permission(struct inode *, const struct richacl *,
 			      unsigned int);
 extern struct richacl *richacl_inherit(const struct richacl *, int);
 extern int richacl_equiv_mode(const struct richacl *, mode_t *);
+extern int check_richacl(struct inode *, int);
+extern int richacl_check_acl(struct inode *, int);
 
 /* richacl_inode.c */
 extern struct richacl *richacl_inherit_inode(const struct richacl *,
-- 
1.9.1

