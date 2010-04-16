From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/24] NFSv4: Reduce the stack footprint of nfs4_remote_referral_get_sb
Date: Fri, 16 Apr 2010 16:31:07 -0400
Message-ID: <1271449882-8580-10-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-9-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932415Ab0DPUb2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:28 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMl4026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:28 -0700 (PDT)
In-Reply-To: <1271449882-8580-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ef2102f..3e9047f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2879,17 +2879,21 @@ static int nfs4_remote_referral_get_sb(struct file_system_type *fs_type,
 	struct super_block *s;
 	struct nfs_server *server;
 	struct dentry *mntroot;
-	struct nfs_fh mntfh;
+	struct nfs_fh *mntfh;
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
 	struct nfs_sb_mountdata sb_mntdata = {
 		.mntflags = flags,
 	};
-	int error;
+	int error = -ENOMEM;
 
 	dprintk("--> nfs4_referral_get_sb()\n");
 
+	mntfh = nfs_alloc_fhandle();
+	if (mntfh == NULL)
+		goto out_err_nofh;
+
 	/* create a new volume representation */
-	server = nfs4_create_referral_server(data, &mntfh);
+	server = nfs4_create_referral_server(data, mntfh);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
 		goto out_err_noserver;
@@ -2921,7 +2925,7 @@ static int nfs4_remote_referral_get_sb(struct file_system_type *fs_type,
 		nfs_fscache_get_super_cookie(s, NULL, data);
 	}
 
-	mntroot = nfs4_get_root(s, &mntfh);
+	mntroot = nfs4_get_root(s, mntfh);
 	if (IS_ERR(mntroot)) {
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
@@ -2938,12 +2942,15 @@ static int nfs4_remote_referral_get_sb(struct file_system_type *fs_type,
 
 	security_sb_clone_mnt_opts(data->sb, s);
 
+	nfs_free_fhandle(mntfh);
 	dprintk("<-- nfs4_referral_get_sb() = 0\n");
 	return 0;
 
 out_err_nosb:
 	nfs_free_server(server);
 out_err_noserver:
+	nfs_free_fhandle(mntfh);
+out_err_nofh:
 	dprintk("<-- nfs4_referral_get_sb() = %d [error]\n", error);
 	return error;
 
@@ -2952,6 +2959,7 @@ error_splat_super:
 		bdi_unregister(&server->backing_dev_info);
 error_splat_bdi:
 	deactivate_locked_super(s);
+	nfs_free_fhandle(mntfh);
 	dprintk("<-- nfs4_referral_get_sb() = %d [splat]\n", error);
 	return error;
 }
-- 
1.6.6.1

