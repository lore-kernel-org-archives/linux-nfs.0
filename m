From: James Morris <jmorris@namei.org>
Subject: [PATCH 6/8][RFC v05] NFSv3: Add server namespace support for XATTR
 protocol implementation
Date: Mon, 21 Jun 2010 21:31:29 +1000 (EST)
Message-ID: <alpine.LRH.2.00.1006212130460.13583@tundra.namei.org>
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-fsdevel@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:38103 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932320Ab0FULbi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jun 2010 07:31:38 -0400
In-Reply-To: <alpine.LRH.2.00.1006212051530.13583-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support for an NFS server namespace for storing and retrieving
client-supplied xattrs.  All xattrs are now stored on the server under
the 'nfsd' namespace, and are not interpreted by the server at all.
This allows clients to utilize arbitrary xattr namespaces and for the
server to act only as a storage mechanism for the xattrs.

Currently, only the user, trusted and system namespaces are
supported by the client.

A new NFS error code has been implemented, so that -ENODATA
may be propagated cleanly from the server to the client when
accessing xattrs on the server.

For files newly created in the security namespace, a call
is made back into the security subsystem to allow setting
of security xattrs before the file is instantiated on the
client.

NFS ACLs continue to work as expected, because they implement a
hard-coded system xattr namespace which is invoked before the
NFS layer.  e.g. any access to a system.posix_acl_access xattr
is invokes the NFS_ACL protocol.

Signed-off-by: James Morris <jmorris@namei.org>
---
 fs/nfs/Kconfig              |   10 ----
 fs/nfs/Makefile             |    2 +-
 fs/nfs/internal.h           |    5 ++-
 fs/nfs/nfs2xdr.c            |    3 +
 fs/nfs/nfs3proc.c           |    9 +++
 fs/nfs/nfs3xattr.c          |   28 ++++++++++-
 fs/nfs/nfs3xattr_handlers.c |  121 +++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs3xattr_user.c     |   53 -------------------
 fs/nfs/super.c              |    2 +-
 fs/nfsd/nfs3xattr.c         |   87 ++++++++++++++++++++----------
 fs/nfsd/nfsd.h              |    1 +
 fs/nfsd/nfsproc.c           |    3 +
 fs/nfsd/vfs.h               |   10 ++++
 include/linux/nfs.h         |    1 +
 14 files changed, 239 insertions(+), 96 deletions(-)
 create mode 100644 fs/nfs/nfs3xattr_handlers.c
 delete mode 100644 fs/nfs/nfs3xattr_user.c

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index b74faec..d9d2c53 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -86,16 +86,6 @@ config NFS_V3_XATTR
 
 	  If unsure, say N.
 
-config NFS_V3_XATTR_USER
-	bool "Extended attributes in the user namespace (EXPERIMENTAL)"
-	depends on NFS_V3_XATTR
-	help
-	  This option selects extended attributes in the user.* namespace,
-	  which are arbitrarily named and managed by users, and conveyed
-	  via the XATTR protocol extension for NFS version 3.
-
-	  If unsure, say N.
-
 config NFS_V4
 	bool "NFS client support for NFS version 4 (EXPERIMENTAL)"
 	depends on NFS_FS && EXPERIMENTAL
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 54018ee..b289d7e 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -12,7 +12,7 @@ nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V3_XATTR_API)	+= nfs3xattr.o
-nfs-$(CONFIG_NFS_V3_XATTR_USER)	+= nfs3xattr_user.o
+nfs-$(CONFIG_NFS_V3_XATTR)	+= nfs3xattr_handlers.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 1a4f777..6aff3a9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -293,9 +293,12 @@ extern int nfs3_proc_setxattr(struct inode *inode, const char *namespace,
 			      size_t size, int flags);
 extern int nfs3_proc_listxattr(struct inode *inode, char *list,
 			       size_t list_len);
+extern int nfs3_init_xattr(struct inode *dir, struct dentry *dentry);
 
-/* nfs3xattr_user.c */
+/* nfs3xattr_handers.c */
 extern struct xattr_handler nfs3_xattr_user_handler;
