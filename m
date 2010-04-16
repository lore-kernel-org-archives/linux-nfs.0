From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/24] NFS: Reduce the stack footprint of nfs_lookup
Date: Fri, 16 Apr 2010 16:31:04 -0400
Message-ID: <1271449882-8580-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-6-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932462Ab0DPUb1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:27 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMl1026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:26 -0700 (PDT)
In-Reply-To: <1271449882-8580-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c      |   45 +++++++++++++++++++++++++++++++++++----------
 fs/nfs/nfs3proc.c |   10 ++++++----
 2 files changed, 41 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index be46f26..4da45ab 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -776,9 +776,9 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 	struct inode *dir;
 	struct inode *inode;
 	struct dentry *parent;
+	struct nfs_fh *fhandle = NULL;
+	struct nfs_fattr *fattr = NULL;
 	int error;
-	struct nfs_fh fhandle;
-	struct nfs_fattr fattr;
 
 	parent = dget_parent(dentry);
 	dir = parent->d_inode;
@@ -811,14 +811,22 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 	if (NFS_STALE(inode))
 		goto out_bad;
 
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
+	error = -ENOMEM;
+	fhandle = nfs_alloc_fhandle();
+	fattr = nfs_alloc_fattr();
+	if (fhandle == NULL || fattr == NULL)
+		goto out_error;
+
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
 	if (error)
 		goto out_bad;
-	if (nfs_compare_fh(NFS_FH(inode), &fhandle))
+	if (nfs_compare_fh(NFS_FH(inode), fhandle))
 		goto out_bad;
-	if ((error = nfs_refresh_inode(inode, &fattr)) != 0)
+	if ((error = nfs_refresh_inode(inode, fattr)) != 0)
 		goto out_bad;
 
+	nfs_free_fattr(fattr);
+	nfs_free_fhandle(fhandle);
 out_set_verifier:
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
  out_valid:
@@ -840,11 +848,21 @@ out_zap_parent:
 		shrink_dcache_parent(dentry);
 	}
 	d_drop(dentry);
+	nfs_free_fattr(fattr);
+	nfs_free_fhandle(fhandle);
 	dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%s/%s) is invalid\n",
 			__func__, dentry->d_parent->d_name.name,
 			dentry->d_name.name);
 	return 0;
+out_error:
+	nfs_free_fattr(fattr);
+	nfs_free_fhandle(fhandle);
+	dput(parent);
+	dfprintk(LOOKUPCACHE, "NFS: %s(%s/%s) lookup returned error %d\n",
+			__func__, dentry->d_parent->d_name.name,
+			dentry->d_name.name, error);
+	return error;
 }
 
 /*
@@ -909,9 +927,9 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 	struct dentry *res;
 	struct dentry *parent;
 	struct inode *inode = NULL;
+	struct nfs_fh *fhandle = NULL;
+	struct nfs_fattr *fattr = NULL;
 	int error;
-	struct nfs_fh fhandle;
-	struct nfs_fattr fattr;
 
 	dfprintk(VFS, "NFS: lookup(%s/%s)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name);
@@ -921,7 +939,6 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 	if (dentry->d_name.len > NFS_SERVER(dir)->namelen)
 		goto out;
 
-	res = ERR_PTR(-ENOMEM);
 	dentry->d_op = NFS_PROTO(dir)->dentry_ops;
 
 	/*
@@ -934,17 +951,23 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 		goto out;
 	}
 
+	res = ERR_PTR(-ENOMEM);
+	fhandle = nfs_alloc_fhandle();
+	fattr = nfs_alloc_fattr();
+	if (fhandle == NULL || fattr == NULL)
+		goto out;
+
 	parent = dentry->d_parent;
 	/* Protect against concurrent sillydeletes */
 	nfs_block_sillyrename(parent);
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
 	if (error == -ENOENT)
 		goto no_entry;
 	if (error < 0) {
 		res = ERR_PTR(error);
 		goto out_unblock_sillyrename;
 	}
-	inode = nfs_fhget(dentry->d_sb, &fhandle, &fattr);
+	inode = nfs_fhget(dentry->d_sb, fhandle, fattr);
 	res = (struct dentry *)inode;
 	if (IS_ERR(res))
 		goto out_unblock_sillyrename;
@@ -960,6 +983,8 @@ no_entry:
 out_unblock_sillyrename:
 	nfs_unblock_sillyrename(parent);
 out:
+	nfs_free_fattr(fattr);
+	nfs_free_fhandle(fhandle);
 	return res;
 }
 
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index e701002..72334c1 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -144,14 +144,12 @@ static int
 nfs3_proc_lookup(struct inode *dir, struct qstr *name,
 		 struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
-	struct nfs_fattr	dir_attr;
 	struct nfs3_diropargs	arg = {
 		.fh		= NFS_FH(dir),
 		.name		= name->name,
 		.len		= name->len
 	};
 	struct nfs3_diropres	res = {
-		.dir_attr	= &dir_attr,
 		.fh		= fhandle,
 		.fattr		= fattr
 	};
@@ -163,16 +161,20 @@ nfs3_proc_lookup(struct inode *dir, struct qstr *name,
 	int			status;
 
 	dprintk("NFS call  lookup %s\n", name->name);
-	nfs_fattr_init(&dir_attr);
+	res.dir_attr = nfs_alloc_fattr();
+	if (res.dir_attr == NULL)
+		return -ENOMEM;
+
 	nfs_fattr_init(fattr);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
-	nfs_refresh_inode(dir, &dir_attr);
+	nfs_refresh_inode(dir, res.dir_attr);
 	if (status >= 0 && !(fattr->valid & NFS_ATTR_FATTR)) {
 		msg.rpc_proc = &nfs3_procedures[NFS3PROC_GETATTR];
 		msg.rpc_argp = fhandle;
 		msg.rpc_resp = fattr;
 		status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	}
+	nfs_free_fattr(res.dir_attr);
 	dprintk("NFS reply lookup: %d\n", status);
 	return status;
 }
-- 
1.6.6.1

