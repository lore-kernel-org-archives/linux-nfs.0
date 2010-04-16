From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/24] NFS: Reduce the stack footprint of nfs_follow_remote_path()
Date: Fri, 16 Apr 2010 16:31:05 -0400
Message-ID: <1271449882-8580-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-7-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932442Ab0DPUb1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:27 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMl2026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:27 -0700 (PDT)
In-Reply-To: <1271449882-8580-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e016372..ef2102f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2671,38 +2671,44 @@ out_freepage:
 static int nfs_follow_remote_path(struct vfsmount *root_mnt,
 		const char *export_path, struct vfsmount *mnt_target)
 {
+	struct nameidata *nd = NULL;
 	struct mnt_namespace *ns_private;
-	struct nameidata nd;
 	struct super_block *s;
 	int ret;
 
+	nd = kmalloc(sizeof(*nd), GFP_KERNEL);
+	if (nd == NULL)
+		return -ENOMEM;
+
 	ns_private = create_mnt_ns(root_mnt);
 	ret = PTR_ERR(ns_private);
 	if (IS_ERR(ns_private))
 		goto out_mntput;
 
 	ret = vfs_path_lookup(root_mnt->mnt_root, root_mnt,
-			export_path, LOOKUP_FOLLOW, &nd);
+			export_path, LOOKUP_FOLLOW, nd);
 
 	put_mnt_ns(ns_private);
 
 	if (ret != 0)
 		goto out_err;
 
-	s = nd.path.mnt->mnt_sb;
+	s = nd->path.mnt->mnt_sb;
 	atomic_inc(&s->s_active);
 	mnt_target->mnt_sb = s;
-	mnt_target->mnt_root = dget(nd.path.dentry);
+	mnt_target->mnt_root = dget(nd->path.dentry);
 
 	/* Correct the device pathname */
-	nfs_fix_devname(&nd.path, mnt_target);
+	nfs_fix_devname(&nd->path, mnt_target);
 
-	path_put(&nd.path);
+	path_put(&nd->path);
+	kfree(nd);
 	down_write(&s->s_umount);
 	return 0;
 out_mntput:
 	mntput(root_mnt);
 out_err:
+	kfree(nd);
 	return ret;
 }
 
-- 
1.6.6.1

