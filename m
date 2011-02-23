Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:35093 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755466Ab1BWNx3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 08:53:29 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: sfrench@us.ibm.com, agruen@linbit.com, dilger.kernel@dilger.ca,
        sandeen@redhat.com, tytso@mit.edu, bfields@fieldses.org,
        jlayton@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, Andreas Gruenbacher <agruen@suse.de>
Subject: [PATCH -V5 10/24] vfs: Add permission flags for setting file attributes
Date: Wed, 23 Feb 2011 19:21:57 +0530
Message-Id: <1298469131-16555-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andreas Gruenbacher <agruen@suse.de>

Some permission models can allow processes to take ownership of a file,
change the file permissions, and set the file timestamps.  Introduce new
permission mask flags and check for those permissions in
inode_change_ok().

Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/attr.c          |   49 ++++++++++++++++++++++++++++++++++++++-----------
 include/linux/fs.h |    3 +++
 2 files changed, 41 insertions(+), 11 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index f081b5a..793f34c 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -13,6 +13,20 @@
 #include <linux/fsnotify.h>
 #include <linux/fcntl.h>
 #include <linux/security.h>
+#include <linux/richacl.h>
+
+static int richacl_change_ok(struct inode *inode, int mask)
+{
+	if (!IS_RICHACL(inode))
+		return -EPERM;
+
+	if (inode->i_op->permission)
+		return inode->i_op->permission(inode, mask, 0);
+	else if (inode->i_op->check_acl)
+		return inode->i_op->check_acl(inode, mask, 0);
+	else
+		return -EPERM;
+}
 
 /**
  * inode_change_ok - check if attribute changes to an inode are allowed
@@ -47,20 +61,29 @@ int inode_change_ok(struct inode *inode, struct iattr *attr)
 	/* Make sure a caller can chown. */
 	if ((ia_valid & ATTR_UID) &&
 	    (current_fsuid() != inode->i_uid ||
-	     attr->ia_uid != inode->i_uid) && !capable(CAP_CHOWN))
-		return -EPERM;
+	     attr->ia_uid != inode->i_uid) &&
+	    (current_fsuid() != attr->ia_uid ||
+	     richacl_change_ok(inode, MAY_TAKE_OWNERSHIP)) &&
+	    !capable(CAP_CHOWN))
+		goto error;
 
 	/* Make sure caller can chgrp. */
-	if ((ia_valid & ATTR_GID) &&
-	    (current_fsuid() != inode->i_uid ||
-	    (!in_group_p(attr->ia_gid) && attr->ia_gid != inode->i_gid)) &&
-	    !capable(CAP_CHOWN))
-		return -EPERM;
+	if (ia_valid & ATTR_GID) {
+		int in_group = in_group_p(attr->ia_gid);
+		if ((current_fsuid() != inode->i_uid ||
+		     (!in_group && attr->ia_gid != inode->i_gid)) &&
+		    (!in_group ||
+		     richacl_change_ok(inode, MAY_TAKE_OWNERSHIP)) &&
+		    !capable(CAP_CHOWN))
+			goto error;
+	}
 
 	/* Make sure a caller can chmod. */
 	if (ia_valid & ATTR_MODE) {
-		if (!is_owner_or_cap(inode))
-			return -EPERM;
+		if (current_fsuid() != inode->i_uid &&
+		    richacl_change_ok(inode, MAY_CHMOD) &&
+		    !capable(CAP_FOWNER))
+			goto error;
 		/* Also check the setgid bit! */
 		if (!in_group_p((ia_valid & ATTR_GID) ? attr->ia_gid :
 				inode->i_gid) && !capable(CAP_FSETID))
@@ -69,11 +92,15 @@ int inode_change_ok(struct inode *inode, struct iattr *attr)
 
 	/* Check for setting the inode time. */
 	if (ia_valid & (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)) {
-		if (!is_owner_or_cap(inode))
-			return -EPERM;
+		if (current_fsuid() != inode->i_uid &&
+		    richacl_change_ok(inode, MAY_SET_TIMES) &&
+		    !capable(CAP_FOWNER))
+			goto error;
 	}
 
 	return 0;
+error:
+	return -EPERM;
 }
 EXPORT_SYMBOL(inode_change_ok);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3ae23a2..1627592 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -66,6 +66,9 @@ struct inodes_stat_t {
 #define MAY_CREATE_DIR 256
 #define MAY_DELETE_CHILD 512
 #define MAY_DELETE_SELF 1024
+#define MAY_TAKE_OWNERSHIP 2048
+#define MAY_CHMOD 4096
+#define MAY_SET_TIMES 8192
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
1.7.1

