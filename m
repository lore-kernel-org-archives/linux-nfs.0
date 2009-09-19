From: James Morris <jmorris@namei.org>
Subject: [PATCH 2/4] NFSv3: add xattr API config option for client
Date: Sun, 20 Sep 2009 01:12:54 +1000 (EST)
Message-ID: <alpine.LRH.2.00.0909200112110.31880@tundra.namei.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	linux-fsdevel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org>
Sender: linux-fsdevel-owner@vger.kernel.org
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
index 2a77bc2..ff75902 100644
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
index 964170d..370f61c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -288,9 +288,13 @@ static inline void nfs4_sequence_free_slot(const struct nfs_client *clp,
 #endif /* CONFIG_NFS_V4_1 */
 }
 
-/* nfs3acl.c */
+/* nfs3xattr.c */
 extern struct xattr_handler *nfs3_xattr_handlers[];
 
+/* nfs3acl.c */
+extern struct xattr_handler nfs3_xattr_acl_access_handler;
+extern struct xattr_handler nfs3_xattr_acl_default_handler;
+
 /*
  * Determine the device name as a string
  */
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 4e15d1a..4d59f44 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -124,26 +124,20 @@ static int nfs3_acl_default_xattr_set(struct inode *inode, const char *name,
 	return nfs3_acl_xattr_set(inode, value, size, flags, ACL_TYPE_DEFAULT);
 }
 
-static struct xattr_handler nfs3_xattr_acl_access_handler = {
+struct xattr_handler nfs3_xattr_acl_access_handler = {
 	.prefix = POSIX_ACL_XATTR_ACCESS,
 	.list   = nfs3_acl_access_xattr_list,
 	.get    = nfs3_acl_access_xattr_get,
 	.set    = nfs3_acl_access_xattr_set,
 };
 
-static struct xattr_handler nfs3_xattr_acl_default_handler = {
+struct xattr_handler nfs3_xattr_acl_default_handler = {
 	.prefix = POSIX_ACL_XATTR_DEFAULT,
 	.list   = nfs3_acl_default_xattr_list,
 	.get    = nfs3_acl_default_xattr_get,
 	.set    = nfs3_acl_default_xattr_set,
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
1.6.2.5


-- 
James Morris
<jmorris@namei.org>
