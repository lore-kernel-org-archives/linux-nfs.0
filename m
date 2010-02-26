From: James Morris <jmorris@namei.org>
Subject: Subject: [PATCH 3/5] NFSv3: add client implementation of XATTR
 protocol
Date: Fri, 26 Feb 2010 15:36:18 +1100 (EST)
Message-ID: <alpine.LRH.2.00.1002261535150.25193@tundra.namei.org>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:50652 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935167Ab0BZEgZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Feb 2010 23:36:25 -0500
In-Reply-To: <alpine.LRH.2.00.1002261457420.25193-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add client support for the Linux NFSv3 extended attribute
side protocol (XATTR).

This extends Linux extended attributes over the network to
servers which support the protocol.

Operation is currently limited to the user.* namespace.

Signed-off-by: James Morris <jmorris@namei.org>
---
 fs/nfs/Kconfig            |   32 ++++++
 fs/nfs/Makefile           |    1 +
 fs/nfs/client.c           |   51 ++++++++++-
 fs/nfs/internal.h         |   11 ++
 fs/nfs/nfs3xattr.c        |  239 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs3xattr_user.c   |   52 ++++++++++
 fs/nfs/nfs3xdr.c          |  187 +++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs_sb.h |    3 +-
 include/linux/nfs_mount.h |    3 +
 include/linux/nfs_xattr.h |   21 ++++
 include/linux/nfs_xdr.h   |   45 +++++++++
 11 files changed, 643 insertions(+), 2 deletions(-)
 create mode 100644 fs/nfs/nfs3xattr_user.c
 create mode 100644 include/linux/nfs_xattr.h

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index d27a88e..e0e2535 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -64,6 +64,38 @@ config NFS_V3_ACL
 
 	  If unsure, say N.
 
+config NFS_V3_XATTR
+	bool "NFS client support for the NFSv3 XATTR protocol extension (EXPERIMENTAL)"
+	depends on NFS_V3 && EXPERIMENTAL
+	select NFS_V3_XATTR_API
+	help
+	  This option selects client suport for the Linux NFSv3 extended
+	  attribute protocol extension (XATTR).
+
+	  This is a side-protocol which extends general support for Linux
+	  extended attributes over the network, and is based on the GPLd
+	  IRIX implmentation (although not wire-compatible with it).
+
+	  Only the user.* namespace is currently supported.  When connected
+	  to a server which also supports XATTR, the full range of extended
+	  attribute system calls:
+
+	    getxattr(2), listxattr(2), setxattr(2) and removexattr(2)
+
+	  should work as expected.
+
+	  If unsure, say N.
+
+config NFS_V3_XATTR_USER
+	bool "Extended attributes in the user namespace (EXPERIMENTAL)"
+	depends on NFS_V3_XATTR
+	help
+	  This option selects extended attributes in the user.* namespace,
+	  which are arbitrarily named and managed by users, and conveyed
+	  via the XATTR protocol extension for NFS version 3.
+
+	  If unsure, say N.
+
 config NFS_V4
 	bool "NFS client support for NFS version 4 (EXPERIMENTAL)"
 	depends on NFS_FS && EXPERIMENTAL
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 1e2743e..54018ee 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -12,6 +12,7 @@ nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V3_XATTR_API)	+= nfs3xattr.o
+nfs-$(CONFIG_NFS_V3_XATTR_USER)	+= nfs3xattr_user.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ee77713..6be7f19 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -97,6 +97,21 @@ struct rpc_program		nfsacl_program = {
 };
 #endif  /* CONFIG_NFS_V3_ACL */
 
