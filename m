From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 12/24] NFS: Reduce stack footprint of nfs3_proc_rename() and nfs4_proc_rename()
Date: Fri, 16 Apr 2010 16:31:10 -0400
Message-ID: <1271449882-8580-13-git-send-email-Trond.Myklebust@netapp.com>
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
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932415Ab0DPUba (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:30 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMl7026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:30 -0700 (PDT)
In-Reply-To: <1271449882-8580-12-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs3proc.c |   23 +++++++++++++----------
 fs/nfs/nfs4proc.c |   16 +++++++++-------
 2 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 9d5d02f..c252fc9 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -432,7 +432,6 @@ static int
 nfs3_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		 struct inode *new_dir, struct qstr *new_name)
 {
-	struct nfs_fattr	old_dir_attr, new_dir_attr;
 	struct nfs3_renameargs	arg = {
 		.fromfh		= NFS_FH(old_dir),
 		.fromname	= old_name->name,
@@ -441,23 +440,27 @@ nfs3_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		.toname		= new_name->name,
 		.tolen		= new_name->len
 	};
-	struct nfs3_renameres	res = {
-		.fromattr	= &old_dir_attr,
-		.toattr		= &new_dir_attr
-	};
+	struct nfs3_renameres res;
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_RENAME],
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
 	};
-	int			status;
+	int status = -ENOMEM;
 
 	dprintk("NFS call  rename %s -> %s\n", old_name->name, new_name->name);
-	nfs_fattr_init(&old_dir_attr);
-	nfs_fattr_init(&new_dir_attr);
+
+	res.fromattr = nfs_alloc_fattr();
+	res.toattr = nfs_alloc_fattr();
+	if (res.fromattr == NULL || res.toattr == NULL)
+		goto out;
+
 	status = rpc_call_sync(NFS_CLIENT(old_dir), &msg, 0);
-	nfs_post_op_update_inode(old_dir, &old_dir_attr);
-	nfs_post_op_update_inode(new_dir, &new_dir_attr);
+	nfs_post_op_update_inode(old_dir, res.fromattr);
+	nfs_post_op_update_inode(new_dir, res.toattr);
+out:
+	nfs_free_fattr(res.toattr);
+	nfs_free_fattr(res.fromattr);
 	dprintk("NFS reply rename: %d\n", status);
 	return status;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3acce87..e027fdb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2656,29 +2656,31 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		.new_name = new_name,
 		.bitmask = server->attr_bitmask,
 	};
-	struct nfs_fattr old_fattr, new_fattr;
 	struct nfs4_rename_res res = {
 		.server = server,
-		.old_fattr = &old_fattr,
-		.new_fattr = &new_fattr,
 	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME],
 		.rpc_argp = &arg,
 		.rpc_resp = &res,
 	};
-	int			status;
+	int status = -ENOMEM;
 	
-	nfs_fattr_init(res.old_fattr);
-	nfs_fattr_init(res.new_fattr);
-	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
+	res.old_fattr = nfs_alloc_fattr();
+	res.new_fattr = nfs_alloc_fattr();
+	if (res.old_fattr == NULL || res.new_fattr == NULL)
+		goto out;
 
+	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
 	if (!status) {
 		update_changeattr(old_dir, &res.old_cinfo);
 		nfs_post_op_update_inode(old_dir, res.old_fattr);
 		update_changeattr(new_dir, &res.new_cinfo);
 		nfs_post_op_update_inode(new_dir, res.new_fattr);
 	}
+out:
+	nfs_free_fattr(res.new_fattr);
+	nfs_free_fattr(res.old_fattr);
 	return status;
 }
 
-- 
1.6.6.1