+extern struct xattr_handler nfs3_xattr_trusted_handler;
+extern struct xattr_handler nfs3_xattr_security_handler;
 
 /* nfs3acl.c */
 extern struct xattr_handler nfs3_xattr_acl_access_handler;
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 81cf142..f72880b 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -701,6 +701,9 @@ static struct {
 	{ NFSERR_SERVERFAULT,	-EREMOTEIO	},
 	{ NFSERR_BADTYPE,	-EBADTYPE	},
 	{ NFSERR_JUKEBOX,	-EJUKEBOX	},
+#ifdef CONFIG_NFS_V3_XATTR
+	{ NFSERR_NODATA,	-ENODATA	},
+#endif
 	{ -1,			-EIO		}
 };
 
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index fabb4f2..6d71153 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -386,6 +386,9 @@ nfs3_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 			goto out;
 	}
 	status = nfs3_proc_set_default_acl(dir, dentry->d_inode, mode);
+	if (status != 0)
+		goto out;
+	status = nfs3_init_xattr(dir, dentry);
 out:
 	nfs3_free_createdata(data);
 	dprintk("NFS reply create: %d\n", status);
@@ -565,6 +568,9 @@ nfs3_proc_mkdir(struct inode *dir, struct dentry *dentry, struct iattr *sattr)
 		goto out;
 
 	status = nfs3_proc_set_default_acl(dir, dentry->d_inode, mode);
+	if (status != 0)
+		goto out;
+	status = nfs3_init_xattr(dir, dentry);
 out:
 	nfs3_free_createdata(data);
 	dprintk("NFS reply mkdir: %d\n", status);
