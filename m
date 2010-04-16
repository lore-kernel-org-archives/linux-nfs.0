From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 22/24] NFS: Reduce stack footprint of nfs_statfs()
Date: Fri, 16 Apr 2010 16:31:20 -0400
Message-ID: <1271449882-8580-23-git-send-email-Trond.Myklebust@netapp.com>
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
 <1271449882-8580-20-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-21-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-22-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16405 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932478Ab0DPUbh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:37 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMlH026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:36 -0700 (PDT)
In-Reply-To: <1271449882-8580-22-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 3e9047f..cb196eb 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -423,15 +423,19 @@ static int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	unsigned char blockbits;
 	unsigned long blockres;
 	struct nfs_fh *fh = NFS_FH(dentry->d_inode);
-	struct nfs_fattr fattr;
-	struct nfs_fsstat res = {
-			.fattr = &fattr,
-	};
-	int error;
+	struct nfs_fsstat res;
+	int error = -ENOMEM;
+
+	res.fattr = nfs_alloc_fattr();
+	if (res.fattr == NULL)
+		goto out_err;
 
 	error = server->nfs_client->rpc_ops->statfs(server, fh, &res);
+
+	nfs_free_fattr(res.fattr);
 	if (error < 0)
 		goto out_err;
+
 	buf->f_type = NFS_SUPER_MAGIC;
 
 	/*
-- 
1.6.6.1

