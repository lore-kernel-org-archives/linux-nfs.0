From: James Morris <jmorris@namei.org>
Subject: [PATCH 5/8][RFC v05] XATTR: add new top level nfsd namespace and
 implement ext3 support
Date: Mon, 21 Jun 2010 21:30:41 +1000 (EST)
Message-ID: <alpine.LRH.2.00.1006212130040.13583@tundra.namei.org>
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-fsdevel@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>
To: linux-nfs@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new top-level 'nfsd' xattr namespace for use by the NFSv3 server
when storing xattrs provided by clients using the XATTR
protocol.

Also implement filesystem-level support for the new namespace for the
ext3 filesystem for testing.

Signed-off-by: James Morris <jmorris@namei.org>
---
 fs/ext3/Makefile      |    2 +-
 fs/ext3/xattr.c       |    2 +
 fs/ext3/xattr.h       |    2 +
 fs/ext3/xattr_nfsd.c  |   58 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/xattr.c            |    6 +++-
 include/linux/xattr.h |    3 ++
 6 files changed, 70 insertions(+), 3 deletions(-)
 create mode 100644 fs/ext3/xattr_nfsd.c

diff --git a/fs/ext3/Makefile b/fs/ext3/Makefile
index e77766a..216ca8a 100644
--- a/fs/ext3/Makefile
+++ b/fs/ext3/Makefile
@@ -7,6 +7,6 @@ obj-$(CONFIG_EXT3_FS) += ext3.o
 ext3-y	:= balloc.o bitmap.o dir.o file.o fsync.o ialloc.o inode.o \
 	   ioctl.o namei.o super.o symlink.o hash.o resize.o ext3_jbd.o
 
-ext3-$(CONFIG_EXT3_FS_XATTR)	 += xattr.o xattr_user.o xattr_trusted.o
+ext3-$(CONFIG_EXT3_FS_XATTR)	 += xattr.o xattr_user.o xattr_trusted.o xattr_nfsd.o
 ext3-$(CONFIG_EXT3_FS_POSIX_ACL) += acl.o
 ext3-$(CONFIG_EXT3_FS_SECURITY)	 += xattr_security.o
