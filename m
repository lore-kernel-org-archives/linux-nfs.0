From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 14/24] NFS: Reduce the stack footprint of nfs_link()
Date: Fri, 16 Apr 2010 16:31:12 -0400
Message-ID: <1271449882-8580-15-git-send-email-Trond.Myklebust@netapp.com>
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
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3308 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932416Ab0DPUbc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:32 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMl9026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:31 -0700 (PDT)
In-Reply-To: <1271449882-8580-14-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs3proc.c |   22 ++++++++++++----------
 fs/nfs/nfs4proc.c |   16 +++++++++-------
 2 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 1c5bfb3..982a81b 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -468,30 +468,32 @@ out:
 static int
 nfs3_proc_link(struct inode *inode, struct inode *dir, struct qstr *name)
 {
-	struct nfs_fattr	dir_attr, fattr;
 	struct nfs3_linkargs	arg = {
 		.fromfh		= NFS_FH(inode),
 		.tofh		= NFS_FH(dir),
 		.toname		= name->name,
 		.tolen		= name->len
 	};
-	struct nfs3_linkres	res = {
-		.dir_attr	= &dir_attr,
-		.fattr		= &fattr
-	};
+	struct nfs3_linkres	res;
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_LINK],
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
 	};
-	int			status;
+	int status = -ENOMEM;
 
 	dprintk("NFS call  link %s\n", name->name);
-	nfs_fattr_init(&dir_attr);
-	nfs_fattr_init(&fattr);
+	res.fattr = nfs_alloc_fattr();
+	res.dir_attr = nfs_alloc_fattr();
+	if (res.fattr == NULL || res.dir_attr == NULL)
+		goto out;
+
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
-	nfs_post_op_update_inode(dir, &dir_attr);
-	nfs_post_op_update_inode(inode, &fattr);
+	nfs_post_op_update_inode(dir, res.dir_attr);
+	nfs_post_op_update_inode(inode, res.fattr);
+out:
+	nfs_free_fattr(res.dir_attr);
+	nfs_free_fattr(res.fattr);
 	dprintk("NFS reply link: %d\n", status);
 	return status;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e027fdb..345b6f9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2707,28 +2707,30 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 		.name   = name,
 		.bitmask = server->attr_bitmask,
 	};
-	struct nfs_fattr fattr, dir_attr;
 	struct nfs4_link_res res = {
 		.server = server,
-		.fattr = &fattr,
-		.dir_attr = &dir_attr,
 	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LINK],
 		.rpc_argp = &arg,
 		.rpc_resp = &res,
 	};
-	int			status;
+	int status = -ENOMEM;
+
+	res.fattr = nfs_alloc_fattr();
+	res.dir_attr = nfs_alloc_fattr();
+	if (res.fattr == NULL || res.dir_attr == NULL)
+		goto out;
 
-	nfs_fattr_init(res.fattr);
-	nfs_fattr_init(res.dir_attr);
 	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, res.dir_attr);
 		nfs_post_op_update_inode(inode, res.fattr);
 	}
-
+out:
+	nfs_free_fattr(res.dir_attr);
+	nfs_free_fattr(res.fattr);
 	return status;
 }
 
-- 
1.6.6.1

