Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2654 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932754Ab2AMULh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:37 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 37/44] NFS: Move v4 super code to the nfs4/ directory
Date: Fri, 13 Jan 2012 15:10:46 -0500
Message-Id: <1326485453-1350-38-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

These functions are needed by the nfs4_fs_type object, so move them into
the v4 subdirectory to compile it all together.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile     |    2 +-
 fs/nfs/nfs4/super.c |  731 +++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/super.c      |  724 --------------------------------------------------
 3 files changed, 732 insertions(+), 725 deletions(-)
 create mode 100644 fs/nfs/nfs4/super.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 6bb7470..34f752d 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -15,7 +15,7 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4/proc.o nfs4/xdr.o nfs4/state.o nfs4/renewd.o \
 			   nfs4/callback_proc.o nfs4/namespace.o \
 			   nfs4/client.o nfs4/module.o nfs4/sysctl.o \
 			   nfs4/getroot.o nfs4/inode.o nfs4/file.o \
-			   nfs4/dir.o
+			   nfs4/dir.o nfs4/super.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/nfs4/super.c b/fs/nfs/nfs4/super.c
new file mode 100644
index 0000000..12efb65
--- /dev/null
+++ b/fs/nfs/nfs4/super.c
@@ -0,0 +1,731 @@
+
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/nfs_fs.h>
+#include <linux/sunrpc/sched.h>
+#include <linux/nfs_fs_sb.h>
+
+#include "delegation.h"
+#include "../internal.h"
+#include "../fscache.h"
+#include "../nfs.h"
+
+#define NFSDBG_FACILITY		NFSDBG_VFS
+
+static struct dentry *nfs4_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data);
+static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data);
+static struct dentry *nfs4_xdev_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data);
+static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data);
+static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data);
+static void nfs4_kill_super(struct super_block *sb);
+
+struct file_system_type nfs4_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.mount		= nfs4_mount,
+	.kill_sb	= nfs4_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+static struct file_system_type nfs4_remote_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.mount		= nfs4_remote_mount,
+	.kill_sb	= nfs4_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+struct file_system_type nfs4_xdev_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.mount		= nfs4_xdev_mount,
+	.kill_sb	= nfs4_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+static struct file_system_type nfs4_remote_referral_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.mount		= nfs4_remote_referral_mount,
+	.kill_sb	= nfs4_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+struct file_system_type nfs4_referral_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.mount		= nfs4_referral_mount,
+	.kill_sb	= nfs4_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+static const struct super_operations nfs4_sops = {
+	.alloc_inode	= nfs_alloc_inode,
+	.destroy_inode	= nfs_destroy_inode,
+	.write_inode	= nfs_write_inode,
+	.put_super	= nfs_put_super,
+	.statfs		= nfs_statfs,
+	.evict_inode	= nfs4_evict_inode,
+	.umount_begin	= nfs_umount_begin,
+	.show_options	= nfs_show_options,
+	.show_devname	= nfs_show_devname,
+	.show_path	= nfs_show_path,
+	.show_stats	= nfs_show_stats,
+	.remount_fs	= nfs_remount,
+};
+
+/*
+ * Finish setting up a cloned NFS4 superblock
+ */
+static void nfs4_clone_super(struct super_block *sb,
+			    const struct super_block *old_sb)
+{
+	sb->s_blocksize_bits = old_sb->s_blocksize_bits;
+	sb->s_blocksize = old_sb->s_blocksize;
+	sb->s_maxbytes = old_sb->s_maxbytes;
+	sb->s_time_gran = 1;
+	sb->s_op = old_sb->s_op;
+	/*
+	 * The VFS shouldn't apply the umask to mode bits. We will do
+	 * so ourselves when necessary.
+	 */
+	sb->s_flags  |= MS_POSIXACL;
+	sb->s_xattr  = old_sb->s_xattr;
+	nfs_initialise_sb(sb);
+}
+
+/*
+ * Set up an NFS4 superblock
+ */
+static void nfs4_fill_super(struct super_block *sb)
+{
+	sb->s_time_gran = 1;
+	sb->s_op = &nfs4_sops;
+	/*
+	 * The VFS shouldn't apply the umask to mode bits. We will do
+	 * so ourselves when necessary.
+	 */
+	sb->s_flags  |= MS_POSIXACL;
+	sb->s_xattr = nfs4_xattr_handlers;
+	nfs_initialise_sb(sb);
+}
+
+static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
+{
+	args->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3|
+			 NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL);
+}
+
+int nfs4_validate_text_mount_data(void *options,
+				  struct nfs_parsed_mount_data *args,
+				  struct nfs_fh *mntfh,
+				  const char *dev_name)
+{
+	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
+
+	nfs_set_port(sap, &args->nfs_server.port, NFS_PORT);
+
+	nfs_validate_transport_protocol(args);
+
+	nfs4_validate_mount_flags(args);
+
+	if (args->version != 4) {
+		dfprintk(MOUNT,
+			 "NFS4: Illegal mount version\n");
+		return -EINVAL;
+	}
+
+	if (args->auth_flavor_len > 1) {
+		dfprintk(MOUNT,
+			 "NFS4: Too many RPC auth flavours specified\n");
+		return -EINVAL;
+	}
+
+	if (args->client_address == NULL) {
+		dfprintk(MOUNT,
+			 "NFS4: mount program didn't pass callback address\n");
+		return -EINVAL;
+	}
+
+	return nfs_parse_devname(dev_name,
+				   &args->nfs_server.hostname,
+				   NFS4_MAXNAMLEN,
+				   &args->nfs_server.export_path,
+				   NFS4_MAXPATHLEN);
+}
+
+/*
+ * Validate NFSv4 mount options
+ */
+static int nfs4_validate_mount_data(void *options,
+				    struct nfs_parsed_mount_data *args,
+				    const char *dev_name)
+{
+	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
+	struct nfs4_mount_data *data = (struct nfs4_mount_data *)options;
+	char *c;
+
+	if (data == NULL)
+		goto out_no_data;
+
+	switch (data->version) {
+	case 1:
+		if (data->host_addrlen > sizeof(args->nfs_server.address))
+			goto out_no_address;
+		if (data->host_addrlen == 0)
+			goto out_no_address;
+		args->nfs_server.addrlen = data->host_addrlen;
+		if (copy_from_user(sap, data->host_addr, data->host_addrlen))
+			return -EFAULT;
+		if (!nfs_verify_server_address(sap))
+			goto out_no_address;
+
+		if (data->auth_flavourlen) {
+			if (data->auth_flavourlen > 1)
+				goto out_inval_auth;
+			if (copy_from_user(&args->auth_flavors[0],
+					   data->auth_flavours,
+					   sizeof(args->auth_flavors[0])))
+				return -EFAULT;
+		}
+
+		c = strndup_user(data->hostname.data, NFS4_MAXNAMLEN);
+		if (IS_ERR(c))
+			return PTR_ERR(c);
+		args->nfs_server.hostname = c;
+
+		c = strndup_user(data->mnt_path.data, NFS4_MAXPATHLEN);
+		if (IS_ERR(c))
+			return PTR_ERR(c);
+		args->nfs_server.export_path = c;
+		dfprintk(MOUNT, "NFS: MNTPATH: '%s'\n", c);
+
+		c = strndup_user(data->client_addr.data, 16);
+		if (IS_ERR(c))
+			return PTR_ERR(c);
+		args->client_address = c;
+
+		/*
+		 * Translate to nfs_parsed_mount_data, which nfs4_fill_super
+		 * can deal with.
+		 */
+
+		args->flags	= data->flags & NFS4_MOUNT_FLAGMASK;
+		args->rsize	= data->rsize;
+		args->wsize	= data->wsize;
+		args->timeo	= data->timeo;
+		args->retrans	= data->retrans;
+		args->acregmin	= data->acregmin;
+		args->acregmax	= data->acregmax;
+		args->acdirmin	= data->acdirmin;
+		args->acdirmax	= data->acdirmax;
+		args->nfs_server.protocol = data->proto;
+		nfs_validate_transport_protocol(args);
+
+		break;
+	default:
+		if (nfs_parse_mount_options((char *)options, args) == 0)
+			return -EINVAL;
+
+		if (!nfs_verify_server_address(sap))
+			return -EINVAL;
+
+		return nfs4_validate_text_mount_data(options, args, NULL, dev_name);
+	}
+
+	return 0;
+
+out_no_data:
+	dfprintk(MOUNT, "NFS4: mount program didn't pass any mount data\n");
+	return -EINVAL;
+
+out_inval_auth:
+	dfprintk(MOUNT, "NFS4: Invalid number of RPC auth flavours %d\n",
+		 data->auth_flavourlen);
+	return -EINVAL;
+
+out_no_address:
+	dfprintk(MOUNT, "NFS4: mount program didn't pass remote address\n");
+	return -EINVAL;
+}
+
+/*
+ * Get the superblock for the NFS4 root partition
+ */
+static struct dentry *
+nfs4_remote_mount(struct file_system_type *fs_type, int flags,
+		  const char *dev_name, void *raw_data)
+{
+	struct nfs_parsed_mount_data *data = raw_data;
+	struct super_block *s;
+	struct nfs_server *server;
+	struct nfs_fh *mntfh;
+	struct dentry *mntroot;
+	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
+	struct nfs_sb_mountdata sb_mntdata = {
+		.mntflags = flags,
+	};
+	int error = -ENOMEM;
+
+	mntfh = nfs_alloc_fhandle();
+	if (data == NULL || mntfh == NULL)
+		goto out;
+
+	/* Get a volume representation */
+	server = nfs4_create_server(data, mntfh);
+	if (IS_ERR(server)) {
+		error = PTR_ERR(server);
+		goto out;
+	}
+	sb_mntdata.server = server;
+
+	if (server->flags & NFS4_MOUNT_UNSHARED)
+		compare_super = NULL;
+
+	/* -o noac implies -o sync */
+	if (server->flags & NFS_MOUNT_NOAC)
+		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
+
+	/* Get a superblock - note that we may end up sharing one that already exists */
+	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
+	if (IS_ERR(s)) {
+		error = PTR_ERR(s);
+		goto out_free;
+	}
+
+	if (s->s_fs_info != server) {
+		nfs_free_server(server);
+		server = NULL;
+	} else {
+		error = nfs_bdi_register(server);
+		if (error)
+			goto error_splat_bdi;
+	}
+
+	if (!s->s_root) {
+		/* initial superblock/root creation */
+		nfs4_fill_super(s);
+		nfs_fscache_get_super_cookie(
+			s, data ? data->fscache_uniq : NULL, NULL);
+	}
+
+	mntroot = nfs4_get_root(s, mntfh, dev_name);
+	if (IS_ERR(mntroot)) {
+		error = PTR_ERR(mntroot);
+		goto error_splat_super;
+	}
+
+	error = security_sb_set_mnt_opts(s, &data->lsm_opts);
+	if (error)
+		goto error_splat_root;
+
+	s->s_flags |= MS_ACTIVE;
+
+	nfs_free_fhandle(mntfh);
+	return mntroot;
+
+out:
+	nfs_free_fhandle(mntfh);
+	return ERR_PTR(error);
+
+out_free:
+	nfs_free_server(server);
+	goto out;
+
+error_splat_root:
+	dput(mntroot);
+error_splat_super:
+	if (server && !s->s_root)
+		bdi_unregister(&server->backing_dev_info);
+error_splat_bdi:
+	deactivate_locked_super(s);
+	goto out;
+}
+
+static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
+		int flags, void *data, const char *hostname)
+{
+	struct vfsmount *root_mnt;
+	char *root_devname;
+	size_t len;
+
+	len = strlen(hostname) + 3;
+	root_devname = kmalloc(len, GFP_KERNEL);
+	if (root_devname == NULL)
+		return ERR_PTR(-ENOMEM);
+	snprintf(root_devname, len, "%s:/", hostname);
+	root_mnt = vfs_kern_mount(fs_type, flags, root_devname, data);
+	kfree(root_devname);
+	return root_mnt;
+}
+
+struct nfs_referral_count {
+	struct list_head list;
+	const struct task_struct *task;
+	unsigned int referral_count;
+};
+
+static LIST_HEAD(nfs_referral_count_list);
+static DEFINE_SPINLOCK(nfs_referral_count_list_lock);
+
+static struct nfs_referral_count *nfs_find_referral_count(void)
+{
+	struct nfs_referral_count *p;
+
+	list_for_each_entry(p, &nfs_referral_count_list, list) {
+		if (p->task == current)
+			return p;
+	}
+	return NULL;
+}
+
+#define NFS_MAX_NESTED_REFERRALS 2
+
+static int nfs_referral_loop_protect(void)
+{
+	struct nfs_referral_count *p, *new;
+	int ret = -ENOMEM;
+
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		goto out;
+	new->task = current;
+	new->referral_count = 1;
+
+	ret = 0;
+	spin_lock(&nfs_referral_count_list_lock);
+	p = nfs_find_referral_count();
+	if (p != NULL) {
+		if (p->referral_count >= NFS_MAX_NESTED_REFERRALS)
+			ret = -ELOOP;
+		else
+			p->referral_count++;
+	} else {
+		list_add(&new->list, &nfs_referral_count_list);
+		new = NULL;
+	}
+	spin_unlock(&nfs_referral_count_list_lock);
+	kfree(new);
+out:
+	return ret;
+}
+
+static void nfs_referral_loop_unprotect(void)
+{
+	struct nfs_referral_count *p;
+
+	spin_lock(&nfs_referral_count_list_lock);
+	p = nfs_find_referral_count();
+	p->referral_count--;
+	if (p->referral_count == 0)
+		list_del(&p->list);
+	else
+		p = NULL;
+	spin_unlock(&nfs_referral_count_list_lock);
+	kfree(p);
+}
+
+static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
+		const char *export_path)
+{
+	struct dentry *dentry;
+	int ret = nfs_referral_loop_protect();
+
+	if (ret) {
+		mntput(root_mnt);
+		return ERR_PTR(ret);
+	}
+
+	dentry = mount_subtree(root_mnt, export_path);
+	nfs_referral_loop_unprotect();
+
+	return dentry;
+}
+
+struct dentry *nfs4_try_mount(struct file_system_type *fs_type, int flags,
+			      const char *dev_name, struct nfs_fh *mntfh,
+			      struct nfs_parsed_mount_data *data)
+{
+	char *export_path;
+	struct vfsmount *root_mnt;
+	struct dentry *res;
+
+	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
+
+	export_path = data->nfs_server.export_path;
+	data->nfs_server.export_path = "/";
+	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, data,
+			data->nfs_server.hostname);
+	data->nfs_server.export_path = export_path;
+
+	res = ERR_CAST(root_mnt);
+	if (!IS_ERR(root_mnt))
+		res = nfs_follow_remote_path(root_mnt, export_path);
+
+	dfprintk(MOUNT, "<-- nfs4_try_mount() = %ld%s\n",
+			IS_ERR(res) ? PTR_ERR(res) : 0,
+			IS_ERR(res) ? " [error]" : "");
+	return res;
+}
+
+/*
+ * Get the superblock for an NFS4 mountpoint
+ */
+static struct dentry *nfs4_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data)
+{
+	struct nfs_parsed_mount_data *data;
+	int error = -ENOMEM;
+	struct dentry *res = ERR_PTR(-ENOMEM);
+
+	data = nfs_alloc_parsed_mount_data(4);
+	if (data == NULL)
+		goto out;
+
+	/* Validate the mount data */
+	error = nfs4_validate_mount_data(raw_data, data, dev_name);
+	if (error < 0) {
+		res = ERR_PTR(error);
+		goto out;
+	}
+
+	res = nfs4_try_mount(fs_type, flags, dev_name, NULL, data);
+	if (IS_ERR(res))
+		error = PTR_ERR(res);
+
+out:
+	nfs_free_parsed_mount_data(data);
+	dprintk("<-- nfs4_mount() = %d%s\n", error,
+			error != 0 ? " [error]" : "");
+	return res;
+}
+
+static void nfs4_kill_super(struct super_block *sb)
+{
+	struct nfs_server *server = NFS_SB(sb);
+
+	dprintk("--> %s\n", __func__);
+	nfs_super_return_all_delegations(sb);
+	kill_anon_super(sb);
+	nfs_fscache_release_super_cookie(sb);
+	nfs_free_server(server);
+	dprintk("<-- %s\n", __func__);
+}
+
+/*
+ * Clone an NFS4 server record on xdev traversal (FSID-change)
+ */
+static struct dentry *
+nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
+		 const char *dev_name, void *raw_data)
+{
+	struct nfs_clone_mount *data = raw_data;
+	struct super_block *s;
+	struct nfs_server *server;
+	struct dentry *mntroot;
+	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
+	struct nfs_sb_mountdata sb_mntdata = {
+		.mntflags = flags,
+	};
+	int error;
+
+	dprintk("--> nfs4_xdev_mount()\n");
+
+	/* create a new volume representation */
+	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
+	if (IS_ERR(server)) {
+		error = PTR_ERR(server);
+		goto out_err_noserver;
+	}
+	sb_mntdata.server = server;
+
+	if (server->flags & NFS4_MOUNT_UNSHARED)
+		compare_super = NULL;
+
+	/* -o noac implies -o sync */
+	if (server->flags & NFS_MOUNT_NOAC)
+		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
+
+	/* Get a superblock - note that we may end up sharing one that already exists */
+	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
+	if (IS_ERR(s)) {
+		error = PTR_ERR(s);
+		goto out_err_nosb;
+	}
+
+	if (s->s_fs_info != server) {
+		nfs_free_server(server);
+		server = NULL;
+	} else {
+		error = nfs_bdi_register(server);
+		if (error)
+			goto error_splat_bdi;
+	}
+
+	if (!s->s_root) {
+		/* initial superblock/root creation */
+		nfs4_clone_super(s, data->sb);
+		nfs_fscache_get_super_cookie(s, NULL, data);
+	}
+
+	mntroot = nfs4_get_root(s, data->fh, dev_name);
+	if (IS_ERR(mntroot)) {
+		error = PTR_ERR(mntroot);
+		goto error_splat_super;
+	}
+	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {
+		dput(mntroot);
+		error = -ESTALE;
+		goto error_splat_super;
+	}
+
+	s->s_flags |= MS_ACTIVE;
+
+	security_sb_clone_mnt_opts(data->sb, s);
+
+	dprintk("<-- nfs4_xdev_mount() = 0\n");
+	return mntroot;
+
+out_err_nosb:
+	nfs_free_server(server);
+out_err_noserver:
+	dprintk("<-- nfs4_xdev_mount() = %d [error]\n", error);
+	return ERR_PTR(error);
+
+error_splat_super:
+	if (server && !s->s_root)
+		bdi_unregister(&server->backing_dev_info);
+error_splat_bdi:
+	deactivate_locked_super(s);
+	dprintk("<-- nfs4_xdev_mount() = %d [splat]\n", error);
+	return ERR_PTR(error);
+}
+
+static struct dentry *
+nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
+			   const char *dev_name, void *raw_data)
+{
+	struct nfs_clone_mount *data = raw_data;
+	struct super_block *s;
+	struct nfs_server *server;
+	struct dentry *mntroot;
+	struct nfs_fh *mntfh;
+	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
+	struct nfs_sb_mountdata sb_mntdata = {
+		.mntflags = flags,
+	};
+	int error = -ENOMEM;
+
+	dprintk("--> nfs4_referral_get_sb()\n");
+
+	mntfh = nfs_alloc_fhandle();
+	if (mntfh == NULL)
+		goto out_err_nofh;
+
+	/* create a new volume representation */
+	server = nfs4_create_referral_server(data, mntfh);
+	if (IS_ERR(server)) {
+		error = PTR_ERR(server);
+		goto out_err_noserver;
+	}
+	sb_mntdata.server = server;
+
+	if (server->flags & NFS4_MOUNT_UNSHARED)
+		compare_super = NULL;
+
+	/* -o noac implies -o sync */
+	if (server->flags & NFS_MOUNT_NOAC)
+		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
+
+	/* Get a superblock - note that we may end up sharing one that already exists */
+	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
+	if (IS_ERR(s)) {
+		error = PTR_ERR(s);
+		goto out_err_nosb;
+	}
+
+	if (s->s_fs_info != server) {
+		nfs_free_server(server);
+		server = NULL;
+	} else {
+		error = nfs_bdi_register(server);
+		if (error)
+			goto error_splat_bdi;
+	}
+
+	if (!s->s_root) {
+		/* initial superblock/root creation */
+		nfs4_fill_super(s);
+		nfs_fscache_get_super_cookie(s, NULL, data);
+	}
+
+	mntroot = nfs4_get_root(s, mntfh, dev_name);
+	if (IS_ERR(mntroot)) {
+		error = PTR_ERR(mntroot);
+		goto error_splat_super;
+	}
+	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {
+		dput(mntroot);
+		error = -ESTALE;
+		goto error_splat_super;
+	}
+
+	s->s_flags |= MS_ACTIVE;
+
+	security_sb_clone_mnt_opts(data->sb, s);
+
+	nfs_free_fhandle(mntfh);
+	dprintk("<-- nfs4_referral_get_sb() = 0\n");
+	return mntroot;
+
+out_err_nosb:
+	nfs_free_server(server);
+out_err_noserver:
+	nfs_free_fhandle(mntfh);
+out_err_nofh:
+	dprintk("<-- nfs4_referral_get_sb() = %d [error]\n", error);
+	return ERR_PTR(error);
+
+error_splat_super:
+	if (server && !s->s_root)
+		bdi_unregister(&server->backing_dev_info);
+error_splat_bdi:
+	deactivate_locked_super(s);
+	nfs_free_fhandle(mntfh);
+	dprintk("<-- nfs4_referral_get_sb() = %d [splat]\n", error);
+	return ERR_PTR(error);
+}
+
+/*
+ * Create an NFS4 server record on referral traversal
+ */
+static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
+		int flags, const char *dev_name, void *raw_data)
+{
+	struct nfs_clone_mount *data = raw_data;
+	char *export_path;
+	struct vfsmount *root_mnt;
+	struct dentry *res;
+
+	dprintk("--> nfs4_referral_mount()\n");
+
+	export_path = data->mnt_path;
+	data->mnt_path = "/";
+
+	root_mnt = nfs_do_root_mount(&nfs4_remote_referral_fs_type,
+			flags, data, data->hostname);
+	data->mnt_path = export_path;
+
+	res = ERR_CAST(root_mnt);
+	if (!IS_ERR(root_mnt))
+		res = nfs_follow_remote_path(root_mnt, export_path);
+	dprintk("<-- nfs4_referral_mount() = %ld%s\n",
+			IS_ERR(res) ? PTR_ERR(res) : 0,
+			IS_ERR(res) ? " [error]" : "");
+	return res;
+}
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a06347d..7bab19e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -299,75 +299,6 @@ static const struct super_operations nfs_sops = {
 	.remount_fs	= nfs_remount,
 };
 
