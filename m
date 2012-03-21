Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31911 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757757Ab2CUPVR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:17 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 11/23] NFS: Move lots of code from super.c
Date: Wed, 21 Mar 2012 11:20:41 -0400
Message-Id: <1332343253-24970-12-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch started as an attempt to move from super.c to nfs4super.c,
but each function was dependant on others so I decided that moving
everything over in one chunk would be easier than creating several
smaller (and probably not bisectable) patches.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs.h       |   26 ++-
 fs/nfs/nfs4super.c |  580 +++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/super.c     |  644 ++--------------------------------------------------
 3 files changed, 625 insertions(+), 625 deletions(-)

diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 1f93181..f298c17 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -27,6 +27,11 @@ struct nfs_subversion {
 	struct dentry *(*xdev_mount)(int, const char *, struct nfs_clone_mount *);
 };
 
+struct nfs_sb_mountdata {
+	struct nfs_server *server;
+	int mntflags;
+};
+
 int init_nfs_v4(void);
 void exit_nfs_v4(void);
 
@@ -57,6 +62,25 @@ struct dentry *_nfs_fs_mount(struct file_system_type *, struct nfs_server *,
 			     struct nfs_parsed_mount_data *);
 struct dentry *_nfs_xdev_mount(struct file_system_type *, struct nfs_server *,
 			       int, const char *, void *, int);
-
+struct dentry * nfs_xdev_mount(struct file_system_type *, int, const char *, void *);
+int nfs_statfs(struct dentry *, struct kstatfs *);
+void nfs_umount_begin(struct super_block *);
+struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned);
+void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *);
+int nfs4_validate_text_mount_data(void *, struct nfs_parsed_mount_data *, const char *);
+int nfs_verify_server_address(struct sockaddr *);
+void nfs_validate_transport_protocol(struct nfs_parsed_mount_data *);
+int nfs_parse_mount_options(char *, struct nfs_parsed_mount_data *);
+int nfs_show_options(struct seq_file *, struct dentry *);
+int nfs_show_devname(struct seq_file *, struct dentry *);
+int nfs_show_path(struct seq_file *, struct dentry *);
+int nfs_show_stats(struct seq_file *, struct dentry *);
+int nfs_remount(struct super_block *, int *, char *);
+inline void nfs_initialise_sb(struct super_block *);
+int nfs_compare_super(struct super_block *, void *);
+int nfs_register(struct nfs_server *);
+void nfs_unregister(struct nfs_server *);
+void nfs_put_super(struct super_block *);
+int nfs_set_super(struct super_block *, void *);
 
 #endif /* __LINUX_INTERNAL_NFS_H */
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 9dc0c37..91b4758 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -3,12 +3,581 @@
  */
 #include <linux/module.h>
 #include <linux/nfs_fs.h>
+#include <linux/nfs_mount.h>
 #include <linux/nfs4_mount.h>
 #include <linux/nfs_idmap.h>
 #include "internal.h"
+#include "delegation.h"
+#include "fscache.h"
 #include "nfs4_fs.h"
 #include "nfs.h"
 
