Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:3455 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761469Ab2EJTIF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 15:08:05 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 14/14] NFS: Pass mntfh as part of the nfs_mount_info structure
Date: Thu, 10 May 2012 15:07:43 -0400
Message-Id: <1336676863-9698-15-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336676863-9698-1-git-send-email-bjschuma@netapp.com>
References: <1336676863-9698-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This allows me to use the filehandle allocated in nfs_fs_mount() for nfs
v4 mounts instead of allocating a new one.  Rather than change
nfs4_mount() to look almost exactly like nfs_fs_mount(), I instead
remove the function.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |  107 ++++++++++++++++----------------------------------------
 1 file changed, 31 insertions(+), 76 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index fc62701..c3ae819 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -283,6 +283,7 @@ struct nfs_mount_info {
 	int (*set_security)(struct super_block *, struct dentry *, struct nfs_mount_info *);
 	struct nfs_parsed_mount_data *parsed;
 	struct nfs_clone_mount *cloned;
+	struct nfs_fh *mntfh;
 };
 
 static void nfs_umount_begin(struct super_block *);
@@ -292,8 +293,7 @@ static int  nfs_show_devname(struct seq_file *, struct dentry *);
 static int  nfs_show_path(struct seq_file *, struct dentry *);
 static int  nfs_show_stats(struct seq_file *, struct dentry *);
 static struct dentry *nfs_fs_mount_common(struct file_system_type *,
-		struct nfs_server *, int, const char *, struct nfs_fh *,
-		struct nfs_mount_info *);
+		struct nfs_server *, int, const char *, struct nfs_mount_info *);
 static struct dentry *nfs_fs_mount(struct file_system_type *,
 		int, const char *, void *);
 static struct dentry *nfs_xdev_mount(struct file_system_type *fs_type,
@@ -338,9 +338,7 @@ static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *);
 static int nfs4_validate_mount_data(void *options,
 	struct nfs_parsed_mount_data *args, const char *dev_name);
 static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
-	struct nfs_parsed_mount_data *data);
-static struct dentry *nfs4_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
+	struct nfs_mount_info *mount_info);
 static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
 static struct dentry *nfs4_xdev_mount(struct file_system_type *fs_type,
@@ -354,7 +352,7 @@ static void nfs4_kill_super(struct super_block *sb);
 static struct file_system_type nfs4_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
-	.mount		= nfs4_mount,
+	.mount		= nfs_fs_mount,
 	.kill_sb	= nfs4_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
@@ -1751,24 +1749,23 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
 }
 
 static struct dentry *nfs_try_mount(int flags, const char *dev_name,
-				    struct nfs_fh *mntfh,
 				    struct nfs_mount_info *mount_info)
 {
 	int status;
 	struct nfs_server *server;
 
 	if (mount_info->parsed->need_mount) {
-		status = nfs_request_mount(mount_info->parsed, mntfh);
+		status = nfs_request_mount(mount_info->parsed, mount_info->mntfh);
 		if (status)
 			return ERR_PTR(status);
 	}
 
 	/* Get a volume representation */
-	server = nfs_create_server(mount_info->parsed, mntfh);
+	server = nfs_create_server(mount_info->parsed, mount_info->mntfh);
 	if (IS_ERR(server))
 		return ERR_CAST(server);
 
-	return nfs_fs_mount_common(&nfs_fs_type, server, flags, dev_name, mntfh, mount_info);
+	return nfs_fs_mount_common(&nfs_fs_type, server, flags, dev_name, mount_info);
 }
 
 /*
@@ -2394,7 +2391,6 @@ static int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
 static struct dentry *nfs_fs_mount_common(struct file_system_type *fs_type,
 					  struct nfs_server *server,
 					  int flags, const char *dev_name,
-					  struct nfs_fh *mntfh,
 					  struct nfs_mount_info *mount_info)
 {
 	struct super_block *s;
@@ -2437,7 +2433,7 @@ static struct dentry *nfs_fs_mount_common(struct file_system_type *fs_type,
 		nfs_get_cache_cookie(s, mount_info->parsed, mount_info->cloned);
 	}
 
-	mntroot = nfs_get_root(s, mntfh, dev_name);
+	mntroot = nfs_get_root(s, mount_info->mntfh, dev_name);
 	if (IS_ERR(mntroot))
 		goto error_splat_super;
 
@@ -2472,17 +2468,16 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 		.fill_super = nfs_fill_super,
 		.set_security = nfs_set_sb_security,
 	};
-	struct nfs_fh *mntfh;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	int error;
 
 	mount_info.parsed = nfs_alloc_parsed_mount_data();
-	mntfh = nfs_alloc_fhandle();
-	if (mount_info.parsed == NULL || mntfh == NULL)
+	mount_info.mntfh = nfs_alloc_fhandle();
+	if (mount_info.parsed == NULL || mount_info.mntfh == NULL)
 		goto out;
 
 	/* Validate the mount data */
-	error = nfs_validate_mount_data(fs_type, raw_data, mount_info.parsed, mntfh, dev_name);
+	error = nfs_validate_mount_data(fs_type, raw_data, mount_info.parsed, mount_info.mntfh, dev_name);
 	if (error == NFS_TEXT_DATA)
 		error = nfs_validate_text_mount_data(raw_data, mount_info.parsed, dev_name);
 	if (error < 0) {
@@ -2492,14 +2487,14 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 
 #ifdef CONFIG_NFS_V4
 	if (mount_info.parsed->version == 4)
-		mntroot = nfs4_try_mount(flags, dev_name, mount_info.parsed);
+		mntroot = nfs4_try_mount(flags, dev_name, &mount_info);
 	else
 #endif	/* CONFIG_NFS_V4 */
-		mntroot = nfs_try_mount(flags, dev_name, mntfh, &mount_info);
+		mntroot = nfs_try_mount(flags, dev_name, &mount_info);
 
 out:
 	nfs_free_parsed_mount_data(mount_info.parsed);
-	nfs_free_fhandle(mntfh);
+	nfs_free_fhandle(mount_info.mntfh);
 	return mntroot;
 }
 
