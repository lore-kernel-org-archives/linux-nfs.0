Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60449 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761193Ab2EJTH6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 15:07:58 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 08/14] NFS: Use nfs_fs_mount_common() for remote referral mounts
Date: Thu, 10 May 2012 15:07:37 -0400
Message-Id: <1336676863-9698-9-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336676863-9698-1-git-send-email-bjschuma@netapp.com>
References: <1336676863-9698-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |   89 +++++++++-----------------------------------------------
 1 file changed, 13 insertions(+), 76 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e93a6e9..1157189 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2920,95 +2920,32 @@ static struct dentry *
 nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 			   const char *dev_name, void *raw_data)
 {
-	struct nfs_clone_mount *data = raw_data;
-	struct super_block *s;
+	struct nfs_mount_info mount_info = {
+		.fill_super = nfs4_fill_super,
+		.set_security = nfs_clone_sb_security,
+		.cloned = raw_data,
+	};
 	struct nfs_server *server;
-	struct dentry *mntroot;
+	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	struct nfs_fh *mntfh;
-	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
-	struct nfs_sb_mountdata sb_mntdata = {
-		.mntflags = flags,
-	};
-	int error = -ENOMEM;
 
 	dprintk("--> nfs4_referral_get_sb()\n");
 
 	mntfh = nfs_alloc_fhandle();
-	if (mntfh == NULL)
-		goto out_err_nofh;
+	if (mount_info.cloned == NULL || mntfh == NULL)
+		goto out;
 
 	/* create a new volume representation */
-	server = nfs4_create_referral_server(data, mntfh);
+	server = nfs4_create_referral_server(mount_info.cloned, mntfh);
 	if (IS_ERR(server)) {
-		error = PTR_ERR(server);
-		goto out_err_noserver;
-	}
-	sb_mntdata.server = server;
-
-	if (server->flags & NFS_MOUNT_UNSHARED)
-		compare_super = NULL;
-
-	/* -o noac implies -o sync */
-	if (server->flags & NFS_MOUNT_NOAC)
-		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
-
-	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
-	if (IS_ERR(s)) {
-		error = PTR_ERR(s);
-		goto out_err_nosb;
-	}
-
-	if (s->s_fs_info != server) {
-		nfs_free_server(server);
-		server = NULL;
-	} else {
-		error = nfs_bdi_register(server);
-		if (error)
-			goto error_splat_bdi;
-	}
-
-	if (!s->s_root) {
-		/* initial superblock/root creation */
-		nfs4_fill_super(s, NULL);
-		nfs_get_cache_cookie(s, NULL, data);
-	}
-
-	mntroot = nfs_get_root(s, mntfh, dev_name);
-	if (IS_ERR(mntroot)) {
-		error = PTR_ERR(mntroot);
-		goto error_splat_super;
-	}
-	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {
-		dput(mntroot);
-		error = -ESTALE;
-		goto error_splat_super;
+		mntroot = ERR_CAST(server);
+		goto out;
 	}
 
-	s->s_flags |= MS_ACTIVE;
-
-	security_sb_clone_mnt_opts(data->sb, s);
-
+	mntroot = nfs_fs_mount_common(&nfs4_fs_type, server, flags, dev_name, mntfh, &mount_info);
+out:
 	nfs_free_fhandle(mntfh);
-	dprintk("<-- nfs4_referral_get_sb() = 0\n");
 	return mntroot;
-
-out_err_nosb:
-	nfs_free_server(server);
-out_err_noserver:
-	nfs_free_fhandle(mntfh);
-out_err_nofh:
-	dprintk("<-- nfs4_referral_get_sb() = %d [error]\n", error);
-	return ERR_PTR(error);
-
-error_splat_super:
-	if (server && !s->s_root)
-		bdi_unregister(&server->backing_dev_info);
-error_splat_bdi:
-	deactivate_locked_super(s);
-	nfs_free_fhandle(mntfh);
-	dprintk("<-- nfs4_referral_get_sb() = %d [splat]\n", error);
-	return ERR_PTR(error);
 }
 
 /*
-- 
1.7.10.1

