From: James Morris <jmorris@namei.org>
Subject: [PATCH 4/4] NFSv3: add server implementation of XATTR protocol
Date: Wed, 27 Jan 2010 10:10:00 +1100 (EST)
Message-ID: <alpine.LRH.2.00.1001271009220.15158@tundra.namei.org>
References: <alpine.LRH.2.00.1001270952420.15158@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:45618 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752731Ab0AZXKG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jan 2010 18:10:06 -0500
In-Reply-To: <alpine.LRH.2.00.1001270952420.15158-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add server support for the Linux NFSv3 extended attribute
side protocol (XATTR).

Signed-off-by: James Morris <jmorris@namei.org>
---
 fs/nfs/nfs3xattr_user.c    |   19 ++-
 fs/nfsd/Kconfig            |    8 +
 fs/nfsd/Makefile           |    1 +
 fs/nfsd/nfs3xattr.c        |  354 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsctl.c           |    3 +
 fs/nfsd/nfssvc.c           |   60 +++++++-
 fs/nfsd/vfs.c              |    5 +-
 fs/nfsd/vfs.h              |   13 ++
 fs/nfsd/xdr3.h             |   46 ++++++
 include/linux/sunrpc/svc.h |    2 +-
 10 files changed, 496 insertions(+), 15 deletions(-)
 create mode 100644 fs/nfsd/nfs3xattr.c

diff --git a/fs/nfs/nfs3xattr_user.c b/fs/nfs/nfs3xattr_user.c
index 61ae019..c544fcb 100644
--- a/fs/nfs/nfs3xattr_user.c
+++ b/fs/nfs/nfs3xattr_user.c
@@ -23,24 +23,25 @@
  * now, because we only support this single namespace.  If support is
  * expanded to more namespaces, we we'll need a custom listxattr operation.
  */
-static size_t nfs3_user_xattr_list(struct inode *inode, char *list,
+static size_t nfs3_user_xattr_list(struct dentry *dentry, char *list,
 				   size_t list_len, const char *name,
-				   size_t name_len)
+				   size_t name_len, int hflags)
 {
-	return nfs3_proc_listxattr(inode, list, list_len);
+	return nfs3_proc_listxattr(dentry->d_inode, list, list_len);
 }
 
