Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12008 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756551Ab2D3Skg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 14:40:36 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 4/7] NFS: Create a common fs_mount() function
Date: Mon, 30 Apr 2012 14:40:26 -0400
Message-Id: <1335811229-2989-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335811229-2989-1-git-send-email-bjschuma@netapp.com>
References: <1335811229-2989-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The nfs4_mount() function was only slightly different from the
nfs_fs_mount() function used by the generic client.  I created a new
nfs_mount_info structure to set different parameters to help combine
these functions.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |  327 +++++++++++++++-----------------------------------------
 1 file changed, 86 insertions(+), 241 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b7a071d..b9ee798 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -325,10 +325,8 @@ static const struct super_operations nfs_sops = {
 #ifdef CONFIG_NFS_V4
 static int nfs4_validate_text_mount_data(void *options,
 	struct nfs_parsed_mount_data *args, const char *dev_name);
-static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
+struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 	struct nfs_parsed_mount_data *data);
-static struct dentry *nfs4_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
 static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
 static struct dentry *nfs4_xdev_mount(struct file_system_type *fs_type,
@@ -342,7 +340,7 @@ static void nfs4_kill_super(struct super_block *sb);
 static struct file_system_type nfs4_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
-	.mount		= nfs4_mount,
+	.mount		= nfs_fs_mount,
 	.kill_sb	= nfs4_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
@@ -2125,12 +2123,19 @@ static inline void nfs_initialise_sb(struct super_block *sb)
 	nfs_super_set_maxbytes(sb, server->maxfilesize);
 }
 
+struct nfs_mount_info {
+	void (*fill_super)(struct super_block *, struct nfs_mount_info *);
+	struct nfs_parsed_mount_data *parsed;
+	unsigned int unshared;
+};
+
 /*
  * Finish setting up an NFS2/3 superblock
  */
 static void nfs_fill_super(struct super_block *sb,
-			   struct nfs_parsed_mount_data *data)
+			   struct nfs_mount_info *mount_info)
 {
+	struct nfs_parsed_mount_data *data = mount_info->parsed;
 	struct nfs_server *server = NFS_SB(sb);
 
 	sb->s_blocksize_bits = 0;
@@ -2283,13 +2288,13 @@ static int nfs_bdi_register(struct nfs_server *server)
 	return bdi_register_dev(&server->backing_dev_info, server->s_dev);
 }
 
