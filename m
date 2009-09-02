From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 6/8] nfsv4: Implement posix listxattr
Date: Wed,  2 Sep 2009 17:54:26 +0530
Message-ID: <1251894268-1555-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org,
	nfsv4@linux-nfs.org, ffilzlnx@us.ibm.com, agruen@suse.de,
	aneesh.kumar@linux.vnet.ibm.com, sfrench@us.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([59.145.155.7]:49801 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbZIBMZO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 08:25:14 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id n82CPDoY001872
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:55:13 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n82CPD9R1191998
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:55:13 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n82CPBoZ001776
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 22:25:12 +1000
In-Reply-To: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/nfs/nfs4pacl.c |  141 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4proc.c |    4 ++
 2 files changed, 142 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4pacl.c b/fs/nfs/nfs4pacl.c
index c1c2b04..162f4c5 100644
--- a/fs/nfs/nfs4pacl.c
+++ b/fs/nfs/nfs4pacl.c
@@ -7,12 +7,132 @@
 #include <linux/xattr.h>
 
 #include "internal.h"
+#define NFSDBG_FACILITY	NFSDBG_PROC
+
+struct posix_acl *nfs4_proc_getacl(struct inode *inode, int type)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs4_getpaclres res;
+	struct page *pages[NFSACL_MAXPAGES] = { };
+	struct nfs4_getpaclargs args = {
+		.fh = NFS_FH(inode),
+		/* The xdr layer may allocate pages here. */
+		.pages = pages,
+	};
+	struct rpc_message msg = {
+		.rpc_argp	= &args,
+		.rpc_resp	= &res,
+	};
+	struct posix_acl *acl;
+	int status, count;
+
+	memset(&res, 0, sizeof(struct nfs4_getpaclres));
+	if (!nfs_server_capable(inode, NFS_CAP_PACLS))
+		return ERR_PTR(-EOPNOTSUPP);
+
+	status = nfs_revalidate_inode(server, inode);
+	if (status < 0)
+		return ERR_PTR(status);
+	acl  = get_cached_acl(inode, type);
+	if (acl != ACL_NOT_CACHED)
+		return acl;
+	acl = NULL;
+
+	/*
+	 * Only get the access acl when explicitly requested: We don't
+	 * need it for access decisions, and only some applications use
+	 * it. Applications which request the access acl first are not
+	 * penalized from this optimization.
+	 */
+	if (type == ACL_TYPE_ACCESS)
+		args.mask |= NFS_ACLCNT|NFS_ACL;
+	if (S_ISDIR(inode->i_mode))
+		args.mask |= NFS_DFACLCNT|NFS_DFACL;
+	if (args.mask == 0)
+		return NULL;
+
+	dprintk("NFS4 call getacl\n");
+	msg.rpc_proc = &server->client_acl->cl_procinfo[NFSPROC4_CLNT_GETPACL];
+	status = rpc_call_sync(server->client_acl, &msg, 0);
+	dprintk("NFS4 reply getacl: %d\n", status);
+
+	/* pages may have been allocated at the xdr layer. */
+	for (count = 0; count < NFSACL_MAXPAGES && args.pages[count]; count++)
+		__free_page(args.pages[count]);
+
+	switch (status) {
+	case 0:
+		break;
+	case -EPFNOSUPPORT:
+	case -EPROTONOSUPPORT:
+		dprintk("NFS_V4_PACL extension not supported; disabling\n");
+		server->caps &= ~NFS_CAP_PACLS;
+	case -ENOTSUPP:
+		status = -EOPNOTSUPP;
+	default:
+		goto getout;
+	}
+	if ((args.mask & res.mask) != args.mask) {
+		status = -EIO;
+		goto getout;
+	}
+
+	if (res.acl_access != NULL) {
+		if (posix_acl_equiv_mode(res.acl_access, NULL) == 0) {
+			posix_acl_release(res.acl_access);
+			res.acl_access = NULL;
+		}
+	}
+	if (res.mask & NFS_ACL)
+		set_cached_acl(inode, type, res.acl_access);
+	if (res.mask & NFS_DFACL)
+		set_cached_acl(inode, type, res.acl_default);
+
+	switch (type) {
+	case ACL_TYPE_ACCESS:
+		acl = res.acl_access;
+		res.acl_access = NULL;
+		break;
+
+	case ACL_TYPE_DEFAULT:
+		acl = res.acl_default;
+		res.acl_default = NULL;
+	}
+
+getout:
+	posix_acl_release(res.acl_access);
+	posix_acl_release(res.acl_default);
+
+	if (status != 0) {
+		posix_acl_release(acl);
+		acl = ERR_PTR(status);
+	}
+	return acl;
+}
 
 static size_t nfs4_xattr_list_pacl_default(struct inode *inode, char *list,
 				size_t list_len, const char *name,
 				size_t name_len)
 {
-	return 0;
+	int ret = 0;
+	struct posix_acl *acl;
+	size_t len = strlen(POSIX_ACL_XATTR_DEFAULT) + 1;
+
+	if (S_ISDIR(inode->i_mode)) {
+		acl = nfs4_proc_getacl(inode, ACL_TYPE_DEFAULT);
+		if (IS_ERR(acl))
+			return PTR_ERR(acl);
+		if (acl) {
+			if (list && len <= list_len) {
+				memcpy(list, POSIX_ACL_XATTR_DEFAULT, len);
+				ret = len;
+			} else
+				ret = -ERANGE;
+			posix_acl_release(acl);
+		}
+		return ret;
+	}
+	return ret;
 }
 
 static int nfs4_xattr_get_pacl_default(struct inode *inode, const char *key,
@@ -35,10 +155,25 @@ struct xattr_handler nfs4_xattr_pacl_default_handler = {
 };
 
 static size_t nfs4_xattr_list_pacl_access(struct inode *inode, char *list,
-				size_t list_len, const char *name,
+					size_t list_len, const char *name,
 				size_t name_len)
 {
-	return 0;
+	int ret = 0;
+	struct posix_acl *acl;
+	size_t len = strlen(POSIX_ACL_XATTR_ACCESS) + 1;
+
+	acl = nfs4_proc_getacl(inode, ACL_TYPE_ACCESS);
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
+	if (acl) {
+		if (list && len <= list_len) {
+			memcpy(list, POSIX_ACL_XATTR_ACCESS, len);
+			ret = len;
+		} else
+			ret = -ERANGE;
+		posix_acl_release(acl);
+	}
+	return ret;
 }
 
 static int nfs4_xattr_get_pacl_access(struct inode *inode, const char *key,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2c71885..b2e8fe4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3120,6 +3120,10 @@ static void nfs4_set_cached_acl(struct inode *inode, struct nfs4_cached_acl *acl
 static void nfs4_zap_acl_attr(struct inode *inode)
 {
 	nfs4_set_cached_acl(inode, NULL);
+#ifdef CONFIG_NFS4_FS_POSIX_ACL
+	forget_cached_acl(inode, ACL_TYPE_DEFAULT);
+	forget_cached_acl(inode, ACL_TYPE_ACCESS);
+#endif
 }
 
 static inline ssize_t nfs4_read_cached_acl(struct inode *inode, char *buf, size_t buflen)
-- 
1.6.4.2.253.g0b1fac

