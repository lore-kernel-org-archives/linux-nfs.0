Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:26541 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932127AbdDGSP4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:56 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 15/34] NFS: Remove extra dprintk()s from namespace.c
Date: Fri, 7 Apr 2017 14:15:09 -0400
Message-ID: <20170407181528.2832-16-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/namespace.c | 34 ++++++++--------------------------
 1 file changed, 8 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 786f17580582..1a224a33a6c2 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -143,11 +143,8 @@ struct vfsmount *nfs_d_automount(struct path *path)
 	struct nfs_fh *fh = NULL;
 	struct nfs_fattr *fattr = NULL;
 
-	dprintk("--> nfs_d_automount()\n");
-
-	mnt = ERR_PTR(-ESTALE);
 	if (IS_ROOT(path->dentry))
-		goto out_nofree;
+		return ERR_PTR(-ESTALE);
 
 	mnt = ERR_PTR(-ENOMEM);
 	fh = nfs_alloc_fhandle();
@@ -155,13 +152,10 @@ struct vfsmount *nfs_d_automount(struct path *path)
 	if (fh == NULL || fattr == NULL)
 		goto out;
 
-	dprintk("%s: enter\n", __func__);
-
 	mnt = server->nfs_client->rpc_ops->submount(server, path->dentry, fh, fattr);
 	if (IS_ERR(mnt))
 		goto out;
 
-	dprintk("%s: done, success\n", __func__);
 	mntget(mnt); /* prevent immediate expiration */
 	mnt_set_expiry(mnt, &nfs_automount_list);
 	schedule_delayed_work(&nfs_automount_task, nfs_mountpoint_expiry_timeout);
@@ -169,11 +163,6 @@ struct vfsmount *nfs_d_automount(struct path *path)
 out:
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fh);
-out_nofree:
-	if (IS_ERR(mnt))
-		dprintk("<-- %s(): error %ld\n", __func__, PTR_ERR(mnt));
-	else
-		dprintk("<-- %s() = %p\n", __func__, mnt);
 	return mnt;
 }
 
@@ -248,27 +237,20 @@ struct vfsmount *nfs_do_submount(struct dentry *dentry, struct nfs_fh *fh,
 		.fattr = fattr,
 		.authflavor = authflavor,
 	};
-	struct vfsmount *mnt = ERR_PTR(-ENOMEM);
+	struct vfsmount *mnt;
 	char *page = (char *) __get_free_page(GFP_USER);
 	char *devname;
 
-	dprintk("--> nfs_do_submount()\n");
-
-	dprintk("%s: submounting on %pd2\n", __func__,
-			dentry);
 	if (page == NULL)
-		goto out;
+		return ERR_PTR(-ENOMEM);
+
 	devname = nfs_devname(dentry, page, PAGE_SIZE);
-	mnt = (struct vfsmount *)devname;
 	if (IS_ERR(devname))
-		goto free_page;
-	mnt = nfs_do_clone_mount(NFS_SB(dentry->d_sb), devname, &mountdata);
-free_page:
-	free_page((unsigned long)page);
-out:
-	dprintk("%s: done\n", __func__);
+		mnt = (struct vfsmount *)devname;
+	else
+		mnt = nfs_do_clone_mount(NFS_SB(dentry->d_sb), devname, &mountdata);
 
-	dprintk("<-- nfs_do_submount() = %p\n", mnt);
+	free_page((unsigned long)page);
 	return mnt;
 }
 EXPORT_SYMBOL_GPL(nfs_do_submount);
-- 
2.12.2

