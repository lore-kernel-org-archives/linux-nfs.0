From: James Morris <jmorris@namei.org>
Subject: [PATCH 2/5] NFSv3: add xattr API config option for client
Date: Fri, 26 Feb 2010 15:35:11 +1100 (EST)
Message-ID: <alpine.LRH.2.00.1002261534280.25193@tundra.namei.org>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>
To: linux-nfs@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>
Sender: linux-security-module-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a separate configuration option for xattr API use by NFSv3 client 
code, and make it independent of ACLs, so other NFSv3 client code (e.g. 
the subsequent XATTR side-protocol) can use it.

Move the ACL handlers into the new xattr API file, where all such
handlers in the NFSv3 client code will live.

Signed-off-by: James Morris <jmorris@namei.org>
---
 fs/nfs/Kconfig     |    4 ++++
 fs/nfs/Makefile    |    1 +
 fs/nfs/internal.h  |    6 +++++-
 fs/nfs/nfs3acl.c   |   10 ++--------
 fs/nfs/nfs3xattr.c |   25 +++++++++++++++++++++++++
 5 files changed, 37 insertions(+), 9 deletions(-)
 create mode 100644 fs/nfs/nfs3xattr.c

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 59e5673..d27a88e 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -38,9 +38,13 @@ config NFS_V3
 
 	  If unsure, say Y.
 
+config NFS_V3_XATTR_API
+	def_bool n
+
 config NFS_V3_ACL
 	bool "NFS client support for the NFSv3 ACL protocol extension"
 	depends on NFS_V3
+	select NFS_V3_XATTR_API
 	help
 	  Some NFS servers support an auxiliary NFSv3 ACL protocol that
 	  Sun added to Solaris but never became an official part of the
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index da7fda6..1e2743e 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -11,6 +11,7 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o nfs2xdr.o \
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
+nfs-$(CONFIG_NFS_V3_XATTR_API)	+= nfs3xattr.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9bb918a..48fcac9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -285,9 +285,13 @@ static inline char *nfs_devname(const struct vfsmount *mnt_parent,
 			dentry, buffer, buflen);
 }
 
-/* nfs3acl.c */
+/* nfs3xattr.c */
 extern struct xattr_handler *nfs3_xattr_handlers[];
 
+/* nfs3acl.c */
+extern struct xattr_handler nfs3_xattr_acl_access_handler;
+extern struct xattr_handler nfs3_xattr_acl_default_handler;
+
 /*
  * Determine the actual block size (and log2 thereof)
  */
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index c03f8e0..6288ae4 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -75,7 +75,7 @@ static int nfs3_acl_xattr_set(struct dentry *dentry, const char *name,
 	return error;
 }
 
-static struct xattr_handler nfs3_xattr_acl_access_handler = {
+struct xattr_handler nfs3_xattr_acl_access_handler = {
 	.prefix = POSIX_ACL_XATTR_ACCESS,
 	.flags	= ACL_TYPE_ACCESS,
 	.list   = nfs3_acl_xattr_list,
@@ -83,7 +83,7 @@ static struct xattr_handler nfs3_xattr_acl_access_handler = {
 	.set    = nfs3_acl_xattr_set,
 };
 
-static struct xattr_handler nfs3_xattr_acl_default_handler = {
+struct xattr_handler nfs3_xattr_acl_default_handler = {
 	.prefix = POSIX_ACL_XATTR_DEFAULT,
 	.flags	= ACL_TYPE_DEFAULT,
 	.list   = nfs3_acl_xattr_list,
@@ -91,12 +91,6 @@ static struct xattr_handler nfs3_xattr_acl_default_handler = {
 	.set    = nfs3_acl_xattr_set,
 };
 
-struct xattr_handler *nfs3_xattr_handlers[] = {
-	&nfs3_xattr_acl_access_handler,
-	&nfs3_xattr_acl_default_handler,
-	NULL
-};
-
 static void __nfs3_forget_cached_acls(struct nfs_inode *nfsi)
 {
 	if (!IS_ERR(nfsi->acl_access)) {
diff --git a/fs/nfs/nfs3xattr.c b/fs/nfs/nfs3xattr.c
new file mode 100644
index 0000000..de69f1e
--- /dev/null
+++ b/fs/nfs/nfs3xattr.c
@@ -0,0 +1,25 @@
+/*
+ * Extended attribute (xattr) API and protocol for NFSv3.
+ *
+ * Copyright (C) 2009 Red Hat, Inc., James Morris <jmorris@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2,
+ * as published by the Free Software Foundation.
+ */
+#include <linux/fs.h>
+#include <linux/nfs.h>
+#include <linux/nfs3.h>
+#include <linux/nfs_fs.h>
+
+#include "internal.h"
+
+#define NFSDBG_FACILITY	NFSDBG_PROC
+
+struct xattr_handler *nfs3_xattr_handlers[] = {
+#ifdef CONFIG_NFS_V3_ACL
+	&nfs3_xattr_acl_access_handler,
+	&nfs3_xattr_acl_default_handler,
+#endif
+	NULL
+};
-- 
1.6.3.3


-- 
James Morris
<jmorris@namei.org>