-static int nfs3_user_xattr_get(struct inode *inode, const char *name,
-			       void *buffer, size_t size)
+static int nfs3_user_xattr_get(struct dentry *dentry, const char *name,
+			       void *buffer, size_t size, int hflags)
 {
-	return nfs3_proc_getxattr(inode, XATTR_USER_PREFIX,
+	return nfs3_proc_getxattr(dentry->d_inode, XATTR_USER_PREFIX,
 				  name, buffer, size);
 }
 
-static int nfs3_user_xattr_set(struct inode *inode, const char *name,
-			       const void *value, size_t size, int flags)
+static int nfs3_user_xattr_set(struct dentry *dentry, const char *name,
+			       const void *value, size_t size,
+			       int flags, int hflags)
 {
-	return nfs3_proc_setxattr(inode, XATTR_USER_PREFIX,
+	return nfs3_proc_setxattr(dentry->d_inode, XATTR_USER_PREFIX,
 				  name, value, size, flags);
 }
 
diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 503b9da..4252d16 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -64,6 +64,14 @@ config NFSD_V3_ACL
 
 	  If unsure, say N.
 
+config NFSD_V3_XATTR
+	bool "NFS server support for the NFSv3 XATTR protocol extension (EXPERIMENTAL)"
+	depends on NFSD_V3 && EXPERIMENTAL
+	help
+	  NFS server support for the NFSv3 XATTR protocol.
+
+	  If unsure, say N.
+
 config NFSD_V4
 	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
 	depends on NFSD && PROC_FS && EXPERIMENTAL
diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 9b118ee..e206b52 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -9,5 +9,6 @@ nfsd-y 			:= nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
 nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
 nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
+nfsd-$(CONFIG_NFSD_V3_XATTR) += nfs3xattr.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
 			   nfs4acl.o nfs4callback.o nfs4recover.o
diff --git a/fs/nfsd/nfs3xattr.c b/fs/nfsd/nfs3xattr.c
new file mode 100644
index 0000000..b5a5faa
--- /dev/null
+++ b/fs/nfsd/nfs3xattr.c
@@ -0,0 +1,354 @@
+/*
+ * Process version 3 NFSXATTR requests.
+ *
+ * Based on the NFSACL code by:
+ * Copyright (C) 2002-2003 Andreas Gruenbacher <agruen@suse.de>
+ *
+ * Copyright (C) 2009 Red Hat, Inc., James Morris <jmorris@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2,
+ * as published by the Free Software Foundation.
+ */
+#include <linux/sunrpc/svc.h>
+#include <linux/nfs3.h>
+#include <linux/xattr.h>
+#include <linux/nfs_xattr.h>
+
+#include "nfsd.h"
+#include "xdr3.h"
+#include "vfs.h"
+#include "cache.h"
+
+#define NFSDDBG_FACILITY	NFSDDBG_PROC
+#define RETURN_STATUS(st)	{ resp->status = (st); return (st); }
+
+/* NULL call */
+static __be32 nfsd3_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
+{
+	return nfs_ok;
+}
+
+/*
+ * GETXATTR
+ *
+ * FIXME:
+ *  - Implement shared xattr cache
+ *  - Audit nfs error returns
+ */
+static __be32 nfsd3_proc_getxattr(struct svc_rqst * rqstp,
+				  struct nfsd3_getxattrargs *argp,
+				  struct nfsd3_getxattrres *resp)
+{
+	__be32 nfserr = nfserrno(-EINVAL);
+	svc_fh *fh;
+	void *value;
+	int ret;
+	char *name, *xattr_name = argp->xattr_name;
+	unsigned int size_max = argp->xattr_size_max;
+	unsigned int name_len = argp->xattr_name_len;
+
+	dprintk("nfsd: GETXATTR(3)  %s %.*s %u\n", SVCFH_fmt(&argp->fh),
+	        name_len, xattr_name, size_max);
+
+	if (name_len > XATTR_NAME_MAX)
+		RETURN_STATUS(nfserr);
+
+	if (size_max > XATTR_SIZE_MAX)
+		RETURN_STATUS(nfserr);
+
+	/* Probes must be handled by the client */
+	if (size_max == 0)
+		RETURN_STATUS(nfserr);
+
+	fh = fh_copy(&resp->fh, &argp->fh);
+	nfserr = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_READ);
+	if (nfserr)
+		RETURN_STATUS(nfserr);
+
+	/* Convert xdr string to real string */
+	name = kmalloc(name_len + 1, GFP_KERNEL);
+	if (name == NULL)
+		RETURN_STATUS(nfserrno(-ENOMEM));
+
+	ret = snprintf(name, name_len + 1, "%.*s", name_len, xattr_name);
+	if (ret > name_len) {
+		nfserr = nfserrno(-EINVAL);
+		goto cleanup;
+	}
+
+	/* Only the user namespace is currently supported by the server */
+	if (strncmp(name, XATTR_USER_PREFIX, XATTR_USER_PREFIX_LEN)) {
+		nfserr = nfserrno(-EINVAL);
+		goto cleanup;
+	}
+
+	ret = nfsd_getxattr(fh->fh_dentry, name, &value);
+	if (ret <= 0) {
+		if (ret == 0)
+			ret = -ENODATA;
+		nfserr = nfserrno(ret);
+		goto cleanup;
+	}
+
+	nfserr = 0;
+	resp->xattr_val = value;
+	resp->xattr_val_len = ret;
+
+cleanup:
+	kfree(name);
+	RETURN_STATUS(nfserr);
+}
+
+/* cribbed from decode pathname */
+static __be32 *decode_xattrname(__be32 *p, char **namp, unsigned int *lenp)
+{
+	char *name;
+	unsigned int i;
+
+	p = xdr_decode_string_inplace(p, namp, lenp, XATTR_NAME_MAX);
+	if (p != NULL)
+		for (i = 0, name = *namp; i < *lenp; i++, name++)
+			if (*name == '\0')
+				return NULL;
+	return p;
+}
+
+static int nfs3svc_decode_getxattrargs(struct svc_rqst *rqstp, __be32 *p,
+				       struct nfsd3_getxattrargs *argp)
+{
+	if (!(p = nfs3svc_decode_fh(p, &argp->fh)))
+		return 0;
+	if (!(p = decode_xattrname(p, &argp->xattr_name, &argp->xattr_name_len)))
+		return 0;
+	argp->xattr_size_max = ntohl(*p++);
+	return xdr_argsize_check(rqstp, p);
+}
+
+static int nfs3svc_encode_getxattrres(struct svc_rqst *rqstp, __be32 *p,
+				      struct nfsd3_getxattrres *resp)
+{
+	p = nfs3svc_encode_post_op_attr(rqstp, p, &resp->fh);
+	if (resp->status == 0)
+		p = xdr_encode_array(p, resp->xattr_val, resp->xattr_val_len);
+	return xdr_ressize_check(rqstp, p);
+}
+
+static int nfs3svc_release_getxattr(struct svc_rqst *rqstp, __be32 *p,
+				    struct nfsd3_getxattrres *resp)
+{
+	fh_put(&resp->fh);
+	kfree(resp->xattr_val);
+	return 1;
+}
+
+/*
+ * SETXATTR and RMXATTR
+ *
+ * RMXATTR is detected with zero buffer len and XATTR_REPLACE.
+ *
+ */
+static __be32 nfsd3_proc_setxattr(struct svc_rqst * rqstp,
+				  struct nfsd3_setxattrargs *argp,
+				  struct nfsd3_setxattrres *resp)
+{
+	__be32 nfserr = nfserrno(-EINVAL);
+	svc_fh *fh;
+	int ret;
+	char *name, *xattr_name = argp->xattr_name;
+	unsigned int name_len = argp->xattr_name_len;
+	unsigned int val_len = argp->xattr_val_len;
+	unsigned int flags = argp->xattr_flags;
+
+	dprintk("nfsd: SETXATTR(3)  %s %.*s %u %#x\n", SVCFH_fmt(&argp->fh),
+		name_len, xattr_name, val_len, flags);
+
+	if (name_len > XATTR_NAME_MAX)
+		RETURN_STATUS(nfserr);
+
+	if (val_len > XATTR_SIZE_MAX)
+		RETURN_STATUS(nfserr);
+
+	if (flags & ~(XATTR_CREATE|XATTR_REPLACE))
+		RETURN_STATUS(nfserr);
+
+	fh = fh_copy(&resp->fh, &argp->fh);
+	nfserr = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_SATTR);
+	if (nfserr)
+		RETURN_STATUS(nfserr);
+
+	/* Convert xdr string to real string */
+	name = kmalloc(name_len + 1, GFP_KERNEL);
+	if (name == NULL)
+		RETURN_STATUS(nfserrno(-ENOMEM));
+
+	ret = snprintf(name, name_len + 1, "%.*s", name_len, xattr_name);
+	if (ret > name_len) {
+		nfserr = nfserrno(-EINVAL);
+		goto cleanup;
+	}
+
+	/* Only the user namespace is currently supported by the server */
+	if (strncmp(name, XATTR_USER_PREFIX, XATTR_USER_PREFIX_LEN)) {
+		nfserr = nfserrno(-EINVAL);
+		goto cleanup;
+	}
+
+	if (!val_len) {
+		if (flags & ~XATTR_REPLACE) {
+			nfserr = nfserrno(-EINVAL);
+			goto cleanup;
+		}
+		ret = vfs_removexattr(fh->fh_dentry, name);
+	} else
+		ret = vfs_setxattr(fh->fh_dentry, name,
+				   argp->xattr_val, val_len, flags);
+
+	nfserr = nfserrno(ret);
+
+cleanup:
+	kfree(name);
+	RETURN_STATUS(nfserr);
+}
+
+static int nfs3svc_decode_setxattrargs(struct svc_rqst *rqstp, __be32 *p,
+				       struct nfsd3_setxattrargs *argp)
+{
+	if (!(p = nfs3svc_decode_fh(p, &argp->fh)))
+		return 0;
+	if (!(p = decode_xattrname(p, &argp->xattr_name, &argp->xattr_name_len)))
+		return 0;
+	if (!(p = xdr_decode_string_inplace(p, &argp->xattr_val,
+					&argp->xattr_val_len, XATTR_SIZE_MAX)))
+		return 0;
+	argp->xattr_flags = ntohl(*p++);
+	return xdr_argsize_check(rqstp, p);
+}
+
+static int nfs3svc_encode_setxattrres(struct svc_rqst *rqstp, __be32 *p,
+				      struct nfsd3_setxattrres *resp)
+{
+	p = nfs3svc_encode_post_op_attr(rqstp, p, &resp->fh);
+	return xdr_ressize_check(rqstp, p);
+}
+
+static int nfs3svc_release_setxattr(struct svc_rqst *rqstp, __be32 *p,
+				    struct nfsd3_setxattrres *resp)
+{
+	fh_put(&resp->fh);
+	return 1;
+}
+
+/*
+ * LISTXATTR
+ *
+ * TODO: namespace filtering?
+ */
+static __be32 nfsd3_proc_listxattr(struct svc_rqst * rqstp,
+				   struct nfsd3_listxattrargs *argp,
+				   struct nfsd3_listxattrres *resp)
+{
+	__be32 nfserr = nfserrno(-EINVAL);
+	svc_fh *fh;
+	char *list;
+	int ret;
+	unsigned int list_max = argp->xattr_list_max;
+
+	dprintk("nfsd: LISTXATTR(3)  %s %u\n", SVCFH_fmt(&argp->fh), list_max);
+
+	if (list_max > XATTR_LIST_MAX)
+		RETURN_STATUS(nfserr);
+
+	/* Probes must be handled by the client */
+	if (list_max == 0)
+		RETURN_STATUS(nfserr);
+
+	fh = fh_copy(&resp->fh, &argp->fh);
+	nfserr = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_READ);
+	if (nfserr)
+		RETURN_STATUS(nfserr);
+
+	list = kmalloc(list_max, GFP_ATOMIC);
+	if (list == NULL)
+		RETURN_STATUS(nfserrno(-ENOMEM));
+
+	ret = vfs_listxattr(fh->fh_dentry, list, list_max);
+	if (ret <= 0) {
+		if (ret == 0)
+			ret = -ENODATA;
+		RETURN_STATUS(nfserrno(ret));
+	}
+
+	nfserr = 0;
+	resp->xattr_list = list;
+	resp->xattr_list_len = ret;
+
+	RETURN_STATUS(nfserr);
+}
+
+static int nfs3svc_decode_listxattrargs(struct svc_rqst *rqstp, __be32 *p,
+				        struct nfsd3_listxattrargs *argp)
+{
+	if (!(p = nfs3svc_decode_fh(p, &argp->fh)))
+		return 0;
+	argp->xattr_list_max = ntohl(*p++);
+	return xdr_argsize_check(rqstp, p);
+}
+
+static int nfs3svc_encode_listxattrres(struct svc_rqst *rqstp, __be32 *p,
+				       struct nfsd3_listxattrres *resp)
+{
+	p = nfs3svc_encode_post_op_attr(rqstp, p, &resp->fh);
+	if (resp->status == 0)
+		p = xdr_encode_array(p, resp->xattr_list, resp->xattr_list_len);
+	return xdr_ressize_check(rqstp, p);
+}
+
+static int nfs3svc_release_listxattr(struct svc_rqst *rqstp, __be32 *p,
+				     struct nfsd3_listxattrres *resp)
+{
+	fh_put(&resp->fh);
+	kfree(resp->xattr_list);
+	return 1;
+}
+
+#define ST 1		/* status */
+#define AT 21           /* attributes */
+#define pAT (1+AT)      /* post attributes - conditional */
+
+#define nfs3svc_decode_voidargs		NULL
+#define nfs3svc_release_void		NULL
+#define nfsd3_voidres			nfsd3_voidargs
+struct nfsd3_voidargs { int dummy; };
+
+#define PROC(name, argt, rest, relt, cache, respsize)	\
+ { (svc_procfunc) nfsd3_proc_##name,		\
+   (kxdrproc_t) nfs3svc_decode_##argt##args,	\
+   (kxdrproc_t) nfs3svc_encode_##rest##res,	\
+   (kxdrproc_t) nfs3svc_release_##relt,		\
+   sizeof(struct nfsd3_##argt##args),		\
+   sizeof(struct nfsd3_##rest##res),		\
+   0,						\
+   cache,					\
+   respsize,					\
+ }
+
+#define G_RSZ	(ST+pAT+1+(XATTR_SIZE_MAX>>2))
+#define S_RSZ	(ST+pAT)
+#define L_RSZ	(ST+pAT+1+(XATTR_LIST_MAX>>2))
+
+static struct svc_procedure nfsd_xattr_procedures3[] = {
+  PROC(null,       void,       void,       void,       RC_NOCACHE, ST),
+  PROC(getxattr,   getxattr,   getxattr,   getxattr,   RC_NOCACHE, G_RSZ),
+  PROC(setxattr,   setxattr,   setxattr,   setxattr,   RC_NOCACHE, S_RSZ),
+  PROC(listxattr,  listxattr,  listxattr,  listxattr,  RC_NOCACHE, L_RSZ),
+};
+
+struct svc_version	nfsd_xattr_version3 = {
+	.vs_vers	= 3,
+	.vs_nproc	= 4,
+	.vs_proc	= nfsd_xattr_procedures3,
+	.vs_dispatch	= nfsd_dispatch,
+	.vs_xdrsize	= NFS3_SVC_XDRSIZE,
+	.vs_hidden	= 1,
+};
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 2604c3e..0fc6608 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1378,6 +1378,8 @@ static int create_proc_exports_entry(void)
 }
 #endif
 
+extern void __init nfsd_prog_init(void);
+
 static int __init init_nfsd(void)
 {
 	int retval;
@@ -1386,6 +1388,7 @@ static int __init init_nfsd(void)
 	retval = nfs4_state_init(); /* nfs4 locking state */
 	if (retval)
 		return retval;
+	nfsd_prog_init();
 	nfsd_stat_init();	/* Statistics */
 	retval = nfsd_reply_cache_init();
 	if (retval)
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 171699e..6f0f472 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -15,6 +15,7 @@
 #include <linux/sunrpc/svcsock.h>
 #include <linux/lockd/bind.h>
 #include <linux/nfsacl.h>
+#include <linux/nfs_xattr.h>
 #include <linux/seq_file.h>
 #include "nfsd.h"
 #include "cache.h"
@@ -87,6 +88,27 @@ static struct svc_stat	nfsd_acl_svcstats = {
 };
 #endif /* defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) */
 
+#ifdef CONFIG_NFSD_V3_XATTR
+static struct svc_stat	nfsd_xattr_svcstats;
+static struct svc_version *	nfsd_xattr_version[] = {
+	[3] = &nfsd_xattr_version3,
+};
+
+#define NFSD_XATTR_MINVERS	3
+#define NFSD_XATTR_NRVERS	ARRAY_SIZE(nfsd_xattr_version)
+static struct svc_version *nfsd_xattr_versions[NFSD_XATTR_NRVERS];
+
+static struct svc_program	nfsd_xattr_program = {
+	.pg_prog		= NFS_XATTR_PROGRAM,
+	.pg_nvers		= NFSD_XATTR_NRVERS,
+	.pg_vers		= nfsd_xattr_versions,
+	.pg_name		= "nfsxattr",
+	.pg_class		= "nfsd",		/* share nfsd auth */
+	.pg_stats		= &nfsd_xattr_svcstats,
+	.pg_authenticate	= &svc_set_client,
+};
+#endif	/* CONFIG_NFSD_V3_XATTR */
+
 static struct svc_version *	nfsd_version[] = {
 	[2] = &nfsd_version2,
 #if defined(CONFIG_NFSD_V3)
@@ -102,9 +124,6 @@ static struct svc_version *	nfsd_version[] = {
 static struct svc_version *nfsd_versions[NFSD_NRVERS];
 
 struct svc_program		nfsd_program = {
-#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
-	.pg_next		= &nfsd_acl_program,
-#endif
 	.pg_prog		= NFS_PROGRAM,		/* program number */
 	.pg_nvers		= NFSD_NRVERS,		/* nr of entries in nfsd_version */
 	.pg_vers		= nfsd_versions,	/* version table */
@@ -115,6 +134,28 @@ struct svc_program		nfsd_program = {
 
 };
 
+static void __init nfsd_prog_add(struct svc_program *new)
+{
+	struct svc_program *p = &nfsd_program;
+
+	while (p->pg_next)
+		p = p->pg_next;
+
+	p->pg_next = new;
+}
+
+/* Dynamically initialize list of service programs */
+void __init nfsd_prog_init(void)
+{
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+	nfsd_prog_add(&nfsd_acl_program);
+#endif
+
+#ifdef CONFIG_NFSD_V3_XATTR
+	nfsd_prog_add(&nfsd_xattr_program);
+#endif
+}
+
 u32 nfsd_supported_minorversion;
 
 int nfsd_vers(int vers, enum vers_op change)
@@ -128,6 +169,10 @@ int nfsd_vers(int vers, enum vers_op change)
 		if (vers < NFSD_ACL_NRVERS)
 			nfsd_acl_versions[vers] = nfsd_acl_version[vers];
 #endif
+#ifdef CONFIG_NFSD_V3_XATTR
+		if (vers < NFSD_XATTR_NRVERS)
+			nfsd_xattr_versions[vers] = nfsd_xattr_version[vers];
+#endif
 		break;
 	case NFSD_CLEAR:
 		nfsd_versions[vers] = NULL;
@@ -135,6 +180,10 @@ int nfsd_vers(int vers, enum vers_op change)
 		if (vers < NFSD_ACL_NRVERS)
 			nfsd_acl_versions[vers] = NULL;
 #endif
+#ifdef CONFIG_NFSD_V3_XATTR
+		if (vers < NFSD_XATTR_NRVERS)
+			nfsd_xattr_versions[vers] = NULL;
+#endif
 		break;
 	case NFSD_TEST:
 		return nfsd_versions[vers] != NULL;
@@ -213,6 +262,11 @@ void nfsd_reset_versions(void)
 			nfsd_acl_program.pg_vers[i] =
 				nfsd_acl_version[i];
 #endif
+#ifdef CONFIG_NFSD_V3_XATTR
+		for (i = NFSD_XATTR_MINVERS; i < NFSD_XATTR_NRVERS; i++)
+			nfsd_xattr_program.pg_vers[i] =
+				nfsd_xattr_version[i];
+#endif
 	}
 }
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c194793..b369fe4 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -428,8 +428,9 @@ out_nfserr:
 
 #if defined(CONFIG_NFSD_V2_ACL) || \
     defined(CONFIG_NFSD_V3_ACL) || \
-    defined(CONFIG_NFSD_V4)
-static ssize_t nfsd_getxattr(struct dentry *dentry, char *key, void **buf)
+    defined(CONFIG_NFSD_V4) || \
+    defined(CONFIG_NFSD_V3_XATTR)
+ssize_t nfsd_getxattr(struct dentry *dentry, char *key, void **buf)
 {
 	ssize_t buflen;
 	ssize_t ret;
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 4b1de0a..f8132f3 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -98,4 +98,17 @@ struct posix_acl *nfsd_get_posix_acl(struct svc_fh *, int);
 int nfsd_set_posix_acl(struct svc_fh *, int, struct posix_acl *);
 #endif
 
+#if defined(CONFIG_NFSD_V2_ACL) || \
+    defined(CONFIG_NFSD_V3_ACL) || \
+    defined(CONFIG_NFSD_V4) || \
+    defined(CONFIG_NFSD_V3_XATTR)
+ssize_t nfsd_getxattr(struct dentry *dentry, char *key, void **buf);
+#endif
+
+#ifdef CONFIG_NFSD_V3_XATTR
+extern struct svc_version nfsd_xattr_version3;
+#else
+#define nfsd_xattr_version3 NULL
+#endif
+
 #endif /* LINUX_NFSD_VFS_H */
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 7df980e..e6ccc60 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -119,6 +119,27 @@ struct nfsd3_setaclargs {
 	struct posix_acl	*acl_default;
 };
 
+struct nfsd3_getxattrargs {
+	struct svc_fh           fh;
+	char *                  xattr_name;
+	unsigned int            xattr_name_len;
+	unsigned int            xattr_size_max;
+};
+
+struct nfsd3_setxattrargs {
+	struct svc_fh           fh;
+	unsigned int            xattr_flags;
+	char *                  xattr_name;
+	unsigned int            xattr_name_len;
+	char *                  xattr_val;
+	int                     xattr_val_len;
+};
+
+struct nfsd3_listxattrargs {
+	struct svc_fh           fh;
+	unsigned int            xattr_list_max;
+};
+
 struct nfsd3_attrstat {
 	__be32			status;
 	struct svc_fh		fh;
@@ -227,6 +248,25 @@ struct nfsd3_getaclres {
 	struct posix_acl	*acl_default;
 };
 
+struct nfsd3_getxattrres {
+	__be32                  status;
+	struct svc_fh           fh;
+	char *                  xattr_val;
+	unsigned int            xattr_val_len;
+};
+
+struct nfsd3_setxattrres {
+	__be32                  status;
+	struct svc_fh           fh;
+};
+
+struct nfsd3_listxattrres {
+	__be32                  status;
+	struct svc_fh           fh;
+	char *                  xattr_list;
+	unsigned int            xattr_list_len;
+};
+
 /* dummy type for release */
 struct nfsd3_fhandle_pair {
 	__u32			dummy;
@@ -247,6 +287,9 @@ union nfsd3_xdrstore {
 	struct nfsd3_linkargs		linkargs;
 	struct nfsd3_symlinkargs	symlinkargs;
 	struct nfsd3_readdirargs	readdirargs;
+	struct nfsd3_getxattrargs	getxattrargs;
+	struct nfsd3_setxattrargs	setxattrargs;
+	struct nfsd3_listxattrargs	listxattrargs;
 	struct nfsd3_diropres 		diropres;
 	struct nfsd3_accessres		accessres;
 	struct nfsd3_readlinkres	readlinkres;
@@ -260,6 +303,9 @@ union nfsd3_xdrstore {
 	struct nfsd3_pathconfres	pathconfres;
 	struct nfsd3_commitres		commitres;
 	struct nfsd3_getaclres		getaclres;
+	struct nfsd3_getxattrres	getxattrres;
+	struct nfsd3_setxattrres	setxattrres;
+	struct nfsd3_listxattrres	listxattrres;
 };
 
 #define NFS3_SVC_XDRSIZE		sizeof(union nfsd3_xdrstore)
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5a3085b..8bde5c1 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -371,7 +371,7 @@ struct svc_version {
 	u32			vs_xdrsize;	/* xdrsize needed for this version */
 
 	unsigned int		vs_hidden : 1;	/* Don't register with portmapper.
-						 * Only used for nfsacl so far. */
+						 * Used for nfsacl and nfsxattr. */
 
 	/* Override dispatch function (e.g. when caching replies).
 	 * A return value of 0 means drop the request. 
-- 
1.6.3.3

