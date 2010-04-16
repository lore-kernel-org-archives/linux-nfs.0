From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 13/24] NFS: Reduce stack footprint of nfs_readdir()
Date: Fri, 16 Apr 2010 16:31:11 -0400
Message-ID: <1271449882-8580-14-git-send-email-Trond.Myklebust@netapp.com>
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
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932442Ab0DPUbb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:31 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMl8026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:30 -0700 (PDT)
In-Reply-To: <1271449882-8580-13-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c      |   17 ++++++++++-------
 fs/nfs/nfs3proc.c |   13 ++++++++-----
 2 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4da45ab..dd94f83 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -530,9 +530,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	nfs_readdir_descriptor_t my_desc,
 			*desc = &my_desc;
 	struct nfs_entry my_entry;
-	struct nfs_fh	 fh;
-	struct nfs_fattr fattr;
-	long		res;
+	int res = -ENOMEM;
 
 	dfprintk(FILE, "NFS: readdir(%s/%s) starting at cookie %llu\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
@@ -554,9 +552,11 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 
 	my_entry.cookie = my_entry.prev_cookie = 0;
 	my_entry.eof = 0;
-	my_entry.fh = &fh;
-	my_entry.fattr = &fattr;
-	nfs_fattr_init(&fattr);
+	my_entry.fh = nfs_alloc_fhandle();
+	my_entry.fattr = nfs_alloc_fattr();
+	if (my_entry.fh == NULL || my_entry.fattr == NULL)
+		goto out_alloc_failed;
+
 	desc->entry = &my_entry;
 
 	nfs_block_sillyrename(dentry);
@@ -598,7 +598,10 @@ out:
 	nfs_unblock_sillyrename(dentry);
 	if (res > 0)
 		res = 0;
-	dfprintk(FILE, "NFS: readdir(%s/%s) returns %ld\n",
+out_alloc_failed:
+	nfs_free_fattr(my_entry.fattr);
+	nfs_free_fhandle(my_entry.fh);
+	dfprintk(FILE, "NFS: readdir(%s/%s) returns %d\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			res);
 	return res;
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index c252fc9..1c5bfb3 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -597,7 +597,6 @@ nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		  u64 cookie, struct page *page, unsigned int count, int plus)
 {
 	struct inode		*dir = dentry->d_inode;
-	struct nfs_fattr	dir_attr;
 	__be32			*verf = NFS_COOKIEVERF(dir);
 	struct nfs3_readdirargs	arg = {
 		.fh		= NFS_FH(dir),
@@ -608,7 +607,6 @@ nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		.pages		= &page
 	};
 	struct nfs3_readdirres	res = {
-		.dir_attr	= &dir_attr,
 		.verf		= verf,
 		.plus		= plus
 	};
@@ -618,7 +616,7 @@ nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		.rpc_resp	= &res,
 		.rpc_cred	= cred
 	};
-	int			status;
+	int status = -ENOMEM;
 
 	if (plus)
 		msg.rpc_proc = &nfs3_procedures[NFS3PROC_READDIRPLUS];
@@ -626,12 +624,17 @@ nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 	dprintk("NFS call  readdir%s %d\n",
 			plus? "plus" : "", (unsigned int) cookie);
 
-	nfs_fattr_init(&dir_attr);
+	res.dir_attr = nfs_alloc_fattr();
+	if (res.dir_attr == NULL)
+		goto out;
+
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 
 	nfs_invalidate_atime(dir);
+	nfs_refresh_inode(dir, res.dir_attr);
 
-	nfs_refresh_inode(dir, &dir_attr);
+	nfs_free_fattr(res.dir_attr);
+out:
 	dprintk("NFS reply readdir: %d\n", status);
 	return status;
 }
-- 
1.6.6.1

