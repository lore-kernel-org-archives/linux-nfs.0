Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:40736 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350AbaD0QPg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2014 12:15:36 -0400
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 02:15:35 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V1 08/22] vfs: Add permission flags for setting file attributes
Date: Sun, 27 Apr 2014 21:44:39 +0530
Message-Id: <1398615293-22931-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

Some permission models can allow processes to take ownership of a file,
change the file permissions, and set the file timestamps.  Introduce new
permission mask flags and check for those permissions in
inode_change_ok().

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/attr.c          | 68 ++++++++++++++++++++++++++++++++++++++++++++----------
 fs/namei.c         |  2 +-
 include/linux/fs.h |  4 ++++
 3 files changed, 61 insertions(+), 13 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 1d158c972442..e468d4f2dca8 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -16,6 +16,54 @@
 #include <linux/evm.h>
 #include <linux/ima.h>
 
+static int richacl_change_ok(struct inode *inode, int mask)
+{
+	if (!IS_RICHACL(inode))
+		return -EPERM;
+
+	if (inode->i_op->permission)
+		return inode->i_op->permission(inode, mask);
+
+	return check_acl(inode, mask);
+}
+
+static bool inode_uid_change_ok(struct inode *inode, kuid_t ia_uid)
+{
+	if (uid_eq(current_fsuid(), inode->i_uid) &&
+	    uid_eq(ia_uid, inode->i_uid))
+		return true;
+	if (uid_eq(current_fsuid(), ia_uid) &&
+	    richacl_change_ok(inode, MAY_TAKE_OWNERSHIP) == 0)
+		return true;
+	if (capable(CAP_CHOWN))
+		return true;
+	return false;
+}
+
+static bool inode_gid_change_ok(struct inode *inode, kgid_t ia_gid)
+{
+	int in_group = in_group_p(ia_gid);
+	if (uid_eq(current_fsuid(), inode->i_uid) &&
+	    (in_group || gid_eq(ia_gid, inode->i_gid)))
+		return true;
+	if (in_group && richacl_change_ok(inode, MAY_TAKE_OWNERSHIP) == 0)
+		return true;
+	if (capable(CAP_CHOWN))
+		return true;
+	return false;
+}
+
+static bool inode_owner_permitted_or_capable(struct inode *inode, int mask)
+{
+	if (uid_eq(current_fsuid(), inode->i_uid))
+		return true;
+	if (richacl_change_ok(inode, mask) == 0)
+		return true;
+	if (inode_capable(inode, CAP_FOWNER))
+		return true;
+	return false;
+}
+
 /**
  * inode_change_ok - check if attribute changes to an inode are allowed
  * @inode:	inode to check
@@ -47,22 +95,18 @@ int inode_change_ok(struct inode *inode, struct iattr *attr)
 		return 0;
 
 	/* Make sure a caller can chown. */
-	if ((ia_valid & ATTR_UID) &&
-	    (!uid_eq(current_fsuid(), inode->i_uid) ||
-	     !uid_eq(attr->ia_uid, inode->i_uid)) &&
-	    !inode_capable(inode, CAP_CHOWN))
-		return -EPERM;
+	if (ia_valid & ATTR_UID)
+		if (!inode_uid_change_ok(inode, attr->ia_uid))
+			return -EPERM;
 
 	/* Make sure caller can chgrp. */
-	if ((ia_valid & ATTR_GID) &&
-	    (!uid_eq(current_fsuid(), inode->i_uid) ||
-	    (!in_group_p(attr->ia_gid) && !gid_eq(attr->ia_gid, inode->i_gid))) &&
-	    !inode_capable(inode, CAP_CHOWN))
-		return -EPERM;
+	if (ia_valid & ATTR_GID)
+		if (!inode_gid_change_ok(inode, attr->ia_gid))
+			return -EPERM;
 
 	/* Make sure a caller can chmod. */
 	if (ia_valid & ATTR_MODE) {
-		if (!inode_owner_or_capable(inode))
+		if (!inode_owner_permitted_or_capable(inode, MAY_CHMOD))
 			return -EPERM;
 		/* Also check the setgid bit! */
 		if (!in_group_p((ia_valid & ATTR_GID) ? attr->ia_gid :
@@ -73,7 +117,7 @@ int inode_change_ok(struct inode *inode, struct iattr *attr)
 
 	/* Check for setting the inode time. */
 	if (ia_valid & (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)) {
-		if (!inode_owner_or_capable(inode))
+		if (!inode_owner_permitted_or_capable(inode, MAY_SET_TIMES))
 			return -EPERM;
 	}
 
diff --git a/fs/namei.c b/fs/namei.c
index 56ac7613fbca..26b9a8212837 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -249,7 +249,7 @@ void putname(struct filename *name)
 }
 #endif
 
-static int check_acl(struct inode *inode, int mask)
+int check_acl(struct inode *inode, int mask)
 {
 #ifdef CONFIG_FS_POSIX_ACL
 	struct posix_acl *acl;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 33da154dd27d..22d85798b520 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -81,6 +81,9 @@ typedef void (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 #define MAY_CREATE_DIR		0x00000200
 #define MAY_DELETE_CHILD	0x00000400
 #define MAY_DELETE_SELF		0x00000800
+#define MAY_TAKE_OWNERSHIP	0x00001000
+#define MAY_CHMOD		0x00002000
+#define MAY_SET_TIMES		0x00004000
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
@@ -2248,6 +2251,7 @@ extern sector_t bmap(struct inode *, sector_t);
 extern int notify_change(struct dentry *, struct iattr *, struct inode **);
 extern int inode_permission(struct inode *, int);
 extern int generic_permission(struct inode *, int);
+extern int check_acl(struct inode *, int);
 
 static inline bool execute_ok(struct inode *inode)
 {
-- 
1.9.1