+#define NFSDBG_FACILITY		NFSDBG_VFS
+
+struct dentry *nfs4_try_mount(int flags, const char *dev_name,
+	struct nfs_parsed_mount_data *data);
+static struct dentry *nfs4_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data);
+static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
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
+	.mount		= nfs_xdev_mount,
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
+		error = nfs_register(server);
+		if (error)
+			goto error_splat_bdi;
+	}
+
+	if (!s->s_root) {
+		/* initial superblock/root creation */
+		nfs4_fill_super(s);
+		nfs_fscache_get_super_cookie(s, data->fscache_uniq, NULL);
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
+		nfs_unregister(server);
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
+		return nfs4_validate_text_mount_data(options, args, dev_name);
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
+
+static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
+		const char *export_path)
+{
+	struct dentry *dentry;
+	int err;
+
+	if (IS_ERR(root_mnt))
+		return ERR_CAST(root_mnt);
+
+	err = nfs_referral_loop_protect();
+	if (err) {
+		mntput(root_mnt);
+		return ERR_PTR(err);
+	}
+
+	dentry = mount_subtree(root_mnt, export_path);
+	nfs_referral_loop_unprotect();
+
+	return dentry;
+}
+
+struct dentry *nfs4_try_mount(int flags, const char *dev_name,
+			 struct nfs_parsed_mount_data *data)
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
+	res = nfs_follow_remote_path(root_mnt, export_path);
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
+	res = nfs4_try_mount(flags, dev_name, data);
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
+		error = nfs_register(server);
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
+		nfs_unregister(server);
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
+	res = nfs_follow_remote_path(root_mnt, export_path);
+	dprintk("<-- nfs4_referral_mount() = %ld%s\n",
+			IS_ERR(res) ? PTR_ERR(res) : 0,
+			IS_ERR(res) ? " [error]" : "");
+	return res;
+}
+
 static void nfs4_reference(void)
 {
 	try_module_get(THIS_MODULE);
@@ -56,24 +625,31 @@ int __init init_nfs_v4(void)
 
 	err = nfs_idmap_init();
 	if (err < 0)
-		goto out_1;
+		goto out_2;
 
 	err = nfs4_register_sysctl();
 	if (err < 0)
+		goto out_1;
+
+	err = register_filesystem(&nfs4_fs_type);
+	if (err < 0)
 		goto out_0;
 
 	register_nfs_version(&nfs_v4);
 	return 0;
 
 out_0:
-	nfs_idmap_quit();
+	nfs4_unregister_sysctl();
 out_1:
+	nfs_idmap_quit();
+out_2:
 	return err;
 }
 
 void __exit exit_nfs_v4(void)
 {
 	unregister_nfs_version(&nfs_v4);
+	unregister_filesystem(&nfs4_fs_type);
 	nfs4_unregister_sysctl();
 	nfs_idmap_quit();
 }
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 9a9d45d..e2dd324 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -37,12 +37,10 @@
 #include <linux/sunrpc/xprtrdma.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
-#include <linux/nfs4_mount.h>
 #include <linux/lockd/bind.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
 #include <linux/namei.h>
-#include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
 #include <linux/in6.h>
@@ -58,9 +56,6 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
-#include "nfs4_fs.h"
-#include "callback.h"
-#include "delegation.h"
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
@@ -279,19 +274,9 @@ static match_table_t nfs_vers_tokens = {
 	{ Opt_vers_err, NULL }
 };
 
-static void nfs_umount_begin(struct super_block *);
-static int  nfs_statfs(struct dentry *, struct kstatfs *);
-static int  nfs_show_options(struct seq_file *, struct dentry *);
-static int  nfs_show_devname(struct seq_file *, struct dentry *);
-static int  nfs_show_path(struct seq_file *, struct dentry *);
-static int  nfs_show_stats(struct seq_file *, struct dentry *);
 static struct dentry *nfs_fs_mount(struct file_system_type *,
 		int, const char *, void *);
-static struct dentry *nfs_xdev_mount(struct file_system_type *fs_type,
-		int flags, const char *dev_name, void *raw_data);
-static void nfs_put_super(struct super_block *);
 static void nfs_kill_super(struct super_block *);
-static int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 
 struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
@@ -325,77 +310,6 @@ static const struct super_operations nfs_sops = {
 	.remount_fs	= nfs_remount,
 };
 
-#ifdef CONFIG_NFS_V4
-static int nfs4_validate_text_mount_data(void *options,
-	struct nfs_parsed_mount_data *args, const char *dev_name);
-struct dentry *nfs4_try_mount(int flags, const char *dev_name,
-	struct nfs_parsed_mount_data *data);
-static struct dentry *nfs4_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
-static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
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
-	.mount		= nfs_xdev_mount,
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
@@ -415,18 +329,9 @@ int __init register_nfs_fs(void)
 	ret = nfs_register_sysctl();
 	if (ret < 0)
 		goto error_1;
-#ifdef CONFIG_NFS_V4
-	ret = register_filesystem(&nfs4_fs_type);
-	if (ret < 0)
-		goto error_2;
-#endif
 	register_shrinker(&acl_shrinker);
 	return 0;
 
-#ifdef CONFIG_NFS_V4
-error_2:
-	nfs_unregister_sysctl();
-#endif
 error_1:
 	unregister_filesystem(&nfs_fs_type);
 error_0:
@@ -439,9 +344,6 @@ error_0:
 void __exit unregister_nfs_fs(void)
 {
 	unregister_shrinker(&acl_shrinker);
-#ifdef CONFIG_NFS_V4
-	unregister_filesystem(&nfs4_fs_type);
-#endif
 	nfs_unregister_sysctl();
 	unregister_filesystem(&nfs_fs_type);
 }
