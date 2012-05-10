Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33649 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760029Ab2EJPUj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 11:20:39 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v3 05/14] NFS: Create a common fs_mount() function
Date: Thu, 10 May 2012 11:19:56 -0400
Message-Id: <1336663205-23886-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336663205-23886-1-git-send-email-bjschuma@netapp.com>
References: <1336663205-23886-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The nfs4_mount() function was only slightly different from the
nfs_fs_mount() function used by the generic client.  I created a new
nfs_mount_info structure to set different parameters to help combine
these functions.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |  185 +++++++++++++++++++++++---------------------------------
 1 file changed, 76 insertions(+), 109 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 40d43e0..64a62da 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -277,6 +277,11 @@ static match_table_t nfs_vers_tokens = {
 	{ Opt_vers_err, NULL }
 };
 
+struct nfs_mount_info {
+	void (*fill_super)(struct super_block *, struct nfs_mount_info *);
+	struct nfs_parsed_mount_data *parsed;
+};
+
 static void nfs_umount_begin(struct super_block *);
 static int  nfs_statfs(struct dentry *, struct kstatfs *);
 static int  nfs_show_options(struct seq_file *, struct dentry *);
@@ -2129,8 +2134,9 @@ static inline void nfs_initialise_sb(struct super_block *sb)
  * Finish setting up an NFS2/3 superblock
  */
 static void nfs_fill_super(struct super_block *sb,
-			   struct nfs_parsed_mount_data *data)
+			   struct nfs_mount_info *mount_info)
 {
+	struct nfs_parsed_mount_data *data = mount_info->parsed;
 	struct nfs_server *server = NFS_SB(sb);
 
 	sb->s_blocksize_bits = 0;
@@ -2304,47 +2310,21 @@ static int nfs_bdi_register(struct nfs_server *server)
 	return bdi_register_dev(&server->backing_dev_info, server->s_dev);
 }
 
-static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data)
+static struct dentry *nfs_fs_mount_common(struct file_system_type *fs_type,
+					  struct nfs_server *server,
+					  int flags, const char *dev_name,
+					  struct nfs_fh *mntfh,
+					  struct nfs_mount_info *mount_info)
 {
-	struct nfs_server *server = NULL;
 	struct super_block *s;
-	struct nfs_parsed_mount_data *data;
-	struct nfs_fh *mntfh;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
 	struct nfs_sb_mountdata sb_mntdata = {
 		.mntflags = flags,
+		.server = server,
 	};
 	int error;
 
-	data = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);
-	mntfh = nfs_alloc_fhandle();
-	if (data == NULL || mntfh == NULL)
-		goto out;
-
-	/* Validate the mount data */
-	error = nfs_validate_mount_data(raw_data, data, mntfh, dev_name);
-	if (error < 0) {
-		mntroot = ERR_PTR(error);
-		goto out;
-	}
-
-#ifdef CONFIG_NFS_V4
-	if (data->version == 4) {
-		mntroot = nfs4_try_mount(flags, dev_name, data);
-		goto out;
-	}
-#endif	/* CONFIG_NFS_V4 */
-
-	/* Get a volume representation */
-	server = nfs_create_server(data, mntfh);
-	if (IS_ERR(server)) {
-		mntroot = ERR_CAST(server);
-		goto out;
-	}
-	sb_mntdata.server = server;
-
 	if (server->flags & NFS_MOUNT_UNSHARED)
 		compare_super = NULL;
 
@@ -2372,23 +2352,21 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		nfs_fill_super(s, data);
-		nfs_get_cache_cookie(s, data, NULL);
+		mount_info->fill_super(s, mount_info);
+		nfs_get_cache_cookie(s, mount_info->parsed, NULL);
 	}
 
 	mntroot = nfs_get_root(s, mntfh, dev_name);
 	if (IS_ERR(mntroot))
 		goto error_splat_super;
 
-	error = security_sb_set_mnt_opts(s, &data->lsm_opts);
+	error = security_sb_set_mnt_opts(s, &mount_info->parsed->lsm_opts);
 	if (error)
 		goto error_splat_root;
 
 	s->s_flags |= MS_ACTIVE;
 
 out:
-	nfs_free_parsed_mount_data(data);
-	nfs_free_fhandle(mntfh);
 	return mntroot;
 
 out_err_nosb:
@@ -2406,6 +2384,52 @@ error_splat_bdi:
 	goto out;
 }
 
