From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 17/24] NFS: Reduce the stack footprint of nfs_rmdir
Date: Fri, 16 Apr 2010 16:31:15 -0400
Message-ID: <1271449882-8580-18-git-send-email-Trond.Myklebust@netapp.com>
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
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13850 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932478Ab0DPUbd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:33 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMlC026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:33 -0700 (PDT)
In-Reply-To: <1271449882-8580-17-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs3proc.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 80378d1..fabb4f2 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -574,7 +574,7 @@ out:
 static int
 nfs3_proc_rmdir(struct inode *dir, struct qstr *name)
 {
-	struct nfs_fattr	dir_attr;
+	struct nfs_fattr	*dir_attr;
 	struct nfs3_diropargs	arg = {
 		.fh		= NFS_FH(dir),
 		.name		= name->name,
@@ -583,14 +583,19 @@ nfs3_proc_rmdir(struct inode *dir, struct qstr *name)
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_RMDIR],
 		.rpc_argp	= &arg,
-		.rpc_resp	= &dir_attr,
 	};
-	int			status;
+	int status = -ENOMEM;
 
 	dprintk("NFS call  rmdir %s\n", name->name);
-	nfs_fattr_init(&dir_attr);
+	dir_attr = nfs_alloc_fattr();
+	if (dir_attr == NULL)
+		goto out;
+
+	msg.rpc_resp = dir_attr;
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
-	nfs_post_op_update_inode(dir, &dir_attr);
+	nfs_post_op_update_inode(dir, dir_attr);
+	nfs_free_fattr(dir_attr);
+out:
 	dprintk("NFS reply rmdir: %d\n", status);
 	return status;
 }
-- 
1.6.6.1

