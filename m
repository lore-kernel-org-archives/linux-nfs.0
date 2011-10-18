Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:46771 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932827Ab1JRPep (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 11:34:45 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V7 11/26] vfs: Add permission flags for setting file attributes
Date: Tue, 18 Oct 2011 21:02:46 +0530
Message-Id: <1318951981-5508-12-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

Some permission models can allow processes to take ownership of a file,
change the file permissions, and set the file timestamps.  Introduce new
permission mask flags and check for those permissions in
inode_change_ok().

Acked-by: David Howells <dhowells@redhat.com>
Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/attr.c          |   70 +++++++++++++++++++++++++++++++++++++++++++--------
 fs/namei.c         |    2 +-
 include/linux/fs.h |    4 +++
 3 files changed, 64 insertions(+), 12 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index f15e9e3..00578b9 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -14,6 +14,55 @@
 #include <linux/fcntl.h>
 #include <linux/security.h>
 
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
+static bool inode_uid_change_ok(struct inode *inode, uid_t ia_uid)
+{
+	if (current_fsuid() == inode->i_uid && ia_uid == inode->i_uid)
+		return true;
+	if (current_fsuid() == ia_uid &&
+	    richacl_change_ok(inode, MAY_TAKE_OWNERSHIP) == 0)
+		return true;
+	if (capable(CAP_CHOWN))
+		return true;
+	return false;
+}
+
+static bool inode_gid_change_ok(struct inode *inode, gid_t ia_gid)
+{
+	int in_group = in_group_p(ia_gid);
+	if (current_fsuid() == inode->i_uid &&
+	    (in_group || ia_gid == inode->i_gid))
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
+	struct user_namespace *ns = inode_userns(inode);
+
+	if (current_user_ns() == ns && current_fsuid() == inode->i_uid)
+		return true;
+	if (richacl_change_ok(inode, mask) == 0)
+		return true;
+	if (ns_capable(ns, CAP_FOWNER))
+		return true;
+	return false;
+}
+
 /**
  * inode_change_ok - check if attribute changes to an inode are allowed
  * @inode:	inode to check
@@ -45,21 +94,20 @@ int inode_change_ok(struct inode *inode, struct iattr *attr)
 		return 0;
 
 	/* Make sure a caller can chown. */
-	if ((ia_valid & ATTR_UID) &&
-	    (current_fsuid() != inode->i_uid ||
-	     attr->ia_uid != inode->i_uid) && !capable(CAP_CHOWN))
-		return -EPERM;
+	if (ia_valid & ATTR_UID) {
+		if (!inode_uid_change_ok(inode, attr->ia_uid))
+			return -EPERM;
+	}
 
 	/* Make sure caller can chgrp. */
-	if ((ia_valid & ATTR_GID) &&
-	    (current_fsuid() != inode->i_uid ||
-	    (!in_group_p(attr->ia_gid) && attr->ia_gid != inode->i_gid)) &&
-	    !capable(CAP_CHOWN))
-		return -EPERM;
+	if (ia_valid & ATTR_GID) {
+		if (!inode_gid_change_ok(inode, attr->ia_gid))
+			return -EPERM;
+	}
 
 	/* Make sure a caller can chmod. */
 	if (ia_valid & ATTR_MODE) {
-		if (!inode_owner_or_capable(inode))
+		if (!inode_owner_permitted_or_capable(inode, MAY_CHMOD))
 			return -EPERM;
 		/* Also check the setgid bit! */
 		if (!in_group_p((ia_valid & ATTR_GID) ? attr->ia_gid :
@@ -69,7 +117,7 @@ int inode_change_ok(struct inode *inode, struct iattr *attr)
 
 	/* Check for setting the inode time. */
 	if (ia_valid & (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)) {
-		if (!inode_owner_or_capable(inode))
+		if (!inode_owner_permitted_or_capable(inode, MAY_SET_TIMES))
 			return -EPERM;
 	}
 
diff --git a/fs/namei.c b/fs/namei.c
index 7bf42e8..eb8f918 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -174,7 +174,7 @@ void putname(const char *name)
 EXPORT_SYMBOL(putname);
 #endif
 
-static int check_acl(struct inode *inode, int mask)
+int check_acl(struct inode *inode, int mask)
 {
 #ifdef CONFIG_FS_POSIX_ACL
 	struct posix_acl *acl;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 724a4f4..ac1d8e5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -71,6 +71,9 @@ struct inodes_stat_t {
 #define MAY_CREATE_DIR		0x00000200
 #define MAY_DELETE_CHILD	0x00000400
 #define MAY_DELETE_SELF		0x00000800
+#define MAY_TAKE_OWNERSHIP	0x00001000
+#define MAY_CHMOD		0x00002000
+#define MAY_SET_TIMES		0x00004000
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
@@ -2232,6 +2235,7 @@ extern sector_t bmap(struct inode *, sector_t);
 extern int notify_change(struct dentry *, struct iattr *);
 extern int inode_permission(struct inode *, int);
 extern int generic_permission(struct inode *, int);
+extern int check_acl(struct inode *, int);
 
 static inline bool execute_ok(struct inode *inode)
 {
-- 
1.7.5.4