+static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data)
+{
+	struct nfs_server *server;
+	struct nfs_parsed_mount_data *data = NULL;
+	struct nfs_mount_info mount_info = {
+		.fill_super = nfs_fill_super,
+	};
+	struct nfs_fh *mntfh;
+	struct dentry *mntroot = ERR_PTR(-ENOMEM);
+	int error;
+
+	data = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);
+	mntfh = nfs_alloc_fhandle();
+	if (data == NULL || mntfh == NULL)
+		goto out;
+
+	/* Validate the mount data */
+	error = nfs_validate_mount_data(raw_data, data, mntfh, dev_name);
+	if (error < 0) {
+		mntroot = ERR_PTR(error);
+		goto out;
+	}
+	mount_info.parsed = data;
+
+#ifdef CONFIG_NFS_V4
+	if (data->version == 4) {
+		mntroot = nfs4_try_mount(flags, dev_name, data);
+		goto out;
+	}
+#endif	/* CONFIG_NFS_V4 */
+
+	/* Get a volume representation */
+	server = nfs_create_server(data, mntfh);
+	if (IS_ERR(server)) {
+		mntroot = ERR_CAST(server);
+		goto out;
+	}
+
+	mntroot = nfs_fs_mount_common(fs_type, server, flags, dev_name, mntfh, &mount_info);
+out:
+	nfs_free_parsed_mount_data(data);
+	nfs_free_fhandle(mntfh);
+	return mntroot;
+}
+
 /*
  * Ensure that we unregister the bdi before kill_anon_super
  * releases the device name
@@ -2544,7 +2568,8 @@ static void nfs4_clone_super(struct super_block *sb,
 /*
  * Set up an NFS4 superblock
  */
-static void nfs4_fill_super(struct super_block *sb)
+static void nfs4_fill_super(struct super_block *sb,
+			    struct nfs_mount_info *mount_info)
 {
 	sb->s_time_gran = 1;
 	sb->s_op = &nfs4_sops;
@@ -2696,89 +2721,31 @@ static struct dentry *
 nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 		  const char *dev_name, void *raw_data)
 {
-	struct nfs_parsed_mount_data *data = raw_data;
-	struct super_block *s;
+	struct nfs_mount_info mount_info = {
+		.fill_super = nfs4_fill_super,
+		.parsed = raw_data,
+	};
 	struct nfs_server *server;
 	struct nfs_fh *mntfh;
-	struct dentry *mntroot;
-	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
-	struct nfs_sb_mountdata sb_mntdata = {
-		.mntflags = flags,
-	};
-	int error = -ENOMEM;
+	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 
 	mntfh = nfs_alloc_fhandle();
-	if (data == NULL || mntfh == NULL)
+	if (mount_info.parsed == NULL || mntfh == NULL)
 		goto out;
 
 	/* Get a volume representation */
-	server = nfs4_create_server(data, mntfh);
+	server = nfs4_create_server(mount_info.parsed, mntfh);
 	if (IS_ERR(server)) {
-		error = PTR_ERR(server);
+		mntroot = ERR_CAST(server);
 		goto out;
 	}
-	sb_mntdata.server = server;
 
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
-		goto out_free;
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
-		nfs4_fill_super(s);
-		nfs_get_cache_cookie(s, data, NULL);
-	}
-
-	mntroot = nfs_get_root(s, mntfh, dev_name);
-	if (IS_ERR(mntroot)) {
-		error = PTR_ERR(mntroot);
-		goto error_splat_super;
-	}
-
-	error = security_sb_set_mnt_opts(s, &data->lsm_opts);
-	if (error)
-		goto error_splat_root;
-
-	s->s_flags |= MS_ACTIVE;
-
-	nfs_free_fhandle(mntfh);
-	return mntroot;
+	mntroot = nfs_fs_mount_common(fs_type, server, flags,
+				      dev_name, mntfh, &mount_info);
 
 out:
 	nfs_free_fhandle(mntfh);
-	return ERR_PTR(error);
-
-out_free:
-	nfs_free_server(server);
-	goto out;
-
-error_splat_root:
-	dput(mntroot);
-error_splat_super:
-	if (server && !s->s_root)
-		bdi_unregister(&server->backing_dev_info);
-error_splat_bdi:
-	deactivate_locked_super(s);
-	goto out;
+	return mntroot;
 }
 
 static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
@@ -3099,7 +3066,7 @@ nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		nfs4_fill_super(s);
+		nfs4_fill_super(s, NULL);
 		nfs_get_cache_cookie(s, NULL, data);
 	}
 
-- 
1.7.10.1