-#ifdef CONFIG_NFS_V4
-static struct dentry *nfs4_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
-static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
-static struct dentry *nfs4_xdev_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
-static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
-static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
-static void nfs4_kill_super(struct super_block *sb);
-
-struct file_system_type nfs4_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_mount,
-	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
-static struct file_system_type nfs4_remote_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_remote_mount,
-	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
-struct file_system_type nfs4_xdev_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_xdev_mount,
-	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
-static struct file_system_type nfs4_remote_referral_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_remote_referral_mount,
-	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
-struct file_system_type nfs4_referral_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_referral_mount,
-	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
-static const struct super_operations nfs4_sops = {
-	.alloc_inode	= nfs_alloc_inode,
-	.destroy_inode	= nfs_destroy_inode,
-	.write_inode	= nfs_write_inode,
-	.put_super	= nfs_put_super,
-	.statfs		= nfs_statfs,
-	.evict_inode	= nfs4_evict_inode,
-	.umount_begin	= nfs_umount_begin,
-	.show_options	= nfs_show_options,
-	.show_devname	= nfs_show_devname,
-	.show_path	= nfs_show_path,
-	.show_stats	= nfs_show_stats,
-	.remount_fs	= nfs_remount,
-};
-#endif
-
 static struct shrinker acl_shrinker = {
 	.shrink		= nfs_access_cache_shrinker,
 	.seeks		= DEFAULT_SEEKS,
@@ -2456,658 +2387,3 @@ error_splat_bdi:
 	dprintk("<-- nfs_xdev_mount() = %d [splat]\n", error);
 	return ERR_PTR(error);
 }