+#ifdef CONFIG_NFS_V3_XATTR
+static struct rpc_stat		nfs_xattr_rpcstat = { &nfs_xattr_program };
+static struct rpc_version *	nfs_xattr_version[] = {
+	[3]			= &nfs_xattr_version3,
+};
+
+struct rpc_program		nfs_xattr_program = {
+	.name			= "nfsxattr",
+	.number			= NFS_XATTR_PROGRAM,
+	.nrvers			= ARRAY_SIZE(nfs_xattr_version),
+	.version		= nfs_xattr_version,
+	.stats			= &nfs_xattr_rpcstat,
+};
+#endif  /* CONFIG_NFS_V3_XATTR */
+
 struct nfs_client_initdata {
 	const char *hostname;
 	const struct sockaddr *addr;
@@ -706,6 +721,36 @@ static inline void nfs_init_server_aclclient(struct nfs_server *server)
 #endif
 
 /*
+ * Initialise an NFSv3 XATTR client connection
+ */
+#ifdef CONFIG_NFS_V3_XATTR
+static void nfs_init_server_xattrclient(struct nfs_server *server)
+{
+	if (server->nfs_client->rpc_ops->version != 3)
+		goto out_no_xattr;
+	if (server->flags & NFS_MOUNT_NOXATTR)
+		goto out_no_xattr;
+
+	server->client_xattr = rpc_bind_new_program(server->client, &nfs_xattr_program, 3);
+	if (IS_ERR(server->client_xattr))
+		goto out_no_xattr;
+
+	/* No errors! Assume that XATTR is supported */
+	server->caps |= NFS_CAP_XATTR;
+	return;
+
+out_no_xattr:
+	server->caps &= ~NFS_CAP_XATTR;
+}
+#else
+static inline void nfs_init_server_xattrclient(struct nfs_server *server)
+{
+	server->flags &= ~NFS_MOUNT_NOXATTR;
+	server->caps &= ~NFS_CAP_XATTR;
+}
+#endif
+
+/*
  * Create a general RPC client
  */
 static int nfs_init_server_rpcclient(struct nfs_server *server,
@@ -851,8 +896,12 @@ static int nfs_init_server(struct nfs_server *server,
 	server->mountd_protocol = data->mount_server.protocol;
 
 	server->namelen  = data->namlen;
-	/* Create a client RPC handle for the NFSv3 ACL management interface */
+	/*
+	 * Create client RPC handles for the NFSv3 ACL and XATTR management
+	 * interfaces
+	 */
 	nfs_init_server_aclclient(server);
+	nfs_init_server_xattrclient(server);
 	dprintk("<-- nfs_init_server() = 0 [new %p]\n", clp);
 	return 0;
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 48fcac9..3661a64 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -288,6 +288,17 @@ static inline char *nfs_devname(const struct vfsmount *mnt_parent,
 /* nfs3xattr.c */
 extern struct xattr_handler *nfs3_xattr_handlers[];
 
+extern int nfs3_proc_getxattr(struct inode *inode, const char *namespace,
+			      const char *name, void *value, size_t size);
+extern int nfs3_proc_setxattr(struct inode *inode, const char *namespace,
+			      const char *name, const void *value,
+			      size_t size, int flags);
+extern int nfs3_proc_listxattr(struct inode *inode, char *list,
+			       size_t list_len);
+
+/* nfs3xattr_user.c */
+extern struct xattr_handler nfs3_xattr_user_handler;
+
 /* nfs3acl.c */
 extern struct xattr_handler nfs3_xattr_acl_access_handler;
 extern struct xattr_handler nfs3_xattr_acl_default_handler;
diff --git a/fs/nfs/nfs3xattr.c b/fs/nfs/nfs3xattr.c
index de69f1e..7ff651b 100644
--- a/fs/nfs/nfs3xattr.c
+++ b/fs/nfs/nfs3xattr.c
@@ -1,6 +1,8 @@
 /*
  * Extended attribute (xattr) API and protocol for NFSv3.
  *
+ * Based on the ACL code.
+ *
  * Copyright (C) 2009 Red Hat, Inc., James Morris <jmorris@redhat.com>
  *
  * This program is free software; you can redistribute it and/or modify
@@ -17,9 +19,246 @@
 #define NFSDBG_FACILITY	NFSDBG_PROC
 
 struct xattr_handler *nfs3_xattr_handlers[] = {
+#ifdef CONFIG_NFS_V3_XATTR_USER
+	&nfs3_xattr_user_handler,
+#endif
 #ifdef CONFIG_NFS_V3_ACL
 	&nfs3_xattr_acl_access_handler,
 	&nfs3_xattr_acl_default_handler,
 #endif
 	NULL
 };
+
+#ifdef CONFIG_NFS_V3_XATTR
+/*
+ * XATTR protocol
+ */
+
+/*
+ * Call GETXATTR
+ *
+ * FIXME:
+ * - Cache xattrs
+ * - Handle size probing
+ */
+int nfs3_proc_getxattr(struct inode *inode, const char *namespace,
+		       const char *name, void *value, size_t size)
+{
+	int status;
+	struct nfs_fattr fattr;
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs3_getxattrargs args = {
+		.fh		= NFS_FH(inode),
+	};
+	struct nfs3_getxattrres res = {
+		.fattr		= &fattr,
+	};
+	struct rpc_message msg = {
+		.rpc_argp	= &args,
+		.rpc_resp	= &res,
+	};
+
+	if (!name || !*name)
+		return -EINVAL;
+
+	if (size > XATTR_SIZE_MAX)
+		return -EINVAL;
+
+	if (!nfs_server_capable(inode, NFS_CAP_XATTR))
+		return -EOPNOTSUPP;
+
+	status = nfs_revalidate_inode(server, inode);
+	if (status < 0)
+		return status;
+
+	/*
+	 * Applications usually first probe the xattr value size, then
+	 * perform a full call.  For now, just return a dummy value.
+	 */
+	if (!size || !value)
+		return 4096;
+
+	args.xattr_namespace = namespace;
+	args.xattr_name = name;
+	args.xattr_size_max = size;
+
+	/*
+	 * FIXME
+	 *
+	 * This is ugly.  We pre-allocate a buffer for the XDR layer to use,
+	 * passing the size of the buffer via xattr_val_len, which is
+	 * updated with the actual length decoded.  We should investigate
+	 * using the page-based interface used by ACLs and others, or some
+	 * other better way.
+	 */
+	res.xattr_val_len = size;
+	res.xattr_val = kmalloc(size, GFP_KERNEL);
+	if (!res.xattr_val)
+		return -ENOMEM;
+
+	dprintk("NFS call getxattr %s%s %zd\n", namespace, name, size);
+
+	msg.rpc_proc = &server->client_xattr->cl_procinfo[XATTRPROC3_GETXATTR];
+	nfs_fattr_init(&fattr);
+	status = rpc_call_sync(server->client_xattr, &msg, 0);
+
+	dprintk("NFS reply getxattr: status=%d len=%d\n",
+		status, res.xattr_val_len);
+
+	switch (status) {
+	case 0:
+		status = nfs_refresh_inode(inode, &fattr);
+		break;
+	case -EPFNOSUPPORT:
+	case -EPROTONOSUPPORT:
+		dprintk("NFS_V3_XATTR extension not supported; disabling\n");
+		server->caps &= ~NFS_CAP_XATTR;
+	case -ENOTSUPP:
+		status = -EOPNOTSUPP;
+	default:
+		goto cleanup;
+	}
+
+	status = res.xattr_val_len;
+	if (status <= size)
+		memcpy(value, res.xattr_val, status);
+
+cleanup:
+	kfree(res.xattr_val);
+	return status;
+}
+
+/*
+ * Call SETXATTR or RMXATTR
+ *
+ * RMXATTR is invoked with a NULL buffer and XATTR_REPLACE.
+ *
+ */
+int nfs3_proc_setxattr(struct inode *inode, const char *namespace,
+		       const char *name, const void *value,
+		       size_t size, int flags)
+
+{
+	int status;
+	struct nfs_fattr fattr;
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs3_setxattrargs args = {
+		.fh		= NFS_FH(inode),
+	};
+	struct nfs3_setxattrres res = {
+		.fattr		= &fattr,
+	};
+	struct rpc_message msg = {
+		.rpc_argp	= &args,
+		.rpc_resp	= &res,
+	};
+
+	if (!name || !*name)
+		return -EINVAL;
+
+	if (!nfs_server_capable(inode, NFS_CAP_XATTR))
+		return -EOPNOTSUPP;
+
+	status = nfs_revalidate_inode(server, inode);
+	if (status < 0)
+		return status;
+
+	args.xattr_namespace = namespace;
+	args.xattr_name = name;
+	args.xattr_flags = flags;
+	args.xattr_val = value;
+	args.xattr_val_len = size;
+
+	dprintk("NFS call setxattr %s%s %zd 0x%08x\n",
+		namespace, name, size, flags);
+
+	msg.rpc_proc = &server->client_xattr->cl_procinfo[XATTRPROC3_SETXATTR];
+	nfs_fattr_init(&fattr);
+	status = rpc_call_sync(server->client_xattr, &msg, 0);
+
+	dprintk("NFS reply setxattr: status=%d\n", status);
+
+	switch (status) {
+	case 0:
+		status = nfs_refresh_inode(inode, &fattr);
+		break;
+	case -EPFNOSUPPORT:
+	case -EPROTONOSUPPORT:
+		dprintk("NFS_V3_XATTR extension not supported; disabling\n");
+		server->caps &= ~NFS_CAP_XATTR;
+	case -ENOTSUPP:
+		status = -EOPNOTSUPP;
+	default:
+		break;
+	}
+	return status;
+}
+
+/*
+ * Call LISTXATTR
+ */
+int nfs3_proc_listxattr(struct inode *inode, char *list, size_t list_len)
+{
+	int status;
+	struct nfs_fattr fattr;
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs3_listxattrargs args = {
+		.fh		= NFS_FH(inode),
+	};
+	struct nfs3_listxattrres res = {
+		.fattr		= &fattr,
+	};
+	struct rpc_message msg = {
+		.rpc_argp	= &args,
+		.rpc_resp	= &res,
+	};
+
+	if (list_len > XATTR_LIST_MAX)
+		return -EINVAL;
+
+	if (!nfs_server_capable(inode, NFS_CAP_XATTR))
+		return -EOPNOTSUPP;
+
+	dprintk("NFS call listxattr %zd\n", list_len);
+
+	/* FIXME: handle probes */
+	if (!list || !list_len)
+		return 1024;
+
+	args.xattr_list_max = list_len;
+
+	/* FIXME (see comments for getxattr) */
+	res.xattr_list_len = list_len;
+	res.xattr_list = kmalloc(list_len, GFP_KERNEL);
+	if (!res.xattr_list)
+		return -ENOMEM;
+
+	msg.rpc_proc = &server->client_xattr->cl_procinfo[XATTRPROC3_LISTXATTR];
+	nfs_fattr_init(&fattr);
+	status = rpc_call_sync(server->client_xattr, &msg, 0);
+
+	dprintk("NFS reply listxattr: status=%d\n", status);
+
+	switch (status) {
+	case 0:
+		status = nfs_refresh_inode(inode, &fattr);
+		break;
+	case -EPFNOSUPPORT:
+	case -EPROTONOSUPPORT:
+		dprintk("NFS_V3_XATTR extension not supported; disabling\n");
+		server->caps &= ~NFS_CAP_XATTR;
+	case -ENOTSUPP:
+		status = -EOPNOTSUPP;
+	default:
+		goto cleanup;
+	}
+
+	status = res.xattr_list_len;
+	if (status <= list_len)
+		memcpy(list, res.xattr_list, status);
+
+cleanup:
+	kfree(res.xattr_list);
+	return status;
+}
+#endif	/* CONFIG_NFS_V3_XATTR */
diff --git a/fs/nfs/nfs3xattr_user.c b/fs/nfs/nfs3xattr_user.c
new file mode 100644
index 0000000..61ae019
--- /dev/null
+++ b/fs/nfs/nfs3xattr_user.c
@@ -0,0 +1,52 @@
+/*
+ * Support for extended attributes in the the user.* namespace, which are
+ * arbitrarily named and managed by users and conveyed via the XATTR
+ * protocol extension.
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
+ * The generic xattr code will call this for each helper, which is ok for
+ * now, because we only support this single namespace.  If support is
+ * expanded to more namespaces, we we'll need a custom listxattr operation.
+ */
+static size_t nfs3_user_xattr_list(struct inode *inode, char *list,
+				   size_t list_len, const char *name,
+				   size_t name_len)
+{
+	return nfs3_proc_listxattr(inode, list, list_len);
+}
+
+static int nfs3_user_xattr_get(struct inode *inode, const char *name,
+			       void *buffer, size_t size)
+{
+	return nfs3_proc_getxattr(inode, XATTR_USER_PREFIX,
+				  name, buffer, size);
+}
+
+static int nfs3_user_xattr_set(struct inode *inode, const char *name,
+			       const void *value, size_t size, int flags)
+{
+	return nfs3_proc_setxattr(inode, XATTR_USER_PREFIX,
+				  name, value, size, flags);
+}
+
+struct xattr_handler nfs3_xattr_user_handler = {
+	.prefix = XATTR_USER_PREFIX,
+	.list   = nfs3_user_xattr_list,
+	.get    = nfs3_user_xattr_get,
+	.set    = nfs3_user_xattr_set,
+};
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 5fe5492..1552e6e 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -88,6 +88,26 @@
 #define ACL3_setaclres_sz	(1+NFS3_post_op_attr_sz)
 
 /*
+ * FIXME: currently, the RPC layer will allocate the maximum buffer size
+ * here for each call (which can be ~ 64k).  The Labeled NFS prototype code
+ * uses 4k, although we should not impose limits for NFS which don't exist
+ * in the OS unless absolutely necsssary.  We likely need a dynamic scheme
+ * here, possibly using pages.
+ */
+#define XATTR3_xattrname_sz	(1+(XATTR_NAME_MAX>>2))
+#define XATTR3_xattrval_sz	(1+(XATTR_SIZE_MAX>>2))
+#define XATTR3_xattrlist_sz	(1+(XATTR_LIST_MAX>>2))
+
+#define XATTR3_getxattrargs_sz	(NFS3_fh_sz+XATTR3_xattrname_sz+1)
+#define XATTR3_getxattrres_sz	(1+NFS3_post_op_attr_sz+XATTR3_xattrval_sz)
+
+#define XATTR3_setxattrargs_sz	(NFS3_fh_sz+XATTR3_xattrname_sz+XATTR3_xattrval_sz+1)
+#define XATTR3_setxattrres_sz	(1+NFS3_post_op_attr_sz)
+
+#define XATTR3_listxattrargs_sz	(NFS3_fh_sz+1)
+#define XATTR3_listxattrres_sz	(1+NFS3_post_op_attr_sz+XATTR3_xattrlist_sz)
+
+/*
  * Map file type to S_IFMT bits
  */
 static const umode_t nfs_type2fmt[] = {
@@ -727,6 +747,72 @@ nfs3_xdr_setaclargs(struct rpc_rqst *req, __be32 *p,
 }
 #endif  /* CONFIG_NFS_V3_ACL */
 
+#ifdef CONFIG_NFS_V3_XATTR
+/*
+ * Special case of xdr_encode_opaque, where the xattr helpers hand us
+ * separate namespace and name buffers, which we encode as a single XDR
+ * string over the wire.  Neither namespace nor name may be empty or null.
+ */
+static __be32 *xattr_encode_name(__be32 *p, const char *namespace, const char *name)
+{
+	unsigned int nslen, namelen, totlen, quadlen, padding;
+
+	nslen = strlen(namespace);
+	namelen = strlen(name);
+	totlen = nslen + namelen;
+	quadlen = XDR_QUADLEN(totlen);
+	padding = (quadlen << 2) - totlen;
+
+	*p++ = cpu_to_be32(totlen);
+	memcpy(p, namespace, nslen);
+	memcpy((char *)p + nslen, name, namelen);
+
+	if (padding != 0)
+		memset((char *)p + totlen, 0, padding);
+	p += quadlen;
+	return p;
+}
+
+/*
+ * Encode GETXATTR arguments
+ */
+static int nfs3_xdr_getxattrargs(struct rpc_rqst *req, __be32 *p,
+				 struct nfs3_getxattrargs *args)
+{
+	p = xdr_encode_fhandle(p, args->fh);
+	p = xattr_encode_name(p, args->xattr_namespace, args->xattr_name);
+	*p++ = htonl(args->xattr_size_max);
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	return 0;
+}
+
+/*
+ * Encode SETXATTR arguments
+ */
+static int nfs3_xdr_setxattrargs(struct rpc_rqst *req, __be32 *p,
+				 struct nfs3_setxattrargs *args)
+{
+	p = xdr_encode_fhandle(p, args->fh);
+	p = xattr_encode_name(p, args->xattr_namespace, args->xattr_name);
+	p = xdr_encode_array(p, args->xattr_val, args->xattr_val_len);
+	*p++ = htonl(args->xattr_flags);
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	return 0;
+}
+
+/*
+ * Encode LISTXATTR arguments
+ */
+static int nfs3_xdr_listxattrargs(struct rpc_rqst *req, __be32 *p,
+				  struct nfs3_listxattrargs *args)
+{
+	p = xdr_encode_fhandle(p, args->fh);
+	*p++ = htonl(args->xattr_list_max);
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	return 0;
+}
+#endif	/* CONFIG_NFS_V3_XATTR */
+
 /*
  * NFS XDR decode functions
  */
@@ -1136,6 +1222,69 @@ nfs3_xdr_setaclres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 }
 #endif  /* CONFIG_NFS_V3_ACL */
 
+#ifdef CONFIG_NFS_V3_XATTR
+/*
+ * Decode GETXATTR reply
+ *
+ * FIXME: determine appropriate error returns
+ */
+static int nfs3_xdr_getxattrres(struct rpc_rqst *req, __be32 *p,
+				struct nfs3_getxattrres *res)
+{
+	char *xattr_val;
+	unsigned int xattr_max_size = res->xattr_val_len;
+	int status = ntohl(*p++);
+
+	if (status != 0)
+		return nfs_stat_to_errno(status);
+
+	p = xdr_decode_post_op_attr(p, res->fattr);
+	p = xdr_decode_string_inplace(p, &xattr_val,
+	                              &res->xattr_val_len,
+	                              xattr_max_size);
+	if (p == NULL)
+		return -EINVAL;
+	memcpy(res->xattr_val, xattr_val, res->xattr_val_len);
+	return 0;
+}
+
+/*
+ * Decode SETXATTR reply
+ */
+static int nfs3_xdr_setxattrres(struct rpc_rqst *req, __be32 *p,
+				struct nfs3_setxattrres *res)
+{
+	int status = ntohl(*p++);
+
+	if (status)
+		return nfs_stat_to_errno(status);
+	xdr_decode_post_op_attr(p, res->fattr);
+	return 0;
+}
+
+/*
+ * Decode LISTXATTR reply
+ */
+static int nfs3_xdr_listxattrres(struct rpc_rqst *req, __be32 *p,
+				 struct nfs3_listxattrres *res)
+{
+	char *xattr_list;
+	unsigned int size = res->xattr_list_len;
+	int status = ntohl(*p++);
+
+	if (status != 0)
+		return nfs_stat_to_errno(status);
+
+	p = xdr_decode_post_op_attr(p, res->fattr);
+	p = xdr_decode_string_inplace(p, &xattr_list,
+	                              &res->xattr_list_len, size);
+	if (p == NULL)
+		return -EINVAL;
+	memcpy(res->xattr_list, xattr_list, res->xattr_list_len);
+	return 0;
+}
+#endif	/* CONFIG_NFS_V3_XATTR */
+
 #define PROC(proc, argtype, restype, timer)				\
 [NFS3PROC_##proc] = {							\
 	.p_proc      = NFS3PROC_##proc,					\
@@ -1207,3 +1356,41 @@ struct rpc_version		nfsacl_version3 = {
 	.procs			= nfs3_acl_procedures,
 };
 #endif  /* CONFIG_NFS_V3_ACL */
+
+#ifdef CONFIG_NFS_V3_XATTR
+static struct rpc_procinfo	nfs3_xattr_procedures[] = {
+	[XATTRPROC3_GETXATTR] = {
+		.p_proc		= XATTRPROC3_GETXATTR,
+		.p_encode	= (kxdrproc_t) nfs3_xdr_getxattrargs,
+		.p_decode	= (kxdrproc_t) nfs3_xdr_getxattrres,
+		.p_arglen	= XATTR3_getxattrargs_sz,
+		.p_replen	= XATTR3_getxattrres_sz,
+		.p_timer	= 1,
+		.p_name		= "GETXATTR",
+	},
+	[XATTRPROC3_SETXATTR] = {
+		.p_proc		= XATTRPROC3_SETXATTR,
+		.p_encode	= (kxdrproc_t) nfs3_xdr_setxattrargs,
+		.p_decode	= (kxdrproc_t) nfs3_xdr_setxattrres,
+		.p_arglen	= XATTR3_setxattrargs_sz,
+		.p_replen	= XATTR3_setxattrres_sz,
+		.p_timer	= 1,
+		.p_name		= "SETXATTR",
+	},
+	[XATTRPROC3_LISTXATTR] = {
+		.p_proc		= XATTRPROC3_LISTXATTR,
+		.p_encode	= (kxdrproc_t) nfs3_xdr_listxattrargs,
+		.p_decode	= (kxdrproc_t) nfs3_xdr_listxattrres,
+		.p_arglen	= XATTR3_listxattrargs_sz,
+		.p_replen	= XATTR3_listxattrres_sz,
+		.p_timer	= 1,
+		.p_name		= "LISTXATTR",
+	},
+};
+
+struct rpc_version		nfs_xattr_version3 = {
+	.number			= 3,
+	.nrprocs		= ARRAY_SIZE(nfs3_xattr_procedures),
+	.procs			= nfs3_xattr_procedures,
+};
+#endif	/* CONFIG_NFS_V3_XATTR */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 34fc6be..c881ac4 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -104,6 +104,7 @@ struct nfs_server {
 	struct list_head	master_link;	/* link in master servers list */
 	struct rpc_clnt *	client;		/* RPC client handle */
 	struct rpc_clnt *	client_acl;	/* ACL RPC client handle */
+	struct rpc_clnt *	client_xattr;	/* XATTR RPC client handle */
 	struct nlm_host		*nlm_host;	/* NLM client handle */
 	struct nfs_iostats *	io_stats;	/* I/O statistics */
 	struct backing_dev_info	backing_dev_info;
@@ -176,7 +177,7 @@ struct nfs_server {
 #define NFS_CAP_ATIME		(1U << 11)
 #define NFS_CAP_CTIME		(1U << 12)
 #define NFS_CAP_MTIME		(1U << 13)
-
+#define NFS_CAP_XATTR		(1U << 14)
 
 /* maximum number of slots to use */
 #define NFS4_MAX_SLOT_TABLE RPC_MAX_SLOT_TABLE
diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
index 4499016..04bb4ee 100644
--- a/include/linux/nfs_mount.h
+++ b/include/linux/nfs_mount.h
@@ -70,4 +70,7 @@ struct nfs_mount_data {
 #define NFS_MOUNT_LOOKUP_CACHE_NONE	0x20000
 #define NFS_MOUNT_NORESVPORT		0x40000
 
+/* FIXME: determine semantics and modify flagmask if exposed to userland */
+#define NFS_MOUNT_NOXATTR		0x80000
+
 #endif
diff --git a/include/linux/nfs_xattr.h b/include/linux/nfs_xattr.h
new file mode 100644
index 0000000..98fdbed
--- /dev/null
+++ b/include/linux/nfs_xattr.h
@@ -0,0 +1,21 @@
+/*
+ * Extended attribute protocol for NFSv3 (XATTR)
+ *
+ *
+ * Copyright (C) 2009 Red Hat, Inc., James Morris <jmorris@redhat.com>
+ *
+ */
+#ifndef __LINUX_NFS_XATTR_H
+#define __LINUX_NFS_XATTR_H
+
+#include <linux/xattr.h>
+
+#define NFS_XATTR_PROGRAM	391063	/* TODO: find another value */
+
+/* xattr procedure numbers */
+#define XATTRPROC3_GETXATTR	1
+#define XATTRPROC3_SETXATTR	2
+#define XATTRPROC3_LISTXATTR	3
+#define XATTRPROC3_RMXATTR	4
+
+#endif  /* __LINUX_NFS_XATTR_H */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 89b2881..5e79744 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -2,6 +2,7 @@
 #define _LINUX_NFS_XDR_H
 
 #include <linux/nfsacl.h>
+#include <linux/nfs_xattr.h>
 #include <linux/nfs3.h>
 
 /*
@@ -514,6 +515,27 @@ struct nfs3_setaclargs {
 	struct page **		pages;
 };
 
+struct nfs3_getxattrargs {
+	struct nfs_fh *		fh;
+	const char *		xattr_namespace;
+	const char *		xattr_name;
+	unsigned int		xattr_size_max;
+};
+
+struct nfs3_setxattrargs {
+	struct nfs_fh *		fh;
+	unsigned int		xattr_flags;
+	const char *		xattr_namespace;
+	const char *		xattr_name;
+	const char *		xattr_val;
+	int			xattr_val_len;
+};
+
+struct nfs3_listxattrargs {
+	struct nfs_fh *		fh;
+	unsigned int		xattr_list_max;
+};
+
 struct nfs_diropok {
 	struct nfs_fh *		fh;
 	struct nfs_fattr *	fattr;
@@ -646,6 +668,26 @@ struct nfs3_getaclres {
 	struct posix_acl *	acl_default;
 };
 
+struct nfs3_getxattrres {
+	struct nfs_fattr *	fattr;
+	char *			xattr_val;
+	int			xattr_val_len;
+};
+
+/*
+ * Note: if we don't add any more fields, we can get rid of this struct and
+ * just use fattr in the calling code.
+ */
+struct nfs3_setxattrres {
+	struct nfs_fattr *	fattr;
+};
+
+struct nfs3_listxattrres {
+	struct nfs_fattr *	fattr;
+	char *			xattr_list;
+	int			xattr_list_len;
+};
+
 #ifdef CONFIG_NFS_V4
 
 typedef u64 clientid4;
@@ -1074,4 +1116,7 @@ extern struct rpc_version	nfs_version4;
 extern struct rpc_version	nfsacl_version3;
 extern struct rpc_program	nfsacl_program;
 
+extern struct rpc_version	nfs_xattr_version3;
+extern struct rpc_program	nfs_xattr_program;
+
 #endif
-- 
1.6.3.3


-- 
James Morris
<jmorris@namei.org>
