From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 8/8] nfsv4: Implement setfacl
Date: Wed,  2 Sep 2009 17:54:28 +0530
Message-ID: <1251894268-1555-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org,
	nfsv4@linux-nfs.org, ffilzlnx@us.ibm.com, agruen@suse.de,
	aneesh.kumar@linux.vnet.ibm.com, sfrench@us.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([59.145.155.3]:33083 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbZIBMZU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 08:25:20 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp03.in.ibm.com (8.14.3/8.13.1) with ESMTP id n82CPKNx026657
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:55:20 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n82CPKcI2002982
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:55:20 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n82CPJ9Z002051
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 22:25:20 +1000
In-Reply-To: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/nfs/nfs4pacl.c |  140 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 138 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4pacl.c b/fs/nfs/nfs4pacl.c
index a13a833..1978739 100644
--- a/fs/nfs/nfs4pacl.c
+++ b/fs/nfs/nfs4pacl.c
@@ -110,6 +110,124 @@ getout:
 	return acl;
 }
 
+static int nfs4_proc_setacls(struct inode *inode, struct posix_acl *acl,
+		  struct posix_acl *dfacl)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct page *pages[NFSACL_MAXPAGES];
+	struct nfs4_setpaclargs args = {
+		.inode = inode,
+		.mask = NFS_ACL,
+		.acl_access = acl,
+		.pages = pages,
+	};
+	struct rpc_message msg = {
+		.rpc_argp	= &args,
+	};
+	int status;
+
+	status = -EOPNOTSUPP;
+	if (!nfs_server_capable(inode, NFS_CAP_PACLS))
+		goto out;
+
+	/* We are doing this here, because XDR marshalling can only
+	   return -ENOMEM. */
+	status = -ENOSPC;
+	if (acl != NULL && acl->a_count > NFS_ACL_MAX_ENTRIES)
+		goto out;
+	if (dfacl != NULL && dfacl->a_count > NFS_ACL_MAX_ENTRIES)
+		goto out;
+	if (S_ISDIR(inode->i_mode)) {
+		args.mask |= NFS_DFACL;
+		args.acl_default = dfacl;
+		args.len = nfsacl_size(acl, dfacl);
+	} else
+		args.len = nfsacl_size(acl, NULL);
+
+	if (args.len > NFS_ACL_INLINE_BUFSIZE) {
+		unsigned int npages = 1 + ((args.len - 1) >> PAGE_SHIFT);
+
+		status = -ENOMEM;
+		do {
+			args.pages[args.npages] = alloc_page(GFP_KERNEL);
+			if (args.pages[args.npages] == NULL)
+				goto out_freepages;
+			args.npages++;
+		} while (args.npages < npages);
+	}
+
+	dprintk("NFSV4 call setacl\n");
+	msg.rpc_proc = &server->client_acl->cl_procinfo[NFSPROC4_CLNT_SETPACL];
+	status = rpc_call_sync(server->client_acl, &msg, 0);
+	nfs_access_zap_cache(inode);
+	nfs_zap_acl_cache(inode);
+	dprintk("NFSv4 reply setacl: %d\n", status);
+
+	switch (status) {
+	case 0:
+		if (!IS_ERR(dfacl))
+			set_cached_acl(inode, ACL_TYPE_DEFAULT, dfacl);
+		if (!IS_ERR(acl))
+			set_cached_acl(inode, ACL_TYPE_ACCESS, acl);
+		break;
+	case -EPFNOSUPPORT:
+	case -EPROTONOSUPPORT:
+		dprintk("NFS_V4_PACL SETACL RPC not supported"
+				"(will not retry)\n");
+		server->caps &= ~NFS_CAP_PACLS;
+	case -ENOTSUPP:
+		status = -EOPNOTSUPP;
+	}
+out_freepages:
+	while (args.npages != 0) {
+		args.npages--;
+		__free_page(args.pages[args.npages]);
+	}
+out:
+	return status;
+}
+
+int nfs4_proc_setacl(struct inode *inode, int type, struct posix_acl *acl)
+{
+	int status;
+	struct posix_acl *alloc = NULL, *dfacl = NULL;
+
+	if (S_ISDIR(inode->i_mode)) {
+		switch (type) {
+		case ACL_TYPE_ACCESS:
+			alloc = dfacl = nfs4_proc_getacl(inode,
+						ACL_TYPE_DEFAULT);
+			if (IS_ERR(alloc))
+				goto fail;
+			break;
+
+		case ACL_TYPE_DEFAULT:
+			dfacl = acl;
+			alloc = acl = nfs4_proc_getacl(inode,
+						ACL_TYPE_ACCESS);
+			if (IS_ERR(alloc))
+				goto fail;
+			break;
+
+		default:
+			return -EINVAL;
+		}
+	} else if (type != ACL_TYPE_ACCESS)
+			return -EINVAL;
+
+	if (acl == NULL) {
+		alloc = acl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
+		if (IS_ERR(alloc))
+			goto fail;
+	}
+	status = nfs4_proc_setacls(inode, acl, dfacl);
+	posix_acl_release(alloc);
+	return status;
+
+fail:
+	return PTR_ERR(alloc);
+}
+
 static size_t nfs4_xattr_list_pacl_default(struct inode *inode, char *list,
 				size_t list_len, const char *name,
 				size_t name_len)
@@ -159,7 +277,16 @@ static int nfs4_xattr_get_pacl_default(struct inode *inode, const char *key,
 static int nfs4_xattr_set_pacl_default(struct inode *inode, const char *key,
 			const void *buf, size_t buflen, int flags)
 {
-	return -EOPNOTSUPP;
+	int error;
+	struct posix_acl *acl;
+
+	acl = posix_acl_from_xattr(buf, buflen);
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
+	error = nfs4_proc_setacl(inode, ACL_TYPE_DEFAULT, acl);
+	posix_acl_release(acl);
+
+	return error;
 }
 
 struct xattr_handler nfs4_xattr_pacl_default_handler = {
@@ -212,7 +339,16 @@ static int nfs4_xattr_get_pacl_access(struct inode *inode, const char *key,
 static int nfs4_xattr_set_pacl_access(struct inode *inode, const char *key,
 			const void *buf, size_t buflen, int flags)
 {
-	return -EOPNOTSUPP;
+	int error;
+	struct posix_acl *acl;
+
+	acl = posix_acl_from_xattr(buf, buflen);
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
+	error = nfs4_proc_setacl(inode, ACL_TYPE_ACCESS, acl);
+	posix_acl_release(acl);
+
+	return error;
 }
 
 
-- 
1.6.4.2.253.g0b1fac

