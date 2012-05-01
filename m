Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2959 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755635Ab2EASVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 14:21:43 -0400
Message-ID: <4FA029B5.9090702@netapp.com>
Date: Tue, 01 May 2012 14:21:41 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: bjschuma@netapp.com
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/7] NFS: Use nfs_fs_mount_common() for xdev mounts
References: <1335811229-2989-1-git-send-email-bjschuma@netapp.com> <1335811229-2989-7-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335811229-2989-7-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/30/2012 02:40 PM, bjschuma@netapp.com wrote:

> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> At this point, there are only a few small differences between these two
> functions.  I can set a few function pointers in the nfs_mount_info
> struct to get around these differences.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/super.c |   97 ++++++++++++++++----------------------------------------
>  1 file changed, 27 insertions(+), 70 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index eefb3ed..9ed670b 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c

...

> @@ -2463,71 +2476,14 @@ nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
>  	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr, data->authflavor);
>  	if (IS_ERR(server)) {
>  		error = PTR_ERR(server);
> -		goto out_err_noserver;
> -	}
> -	sb_mntdata.server = server;
> -
> -	if (server->flags & mount_info->unshared)
> -		compare_super = NULL;
> -
> -	/* -o noac implies -o sync */
> -	if (server->flags & NFS_MOUNT_NOAC)
> -		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
> -
> -	/* Get a superblock - note that we may end up sharing one that already exists */
> -	s = sget(&nfs_fs_type, compare_super, nfs_set_super, &sb_mntdata);
> -	if (IS_ERR(s)) {
> -		error = PTR_ERR(s);
> -		goto out_err_nosb;
> -	}
> -
> -	if (s->s_fs_info != server) {
> -		nfs_free_server(server);
> -		server = NULL;
> -	} else {
> -		error = nfs_bdi_register(server);
> -		if (error)
> -			goto error_splat_bdi;
> -	}
> -
> -	if (!s->s_root) {
> -		/* initial superblock/root creation */
> -		mount_info->fill_super(s, mount_info);
> -		nfs_fscache_get_super_cookie(s, NULL, data);
> -	}
> -
> -	mntroot = nfs_get_root(s, data->fh, dev_name);
> -	if (IS_ERR(mntroot)) {
> -		error = PTR_ERR(mntroot);
> -		goto error_splat_super;
> -	}
> -	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {
> -		dput(mntroot);
> -		error = -ESTALE;
> -		goto error_splat_super;
> +		goto out;
>  	}
>  
> -	s->s_flags |= MS_ACTIVE;
> -
> -	/* clone any lsm security options from the parent to the new sb */
> -	security_sb_clone_mnt_opts(data->sb, s);
> -
> -	dprintk("<-- nfs_xdev_mount_common() = 0\n");
> +	mount_info->fill_super = nfs_clone_super;
> +	mount_info->set_security = nfs_clone_sb_security;


This will overwrite the fill_super function set by nfs4_xdev_mount() to call nfs_clone_super() instead of nfs4_clone_super().  Here is an updated patch:


NFS: Use nfs_fs_mount_common() for xdev mounts

At this point, there are only a few small differences between these two
functions.  I can set a few function pointers in the nfs_mount_info
struct to get around these differences.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |   97 ++++++++++++++++----------------------------------------
 1 file changed, 27 insertions(+), 70 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index eefb3ed..ae82482 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2125,6 +2125,7 @@ static inline void nfs_initialise_sb(struct super_block *sb)
 
 struct nfs_mount_info {
 	void (*fill_super)(struct super_block *, struct nfs_mount_info *);
+	int (*set_security)(struct super_block *, struct dentry *, struct nfs_mount_info *);
 	struct nfs_parsed_mount_data *parsed;
 	struct nfs_clone_mount *cloned;
 	unsigned int unshared;
@@ -2290,6 +2291,22 @@ static int nfs_bdi_register(struct nfs_server *server)
 	return bdi_register_dev(&server->backing_dev_info, server->s_dev);
 }
 