@@ -465,7 +367,7 @@ void nfs_sb_deactive(struct super_block *sb)
 /*
  * Deliver file system statistics to userspace
  */
-static int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
+int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
 	struct nfs_server *server = NFS_SB(dentry->d_sb);
 	unsigned char blockbits;
@@ -748,7 +650,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 /*
  * Describe the mount options on this VFS mountpoint
  */
-static int nfs_show_options(struct seq_file *m, struct dentry *root)
+int nfs_show_options(struct seq_file *m, struct dentry *root)
 {
 	struct nfs_server *nfss = NFS_SB(root->d_sb);
 
@@ -806,7 +708,7 @@ static void show_implementation_id(struct seq_file *m, struct nfs_server *nfss)
 }
 #endif
 
-static int nfs_show_devname(struct seq_file *m, struct dentry *root)
+int nfs_show_devname(struct seq_file *m, struct dentry *root)
 {
 	char *page = (char *) __get_free_page(GFP_KERNEL);
 	char *devname, *dummy;
@@ -822,7 +724,7 @@ static int nfs_show_devname(struct seq_file *m, struct dentry *root)
 	return err;
 }
 
-static int nfs_show_path(struct seq_file *m, struct dentry *dentry)
+int nfs_show_path(struct seq_file *m, struct dentry *dentry)
 {
 	seq_puts(m, "/");
 	return 0;
@@ -831,7 +733,7 @@ static int nfs_show_path(struct seq_file *m, struct dentry *dentry)
 /*
  * Present statistical information for this VFS mountpoint
  */
-static int nfs_show_stats(struct seq_file *m, struct dentry *root)
+int nfs_show_stats(struct seq_file *m, struct dentry *root)
 {
 	int i, cpu;
 	struct nfs_server *nfss = NFS_SB(root->d_sb);
@@ -924,7 +826,7 @@ static int nfs_show_stats(struct seq_file *m, struct dentry *root)
  * Begin unmount by attempting to remove all automounted mountpoints we added
  * in response to xdev traversals and referrals
  */
-static void nfs_umount_begin(struct super_block *sb)
+void nfs_umount_begin(struct super_block *sb)
 {
 	struct nfs_server *server;
 	struct rpc_clnt *rpc;
@@ -939,7 +841,7 @@ static void nfs_umount_begin(struct super_block *sb)
 		rpc_killall_tasks(rpc);
 }
 
-static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int version)
+struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int version)
 {
 	struct nfs_parsed_mount_data *data;
 
@@ -962,7 +864,7 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int ve
 	return data;
 }
 
