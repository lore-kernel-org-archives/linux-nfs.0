Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60590 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751124AbdFBKOG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Jun 2017 06:14:06 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170530145043.GG6365@ZenIV.linux.org.uk>
References: <20170530145043.GG6365@ZenIV.linux.org.uk> <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: dhowells@redhat.com, mszeredi@redhat.com, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [RFC][PATCH 00/23] VFS: Introduce superblock configuration context [ver #4]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 02 Jun 2017 11:14:03 +0100
Message-ID: <1050.1496398443@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Al,

Here are some changes I've made, based on your comments plus a little more:

 (*) Get rid of the old vfs_new_sb_config() and rename
     __vfs_new_sb_config() to that.  The callers then have to provide a
     file_system_type pointer and all the args.

 (*) Add a "struct net *s_net_ns" to struct super_block and add a
     FS_IS_NETFS filesystem flag to indicate that this is a network
     filesystem and that s_net_ns should point to a network namespace (it
     should be NULL otherwise).

     [*] Make alloc_super() take an sb_config.

     [*] Provide an sget_sc() that takes an sb_config rather than type,
     	 flags and data.

     [*] sget_sc() sets the type, flags and namespaces from the sb_config
     	 and requires the superblock it's searching for to match both
     	 s_user_ns and s_net_ns.

     [*] The compare and set functions used by sget_sc() take an sb_config
     	 rather than a void* data pointer.

     [*] The xprt_net check in nfs_compare_super_address() is then
     	 superfluous.

     [*] An nfs_server pointer is added to struct nfs_sb_config rendering
     	 struct nfs_sb_mountdata superfluous.

 (*) Make vfs_new_sb_config() get the user_ns and net_ns from a source
     appropriate to the purpose flag: the current->nsproxy if new, the
     reference sb if submount and none if remount.

 (*) Call ->validate() in do_remount().  Ideally, I should be able to make
     do_remount() use the sb_config path unconditionally, but for
     mount_single().  Why does mount_single() remount the fs if it already
     exists?

 (*) Get rid of vfs_submount_sc() and just call vfs_kern_mount_sc()
     directly, having passed SB_CONFIG_FOR_SUBMOUNT to vfs_new_sb_config().

     [*] Don't set MS_SUBMOUNT in this path as it's only used as a
     	 permissions skip - and we can just check the purpose.

     [*] The user_ns check in vfs_submount_sc() is no longer required as
     	 sb_config carries the user_ns information.

 (*) Removed the inode locking from sys_fsmount().

 (*) Moved the security_sb_mountpoint() call into do_new_mount_sc().

What I haven't done yet:

 (*) Renamed sb_config -> fs_context.  I'd rather avoid renaming again
     unless I really have to.

 (*) Convert MS_* to SB_* flags in s_flags and weed out things that don't
     actually go in there (like MS_SUBMOUNT).  This needs to be a separate
     patch.

 (*) Updated the docs.

 (*) Other filesystem conversions.

David
---
diff --git a/fs/fsopen.c b/fs/fsopen.c
index cbede77158ba..2787792d1fc1 100644
--- a/fs/fsopen.c
+++ b/fs/fsopen.c
@@ -222,6 +222,7 @@ fs_initcall(init_fs_fs);
 SYSCALL_DEFINE3(fsopen, const char __user *, _fs_name, int, reserved,
 		unsigned int, flags)
 {
+	struct file_system_type *fs_type;
 	struct sb_config *sc;
 	struct file *file;
 	const char *fs_name;
@@ -234,8 +235,13 @@ SYSCALL_DEFINE3(fsopen, const char __user *, _fs_name, int, reserved,
 	if (IS_ERR(fs_name))
 		return PTR_ERR(fs_name);
 
-	sc = vfs_new_sb_config(fs_name);
+	fs_type = get_fs_type(fs_name);
 	kfree(fs_name);
+	if (!fs_type)
+		return -ENODEV;
+
+	sc = vfs_new_sb_config(fs_type, NULL, 0, SB_CONFIG_FOR_NEW);
+	put_filesystem(fs_type);
 	if (IS_ERR(sc))
 		return PTR_ERR(sc);
 
diff --git a/fs/libfs.c b/fs/libfs.c
index e8787adf0363..eaaab3b3b820 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -583,7 +583,7 @@ int simple_pin_fs(struct file_system_type *type, struct vfsmount **mount, int *c
 	if (unlikely(!*mount)) {
 		spin_unlock(&pin_fs_lock);
 
-		sc = __vfs_new_sb_config(type, NULL, MS_KERNMOUNT, SB_CONFIG_FOR_NEW);
+		sc = vfs_new_sb_config(type, NULL, MS_KERNMOUNT, SB_CONFIG_FOR_NEW);
 		if (IS_ERR(sc))
 			return PTR_ERR(sc);
 
diff --git a/fs/namespace.c b/fs/namespace.c
index 38ee00e8a45d..083ea719383a 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2297,6 +2297,12 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 		err = parse_monolithic_mount_data(sc, data);
 		if (err < 0)
 			goto err_sc;
+
+		if (sc->ops->validate) {
+			err = sc->ops->validate(sc);
+			if (err < 0)
+				goto err_sc;
+		}
 	} else {
 		err = security_sb_remount(sb, data);
 		if (err)
@@ -2460,6 +2466,10 @@ static int do_new_mount_sc(struct sb_config *sc, struct path *mountpoint,
 	struct vfsmount *mnt;
 	int ret;
 
+	ret = security_sb_mountpoint(sc, mountpoint);
+	if (ret < 0)
+		return ret;;
+
 	mnt = vfs_kern_mount_sc(sc);
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
@@ -2486,21 +2496,28 @@ static int do_new_mount_sc(struct sb_config *sc, struct path *mountpoint,
  * create a new mount for userspace and request it to be added into the
  * namespace's tree
  */
-static int do_new_mount(struct path *mountpoint, const char *fstype, int flags,
-			int mnt_flags, const char *name, void *data)
+static int do_new_mount(struct path *mountpoint, const char *fstype,
+			int ms_flags, int mnt_flags, const char *name,
+			void *data)
 {
+	struct file_system_type *fs_type;
 	struct sb_config *sc;
-	int err;
+	int err = -EINVAL;
 
 	if (!fstype)
-		return -EINVAL;
+		goto err;
+
+	err = -ENODEV;
+	fs_type = get_fs_type(fstype);
+	if (!fs_type)
+		goto err;
 
-	sc = vfs_new_sb_config(fstype);
+	sc = vfs_new_sb_config(fs_type, NULL, ms_flags, SB_CONFIG_FOR_NEW);
+	put_filesystem(fs_type);
 	if (IS_ERR(sc)) {
 		err = PTR_ERR(sc);
 		goto err;
 	}
-	sc->ms_flags = flags;
 
 	err = -ENOMEM;
 	sc->device = kstrdup(name, GFP_KERNEL);
@@ -3174,7 +3191,7 @@ struct vfsmount *vfs_kern_mount(struct file_system_type *type,
 	if (!type)
 		return ERR_PTR(-EINVAL);
 
-	sc = __vfs_new_sb_config(type, NULL, flags, SB_CONFIG_FOR_NEW);
+	sc = vfs_new_sb_config(type, NULL, flags, SB_CONFIG_FOR_NEW);
 	if (IS_ERR(sc))
 		return ERR_CAST(sc);
 
@@ -3209,21 +3226,6 @@ struct vfsmount *vfs_kern_mount(struct file_system_type *type,
 EXPORT_SYMBOL_GPL(vfs_kern_mount);
 
 struct vfsmount *
-vfs_submount_sc(const struct dentry *mountpoint, struct sb_config *sc)
-{
-	/* Until it is worked out how to pass the user namespace
-	 * through from the parent mount to the submount don't support
-	 * unprivileged mounts with submounts.
-	 */
-	if (mountpoint->d_sb->s_user_ns != &init_user_ns)
-		return ERR_PTR(-EPERM);
-
-	sc->ms_flags = MS_SUBMOUNT;
-	return vfs_kern_mount_sc(sc);
-}
-EXPORT_SYMBOL_GPL(vfs_submount_sc);
-
-struct vfsmount *
 vfs_submount(const struct dentry *mountpoint, struct file_system_type *type,
 	     const char *name, void *data)
 {
@@ -3247,7 +3249,6 @@ SYSCALL_DEFINE5(fsmount, int, fs_fd, int, dfd, const char __user *, dir_name,
 		unsigned int, at_flags, unsigned int, flags)
 {
 	struct sb_config *sc;
-	struct inode *inode;
 	struct path mountpoint;
 	struct fd f;
 	unsigned int lookup_flags, mnt_flags = 0;
@@ -3316,13 +3317,8 @@ SYSCALL_DEFINE5(fsmount, int, fs_fd, int, dfd, const char __user *, dir_name,
 		goto err_fsfd;
 	}
 
-	ret = security_sb_mountpoint(sc, &mountpoint);
-	if (ret < 0)
-		goto err_mp;
-
 	ret = do_new_mount_sc(sc, &mountpoint, mnt_flags);
 
-err_mp:
 	path_put(&mountpoint);
 err_fsfd:
 	fdput(f);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7acca9f53bcd..7dd98709d247 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -130,6 +130,7 @@ struct nfs_sb_config {
 
 	struct nfs_fh		*mntfh;
 	struct nfs_subversion	*nfs_mod;
+	struct nfs_server	*server;
 
 	int (*set_security)(struct super_block *, struct nfs_sb_config *);
 
diff --git a/fs/nfs/mount.c b/fs/nfs/mount.c
index 4ab3338b2208..27ac3b373168 100644
--- a/fs/nfs/mount.c
+++ b/fs/nfs/mount.c
@@ -1401,7 +1401,6 @@ static int nfs_mount_init_from_sb(struct sb_config *sc,
 {
 	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
 	struct nfs_server *nfss = sb->s_fs_info;
-	struct net *net = nfss->nfs_client->cl_net;
 
 	cfg->flags		= nfss->flags;
 	cfg->rsize		= nfss->rsize;
@@ -1421,9 +1420,9 @@ static int nfs_mount_init_from_sb(struct sb_config *sc,
 	memcpy(&cfg->nfs_server.address, &nfss->nfs_client->cl_addr,
 		cfg->nfs_server.addrlen);
 
-	if (cfg->sc.net_ns != net) {
-		put_net(cfg->sc.net_ns);
-		cfg->sc.net_ns = get_net(net);
+	if (cfg->sc.net_ns != nfss->nfs_client->cl_net) {
+		WARN_ON(1);
+		return -EINVAL;
 	}
 
 	cfg->nfs_mod = nfss->nfs_client->cl_nfs_mod;
@@ -1476,10 +1475,10 @@ static int nfs_init_sb_config(struct sb_config *sc, struct super_block *src_sb)
 struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs",
-	.init_sb_config	= nfs_init_sb_config,
 	.sb_config_size	= sizeof(struct nfs_sb_config),
+	.init_sb_config	= nfs_init_sb_config,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA|FS_IS_NETFS,
 };
 MODULE_ALIAS_FS("nfs");
 EXPORT_SYMBOL_GPL(nfs_fs_type);
@@ -1491,7 +1490,7 @@ struct file_system_type nfs4_fs_type = {
 	.sb_config_size	= sizeof(struct nfs_sb_config),
 	.init_sb_config	= nfs_init_sb_config,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA|FS_IS_NETFS,
 };
 MODULE_ALIAS_FS("nfs4");
 MODULE_ALIAS("nfs4");
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index e95e669e4db8..e8e620b2de41 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -210,15 +210,6 @@ void nfs_release_automount_timer(void)
 		cancel_delayed_work(&nfs_automount_task);
 }
 
-/*
- * Clone a mountpoint of the appropriate type
- */
-static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
-					   struct nfs_sb_config *cfg)
-{
-	return vfs_submount_sc(cfg->clone_data.dentry, &cfg->sc);
-}
-
 /**
  * nfs_do_submount - set up mountpoint when crossing a filesystem boundary
  * @dentry - parent directory
@@ -239,8 +230,8 @@ struct vfsmount *nfs_do_submount(struct dentry *dentry, struct nfs_fh *fh,
 	/* Open a new mount context, transferring parameters from the parent
 	 * superblock, including the network namespace.
 	 */
-	sc = __vfs_new_sb_config(&nfs_fs_type, dentry->d_sb, 0,
-				 SB_CONFIG_FOR_SUBMOUNT);
+	sc = vfs_new_sb_config(&nfs_fs_type, dentry->d_sb, 0,
+			       SB_CONFIG_FOR_SUBMOUNT);
 	if (IS_ERR(sc))
 		return ERR_CAST(sc);
 	cfg = container_of(sc, struct nfs_sb_config, sc);
@@ -275,7 +266,7 @@ struct vfsmount *nfs_do_submount(struct dentry *dentry, struct nfs_fh *fh,
 	if (ret < 0)
 		goto err_sc;
 
-	mnt = nfs_do_clone_mount(NFS_SB(dentry->d_sb), cfg);
+	mnt = vfs_kern_mount_sc(&cfg->sc);
 	goto err_sc;
 
 err_buffer:
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 60b711aa0618..978ee33a19ab 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -322,7 +322,7 @@ static struct vfsmount *try_location(struct dentry *dentry,
 		p += cfg->nfs_server.export_path_len;
 		*p = 0;
 
-		mnt = vfs_submount_sc(cfg->clone_data.dentry, &cfg->sc);
+		mnt = vfs_kern_mount_sc(&cfg->sc);
 		if (!IS_ERR(mnt))
 			break;
 	}
@@ -347,8 +347,8 @@ static struct vfsmount *nfs_follow_referral(struct dentry *dentry,
 	if (locations == NULL || locations->nlocations <= 0)
 		goto out;
 
-	sc = __vfs_new_sb_config(&nfs4_fs_type, dentry->d_sb, 0,
-				 SB_CONFIG_FOR_SUBMOUNT);
+	sc = vfs_new_sb_config(&nfs4_fs_type, dentry->d_sb, 0,
+			       SB_CONFIG_FOR_SUBMOUNT);
 	if (IS_ERR(sc)) {
 		mnt = ERR_CAST(sc);
 		goto out;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 34a7c16cb33c..92293315b070 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1013,13 +1013,14 @@ static void nfs_clone_super(struct super_block *sb, struct nfs_sb_config *cfg)
  	nfs_initialise_sb(sb);
 }
 
-static int nfs_compare_mount_options(const struct super_block *s, const struct nfs_server *b, int flags)
+static int nfs_compare_mount_options(const struct super_block *s, const struct nfs_server *b,
+				     const struct nfs_sb_config *cfg)
 {
 	const struct nfs_server *a = s->s_fs_info;
 	const struct rpc_clnt *clnt_a = a->client;
 	const struct rpc_clnt *clnt_b = b->client;
 
-	if ((s->s_flags & NFS_MS_MASK) != (flags & NFS_MS_MASK))
+	if ((s->s_flags & NFS_MS_MASK) != (cfg->sc.ms_flags & NFS_MS_MASK))
 		goto Ebusy;
 	if (a->nfs_client != b->nfs_client)
 		goto Ebusy;
@@ -1045,18 +1046,13 @@ static int nfs_compare_mount_options(const struct super_block *s, const struct n
 	return 0;
 }
 
-struct nfs_sb_mountdata {
-	struct nfs_server *server;
-	int mntflags;
-};
-
-static int nfs_set_super(struct super_block *s, void *data)
+static int nfs_set_super(struct super_block *s, struct sb_config *sc)
 {
-	struct nfs_sb_mountdata *sb_mntdata = data;
-	struct nfs_server *server = sb_mntdata->server;
+	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
+	struct nfs_server *server = cfg->server;
 	int ret;
 
-	s->s_flags = sb_mntdata->mntflags;
+	s->s_flags = cfg->sc.ms_flags;
 	s->s_fs_info = server;
 	s->s_d_op = server->nfs_client->rpc_ops->dentry_ops;
 	ret = set_anon_super(s, server);
@@ -1069,11 +1065,6 @@ static int nfs_compare_super_address(struct nfs_server *server1,
 				     struct nfs_server *server2)
 {
 	struct sockaddr *sap1, *sap2;
-	struct rpc_xprt *xprt1 = server1->client->cl_xprt;
-	struct rpc_xprt *xprt2 = server2->client->cl_xprt;
-
-	if (!net_eq(xprt1->xprt_net, xprt2->xprt_net))
-		return 0;
 
 	sap1 = (struct sockaddr *)&server1->nfs_client->cl_addr;
 	sap2 = (struct sockaddr *)&server2->nfs_client->cl_addr;
@@ -1107,11 +1098,10 @@ static int nfs_compare_super_address(struct nfs_server *server1,
 	return 1;
 }
 
-static int nfs_compare_super(struct super_block *sb, void *data)
+static int nfs_compare_super(struct super_block *sb, struct sb_config *sc)
 {
-	struct nfs_sb_mountdata *sb_mntdata = data;
-	struct nfs_server *server = sb_mntdata->server, *old = NFS_SB(sb);
-	int mntflags = sb_mntdata->mntflags;
+	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
+	struct nfs_server *server = cfg->server, *old = NFS_SB(sb);
 
 	if (!nfs_compare_super_address(old, server))
 		return 0;
@@ -1120,7 +1110,7 @@ static int nfs_compare_super(struct super_block *sb, void *data)
 		return 0;
 	if (memcmp(&old->fsid, &server->fsid, sizeof(old->fsid)) != 0)
 		return 0;
-	return nfs_compare_mount_options(sb, server, mntflags);
+	return nfs_compare_mount_options(sb, server, cfg);
 }
 
 #ifdef CONFIG_NFS_FSCACHE
@@ -1199,11 +1189,7 @@ int nfs_get_tree_common(struct nfs_server *server, struct nfs_sb_config *cfg)
 {
 	struct super_block *s;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
-	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
-	struct nfs_sb_mountdata sb_mntdata = {
-		.mntflags = cfg->sc.ms_flags,
-		.server = server,
-	};
+	int (*compare_super)(struct super_block *, struct sb_config *) = nfs_compare_super;
 	int error;
 
 	if (server->flags & NFS_MOUNT_UNSHARED)
@@ -1211,15 +1197,16 @@ int nfs_get_tree_common(struct nfs_server *server, struct nfs_sb_config *cfg)
 
 	/* -o noac implies -o sync */
 	if (server->flags & NFS_MOUNT_NOAC)
-		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
+		cfg->sc.ms_flags |= MS_SYNCHRONOUS;
 
 	if (cfg->clone_data.cloned && cfg->clone_data.sb != NULL)
 		if (cfg->clone_data.sb->s_flags & MS_SYNCHRONOUS)
-			sb_mntdata.mntflags |= MS_SYNCHRONOUS;
+			cfg->sc.ms_flags |= MS_SYNCHRONOUS;
 
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(cfg->nfs_mod->nfs_fs, compare_super, nfs_set_super, cfg->sc.ms_flags,
-		 &sb_mntdata);
+	cfg->server = server;
+	s = sget_sc(&cfg->sc, compare_super, nfs_set_super);
+	cfg->server = NULL;
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
 		errorf("NFS: Couldn't get superblock");
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 9878b62e874c..c5d24c5f23cd 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -299,7 +299,7 @@ int pid_ns_prepare_proc(struct pid_namespace *ns)
 	struct vfsmount *mnt;
 	int ret;
 
-	sc = __vfs_new_sb_config(&proc_fs_type, NULL, 0, SB_CONFIG_FOR_NEW);
+	sc = vfs_new_sb_config(&proc_fs_type, NULL, 0, SB_CONFIG_FOR_NEW);
 	if (IS_ERR(sc))
 		return PTR_ERR(sc);
 
diff --git a/fs/sb_config.c b/fs/sb_config.c
index 4d9bfb982d41..74319550e4e7 100644
--- a/fs/sb_config.c
+++ b/fs/sb_config.c
@@ -178,10 +178,10 @@ int generic_monolithic_mount_data(struct sb_config *ctx, void *data)
 EXPORT_SYMBOL(generic_monolithic_mount_data);
 
 /**
- * __vfs_new_sb_config - Create a superblock config.
+ * vfs_new_sb_config - Create a superblock config.
  * @fs_type: The filesystem type.
  * @src_sb: A superblock from which this one derives (or NULL)
- * @ms_flags: Superblock flags and op flags (such as MS_REMOUNT)
+ * @ms_flags: Superblock flags.
  * @purpose: The purpose that this configuration shall be used for.
  *
  * Open a filesystem and create a mount context.  The mount context is
@@ -189,10 +189,10 @@ EXPORT_SYMBOL(generic_monolithic_mount_data);
  * another superblock (@src_sb), may have parameters such as namespaces copied
  * across from that superblock.
  */
-struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
-				      struct super_block *src_sb,
-				      unsigned int ms_flags,
-				      enum sb_config_purpose purpose)
+struct sb_config *vfs_new_sb_config(struct file_system_type *fs_type,
+				    struct super_block *src_sb,
+				    unsigned int ms_flags,
+				    enum sb_config_purpose purpose)
 {
 	struct sb_config *sc;
 	size_t sc_size = fs_type->sb_config_size;
@@ -210,10 +210,27 @@ struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
 	sc->purpose	= purpose;
 	sc->ms_flags	= ms_flags;
 	sc->fs_type	= get_filesystem(fs_type);
-	sc->net_ns	= get_net(current->nsproxy->net_ns);
-	sc->user_ns	= get_user_ns(current_user_ns());
 	sc->cred	= get_current_cred();
 
+	switch (purpose) {
+	case SB_CONFIG_FOR_NEW:
+		sc->user_ns = get_user_ns(sc->cred->user_ns);
+		if (fs_type->fs_flags & FS_IS_NETFS)
+			sc->net_ns = get_net(current->nsproxy->net_ns);
+		break;
+	case SB_CONFIG_FOR_SUBMOUNT:
+		sc->user_ns = get_user_ns(src_sb->s_user_ns);
+		if (src_sb->s_net_ns)
+			sc->net_ns = get_net(src_sb->s_net_ns);
+		break;
+	case SB_CONFIG_FOR_REMOUNT:
+		/* We don't pin any namespaces as the superblock's
+		 * subscriptions cannot be changed at this point.
+		 */
+		break;
+	}
+
+
 	/* TODO: Make all filesystems support this unconditionally */
 	if (sc->fs_type->init_sb_config) {
 		ret = sc->fs_type->init_sb_config(sc, src_sb);
@@ -236,31 +253,6 @@ struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
 	put_sb_config(sc);
 	return ERR_PTR(ret);
 }
-EXPORT_SYMBOL(__vfs_new_sb_config);
-
-/**
- * vfs_new_sb_config - Create a superblock config for a new mount.
- * @fs_name: The name of the filesystem
- *
- * Open a filesystem and create a superblock config context for a new mount
- * that will hold the mount options, device name, security details, etc..  Note
- * that the caller should check the ->ops pointer in the returned context to
- * determine whether the filesystem actually supports the superblock context
- * itself.
- */
-struct sb_config *vfs_new_sb_config(const char *fs_name)
-{
-	struct file_system_type *fs_type;
-	struct sb_config *sc;
-
-	fs_type = get_fs_type(fs_name);
-	if (!fs_type)
-		return ERR_PTR(-ENODEV);
-
-	sc = __vfs_new_sb_config(fs_type, NULL, 0, SB_CONFIG_FOR_NEW);
-	put_filesystem(fs_type);
-	return sc;
-}
 EXPORT_SYMBOL(vfs_new_sb_config);
 
 /**
@@ -274,8 +266,8 @@ EXPORT_SYMBOL(vfs_new_sb_config);
 struct sb_config *vfs_sb_reconfig(struct vfsmount *mnt,
 				  unsigned int ms_flags)
 {
-	return __vfs_new_sb_config(mnt->mnt_sb->s_type, mnt->mnt_sb,
-				   ms_flags, SB_CONFIG_FOR_REMOUNT);
+	return vfs_new_sb_config(mnt->mnt_sb->s_type, mnt->mnt_sb,
+				 ms_flags, SB_CONFIG_FOR_REMOUNT);
 }
 
 /**
diff --git a/fs/super.c b/fs/super.c
index c2c0435550f6..1412ac0a88d8 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -34,6 +34,7 @@
 #include <linux/fsnotify.h>
 #include <linux/lockdep.h>
 #include <linux/user_namespace.h>
+#include <net/net_namespace.h>
 #include <linux/sb_config.h>
 #include "internal.h"
 
@@ -174,16 +175,13 @@ static void destroy_super(struct super_block *s)
 }
 
 /**
- *	alloc_super	-	create new superblock
- *	@type:	filesystem type superblock should belong to
- *	@flags: the mount flags
- *	@user_ns: User namespace for the super_block
+ *	alloc_super - Create new superblock
+ *	@sc: The filesystem configuration context
  *
  *	Allocates and initializes a new &struct super_block.  alloc_super()
  *	returns a pointer new superblock or %NULL if allocation had failed.
  */
-static struct super_block *alloc_super(struct file_system_type *type, int flags,
-				       struct user_namespace *user_ns)
+static struct super_block *alloc_super(struct sb_config *sc)
 {
 	struct super_block *s = kzalloc(sizeof(struct super_block),  GFP_USER);
 	static const struct super_operations default_op;
@@ -193,7 +191,8 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 		return NULL;
 
 	INIT_LIST_HEAD(&s->s_mounts);
-	s->s_user_ns = get_user_ns(user_ns);
+	s->s_user_ns = get_user_ns(sc->user_ns);
+	s->s_net_ns = sc->net_ns ? get_net(sc->net_ns) : NULL;
 
 	if (security_sb_alloc(s))
 		goto fail;
@@ -201,12 +200,12 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	for (i = 0; i < SB_FREEZE_LEVELS; i++) {
 		if (__percpu_init_rwsem(&s->s_writers.rw_sem[i],
 					sb_writers_name[i],
-					&type->s_writers_key[i]))
+					&sc->fs_type->s_writers_key[i]))
 			goto fail;
 	}
 	init_waitqueue_head(&s->s_writers.wait_unfrozen);
 	s->s_bdi = &noop_backing_dev_info;
-	s->s_flags = flags;
+	s->s_flags = sc->ms_flags;
 	if (s->s_user_ns != &init_user_ns)
 		s->s_iflags |= SB_I_NODEV;
 	INIT_HLIST_NODE(&s->s_instances);
@@ -223,7 +222,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 		goto fail;
 
 	init_rwsem(&s->s_umount);
-	lockdep_set_class(&s->s_umount, &type->s_umount_key);
+	lockdep_set_class(&s->s_umount, &sc->fs_type->s_umount_key);
 	/*
 	 * sget() can have s_umount recursion.
 	 *
@@ -243,7 +242,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	s->s_count = 1;
 	atomic_set(&s->s_active, 1);
 	mutex_init(&s->s_vfs_rename_mutex);
-	lockdep_set_class(&s->s_vfs_rename_mutex, &type->s_vfs_rename_key);
+	lockdep_set_class(&s->s_vfs_rename_mutex, &sc->fs_type->s_vfs_rename_key);
 	mutex_init(&s->s_dquot.dqio_mutex);
 	s->s_maxbytes = MAX_NON_LFS;
 	s->s_op = &default_op;
@@ -456,6 +455,80 @@ void generic_shutdown_super(struct super_block *sb)
 EXPORT_SYMBOL(generic_shutdown_super);
 
 /**
+ *	sget_sc - Find or create a superblock
+ *	@sc:	Configuration context.
+ *	@test:	comparison callback
+ *	@set:	setup callback
+ */
+struct super_block *sget_sc(struct sb_config *sc,
+			    int (*test)(struct super_block *, struct sb_config *),
+			    int (*set)(struct super_block *, struct sb_config *))
+{
+	struct super_block *s = NULL;
+	struct super_block *old;
+	int err;
+
+	if (!(sc->ms_flags & MS_KERNMOUNT) &&
+	    sc->purpose != SB_CONFIG_FOR_SUBMOUNT) {
+		if (!(sc->fs_type->fs_flags & FS_USERNS_MOUNT) &&
+		    !capable(CAP_SYS_ADMIN))
+			return ERR_PTR(-EPERM);
+		else if (!ns_capable(sc->user_ns, CAP_SYS_ADMIN))
+			return ERR_PTR(-EPERM);
+	}
+
+retry:
+	spin_lock(&sb_lock);
+	if (test) {
+		hlist_for_each_entry(old, &sc->fs_type->fs_supers, s_instances) {
+			if (!test(old, sc))
+				continue;
+			if (sc->user_ns != old->s_user_ns &&
+			    !net_eq(sc->net_ns, old->s_net_ns)) {
+				spin_unlock(&sb_lock);
+				if (s) {
+					up_write(&s->s_umount);
+					destroy_super(s);
+				}
+				return ERR_PTR(-EBUSY);
+			}
+			if (!grab_super(old))
+				goto retry;
+			if (s) {
+				up_write(&s->s_umount);
+				destroy_super(s);
+				s = NULL;
+			}
+			return old;
+		}
+	}
+	if (!s) {
+		spin_unlock(&sb_lock);
+		s = alloc_super(sc);
+		if (!s)
+			return ERR_PTR(-ENOMEM);
+		goto retry;
+	}
+
+	err = set(s, sc);
+	if (err) {
+		spin_unlock(&sb_lock);
+		up_write(&s->s_umount);
+		destroy_super(s);
+		return ERR_PTR(err);
+	}
+	s->s_type = sc->fs_type;
+	strlcpy(s->s_id, s->s_type->name, sizeof(s->s_id));
+	list_add_tail(&s->s_list, &super_blocks);
+	hlist_add_head(&s->s_instances, &s->s_type->fs_supers);
+	spin_unlock(&sb_lock);
+	get_filesystem(s->s_type);
+	register_shrinker(&s->s_shrink);
+	return s;
+}
+EXPORT_SYMBOL(sget_sc);
+
+/**
  *	sget_userns -	find or create a superblock
  *	@type:	filesystem type superblock should belong to
  *	@test:	comparison callback
@@ -504,7 +577,14 @@ struct super_block *sget_userns(struct file_system_type *type,
 	}
 	if (!s) {
 		spin_unlock(&sb_lock);
-		s = alloc_super(type, (flags & ~MS_SUBMOUNT), user_ns);
+		{
+			struct sb_config sc = {
+				.fs_type	= type,
+				.ms_flags	= flags & ~MS_SUBMOUNT,
+				.user_ns	= user_ns,
+			};
+			s = alloc_super(&sc);
+		}
 		if (!s)
 			return ERR_PTR(-ENOMEM);
 		goto retry;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1acb76f400c4..110aa4125787 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1388,6 +1388,11 @@ struct super_block {
 	 */
 	struct user_namespace *s_user_ns;
 
+	/* If a network filesystem, this is the network namespace in which it
+	 * resides.
+	 */
+	struct net *s_net_ns;
+	
 	/*
 	 * Keep the lru lists last in the structure so they always sit on their
 	 * own individual cachelines.
@@ -2022,11 +2027,12 @@ int sync_inode_metadata(struct inode *inode, int wait);
 
 struct file_system_type {
 	const char *name;
-	int fs_flags;
+	unsigned int fs_flags;
 #define FS_REQUIRES_DEV		1 
 #define FS_BINARY_MOUNTDATA	2
 #define FS_HAS_SUBTYPE		4
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
+#define FS_IS_NETFS		0x10	/* Network fs that uses net namespace (->s_net_ns) */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
 	unsigned short sb_config_size;	/* Size of superblock config context to allocate */
 	struct dentry *(*mount) (struct file_system_type *, int,
@@ -2075,6 +2081,9 @@ void deactivate_locked_super(struct super_block *sb);
 int set_anon_super(struct super_block *s, void *data);
 int get_anon_bdev(dev_t *);
 void free_anon_bdev(dev_t);
+struct super_block *sget_sc(struct sb_config *sc,
+			    int (*test)(struct super_block *, struct sb_config *),
+			    int (*set)(struct super_block *, struct sb_config *));
 struct super_block *sget_userns(struct file_system_type *type,
 			int (*test)(struct super_block *,void *),
 			int (*set)(struct super_block *,void *),
diff --git a/include/linux/mount.h b/include/linux/mount.h
index a5dca6abc4d5..e57067da7c2a 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -95,8 +95,6 @@ extern struct vfsmount *vfs_kern_mount_sc(struct sb_config *sc);
 extern struct vfsmount *vfs_submount(const struct dentry *mountpoint,
 				     struct file_system_type *type,
 				     const char *name, void *data);
-extern struct vfsmount *vfs_submount_sc(const struct dentry *mountpoint,
-					struct sb_config *sc);
 
 extern void mnt_set_expiry(struct vfsmount *mnt, struct list_head *expiry_list);
 extern void mark_mounts_for_expiry(struct list_head *mounts);
diff --git a/include/linux/sb_config.h b/include/linux/sb_config.h
index 144258d82fa1..eec37099f388 100644
--- a/include/linux/sb_config.h
+++ b/include/linux/sb_config.h
@@ -69,11 +69,10 @@ struct sb_config_operations {
 	int (*get_tree)(struct sb_config *sc);
 };
 
-extern struct sb_config *vfs_new_sb_config(const char *fs_name);
-extern struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
-					     struct super_block *src_sb,
-					     unsigned int ms_flags,
-					     enum sb_config_purpose purpose);
+extern struct sb_config *vfs_new_sb_config(struct file_system_type *fs_type,
+					   struct super_block *src_sb,
+					   unsigned int ms_flags,
+					   enum sb_config_purpose purpose);
 extern struct sb_config *vfs_sb_reconfig(struct vfsmount *mnt,
 					 unsigned int ms_flags);
 extern struct sb_config *vfs_dup_sb_config(struct sb_config *src);