-
-#ifdef CONFIG_NFS_V4
-
-/*
- * Finish setting up a cloned NFS4 superblock
- */
-static void nfs4_clone_super(struct super_block *sb,
-			    const struct super_block *old_sb)
-{
-	sb->s_blocksize_bits = old_sb->s_blocksize_bits;
-	sb->s_blocksize = old_sb->s_blocksize;
-	sb->s_maxbytes = old_sb->s_maxbytes;
-	sb->s_time_gran = 1;
-	sb->s_op = old_sb->s_op;
-	/*
-	 * The VFS shouldn't apply the umask to mode bits. We will do
-	 * so ourselves when necessary.
-	 */
-	sb->s_flags  |= MS_POSIXACL;
-	sb->s_xattr  = old_sb->s_xattr;
-	nfs_initialise_sb(sb);
-}
-
-/*
- * Set up an NFS4 superblock
- */
-static void nfs4_fill_super(struct super_block *sb)
-{
-	sb->s_time_gran = 1;
-	sb->s_op = &nfs4_sops;
-	/*
-	 * The VFS shouldn't apply the umask to mode bits. We will do
-	 * so ourselves when necessary.
-	 */
-	sb->s_flags  |= MS_POSIXACL;
-	sb->s_xattr = nfs4_xattr_handlers;
-	nfs_initialise_sb(sb);
-}
-
-static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
-{
-	args->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3|
-			 NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL);
-}
-
-int nfs4_validate_text_mount_data(void *options,
-				  struct nfs_parsed_mount_data *args,
-				  struct nfs_fh *mntfh,
-				  const char *dev_name)
-{
-	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
-
-	nfs_set_port(sap, &args->nfs_server.port, NFS_PORT);
-
-	nfs_validate_transport_protocol(args);
-
-	nfs4_validate_mount_flags(args);
-
-	if (args->version != 4) {
-		dfprintk(MOUNT,
-			 "NFS4: Illegal mount version\n");
-		return -EINVAL;
-	}
-
-	if (args->auth_flavor_len > 1) {
-		dfprintk(MOUNT,
-			 "NFS4: Too many RPC auth flavours specified\n");
-		return -EINVAL;
-	}
-
-	if (args->client_address == NULL) {
-		dfprintk(MOUNT,
-			 "NFS4: mount program didn't pass callback address\n");
-		return -EINVAL;
-	}
-
-	return nfs_parse_devname(dev_name,
-				   &args->nfs_server.hostname,
-				   NFS4_MAXNAMLEN,
-				   &args->nfs_server.export_path,
-				   NFS4_MAXPATHLEN);
-}
-
-/*
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
-		return nfs4_validate_text_mount_data(options, args, NULL, dev_name);
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
- * Get the superblock for the NFS4 root partition
- */
-static struct dentry *
-nfs4_remote_mount(struct file_system_type *fs_type, int flags,
-		  const char *dev_name, void *raw_data)
-{
-	struct nfs_parsed_mount_data *data = raw_data;
-	struct super_block *s;
-	struct nfs_server *server;
-	struct nfs_fh *mntfh;
-	struct dentry *mntroot;
-	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
-	struct nfs_sb_mountdata sb_mntdata = {
-		.mntflags = flags,
-	};
-	int error = -ENOMEM;
-
-	mntfh = nfs_alloc_fhandle();
-	if (data == NULL || mntfh == NULL)
-		goto out;
-
-	/* Get a volume representation */
-	server = nfs4_create_server(data, mntfh);
-	if (IS_ERR(server)) {
-		error = PTR_ERR(server);
-		goto out;
-	}
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
-		nfs_fscache_get_super_cookie(
-			s, data ? data->fscache_uniq : NULL, NULL);
-	}
-
-	mntroot = nfs4_get_root(s, mntfh, dev_name);
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
-
-out:
-	nfs_free_fhandle(mntfh);
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
-}
-
-static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
-		int flags, void *data, const char *hostname)
-{
-	struct vfsmount *root_mnt;
-	char *root_devname;
-	size_t len;
-
-	len = strlen(hostname) + 3;
-	root_devname = kmalloc(len, GFP_KERNEL);
-	if (root_devname == NULL)
-		return ERR_PTR(-ENOMEM);
-	snprintf(root_devname, len, "%s:/", hostname);
-	root_mnt = vfs_kern_mount(fs_type, flags, root_devname, data);
-	kfree(root_devname);
-	return root_mnt;
-}
-
-struct nfs_referral_count {
-	struct list_head list;
-	const struct task_struct *task;
-	unsigned int referral_count;
-};
-
-static LIST_HEAD(nfs_referral_count_list);
-static DEFINE_SPINLOCK(nfs_referral_count_list_lock);
-
-static struct nfs_referral_count *nfs_find_referral_count(void)
-{
-	struct nfs_referral_count *p;
-
-	list_for_each_entry(p, &nfs_referral_count_list, list) {
-		if (p->task == current)
-			return p;
-	}
-	return NULL;
-}
-
-#define NFS_MAX_NESTED_REFERRALS 2
-
-static int nfs_referral_loop_protect(void)
-{
-	struct nfs_referral_count *p, *new;
-	int ret = -ENOMEM;
-
-	new = kmalloc(sizeof(*new), GFP_KERNEL);
-	if (!new)
-		goto out;
-	new->task = current;
-	new->referral_count = 1;
-
-	ret = 0;
-	spin_lock(&nfs_referral_count_list_lock);
-	p = nfs_find_referral_count();
-	if (p != NULL) {
-		if (p->referral_count >= NFS_MAX_NESTED_REFERRALS)
-			ret = -ELOOP;
-		else
-			p->referral_count++;
-	} else {
-		list_add(&new->list, &nfs_referral_count_list);
-		new = NULL;
-	}
-	spin_unlock(&nfs_referral_count_list_lock);
-	kfree(new);
-out:
-	return ret;
-}
-
-static void nfs_referral_loop_unprotect(void)
-{
-	struct nfs_referral_count *p;
-
-	spin_lock(&nfs_referral_count_list_lock);
-	p = nfs_find_referral_count();
-	p->referral_count--;
-	if (p->referral_count == 0)
-		list_del(&p->list);
-	else
-		p = NULL;
-	spin_unlock(&nfs_referral_count_list_lock);
-	kfree(p);
-}
-
-static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
-		const char *export_path)
-{
-	struct dentry *dentry;
-	int ret = nfs_referral_loop_protect();
-
-	if (ret) {
-		mntput(root_mnt);
-		return ERR_PTR(ret);
-	}
-
-	dentry = mount_subtree(root_mnt, export_path);
-	nfs_referral_loop_unprotect();
-
-	return dentry;
-}
-
-struct dentry *nfs4_try_mount(struct file_system_type *fs_type, int flags,
-			      const char *dev_name, struct nfs_fh *mntfh,
-			      struct nfs_parsed_mount_data *data)
-{
-	char *export_path;
-	struct vfsmount *root_mnt;
-	struct dentry *res;
-
-	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
-
-	export_path = data->nfs_server.export_path;
-	data->nfs_server.export_path = "/";
-	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, data,
-			data->nfs_server.hostname);
-	data->nfs_server.export_path = export_path;
-
-	res = ERR_CAST(root_mnt);
-	if (!IS_ERR(root_mnt))
-		res = nfs_follow_remote_path(root_mnt, export_path);
-
-	dfprintk(MOUNT, "<-- nfs4_try_mount() = %ld%s\n",
-			IS_ERR(res) ? PTR_ERR(res) : 0,
-			IS_ERR(res) ? " [error]" : "");
-	return res;
-}
-
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
-	res = nfs4_try_mount(fs_type, flags, dev_name, NULL, data);
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
-static void nfs4_kill_super(struct super_block *sb)
-{
-	struct nfs_server *server = NFS_SB(sb);
-
-	dprintk("--> %s\n", __func__);
-	nfs_super_return_all_delegations(sb);
-	kill_anon_super(sb);
-	nfs_fscache_release_super_cookie(sb);
-	nfs_free_server(server);
-	dprintk("<-- %s\n", __func__);
-}
-
-/*
- * Clone an NFS4 server record on xdev traversal (FSID-change)
- */
-static struct dentry *
-nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
-		 const char *dev_name, void *raw_data)
-{
-	struct nfs_clone_mount *data = raw_data;
-	struct super_block *s;
-	struct nfs_server *server;
-	struct dentry *mntroot;
-	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
-	struct nfs_sb_mountdata sb_mntdata = {
-		.mntflags = flags,
-	};
-	int error;
-
-	dprintk("--> nfs4_xdev_mount()\n");
-
-	/* create a new volume representation */
-	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
-	if (IS_ERR(server)) {
-		error = PTR_ERR(server);
-		goto out_err_noserver;
-	}
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
-		nfs4_clone_super(s, data->sb);
-		nfs_fscache_get_super_cookie(s, NULL, data);
-	}
-
-	mntroot = nfs4_get_root(s, data->fh, dev_name);
-	if (IS_ERR(mntroot)) {
-		error = PTR_ERR(mntroot);
-		goto error_splat_super;
-	}
-	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {
-		dput(mntroot);
-		error = -ESTALE;
-		goto error_splat_super;
-	}
-
-	s->s_flags |= MS_ACTIVE;
-
-	security_sb_clone_mnt_opts(data->sb, s);
-
-	dprintk("<-- nfs4_xdev_mount() = 0\n");
-	return mntroot;
-
-out_err_nosb:
-	nfs_free_server(server);
-out_err_noserver:
-	dprintk("<-- nfs4_xdev_mount() = %d [error]\n", error);
-	return ERR_PTR(error);
-
-error_splat_super:
-	if (server && !s->s_root)
-		bdi_unregister(&server->backing_dev_info);
-error_splat_bdi:
-	deactivate_locked_super(s);
-	dprintk("<-- nfs4_xdev_mount() = %d [splat]\n", error);
-	return ERR_PTR(error);
-}
-
-static struct dentry *
-nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
-			   const char *dev_name, void *raw_data)
-{
-	struct nfs_clone_mount *data = raw_data;
-	struct super_block *s;
-	struct nfs_server *server;
-	struct dentry *mntroot;
-	struct nfs_fh *mntfh;
-	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
-	struct nfs_sb_mountdata sb_mntdata = {
-		.mntflags = flags,
-	};
-	int error = -ENOMEM;
-
-	dprintk("--> nfs4_referral_get_sb()\n");
-
-	mntfh = nfs_alloc_fhandle();
-	if (mntfh == NULL)
-		goto out_err_nofh;
-
-	/* create a new volume representation */
-	server = nfs4_create_referral_server(data, mntfh);
-	if (IS_ERR(server)) {
-		error = PTR_ERR(server);
-		goto out_err_noserver;
-	}
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
-		nfs4_fill_super(s);
-		nfs_fscache_get_super_cookie(s, NULL, data);
-	}
-
-	mntroot = nfs4_get_root(s, mntfh, dev_name);
-	if (IS_ERR(mntroot)) {
-		error = PTR_ERR(mntroot);
-		goto error_splat_super;
-	}
-	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {
-		dput(mntroot);
-		error = -ESTALE;
-		goto error_splat_super;
-	}
-
-	s->s_flags |= MS_ACTIVE;
-
-	security_sb_clone_mnt_opts(data->sb, s);
-
-	nfs_free_fhandle(mntfh);
-	dprintk("<-- nfs4_referral_get_sb() = 0\n");
-	return mntroot;
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
-}
-
-/*
- * Create an NFS4 server record on referral traversal
- */
-static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
-		int flags, const char *dev_name, void *raw_data)
-{
-	struct nfs_clone_mount *data = raw_data;
-	char *export_path;
-	struct vfsmount *root_mnt;
-	struct dentry *res;
-
-	dprintk("--> nfs4_referral_mount()\n");
-
-	export_path = data->mnt_path;
-	data->mnt_path = "/";
-
-	root_mnt = nfs_do_root_mount(&nfs4_remote_referral_fs_type,
-			flags, data, data->hostname);
-	data->mnt_path = export_path;
-
-	res = ERR_CAST(root_mnt);
-	if (!IS_ERR(root_mnt))
-		res = nfs_follow_remote_path(root_mnt, export_path);
-	dprintk("<-- nfs4_referral_mount() = %ld%s\n",
-			IS_ERR(res) ? PTR_ERR(res) : 0,
-			IS_ERR(res) ? " [error]" : "");
-	return res;
-}
-
-#endif /* CONFIG_NFS_V4 */
-- 
1.7.8.3