-static void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
+void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
 {
 	if (data) {
 		kfree(data->client_address);
@@ -981,7 +883,7 @@ static void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
  * Address family must be initialized, and address must not be
  * the ANY address for that family.
  */
-static int nfs_verify_server_address(struct sockaddr *addr)
+int nfs_verify_server_address(struct sockaddr *addr)
 {
 	switch (addr->sa_family) {
 	case AF_INET: {
@@ -1015,7 +917,7 @@ static void nfs_set_port(struct sockaddr *sap, int *port,
  * Sanity check the NFS transport protocol.
  *
  */
-static void nfs_validate_transport_protocol(struct nfs_parsed_mount_data *mnt)
+void nfs_validate_transport_protocol(struct nfs_parsed_mount_data *mnt)
 {
 	switch (mnt->nfs_server.protocol) {
 	case XPRT_TRANSPORT_UDP:
@@ -1162,8 +1064,7 @@ static int nfs_get_option_ul(substring_t args[], unsigned long *option)
  * skipped as they are encountered.  If there were no errors, return 1;
  * otherwise return 0 (zero).
  */
-static int nfs_parse_mount_options(char *raw,
-				   struct nfs_parsed_mount_data *mnt)
+int nfs_parse_mount_options(char *raw, struct nfs_parsed_mount_data *mnt)
 {
 	char *p, *string, *secdata;
 	int rc, sloppy = 0, invalid_option = 0;
@@ -2042,7 +1943,7 @@ nfs_compare_remount_data(struct nfs_server *nfss,
 	return 0;
 }
 
-static int
+int
 nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 {
 	int error;
@@ -2107,7 +2008,7 @@ out:
 /*
  * Initialise the common bits of the superblock
  */
-static inline void nfs_initialise_sb(struct super_block *sb)
+inline void nfs_initialise_sb(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
@@ -2207,12 +2108,7 @@ Ebusy:
 	return 0;
 }
 
-struct nfs_sb_mountdata {
-	struct nfs_server *server;
-	int mntflags;
-};
-
-static int nfs_set_super(struct super_block *s, void *data)
+int nfs_set_super(struct super_block *s, void *data)
 {
 	struct nfs_sb_mountdata *sb_mntdata = data;
 	struct nfs_server *server = sb_mntdata->server;
@@ -2264,7 +2160,7 @@ static int nfs_compare_super_address(struct nfs_server *server1,
 	return 1;
 }
 
-static int nfs_compare_super(struct super_block *sb, void *data)
+int nfs_compare_super(struct super_block *sb, void *data)
 {
 	struct nfs_sb_mountdata *sb_mntdata = data;
 	struct nfs_server *server = sb_mntdata->server, *old = NFS_SB(sb);
@@ -2285,7 +2181,7 @@ static int nfs_bdi_register(struct nfs_server *server)
 	return bdi_register_dev(&server->backing_dev_info, server->s_dev);
 }
 
-static int nfs_register(struct nfs_server *server)
+int nfs_register(struct nfs_server *server)
 {
 	struct nfs_subversion *nfs_mod = get_nfs_server_version(server);
 	int err = nfs_bdi_register(server);
@@ -2294,7 +2190,7 @@ static int nfs_register(struct nfs_server *server)
 	return err;
 }
 
-static void nfs_unregister(struct nfs_server *server)
+void nfs_unregister(struct nfs_server *server)
 {
 	struct nfs_subversion *nfs_mod = get_nfs_server_version(server);
 	bdi_unregister(&server->backing_dev_info);
@@ -2416,7 +2312,7 @@ out:
  * Ensure that we unregister the bdi before kill_anon_super
  * releases the device name
  */
-static void nfs_put_super(struct super_block *s)
+void nfs_put_super(struct super_block *s)
 {
 	nfs_unregister(NFS_SB(s));
 }
@@ -2516,7 +2412,7 @@ error_splat_bdi:
 }
 EXPORT_SYMBOL_GPL(_nfs_xdev_mount);
 
-static struct dentry *
+struct dentry *
 nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	       const char *dev_name, void *raw_data)
 {
@@ -2527,31 +2423,15 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 
 #ifdef CONFIG_NFS_V4
 
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
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
 {
 	args->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3|
 			 NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL);
 }
 
-static int nfs4_validate_text_mount_data(void *options,
-					 struct nfs_parsed_mount_data *args,
-					 const char *dev_name)
+int nfs4_validate_text_mount_data(void *options,
+				  struct nfs_parsed_mount_data *args,
+				  const char *dev_name)
 {
 	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
 
@@ -2580,484 +2460,4 @@ static int nfs4_validate_text_mount_data(void *options,
 				   NFS4_MAXPATHLEN);
 }
 
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
-		error = nfs_register(server);
-		if (error)
-			goto error_splat_bdi;
-	}
-
-	if (!s->s_root) {
-		/* initial superblock/root creation */
-		nfs4_fill_super(s);
-		nfs_fscache_get_super_cookie(s, data->fscache_uniq, NULL);
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
-		nfs_unregister(server);
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
-	int err;
-
-	if (IS_ERR(root_mnt))
-		return ERR_CAST(root_mnt);
-
-	err = nfs_referral_loop_protect();
-	if (err) {
-		mntput(root_mnt);
-		return ERR_PTR(err);
-	}
-
-	dentry = mount_subtree(root_mnt, export_path);
-	nfs_referral_loop_unprotect();
-
-	return dentry;
-}
-
-struct dentry *nfs4_try_mount(int flags, const char *dev_name,
-			 struct nfs_parsed_mount_data *data)
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
-	res = nfs_follow_remote_path(root_mnt, export_path);
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
-		error = nfs_register(server);
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
-		nfs_unregister(server);
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
-	res = nfs_follow_remote_path(root_mnt, export_path);
-	dprintk("<-- nfs4_referral_mount() = %ld%s\n",
-			IS_ERR(res) ? PTR_ERR(res) : 0,
-			IS_ERR(res) ? " [error]" : "");
-	return res;
-}
-
 #endif /* CONFIG_NFS_V4 */
-- 
1.7.9.4

