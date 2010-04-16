From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 19/24] NFS: Reduce the stack footprint of nfs_proc_symlink()
Date: Fri, 16 Apr 2010 16:31:17 -0400
Message-ID: <1271449882-8580-20-git-send-email-Trond.Myklebust@netapp.com>
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
 <1271449882-8580-19-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9553 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932416Ab0DPUbf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:35 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMlE026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:34 -0700 (PDT)
In-Reply-To: <1271449882-8580-19-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/proc.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index aa61f2c..611bec2 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -418,8 +418,8 @@ static int
 nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct page *page,
 		 unsigned int len, struct iattr *sattr)
 {
-	struct nfs_fh fhandle;
-	struct nfs_fattr fattr;
+	struct nfs_fh *fh;
+	struct nfs_fattr *fattr;
 	struct nfs_symlinkargs	arg = {
 		.fromfh		= NFS_FH(dir),
 		.fromname	= dentry->d_name.name,
@@ -432,12 +432,18 @@ nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct page *page,
 		.rpc_proc	= &nfs_procedures[NFSPROC_SYMLINK],
 		.rpc_argp	= &arg,
 	};
-	int			status;
+	int status = -ENAMETOOLONG;
+
+	dprintk("NFS call  symlink %s\n", dentry->d_name.name);
 
 	if (len > NFS2_MAXPATHLEN)
-		return -ENAMETOOLONG;
+		goto out;
 
-	dprintk("NFS call  symlink %s\n", dentry->d_name.name);
+	fh = nfs_alloc_fhandle();
+	fattr = nfs_alloc_fattr();
+	status = -ENOMEM;
+	if (fh == NULL || fattr == NULL)
+		goto out;
 
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
@@ -447,12 +453,12 @@ nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct page *page,
 	 * filehandle size to zero indicates to nfs_instantiate that it
 	 * should fill in the data with a LOOKUP call on the wire.
 	 */
-	if (status == 0) {
-		nfs_fattr_init(&fattr);
-		fhandle.size = 0;
-		status = nfs_instantiate(dentry, &fhandle, &fattr);
-	}
+	if (status == 0)
+		status = nfs_instantiate(dentry, fh, fattr);
 
+	nfs_free_fattr(fattr);
+	nfs_free_fhandle(fh);
+out:
 	dprintk("NFS reply symlink: %d\n", status);
 	return status;
 }
-- 
1.6.6.1