@@ -2540,6 +2535,8 @@ nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
 
 	dprintk("--> nfs_xdev_mount_common()\n");
 
+	mount_info->mntfh = data->fh;
+
 	/* create a new volume representation */
 	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr, data->authflavor);
 	if (IS_ERR(server)) {
@@ -2547,7 +2544,7 @@ nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
 		goto out_err;
 	}
 
-	mntroot = nfs_fs_mount_common(fs_type, server, flags, dev_name, data->fh, mount_info);
+	mntroot = nfs_fs_mount_common(fs_type, server, flags, dev_name, mount_info);
 	dprintk("<-- nfs_xdev_mount_common() = 0\n");
 out:
 	return mntroot;
@@ -2712,33 +2709,25 @@ out_no_address:
  */
 static struct dentry *
 nfs4_remote_mount(struct file_system_type *fs_type, int flags,
-		  const char *dev_name, void *raw_data)
+		  const char *dev_name, void *info)
 {
-	struct nfs_mount_info mount_info = {
-		.fill_super = nfs4_fill_super,
-		.set_security = nfs_set_sb_security,
-		.parsed = raw_data,
-	};
+	struct nfs_mount_info *mount_info = info;
 	struct nfs_server *server;
-	struct nfs_fh *mntfh;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 
-	mntfh = nfs_alloc_fhandle();
-	if (mount_info.parsed == NULL || mntfh == NULL)
-		goto out;
+	mount_info->fill_super = nfs4_fill_super;
+	mount_info->set_security = nfs_set_sb_security;
 
 	/* Get a volume representation */
-	server = nfs4_create_server(mount_info.parsed, mntfh);
+	server = nfs4_create_server(mount_info->parsed, mount_info->mntfh);
 	if (IS_ERR(server)) {
 		mntroot = ERR_CAST(server);
 		goto out;
 	}
 
-	mntroot = nfs_fs_mount_common(fs_type, server, flags,
-				      dev_name, mntfh, &mount_info);
+	mntroot = nfs_fs_mount_common(fs_type, server, flags, dev_name, mount_info);
 
 out:
-	nfs_free_fhandle(mntfh);
 	return mntroot;
 }
 
@@ -2851,17 +2840,18 @@ static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
 }
 
 static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
-			 struct nfs_parsed_mount_data *data)
+			 struct nfs_mount_info *mount_info)
 {
 	char *export_path;
 	struct vfsmount *root_mnt;
 	struct dentry *res;
+	struct nfs_parsed_mount_data *data = mount_info->parsed;
 
 	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
 
 	export_path = data->nfs_server.export_path;
 	data->nfs_server.export_path = "/";
-	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, data,
+	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, mount_info,
 			data->nfs_server.hostname);
 	data->nfs_server.export_path = export_path;
 
@@ -2873,40 +2863,6 @@ static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 	return res;
 }
 
-/*
- * Get the superblock for an NFS4 mountpoint
- */
-static struct dentry *nfs4_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data)
-{
-	struct nfs_parsed_mount_data *data;
-	int error = -ENOMEM;
-	struct dentry *res = ERR_PTR(-ENOMEM);
-
-	data = nfs_alloc_parsed_mount_data();
-	if (data == NULL)
-		goto out;
-
-	/* Validate the mount data */
-	error = nfs_validate_mount_data(fs_type, raw_data, data, NULL, dev_name);
-	if (error == NFS_TEXT_DATA)
-		error = nfs_validate_text_mount_data(raw_data, data, dev_name);
-	if (error < 0) {
-		res = ERR_PTR(error);
-		goto out;
-	}
-
-	res = nfs4_try_mount(flags, dev_name, data);
-	if (IS_ERR(res))
-		error = PTR_ERR(res);
-
-out:
-	nfs_free_parsed_mount_data(data);
-	dprintk("<-- nfs4_mount() = %d%s\n", error,
-			error != 0 ? " [error]" : "");
-	return res;
-}
-
 static void nfs4_kill_super(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
@@ -2945,24 +2901,23 @@ nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 	};
 	struct nfs_server *server;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
-	struct nfs_fh *mntfh;
 
 	dprintk("--> nfs4_referral_get_sb()\n");
 
-	mntfh = nfs_alloc_fhandle();
-	if (mount_info.cloned == NULL || mntfh == NULL)
+	mount_info.mntfh = nfs_alloc_fhandle();
+	if (mount_info.cloned == NULL || mount_info.mntfh == NULL)
 		goto out;
 
 	/* create a new volume representation */
-	server = nfs4_create_referral_server(mount_info.cloned, mntfh);
+	server = nfs4_create_referral_server(mount_info.cloned, mount_info.mntfh);
 	if (IS_ERR(server)) {
 		mntroot = ERR_CAST(server);
 		goto out;
 	}
 
-	mntroot = nfs_fs_mount_common(&nfs4_fs_type, server, flags, dev_name, mntfh, &mount_info);
+	mntroot = nfs_fs_mount_common(&nfs4_fs_type, server, flags, dev_name, &mount_info);
 out:
-	nfs_free_fhandle(mntfh);
+	nfs_free_fhandle(mount_info.mntfh);
 	return mntroot;
 }
 
-- 
1.7.10.1