+static int nfs_set_sb_security(struct super_block *s, struct dentry *mntroot,
+			       struct nfs_mount_info *mount_info)
+{
+	return security_sb_set_mnt_opts(s, &mount_info->parsed->lsm_opts);
+}
+
+static int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
+				 struct nfs_mount_info *mount_info)
+{
+	/* clone any lsm security options from the parent to the new sb */
+	security_sb_clone_mnt_opts(mount_info->cloned->sb, s);
+	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops)
+		return -ESTALE;
+	return 0;
+}
+
 struct dentry *nfs_fs_mount_common(struct file_system_type *fs_type,
 				   struct nfs_server *server,
 				   int flags, const char *dev_name,
@@ -2334,14 +2351,14 @@ struct dentry *nfs_fs_mount_common(struct file_system_type *fs_type,
 	if (!s->s_root) {
 		/* initial superblock/root creation */
 		mount_info->fill_super(s, mount_info);
-		nfs_fscache_get_super_cookie(s, mount_info->parsed, NULL);
+		nfs_fscache_get_super_cookie(s, mount_info->parsed, mount_info->cloned);
 	}
 
 	mntroot = nfs_get_root(s, mntfh, dev_name);
 	if (IS_ERR(mntroot))
 		goto error_splat_super;
 
-	error = security_sb_set_mnt_opts(s, &mount_info->parsed->lsm_opts);
+	error = mount_info->set_security(s, mntroot, mount_info);
 	if (error)
 		goto error_splat_root;
 
@@ -2372,6 +2389,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	struct nfs_parsed_mount_data *data = NULL;
 	struct nfs_mount_info mount_info = {
 		.fill_super = nfs_fill_super,
+		.set_security = nfs_set_sb_security,
 		.unshared = NFS_MOUNT_UNSHARED,
 	};
 	struct nfs_fh *mntfh;
@@ -2448,13 +2466,8 @@ nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
 		const char *dev_name, struct nfs_mount_info *mount_info)
 {
 	struct nfs_clone_mount *data = mount_info->cloned;
-	struct super_block *s;
 	struct nfs_server *server;
-	struct dentry *mntroot;
-	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
-	struct nfs_sb_mountdata sb_mntdata = {
-		.mntflags = flags,
-	};
+	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	int error;
 
 	dprintk("--> nfs_xdev_mount_common()\n");
@@ -2463,71 +2476,12 @@ nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
 	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr, data->authflavor);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
-		goto out_err_noserver;
-	}
-	sb_mntdata.server = server;
-
-	if (server->flags & mount_info->unshared)
-		compare_super = NULL;
-
-	/* -o noac implies -o sync */
-	if (server->flags & NFS_MOUNT_NOAC)
-		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
-
-	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(&nfs_fs_type, compare_super, nfs_set_super, &sb_mntdata);
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
-		mount_info->fill_super(s, mount_info);
-		nfs_fscache_get_super_cookie(s, NULL, data);
-	}
-
-	mntroot = nfs_get_root(s, data->fh, dev_name);
-	if (IS_ERR(mntroot)) {
-		error = PTR_ERR(mntroot);
-		goto error_splat_super;
-	}
-	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {
-		dput(mntroot);
-		error = -ESTALE;
-		goto error_splat_super;
+		goto out;
 	}
 
-	s->s_flags |= MS_ACTIVE;
-
-	/* clone any lsm security options from the parent to the new sb */
-	security_sb_clone_mnt_opts(data->sb, s);
-
-	dprintk("<-- nfs_xdev_mount_common() = 0\n");
+	mntroot = nfs_fs_mount_common(fs_type, server, flags, dev_name, data->fh, mount_info);
+out:
 	return mntroot;
-
-out_err_nosb:
-	nfs_free_server(server);
-out_err_noserver:
-	dprintk("<-- nfs_xdev_mount_common() = %d [error]\n", error);
-	return ERR_PTR(error);
-
-error_splat_super:
-	if (server && !s->s_root)
-		bdi_unregister(&server->backing_dev_info);
-error_splat_bdi:
-	deactivate_locked_super(s);
-	dprintk("<-- nfs_xdev_mount_common() = %d [splat]\n", error);
-	return ERR_PTR(error);
 }
 
 /*
@@ -2539,6 +2493,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 {
 	struct nfs_mount_info mount_info = {
 		.fill_super = nfs_clone_super,
+		.set_security = nfs_clone_sb_security,
 		.cloned   = raw_data,
 		.unshared = NFS_MOUNT_UNSHARED,
 	};
@@ -2631,6 +2586,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 {
 	struct nfs_mount_info mount_info = {
 		.fill_super = nfs4_fill_super,
+		.set_security = nfs_set_sb_security,
 		.parsed = raw_data,
 		.unshared = NFS4_MOUNT_UNSHARED,
 	};
@@ -2807,6 +2763,7 @@ nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 {
 	struct nfs_mount_info mount_info = {
 		.fill_super = nfs4_clone_super,
+		.set_security = nfs_clone_sb_security,
 		.cloned = raw_data,
 		.unshared = NFS4_MOUNT_UNSHARED,
 	};
-- 
1.7.10



> +	mntroot = nfs_fs_mount_common(fs_type, server, flags, dev_name, data->fh, mount_info);
> +out:
>  	return mntroot;
> -
> -out_err_nosb:
> -	nfs_free_server(server);
> -out_err_noserver:
> -	dprintk("<-- nfs_xdev_mount_common() = %d [error]\n", error);
> -	return ERR_PTR(error);
> -
> -error_splat_super:
> -	if (server && !s->s_root)
> -		bdi_unregister(&server->backing_dev_info);
> -error_splat_bdi:
> -	deactivate_locked_super(s);
> -	dprintk("<-- nfs_xdev_mount_common() = %d [splat]\n", error);
> -	return ERR_PTR(error);
>  }
>  
>  /*
> @@ -2631,6 +2587,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
>  {
>  	struct nfs_mount_info mount_info = {
>  		.fill_super = nfs4_fill_super,
> +		.set_security = nfs_set_sb_security,
>  		.parsed = raw_data,
>  		.unshared = NFS4_MOUNT_UNSHARED,
>  	};