@@ -702,6 +708,9 @@ nfs3_proc_mknod(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	if (status != 0)
 		goto out;
 	status = nfs3_proc_set_default_acl(dir, dentry->d_inode, mode);
+	if (status != 0)
+		goto out;
+	status = nfs3_init_xattr(dir, dentry);
 out:
 	nfs3_free_createdata(data);
 	dprintk("NFS reply mknod: %d\n", status);
diff --git a/fs/nfs/nfs3xattr.c b/fs/nfs/nfs3xattr.c
index f34b9a0..3295b17 100644
--- a/fs/nfs/nfs3xattr.c
+++ b/fs/nfs/nfs3xattr.c
@@ -19,8 +19,10 @@
 #define NFSDBG_FACILITY	NFSDBG_PROC
 
 const struct xattr_handler *nfs3_xattr_handlers[] = {
-#ifdef CONFIG_NFS_V3_XATTR_USER
+#ifdef CONFIG_NFS_V3_XATTR
 	&nfs3_xattr_user_handler,
+	&nfs3_xattr_trusted_handler,
+	&nfs3_xattr_security_handler,
 #endif
 #ifdef CONFIG_NFS_V3_ACL
 	&nfs3_xattr_acl_access_handler,
@@ -261,4 +263,28 @@ cleanup:
 	kfree(res.xattr_list);
 	return status;
 }
+
+/*
+ * Create an xattr for a newly created file, if required by the security
+ * subsystem.
+ */
+int nfs3_init_xattr(struct inode *dir, struct dentry *dentry)
+{
+	int ret;
+	size_t len;
+	void *val;
+	struct inode *inode = dentry->d_inode;
+
+	ret = security_inode_init_security(inode, dir, NULL, &val, &len);
+	if (ret) {
+		if (ret == -EOPNOTSUPP)
+			return 0;
+		return ret;
+	}
+
+	ret = security_inode_setsecctx(dentry, val, len);
+	kfree(val);
+
+	return ret;
+}
 #endif	/* CONFIG_NFS_V3_XATTR */
diff --git a/fs/nfs/nfs3xattr_handlers.c b/fs/nfs/nfs3xattr_handlers.c
new file mode 100644
index 0000000..f7eb561
--- /dev/null
+++ b/fs/nfs/nfs3xattr_handlers.c
@@ -0,0 +1,121 @@
+/*
+ * Client support for the NFS_XATTR protocol.
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
+/*
+ * 'user' namespace
+ */
+
+/*
+ * Call the LISTXATTR procedure only once per syscall, when the user
+ * handler is invoked.
+ */
+static size_t nfs3_user_xattr_list(struct dentry *dentry, char *list,
+				   size_t list_len, const char *name,
+				   size_t name_len, int hflags)
+{
+
+	return nfs3_proc_listxattr(dentry->d_inode, list, list_len);
+}
+
+static size_t nfs3_noop_xattr_list(struct dentry *dentry, char *list,
+				   size_t list_len, const char *name,
+				   size_t name_len, int hflags)
+{
+	return 0;
+}
+
+static int nfs3_user_xattr_get(struct dentry *dentry, const char *name,
+			       void *buffer, size_t size, int hflags)
+{
+	return nfs3_proc_getxattr(dentry->d_inode, XATTR_USER_PREFIX,
+				  name, buffer, size);
+}
+
+static int nfs3_user_xattr_set(struct dentry *dentry, const char *name,
+			       const void *value, size_t size,
+			       int flags, int hflags)
+{
+	return nfs3_proc_setxattr(dentry->d_inode, XATTR_USER_PREFIX,
+				  name, value, size, flags);
+}
+
+/*
+ * 'trusted' namespace
+ */
+struct xattr_handler nfs3_xattr_user_handler = {
+	.prefix = XATTR_USER_PREFIX,
+	.list	= nfs3_user_xattr_list,
+	.get    = nfs3_user_xattr_get,
+	.set    = nfs3_user_xattr_set,
+};
+
+static int nfs3_trusted_xattr_get(struct dentry *dentry, const char *name,
+				  void *buffer, size_t size, int hflags)
+{
+	return nfs3_proc_getxattr(dentry->d_inode, XATTR_TRUSTED_PREFIX,
+				  name, buffer, size);
+}
+
+static int nfs3_trusted_xattr_set(struct dentry *dentry, const char *name,
+				  const void *value, size_t size,
+				  int flags, int hflags)
+{
+	return nfs3_proc_setxattr(dentry->d_inode, XATTR_TRUSTED_PREFIX,
+				  name, value, size, flags);
+}
+
+struct xattr_handler nfs3_xattr_trusted_handler = {
+	.prefix = XATTR_TRUSTED_PREFIX,
+	.list	= nfs3_noop_xattr_list,
+	.get    = nfs3_trusted_xattr_get,
+	.set    = nfs3_trusted_xattr_set,
+};
+
+/*
+ * 'security' namespace
+ */
+static int nfs3_security_xattr_get(struct dentry *dentry, const char *name,
+				   void *buffer, size_t size, int hflags)
+{
+	return nfs3_proc_getxattr(dentry->d_inode, XATTR_SECURITY_PREFIX,
+				  name, buffer, size);
+}
+
+static int nfs3_security_xattr_set(struct dentry *dentry, const char *name,
+				   const void *value, size_t size,
+				   int flags, int hflags)
+{
+	int ret;
+
+	ret = nfs3_proc_setxattr(dentry->d_inode, XATTR_SECURITY_PREFIX,
+				  name, value, size, flags);
+
+	/* FIXME: once size probing is fixed, don't translate to zero */
+	if ((flags & XATTR_REPLACE) && ret == -ENODATA) {
+		printk(KERN_DEBUG "%s: ignoring -ENODATA (fixme)\n", __func__);
+		ret = 0;
+	}
+	return ret;
+}
+
+struct xattr_handler nfs3_xattr_security_handler = {
+	.prefix = XATTR_SECURITY_PREFIX,
+	.list	= nfs3_noop_xattr_list,
+	.get    = nfs3_security_xattr_get,
+	.set    = nfs3_security_xattr_set,
+};
diff --git a/fs/nfs/nfs3xattr_user.c b/fs/nfs/nfs3xattr_user.c
deleted file mode 100644
index c544fcb..0000000
--- a/fs/nfs/nfs3xattr_user.c
+++ /dev/null
@@ -1,53 +0,0 @@
-/*
- * Support for extended attributes in the the user.* namespace, which are
- * arbitrarily named and managed by users and conveyed via the XATTR
- * protocol extension.
- *
- * Copyright (C) 2009 Red Hat, Inc., James Morris <jmorris@redhat.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2,
- * as published by the Free Software Foundation.
- */
-#include <linux/fs.h>
-#include <linux/nfs.h>
-#include <linux/nfs3.h>
-#include <linux/nfs_fs.h>
-
-#include "internal.h"
-
-#define NFSDBG_FACILITY	NFSDBG_PROC
-
-/*
- * The generic xattr code will call this for each helper, which is ok for
- * now, because we only support this single namespace.  If support is
- * expanded to more namespaces, we we'll need a custom listxattr operation.
- */
-static size_t nfs3_user_xattr_list(struct dentry *dentry, char *list,
-				   size_t list_len, const char *name,
-				   size_t name_len, int hflags)
-{
-	return nfs3_proc_listxattr(dentry->d_inode, list, list_len);
-}
-
-static int nfs3_user_xattr_get(struct dentry *dentry, const char *name,
-			       void *buffer, size_t size, int hflags)
-{
-	return nfs3_proc_getxattr(dentry->d_inode, XATTR_USER_PREFIX,
-				  name, buffer, size);
-}
-
-static int nfs3_user_xattr_set(struct dentry *dentry, const char *name,
-			       const void *value, size_t size,
-			       int flags, int hflags)
-{
-	return nfs3_proc_setxattr(dentry->d_inode, XATTR_USER_PREFIX,
-				  name, value, size, flags);
-}
-
-struct xattr_handler nfs3_xattr_user_handler = {
-	.prefix = XATTR_USER_PREFIX,
-	.list   = nfs3_user_xattr_list,
-	.get    = nfs3_user_xattr_get,
-	.set    = nfs3_user_xattr_set,
-};
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 62f8db8..b1368c2 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2023,7 +2023,7 @@ static void nfs_fill_super(struct super_block *sb,
 		 */
 		sb->s_flags |= MS_POSIXACL;
 		sb->s_time_gran = 1;
-#if defined(CONFIG_NFS_V3_ACL) || defined (CONFIG_NFS_V3_XATTR_USER)
+#ifdef CONFIG_NFS_V3_XATTR
 		sb->s_xattr = nfs3_xattr_handlers;
 #endif
 	}
diff --git a/fs/nfsd/nfs3xattr.c b/fs/nfsd/nfs3xattr.c
index b5a5faa..d9a7785 100644
--- a/fs/nfsd/nfs3xattr.c
+++ b/fs/nfsd/nfs3xattr.c
@@ -47,11 +47,12 @@ static __be32 nfsd3_proc_getxattr(struct svc_rqst * rqstp,
 	char *name, *xattr_name = argp->xattr_name;
 	unsigned int size_max = argp->xattr_size_max;
 	unsigned int name_len = argp->xattr_name_len;
+	unsigned int name_tot_len = name_len + NFSD_XATTR_PREFIX_LEN;
 
 	dprintk("nfsd: GETXATTR(3)  %s %.*s %u\n", SVCFH_fmt(&argp->fh),
 	        name_len, xattr_name, size_max);
 
-	if (name_len > XATTR_NAME_MAX)
+	if (name_tot_len > XATTR_NAME_MAX)
 		RETURN_STATUS(nfserr);
 
 	if (size_max > XATTR_SIZE_MAX)
@@ -66,27 +67,20 @@ static __be32 nfsd3_proc_getxattr(struct svc_rqst * rqstp,
 	if (nfserr)
 		RETURN_STATUS(nfserr);
 
-	/* Convert xdr string to real string */
-	name = kmalloc(name_len + 1, GFP_KERNEL);
+	/* Convert xattr name to real string and add local prefix */
+	name = kmalloc(name_tot_len + 1, GFP_KERNEL);
 	if (name == NULL)
 		RETURN_STATUS(nfserrno(-ENOMEM));
 
-	ret = snprintf(name, name_len + 1, "%.*s", name_len, xattr_name);
-	if (ret > name_len) {
-		nfserr = nfserrno(-EINVAL);
-		goto cleanup;
-	}
-
-	/* Only the user namespace is currently supported by the server */
-	if (strncmp(name, XATTR_USER_PREFIX, XATTR_USER_PREFIX_LEN)) {
+	ret = snprintf(name, name_tot_len + 1, "%s%.*s",
+		       NFSD_XATTR_PREFIX, name_len, xattr_name);
+	if (ret > name_tot_len) {
 		nfserr = nfserrno(-EINVAL);
 		goto cleanup;
 	}
 
 	ret = nfsd_getxattr(fh->fh_dentry, name, &value);
 	if (ret <= 0) {
-		if (ret == 0)
-			ret = -ENODATA;
 		nfserr = nfserrno(ret);
 		goto cleanup;
 	}
@@ -95,6 +89,8 @@ static __be32 nfsd3_proc_getxattr(struct svc_rqst * rqstp,
 	resp->xattr_val = value;
 	resp->xattr_val_len = ret;
 
+	/* FIXME: verify whether release func is called on error (cf. ACL code) */
+
 cleanup:
 	kfree(name);
 	RETURN_STATUS(nfserr);
@@ -159,11 +155,12 @@ static __be32 nfsd3_proc_setxattr(struct svc_rqst * rqstp,
 	unsigned int name_len = argp->xattr_name_len;
 	unsigned int val_len = argp->xattr_val_len;
 	unsigned int flags = argp->xattr_flags;
+	unsigned int name_tot_len = name_len + NFSD_XATTR_PREFIX_LEN;
 
 	dprintk("nfsd: SETXATTR(3)  %s %.*s %u %#x\n", SVCFH_fmt(&argp->fh),
 		name_len, xattr_name, val_len, flags);
 
-	if (name_len > XATTR_NAME_MAX)
+	if (name_tot_len > XATTR_NAME_MAX)
 		RETURN_STATUS(nfserr);
 
 	if (val_len > XATTR_SIZE_MAX)
@@ -177,19 +174,15 @@ static __be32 nfsd3_proc_setxattr(struct svc_rqst * rqstp,
 	if (nfserr)
 		RETURN_STATUS(nfserr);
 
-	/* Convert xdr string to real string */
-	name = kmalloc(name_len + 1, GFP_KERNEL);
+	/* Convert xattr name to real string and add prefix */
+	name = kmalloc(name_tot_len + 1, GFP_KERNEL);
 	if (name == NULL)
 		RETURN_STATUS(nfserrno(-ENOMEM));
 
-	ret = snprintf(name, name_len + 1, "%.*s", name_len, xattr_name);
-	if (ret > name_len) {
-		nfserr = nfserrno(-EINVAL);
-		goto cleanup;
-	}
+	ret = snprintf(name, name_tot_len + 1, "%s%.*s",
+		       NFSD_XATTR_PREFIX, name_len, xattr_name);
 
-	/* Only the user namespace is currently supported by the server */
-	if (strncmp(name, XATTR_USER_PREFIX, XATTR_USER_PREFIX_LEN)) {
+	if (ret > name_tot_len) {
 		nfserr = nfserrno(-EINVAL);
 		goto cleanup;
 	}
@@ -240,9 +233,30 @@ static int nfs3svc_release_setxattr(struct svc_rqst *rqstp, __be32 *p,
 }
 
 /*
+ * Search the xattr list for those which match the local NFSD prefix. For
+ * each, strip the prefix and copy out the rest of the xattr.
+ */
+static int nfsd3_filter_xattrs(const char *in, char *out, int i_len)
+{
+	int i_idx = 0, o_idx = 0;
+
+	while (i_idx < i_len) {
+		const char *curr = in + i_idx;
+		int c_len = strlen(curr);
+
+		if (!strncmp(NFSD_XATTR_PREFIX, curr, NFSD_XATTR_PREFIX_LEN)) {
+			strcpy(out + o_idx, curr + NFSD_XATTR_PREFIX_LEN);
+			o_idx += c_len - NFSD_XATTR_PREFIX_LEN + 1;
+		}
+
+		i_idx += c_len + 1;
+	}
+
+	return o_idx;
+}
+
+/*
  * LISTXATTR
- *
- * TODO: namespace filtering?
  */
 static __be32 nfsd3_proc_listxattr(struct svc_rqst * rqstp,
 				   struct nfsd3_listxattrargs *argp,
@@ -250,8 +264,8 @@ static __be32 nfsd3_proc_listxattr(struct svc_rqst * rqstp,
 {
 	__be32 nfserr = nfserrno(-EINVAL);
 	svc_fh *fh;
-	char *list;
-	int ret;
+	char *list, *f_list;
+	int ret, f_len;
 	unsigned int list_max = argp->xattr_list_max;
 
 	dprintk("nfsd: LISTXATTR(3)  %s %u\n", SVCFH_fmt(&argp->fh), list_max);
@@ -276,12 +290,27 @@ static __be32 nfsd3_proc_listxattr(struct svc_rqst * rqstp,
 	if (ret <= 0) {
 		if (ret == 0)
 			ret = -ENODATA;
+		kfree(list);
 		RETURN_STATUS(nfserrno(ret));
 	}
 
+	/*
+	 * Filter the xattr list: translate and return only those stored
+	 * with the correct prefix.  The list is a series of nul-terminated
+	 * strings.
+	 */
+	f_list = kmalloc(ret, GFP_ATOMIC);
+	if (f_list == NULL) {
+		kfree(list);
+		RETURN_STATUS(nfserrno(-ENOMEM));
+	}
+
+	f_len = nfsd3_filter_xattrs(list, f_list, ret);
+	kfree(list);
+
 	nfserr = 0;
-	resp->xattr_list = list;
-	resp->xattr_list_len = ret;
+	resp->xattr_list = f_list;
+	resp->xattr_list_len = f_len;
 
 	RETURN_STATUS(nfserr);
 }
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 7237776..b100345 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -166,6 +166,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_cb_path_down	cpu_to_be32(NFSERR_CB_PATH_DOWN)
 #define	nfserr_locked		cpu_to_be32(NFSERR_LOCKED)
 #define	nfserr_wrongsec		cpu_to_be32(NFSERR_WRONGSEC)
+#define nfserr_nodata			cpu_to_be32(NFSERR_NODATA)
 #define nfserr_badiomode		cpu_to_be32(NFS4ERR_BADIOMODE)
 #define nfserr_badlayout		cpu_to_be32(NFS4ERR_BADLAYOUT)
 #define nfserr_bad_session_digest	cpu_to_be32(NFS4ERR_BAD_SESSION_DIGEST)
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index a047ad6..e364367 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -744,6 +744,9 @@ nfserrno (int errno)
 		{ nfserr_notsupp, -EOPNOTSUPP },
 		{ nfserr_toosmall, -ETOOSMALL },
 		{ nfserr_serverfault, -ESERVERFAULT },
+#ifdef CONFIG_NFSD_V3_XATTR
+		{ nfserr_nodata, -ENODATA },
+#endif
 	};
 	int	i;
 
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 4a4d6ec..54079b2 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -108,6 +108,16 @@ ssize_t nfsd_getxattr(struct dentry *dentry, char *key, void **buf);
 
 #ifdef CONFIG_NFSD_V3_XATTR
 extern struct svc_version nfsd_xattr_version3;
+
+/*
+ * Translation prefix for local storage of remote xattrs.  This is currently
+ * hard-coded, but could be made a configurable per-export option.  We're
+ * using the user namespace, which is widely supported by filesystems, and
+ * allows arbitrary manipulation.
+ */
+#define NFSD_XATTR_PREFIX "nfsd."
+#define NFSD_XATTR_PREFIX_LEN (strlen(NFSD_XATTR_PREFIX))
+
 #else
 #define nfsd_xattr_version3 NULL
 #endif
diff --git a/include/linux/nfs.h b/include/linux/nfs.h
index f387919..05fe996 100644
--- a/include/linux/nfs.h
+++ b/include/linux/nfs.h
@@ -110,6 +110,7 @@
 	NFSERR_FILE_OPEN = 10046,      /*       v4 */
 	NFSERR_ADMIN_REVOKED = 10047,  /*       v4 */
 	NFSERR_CB_PATH_DOWN = 10048,   /*       v4 */
+	NFSERR_NODATA = 10049,	       /*    v3    (XATTR) */
 };
 
 /* NFSv2 file types - beware, these are not the same in NFSv3 */
-- 
1.7.0.1