diff --git a/fs/ext3/xattr.c b/fs/ext3/xattr.c
index 71fb8d6..e264320 100644
--- a/fs/ext3/xattr.c
+++ b/fs/ext3/xattr.c
@@ -114,6 +114,7 @@ static const struct xattr_handler *ext3_xattr_handler_map[] = {
 #ifdef CONFIG_EXT3_FS_SECURITY
 	[EXT3_XATTR_INDEX_SECURITY]	     = &ext3_xattr_security_handler,
 #endif
+	[EXT3_XATTR_INDEX_NFSD]		     = &ext3_xattr_nfsd_handler,
 };
 
 const struct xattr_handler *ext3_xattr_handlers[] = {
@@ -126,6 +127,7 @@ const struct xattr_handler *ext3_xattr_handlers[] = {
 #ifdef CONFIG_EXT3_FS_SECURITY
 	&ext3_xattr_security_handler,
 #endif
+	&ext3_xattr_nfsd_handler,
 	NULL
 };
 
diff --git a/fs/ext3/xattr.h b/fs/ext3/xattr.h
index 377fe72..92eac0c 100644
--- a/fs/ext3/xattr.h
+++ b/fs/ext3/xattr.h
@@ -21,6 +21,7 @@
 #define EXT3_XATTR_INDEX_TRUSTED		4
 #define	EXT3_XATTR_INDEX_LUSTRE			5
 #define EXT3_XATTR_INDEX_SECURITY	        6
+#define EXT3_XATTR_INDEX_NFSD			7
 
 struct ext3_xattr_header {
 	__le32	h_magic;	/* magic number for identification */
@@ -63,6 +64,7 @@ extern const struct xattr_handler ext3_xattr_trusted_handler;
 extern const struct xattr_handler ext3_xattr_acl_access_handler;
 extern const struct xattr_handler ext3_xattr_acl_default_handler;
 extern const struct xattr_handler ext3_xattr_security_handler;
+extern const struct xattr_handler ext3_xattr_nfsd_handler;
 
 extern ssize_t ext3_listxattr(struct dentry *, char *, size_t);
 
diff --git a/fs/ext3/xattr_nfsd.c b/fs/ext3/xattr_nfsd.c
new file mode 100644
index 0000000..7e38c35
--- /dev/null
+++ b/fs/ext3/xattr_nfsd.c
@@ -0,0 +1,58 @@
+/*
+ * linux/fs/ext3/xattr_nfsd.c
+ * Handler for nfsd extended attributes.
+ *
+ * Copyright (C) 2003 by Andreas Gruenbacher, <a.gruenbacher@computer.org>
+ * Copyright (C) 2010 Red Hat, Inc., James Morris <jmorris@redhat.com>
+ */
+#include <linux/module.h>
+#include <linux/string.h>
+#include <linux/capability.h>
+#include <linux/fs.h>
+#include <linux/ext3_jbd.h>
+#include <linux/ext3_fs.h>
+#include "xattr.h"
+
+static size_t ext3_xattr_nfsd_list(struct dentry *dentry, char *list,
+				   size_t list_size, const char *name,
+				   size_t name_len, int type)
+{
+	const size_t prefix_len = XATTR_NFSD_PREFIX_LEN;
+	const size_t total_len = prefix_len + name_len + 1;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return 0;
+
+	if (list && total_len <= list_size) {
+		memcpy(list, XATTR_NFSD_PREFIX, prefix_len);
+		memcpy(list+prefix_len, name, name_len);
+		list[prefix_len + name_len] = '\0';
+	}
+	return total_len;
+}
+
+static int ext3_xattr_nfsd_get(struct dentry *dentry, const char *name,
+			       void *buffer, size_t size, int type)
+{
+	if (strcmp(name, "") == 0)
+		return -EINVAL;
+	return ext3_xattr_get(dentry->d_inode, EXT3_XATTR_INDEX_NFSD,
+			      name, buffer, size);
+}
+
+static int ext3_xattr_nfsd_set(struct dentry *dentry, const char *name,
+			       const void *value, size_t size, int flags,
+			       int type)
+{
+	if (strcmp(name, "") == 0)
+		return -EINVAL;
+	return ext3_xattr_set(dentry->d_inode, EXT3_XATTR_INDEX_NFSD, name,
+			      value, size, flags);
+}
+
+const struct xattr_handler ext3_xattr_nfsd_handler = {
+	.prefix	= XATTR_NFSD_PREFIX,
+	.list	= ext3_xattr_nfsd_list,
+	.get	= ext3_xattr_nfsd_get,
+	.set	= ext3_xattr_nfsd_set,
+};
diff --git a/fs/xattr.c b/fs/xattr.c
index 01bb813..ec4129b 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -46,9 +46,11 @@ xattr_permission(struct inode *inode, const char *name, int mask)
 		return 0;
 
 	/*
-	 * The trusted.* namespace can only be accessed by a privileged user.
+	 * The trusted.* and nfsd.* namespaces can only be accessed by a
+	 * privileged user.
 	 */
-	if (!strncmp(name, XATTR_TRUSTED_PREFIX, XATTR_TRUSTED_PREFIX_LEN))
+	if (!strncmp(name, XATTR_TRUSTED_PREFIX, XATTR_TRUSTED_PREFIX_LEN) ||
+	    !strncmp(name, XATTR_NFSD_PREFIX, XATTR_NFSD_PREFIX_LEN))
 		return (capable(CAP_SYS_ADMIN) ? 0 : -EPERM);
 
 	/* In user.* namespace, only regular files and directories can have
diff --git a/include/linux/xattr.h b/include/linux/xattr.h
index 0cfa1e9..da362a7 100644
--- a/include/linux/xattr.h
+++ b/include/linux/xattr.h
@@ -33,6 +33,9 @@
 #define XATTR_USER_PREFIX "user."
 #define XATTR_USER_PREFIX_LEN (sizeof (XATTR_USER_PREFIX) - 1)
 
+#define XATTR_NFSD_PREFIX "nfsd."
+#define XATTR_NFSD_PREFIX_LEN (sizeof (XATTR_NFSD_PREFIX) - 1)
+
 struct inode;
 struct dentry;
 
-- 
1.7.0.1

