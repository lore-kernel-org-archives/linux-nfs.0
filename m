From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 18/24] NFS: Reduce the stack footprint of nfs_proc_create
Date: Fri, 16 Apr 2010 16:31:16 -0400
Message-ID: <1271449882-8580-19-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-9-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-10-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-11-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-12-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-13-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-14-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-15-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-16-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-17-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-18-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13850 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932442Ab0DPUbe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:34 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMlD026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:33 -0700 (PDT)
In-Reply-To: <1271449882-8580-18-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/proc.c |  118 ++++++++++++++++++++++++++++++++-------------------------
 1 files changed, 66 insertions(+), 52 deletions(-)

diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 0288be8..aa61f2c 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -224,35 +224,60 @@ static int nfs_proc_readlink(struct inode *inode, struct page *page,
 	return status;
 }
 
+struct nfs_createdata {
+	struct nfs_createargs arg;
+	struct nfs_diropok res;
+	struct nfs_fh fhandle;
+	struct nfs_fattr fattr;
+};
+
+static struct nfs_createdata *nfs_alloc_createdata(struct inode *dir,
+		struct dentry *dentry, struct iattr *sattr)
+{
+	struct nfs_createdata *data;
+
+	data = kmalloc(sizeof(*data), GFP_KERNEL);
+
+	if (data != NULL) {
+		data->arg.fh = NFS_FH(dir);
+		data->arg.name = dentry->d_name.name;
+		data->arg.len = dentry->d_name.len;
+		data->arg.sattr = sattr;
+		nfs_fattr_init(&data->fattr);
+		data->fhandle.size = 0;
+		data->res.fh = &data->fhandle;
+		data->res.fattr = &data->fattr;
+	}
+	return data;
+};
+
+static void nfs_free_createdata(const struct nfs_createdata *data)
+{
+	kfree(data);
+}
+
 static int
 nfs_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		int flags, struct nameidata *nd)
 {
-	struct nfs_fh		fhandle;
-	struct nfs_fattr	fattr;
-	struct nfs_createargs	arg = {
-		.fh		= NFS_FH(dir),
-		.name		= dentry->d_name.name,
-		.len		= dentry->d_name.len,
-		.sattr		= sattr
-	};
-	struct nfs_diropok	res = {
-		.fh		= &fhandle,
-		.fattr		= &fattr
-	};
+	struct nfs_createdata *data;
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs_procedures[NFSPROC_CREATE],
-		.rpc_argp	= &arg,
-		.rpc_resp	= &res,
 	};
-	int			status;
+	int status = -ENOMEM;
 
-	nfs_fattr_init(&fattr);
 	dprintk("NFS call  create %s\n", dentry->d_name.name);
+	data = nfs_alloc_createdata(dir, dentry, sattr);
+	if (data == NULL)
+		goto out;
+	msg.rpc_argp = &data->arg;
+	msg.rpc_resp = &data->res;
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
 	if (status == 0)
-		status = nfs_instantiate(dentry, &fhandle, &fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+	nfs_free_createdata(data);
+out:
 	dprintk("NFS reply create: %d\n", status);
 	return status;
 }
@@ -264,24 +289,12 @@ static int
 nfs_proc_mknod(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	       dev_t rdev)
 {
-	struct nfs_fh fhandle;
-	struct nfs_fattr fattr;
-	struct nfs_createargs	arg = {
-		.fh		= NFS_FH(dir),
-		.name		= dentry->d_name.name,
-		.len		= dentry->d_name.len,
-		.sattr		= sattr
-	};
-	struct nfs_diropok	res = {
-		.fh		= &fhandle,
-		.fattr		= &fattr
-	};
+	struct nfs_createdata *data;
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs_procedures[NFSPROC_CREATE],
-		.rpc_argp	= &arg,
-		.rpc_resp	= &res,
 	};
-	int status, mode;
+	umode_t mode;
+	int status = -ENOMEM;
 
 	dprintk("NFS call  mknod %s\n", dentry->d_name.name);
 
@@ -294,17 +307,24 @@ nfs_proc_mknod(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		sattr->ia_size = new_encode_dev(rdev);/* get out your barf bag */
 	}
 
-	nfs_fattr_init(&fattr);
+	data = nfs_alloc_createdata(dir, dentry, sattr);
+	if (data == NULL)
+		goto out;
+	msg.rpc_argp = &data->arg;
+	msg.rpc_resp = &data->res;
+
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
 
 	if (status == -EINVAL && S_ISFIFO(mode)) {
 		sattr->ia_mode = mode;
-		nfs_fattr_init(&fattr);
+		nfs_fattr_init(data->res.fattr);
 		status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	}
 	if (status == 0)
-		status = nfs_instantiate(dentry, &fhandle, &fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+	nfs_free_createdata(data);
+out:
 	dprintk("NFS reply mknod: %d\n", status);
 	return status;
 }
@@ -440,31 +460,25 @@ nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct page *page,
 static int
 nfs_proc_mkdir(struct inode *dir, struct dentry *dentry, struct iattr *sattr)
 {
-	struct nfs_fh fhandle;
-	struct nfs_fattr fattr;
-	struct nfs_createargs	arg = {
-		.fh		= NFS_FH(dir),
-		.name		= dentry->d_name.name,
-		.len		= dentry->d_name.len,
-		.sattr		= sattr
-	};
-	struct nfs_diropok	res = {
-		.fh		= &fhandle,
-		.fattr		= &fattr
-	};
+	struct nfs_createdata *data;
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs_procedures[NFSPROC_MKDIR],
-		.rpc_argp	= &arg,
-		.rpc_resp	= &res,
 	};
-	int			status;
+	int status = -ENOMEM;
 
 	dprintk("NFS call  mkdir %s\n", dentry->d_name.name);
-	nfs_fattr_init(&fattr);
+	data = nfs_alloc_createdata(dir, dentry, sattr);
+	if (data == NULL)
+		goto out;
+	msg.rpc_argp = &data->arg;
+	msg.rpc_resp = &data->res;
+
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
 	if (status == 0)
-		status = nfs_instantiate(dentry, &fhandle, &fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+	nfs_free_createdata(data);
+out:
 	dprintk("NFS reply mkdir: %d\n", status);
 	return status;
 }
-- 
1.6.6.1

