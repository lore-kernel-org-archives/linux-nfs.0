Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oproxy7-pub.bluehost.com ([67.222.55.9]:53311 "HELO
	oproxy7-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754202Ab3EIQjN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 May 2013 12:39:13 -0400
Message-ID: <1368117547.5695.37.camel@slavad-ubuntu-12.04>
Subject: [PATCH v4 5/5] hfsplus: integrate of implemented ACLs support into
 driver
From: Vyacheslav Dubeyko <slava@dubeyko.com>
To: Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        Hin-Tak Leung <htl10@users.sourceforge.net>,
        Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 09 May 2013 20:39:07 +0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Vyacheslav Dubeyko <slava@dubeyko.com>
Subject: [PATCH v4 5/5] hfsplus: integrate of implemented ACLs support into driver

This patch integrates of implemented ACLs support into hfsplus driver.

Signed-off-by: Vyacheslav Dubeyko <slava@dubeyko.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@redhat.com>
CC: Al Viro <viro@zeniv.linux.org.uk>
CC: Christoph Hellwig <hch@infradead.org>
CC: Hin-Tak Leung <htl10@users.sourceforge.net>
---
 fs/hfsplus/Makefile         |    2 +-
 fs/hfsplus/dir.c            |    2 ++
 fs/hfsplus/inode.c          |    9 +++++++++
 fs/hfsplus/xattr.c          |   20 ++++++++++++++------
 fs/hfsplus/xattr.h          |   32 +++++++++++++-------------------
 fs/hfsplus/xattr_security.c |   13 +++++++++++++
 6 files changed, 52 insertions(+), 26 deletions(-)

diff --git a/fs/hfsplus/Makefile b/fs/hfsplus/Makefile
index 09d278b..1fb5e7c 100644
--- a/fs/hfsplus/Makefile
+++ b/fs/hfsplus/Makefile
@@ -6,4 +6,4 @@ obj-$(CONFIG_HFSPLUS_FS) += hfsplus.o
 
 hfsplus-objs := super.o options.o inode.o ioctl.o extents.o catalog.o dir.o btree.o \
 		bnode.o brec.o bfind.o tables.o unicode.o wrapper.o bitmap.o part_tbl.o \
-		attributes.o xattr.o xattr_user.o xattr_security.o xattr_trusted.o
+		attributes.o xattr.o xattr_user.o xattr_security.o xattr_trusted.o acl.o
diff --git a/fs/hfsplus/dir.c b/fs/hfsplus/dir.c
index a37ac93..372f6de 100644
--- a/fs/hfsplus/dir.c
+++ b/fs/hfsplus/dir.c
@@ -16,6 +16,7 @@
 #include "hfsplus_fs.h"
 #include "hfsplus_raw.h"
 #include "xattr.h"
+#include "acl.h"
 
 static inline void hfsplus_instantiate(struct dentry *dentry,
 				       struct inode *inode, u32 cnid)
@@ -533,6 +534,7 @@ const struct inode_operations hfsplus_dir_inode_operations = {
 	.getxattr		= generic_getxattr,
 	.listxattr		= hfsplus_listxattr,
 	.removexattr		= hfsplus_removexattr,
+	.get_acl		= hfsplus_get_acl,
 };
 
 const struct file_operations hfsplus_dir_operations = {
diff --git a/fs/hfsplus/inode.c b/fs/hfsplus/inode.c
index f833d35..0171348 100644
--- a/fs/hfsplus/inode.c
+++ b/fs/hfsplus/inode.c
@@ -19,6 +19,7 @@
 #include "hfsplus_fs.h"
 #include "hfsplus_raw.h"
 #include "xattr.h"
+#include "acl.h"
 
 static int hfsplus_readpage(struct file *file, struct page *page)
 {
@@ -316,6 +317,13 @@ static int hfsplus_setattr(struct dentry *dentry, struct iattr *attr)
 
 	setattr_copy(inode, attr);
 	mark_inode_dirty(inode);
+
+	if (attr->ia_valid & ATTR_MODE) {
+		error = hfsplus_acl_chmod(inode);
+		if (unlikely(error))
+			return error;
+	}
+
 	return 0;
 }
 
@@ -383,6 +391,7 @@ static const struct inode_operations hfsplus_file_inode_operations = {
 	.getxattr	= generic_getxattr,
 	.listxattr	= hfsplus_listxattr,
 	.removexattr	= hfsplus_removexattr,
+	.get_acl	= hfsplus_get_acl,
 };
 
 static const struct file_operations hfsplus_file_operations = {
diff --git a/fs/hfsplus/xattr.c b/fs/hfsplus/xattr.c
index f663461..f20e255 100644
--- a/fs/hfsplus/xattr.c
+++ b/fs/hfsplus/xattr.c
@@ -8,11 +8,14 @@
 
 #include "hfsplus_fs.h"
 #include "xattr.h"
+#include "acl.h"
 
 const struct xattr_handler *hfsplus_xattr_handlers[] = {
 	&hfsplus_xattr_osx_handler,
 	&hfsplus_xattr_user_handler,
 	&hfsplus_xattr_trusted_handler,
+	&hfsplus_xattr_acl_access_handler,
+	&hfsplus_xattr_acl_default_handler,
 	&hfsplus_xattr_security_handler,
 	NULL
 };
@@ -49,8 +52,15 @@ static inline int is_known_namespace(const char *name)
 static int can_set_xattr(struct inode *inode, const char *name,
 				const void *value, size_t value_len)
 {
+	/*
+	 * ACLs handler makes conversion from "system.posix_acl_access"
+	 * and "system.posix_acl_default" into "com.apple.system.Security".
+	 */
 	if (!strncmp(name, XATTR_SYSTEM_PREFIX, XATTR_SYSTEM_PREFIX_LEN))
-		return -EOPNOTSUPP; /* TODO: implement ACL support */
+		return -EOPNOTSUPP;
+	else if (!strncmp(name, HFSPLUS_XATTR_ACL_NAME,
+				sizeof(HFSPLUS_XATTR_ACL_NAME)))
+		return 0;
 
 	if (!strncmp(name, XATTR_MAC_OSX_PREFIX, XATTR_MAC_OSX_PREFIX_LEN)) {
 		/*
@@ -253,11 +263,10 @@ static int copy_name(char *buffer, const char *xattr_name, int name_len)
 	return len;
 }
 
-static ssize_t hfsplus_getxattr_finder_info(struct dentry *dentry,
+static ssize_t hfsplus_getxattr_finder_info(struct inode *inode,
 						void *value, size_t size)
 {
 	ssize_t res = 0;
-	struct inode *inode = dentry->d_inode;
 	struct hfs_find_data fd;
 	u16 entry_type;
 	u16 folder_rec_len = sizeof(struct DInfo) + sizeof(struct DXInfo);
@@ -304,10 +313,9 @@ end_getxattr_finder_info:
 	return res;
 }
 
-ssize_t hfsplus_getxattr(struct dentry *dentry, const char *name,
+ssize_t __hfsplus_getxattr(struct inode *inode, const char *name,
 			 void *value, size_t size)
 {
-	struct inode *inode = dentry->d_inode;
 	struct hfs_find_data fd;
 	hfsplus_attr_entry *entry;
 	__be32 xattr_record_type;
@@ -333,7 +341,7 @@ ssize_t hfsplus_getxattr(struct dentry *dentry, const char *name,
 	}
 
 	if (!strcmp_xattr_finder_info(name))
-		return hfsplus_getxattr_finder_info(dentry, value, size);
+		return hfsplus_getxattr_finder_info(inode, value, size);
 
 	if (!HFSPLUS_SB(inode->i_sb)->attr_tree)
 		return -EOPNOTSUPP;
diff --git a/fs/hfsplus/xattr.h b/fs/hfsplus/xattr.h
index 847b695..940dd7a 100644
--- a/fs/hfsplus/xattr.h
+++ b/fs/hfsplus/xattr.h
@@ -14,8 +14,8 @@
 extern const struct xattr_handler hfsplus_xattr_osx_handler;
 extern const struct xattr_handler hfsplus_xattr_user_handler;
 extern const struct xattr_handler hfsplus_xattr_trusted_handler;
-/*extern const struct xattr_handler hfsplus_xattr_acl_access_handler;*/
-/*extern const struct xattr_handler hfsplus_xattr_acl_default_handler;*/
+extern const struct xattr_handler hfsplus_xattr_acl_access_handler;
+extern const struct xattr_handler hfsplus_xattr_acl_default_handler;
 extern const struct xattr_handler hfsplus_xattr_security_handler;
 
 extern const struct xattr_handler *hfsplus_xattr_handlers[];
@@ -29,9 +29,17 @@ static inline int hfsplus_setxattr(struct dentry *dentry, const char *name,
 	return __hfsplus_setxattr(dentry->d_inode, name, value, size, flags);
 }
 
-ssize_t hfsplus_getxattr(struct dentry *dentry, const char *name,
+ssize_t __hfsplus_getxattr(struct inode *inode, const char *name,
 			void *value, size_t size);
 
+static inline ssize_t hfsplus_getxattr(struct dentry *dentry,
+					const char *name,
+					void *value,
+					size_t size)
+{
+	return __hfsplus_getxattr(dentry->d_inode, name, value, size);
+}
+
 ssize_t hfsplus_listxattr(struct dentry *dentry, char *buffer, size_t size);
 
 int hfsplus_removexattr(struct dentry *dentry, const char *name);
@@ -39,22 +47,8 @@ int hfsplus_removexattr(struct dentry *dentry, const char *name);
 int hfsplus_init_security(struct inode *inode, struct inode *dir,
 				const struct qstr *qstr);
 
-static inline int hfsplus_init_acl(struct inode *inode, struct inode *dir)
-{
-	/*TODO: implement*/
-	return 0;
-}
-
-static inline int hfsplus_init_inode_security(struct inode *inode,
+int hfsplus_init_inode_security(struct inode *inode,
 						struct inode *dir,
-						const struct qstr *qstr)
-{
-	int err;
-
-	err = hfsplus_init_acl(inode, dir);
-	if (!err)
-		err = hfsplus_init_security(inode, dir, qstr);
-	return err;
-}
+						const struct qstr *qstr);
 
 #endif
diff --git a/fs/hfsplus/xattr_security.c b/fs/hfsplus/xattr_security.c
index 83b842f..f59b037 100644
--- a/fs/hfsplus/xattr_security.c
+++ b/fs/hfsplus/xattr_security.c
@@ -8,6 +8,7 @@
 
 #include <linux/security.h>
 #include "hfsplus_fs.h"
+#include "acl.h"
 #include "xattr.h"
 
 static int hfsplus_security_getxattr(struct dentry *dentry, const char *name,
@@ -96,6 +97,18 @@ int hfsplus_init_security(struct inode *inode, struct inode *dir,
 					&hfsplus_initxattrs, NULL);
 }
 
+int hfsplus_init_inode_security(struct inode *inode,
+						struct inode *dir,
+						const struct qstr *qstr)
+{
+	int err;
+
+	err = hfsplus_init_acl(inode, dir);
+	if (!err)
+		err = hfsplus_init_security(inode, dir, qstr);
+	return err;
+}
+
 const struct xattr_handler hfsplus_xattr_security_handler = {
 	.prefix	= XATTR_SECURITY_PREFIX,
 	.list	= hfsplus_security_listxattr,
-- 
1.7.9.5



