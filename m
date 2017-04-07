Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:42319 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933181AbdDGSQC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:16:02 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 26/34] NFS: Remove extra dprintk()s from nfs4namespace.c
Date: Fri, 7 Apr 2017 14:15:20 -0400
Message-ID: <20170407181528.2832-27-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4namespace.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index d8b040bd9814..7d531da1bae3 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -340,7 +340,6 @@ static struct vfsmount *nfs_follow_referral(struct dentry *dentry,
 out:
 	free_page((unsigned long) page);
 	free_page((unsigned long) page2);
-	dprintk("%s: done\n", __func__);
 	return mnt;
 }
 
@@ -358,11 +357,9 @@ static struct vfsmount *nfs_do_refmount(struct rpc_clnt *client, struct dentry *
 	int err;
 
 	/* BUG_ON(IS_ROOT(dentry)); */
-	dprintk("%s: enter\n", __func__);
-
 	page = alloc_page(GFP_KERNEL);
 	if (page == NULL)
-		goto out;
+		return mnt;
 
 	fs_locations = kmalloc(sizeof(struct nfs4_fs_locations), GFP_KERNEL);
 	if (fs_locations == NULL)
@@ -386,8 +383,6 @@ static struct vfsmount *nfs_do_refmount(struct rpc_clnt *client, struct dentry *
 out_free:
 	__free_page(page);
 	kfree(fs_locations);
-out:
-	dprintk("%s: done\n", __func__);
 	return mnt;
 }
 
-- 
2.12.2