-static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data)
+struct dentry *nfs_fs_mount_common(struct file_system_type *fs_type,
+				   struct nfs_server *server,
+				   int flags, const char *dev_name,
+				   struct nfs_fh *mntfh,
+				   struct nfs_mount_info *mount_info)
 {
-	struct nfs_server *server = NULL;
 	struct super_block *s;
-	struct nfs_parsed_mount_data *data;
-	struct nfs_fh *mntfh;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
 	struct nfs_sb_mountdata sb_mntdata = {
@@ -2297,34 +2302,9 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
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
 	sb_mntdata.server = server;
 
-	if (server->flags & NFS_MOUNT_UNSHARED)
+	if (server->flags & mount_info->unshared)
 		compare_super = NULL;
 
 	/* -o noac implies -o sync */
@@ -2351,23 +2331,21 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		nfs_fill_super(s, data);
-		nfs_fscache_get_super_cookie(s, data, NULL);
+		mount_info->fill_super(s, mount_info);
+		nfs_fscache_get_super_cookie(s, mount_info->parsed, NULL);
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
@@ -2385,6 +2363,58 @@ error_splat_bdi:
 	goto out;
 }
 
+static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data)
+{
+	struct nfs_server *server;
+	struct nfs_parsed_mount_data *data = NULL;
+	struct nfs_mount_info mount_info = {
+		.fill_super = nfs_fill_super,
+		.unshared = NFS_MOUNT_UNSHARED,
+	};
+	struct nfs_fh *mntfh;
+	struct dentry *mntroot = ERR_PTR(-ENOMEM);
+	int error;
+
+	if (fs_type == &nfs_fs_type)
+		data = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);
+#ifdef CONFIG_NFS_V4
+	else
+		data = nfs_alloc_parsed_mount_data(4);
+#endif
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
@@ -2523,7 +2553,8 @@ static void nfs4_clone_super(struct super_block *sb,
 /*
  * Set up an NFS4 superblock
  */
-static void nfs4_fill_super(struct super_block *sb)
+static void nfs4_fill_super(struct super_block *sb,
+			    struct nfs_mount_info *mount_info)
 {
 	sb->s_time_gran = 1;
 	sb->s_op = &nfs4_sops;
@@ -2574,190 +2605,36 @@ static int nfs4_validate_text_mount_data(void *options,
 }
 
 /*
- * Validate NFSv4 mount options
- */
-static int nfs4_validate_mount_data(void *options,
-				    struct nfs_parsed_mount_data *args,
-				    const char *dev_name)
-{
-	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
-	struct nfs4_mount_data *data = (struct nfs4_mount_data *)options;
-	char *c;
-
-	if (data == NULL)
-		goto out_no_data;
-
-	switch (data->version) {
-	case 1:
-		if (data->host_addrlen > sizeof(args->nfs_server.address))
-			goto out_no_address;
-		if (data->host_addrlen == 0)
-			goto out_no_address;
-		args->nfs_server.addrlen = data->host_addrlen;
-		if (copy_from_user(sap, data->host_addr, data->host_addrlen))
-			return -EFAULT;
-		if (!nfs_verify_server_address(sap))
-			goto out_no_address;
-
-		if (data->auth_flavourlen) {
-			if (data->auth_flavourlen > 1)
-				goto out_inval_auth;
-			if (copy_from_user(&args->auth_flavors[0],
-					   data->auth_flavours,
-					   sizeof(args->auth_flavors[0])))
-				return -EFAULT;
-		}
-
-		c = strndup_user(data->hostname.data, NFS4_MAXNAMLEN);
-		if (IS_ERR(c))
-			return PTR_ERR(c);
-		args->nfs_server.hostname = c;
-
-		c = strndup_user(data->mnt_path.data, NFS4_MAXPATHLEN);
-		if (IS_ERR(c))
-			return PTR_ERR(c);
-		args->nfs_server.export_path = c;
-		dfprintk(MOUNT, "NFS: MNTPATH: '%s'\n", c);
-
-		c = strndup_user(data->client_addr.data, 16);
-		if (IS_ERR(c))
-			return PTR_ERR(c);
-		args->client_address = c;
-
-		/*
-		 * Translate to nfs_parsed_mount_data, which nfs4_fill_super
-		 * can deal with.
-		 */
-
-		args->flags	= data->flags & NFS4_MOUNT_FLAGMASK;
-		args->rsize	= data->rsize;
-		args->wsize	= data->wsize;
-		args->timeo	= data->timeo;
-		args->retrans	= data->retrans;
-		args->acregmin	= data->acregmin;
-		args->acregmax	= data->acregmax;
-		args->acdirmin	= data->acdirmin;
-		args->acdirmax	= data->acdirmax;
-		args->nfs_server.protocol = data->proto;
-		nfs_validate_transport_protocol(args);
-
-		break;
-	default:
-		if (nfs_parse_mount_options((char *)options, args) == 0)
-			return -EINVAL;
-
-		if (!nfs_verify_server_address(sap))
-			return -EINVAL;
-
-		return nfs4_validate_text_mount_data(options, args, dev_name);
-	}
-
-	return 0;
-
-out_no_data:
-	dfprintk(MOUNT, "NFS4: mount program didn't pass any mount data\n");
-	return -EINVAL;
-
-out_inval_auth:
-	dfprintk(MOUNT, "NFS4: Invalid number of RPC auth flavours %d\n",
-		 data->auth_flavourlen);
-	return -EINVAL;
-
-out_no_address:
-	dfprintk(MOUNT, "NFS4: mount program didn't pass remote address\n");
-	return -EINVAL;
-}
-
-/*
  * Get the superblock for the NFS4 root partition
  */
 static struct dentry *
 nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 		  const char *dev_name, void *raw_data)
 {
-	struct nfs_parsed_mount_data *data = raw_data;
-	struct super_block *s;
+	struct nfs_mount_info mount_info = {
+		.fill_super = nfs4_fill_super,
+		.parsed = raw_data,
+		.unshared = NFS4_MOUNT_UNSHARED,
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
-
-	if (server->flags & NFS4_MOUNT_UNSHARED)
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
-		nfs_fscache_get_super_cookie(s, data, NULL);
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
 
+	mntroot = nfs_fs_mount_common(&nfs4_fs_type, server, flags, dev_name, mntfh, &mount_info);
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
@@ -2868,7 +2745,7 @@ static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
 	return dentry;
 }
 
-static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
+struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 			 struct nfs_parsed_mount_data *data)
 {
 	char *export_path;
@@ -2891,38 +2768,6 @@ static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
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
-	data = nfs_alloc_parsed_mount_data(4);
-	if (data == NULL)
-		goto out;
-
-	/* Validate the mount data */
-	error = nfs4_validate_mount_data(raw_data, data, dev_name);
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
@@ -3078,7 +2923,7 @@ nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		nfs4_fill_super(s);
+		nfs4_fill_super(s, NULL);
 		nfs_fscache_get_super_cookie(s, NULL, data);
 	}
 
-- 
1.7.10

