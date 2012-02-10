Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760263Ab2BJWCV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:21 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 11/21] NFS: Move lots of code from super.c
Date: Fri, 10 Feb 2012 17:01:55 -0500
Message-Id: <1328911325-1566-11-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Each function that I moved required me to move two more functions... and
then solve a bunch of modpost errors.  I really wanted this to be less
than 1500 lines (actually, I was hoping for less than 1000).  Too bad
that didn't work out...

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/fscache.c   |    3 +
 fs/nfs/inode.c     |    3 +
 fs/nfs/nfs.h       |   26 ++-
 fs/nfs/nfs4super.c |  571 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/super.c     |  649 ++++------------------------------------------------
 fs/nfs/write.c     |    1 +
 6 files changed, 646 insertions(+), 607 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index 419119c..a5460ff 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -9,6 +9,7 @@
  * 2 of the Licence, or (at your option) any later version.
  */
 
+#include <linux/module.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -163,6 +164,7 @@ non_unique:
 	printk(KERN_WARNING "NFS:"
 	       " Cache request denied due to non-unique superblock keys\n");
 }
+EXPORT_SYMBOL_GPL(nfs_fscache_get_super_cookie);
 
 /*
  * release a per-superblock cookie
@@ -185,6 +187,7 @@ void nfs_fscache_release_super_cookie(struct super_block *sb)
 		nfss->fscache_key = NULL;
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_fscache_release_super_cookie);
 
 /*
  * Initialise the per-inode cache cookie pointer for an NFS inode.
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index da01c56..53bb916 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1459,6 +1459,7 @@ void nfs4_evict_inode(struct inode *inode)
 	/* First call standard NFS clear_inode() code */
 	nfs_clear_inode(inode);
 }
+EXPORT_SYMBOL_GPL(nfs4_evict_inode);
 #endif
 
 struct inode *nfs_alloc_inode(struct super_block *sb)
@@ -1478,6 +1479,7 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
 #endif /* CONFIG_NFS_V4 */
 	return &nfsi->vfs_inode;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_inode);
 
 static void nfs_i_callback(struct rcu_head *head)
 {
@@ -1489,6 +1491,7 @@ void nfs_destroy_inode(struct inode *inode)
 {
 	call_rcu(&inode->i_rcu, nfs_i_callback);
 }
+EXPORT_SYMBOL_GPL(nfs_destroy_inode);
 
 static inline void nfs4_init_once(struct nfs_inode *nfsi)
 {
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index cf49c63..dc1854c 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -29,6 +29,11 @@ struct nfs_subversion {
 	struct dentry *(*xdev_mount)(int, const char *, struct nfs_clone_mount *);
 };
 
+struct nfs_sb_mountdata {
+	struct nfs_server *server;
+	int mntflags;
+};
+
 int init_nfs_v4(void);
 void exit_nfs_v4(void);
 
@@ -59,6 +64,25 @@ struct dentry *_nfs_fs_mount(struct file_system_type *, struct nfs_server *,
 			     struct nfs_parsed_mount_data *);
 struct dentry *_nfs_xdev_mount(struct file_system_type *, struct nfs_server *,
 			       int, const char *, void *, int);
-
+struct dentry * nfs_xdev_mount(struct file_system_type *, int, const char *, void *);
+int nfs_statfs(struct dentry *, struct kstatfs *);
+void nfs_umount_begin(struct super_block *);
+struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned);
+void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *);
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
+int nfs4_validate_text_mount_data(void *, struct nfs_parsed_mount_data *, const char *);
 
 #endif /* __LINUX_INTERNAL_NFS_H */
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 9dc0c37..b35840e 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -3,12 +3,583 @@
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
+EXPORT_SYMBOL_GPL(nfs4_fs_type);
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
+EXPORT_SYMBOL_GPL(nfs4_referral_fs_type);
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
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 88bbebe..30e903c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -261,20 +261,12 @@ static match_table_t nfs_local_lock_tokens = {
 	{ Opt_local_lock_err, NULL }
 };
 
-
-static void nfs_umount_begin(struct super_block *);
-static int  nfs_statfs(struct dentry *, struct kstatfs *);
-static int  nfs_show_options(struct seq_file *, struct dentry *);
-static int  nfs_show_devname(struct seq_file *, struct dentry *);
-static int  nfs_show_path(struct seq_file *, struct dentry *);
-static int  nfs_show_stats(struct seq_file *, struct dentry *);
 static struct dentry *nfs_fs_mount(struct file_system_type *,
 		int, const char *, void *);
-static struct dentry *nfs_xdev_mount(struct file_system_type *fs_type,
+struct dentry *nfs_xdev_mount(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data);
-static void nfs_put_super(struct super_block *);
+void nfs_put_super(struct super_block *);
 static void nfs_kill_super(struct super_block *);
-static int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 
 struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
@@ -308,77 +300,6 @@ static const struct super_operations nfs_sops = {
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
@@ -448,7 +369,7 @@ void nfs_sb_deactive(struct super_block *sb)
 /*
  * Deliver file system statistics to userspace
  */
-static int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
+int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
 	struct nfs_server *server = NFS_SB(dentry->d_sb);
 	unsigned char blockbits;
@@ -509,6 +430,7 @@ static int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	dprintk("%s: statfs error = %d\n", __func__, -error);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_statfs);
 
 /*
  * Map the security flavour number to a name
@@ -721,7 +643,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 /*
  * Describe the mount options on this VFS mountpoint
  */
-static int nfs_show_options(struct seq_file *m, struct dentry *root)
+int nfs_show_options(struct seq_file *m, struct dentry *root)
 {
 	struct nfs_server *nfss = NFS_SB(root->d_sb);
 
@@ -733,6 +655,7 @@ static int nfs_show_options(struct seq_file *m, struct dentry *root)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_show_options);
 
 #ifdef CONFIG_NFS_V4
 #ifdef CONFIG_NFS_V4_1
@@ -761,7 +684,7 @@ static void show_pnfs(struct seq_file *m, struct nfs_server *server) {}
 #endif
 #endif
 
-static int nfs_show_devname(struct seq_file *m, struct dentry *root)
+int nfs_show_devname(struct seq_file *m, struct dentry *root)
 {
 	char *page = (char *) __get_free_page(GFP_KERNEL);
 	char *devname, *dummy;
@@ -776,17 +699,19 @@ static int nfs_show_devname(struct seq_file *m, struct dentry *root)
 	free_page((unsigned long)page);
 	return err;
 }
+EXPORT_SYMBOL_GPL(nfs_show_devname);
 
-static int nfs_show_path(struct seq_file *m, struct dentry *dentry)
+int nfs_show_path(struct seq_file *m, struct dentry *dentry)
 {
 	seq_puts(m, "/");
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_show_path);
 
 /*
  * Present statistical information for this VFS mountpoint
  */
-static int nfs_show_stats(struct seq_file *m, struct dentry *root)
+int nfs_show_stats(struct seq_file *m, struct dentry *root)
 {
 	int i, cpu;
 	struct nfs_server *nfss = NFS_SB(root->d_sb);
@@ -872,12 +797,13 @@ static int nfs_show_stats(struct seq_file *m, struct dentry *root)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_show_stats);
 
 /*
  * Begin unmount by attempting to remove all automounted mountpoints we added
  * in response to xdev traversals and referrals
  */
-static void nfs_umount_begin(struct super_block *sb)
+void nfs_umount_begin(struct super_block *sb)
 {
 	struct nfs_server *server;
 	struct rpc_clnt *rpc;
@@ -891,8 +817,9 @@ static void nfs_umount_begin(struct super_block *sb)
 	if (!IS_ERR(rpc))
 		rpc_killall_tasks(rpc);
 }
+EXPORT_SYMBOL_GPL(nfs_umount_begin);
 
-static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int version)
+struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int version)
 {
 	struct nfs_parsed_mount_data *data;
 
@@ -913,8 +840,9 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int ve
 	}
 	return data;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_parsed_mount_data);
 
-static void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
+void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
 {
 	if (data) {
 		kfree(data->client_address);
@@ -926,6 +854,7 @@ static void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
 		kfree(data);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_free_parsed_mount_data);
 
 /*
  * Sanity-check a server address provided by the mount command.
@@ -933,7 +862,7 @@ static void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
  * Address family must be initialized, and address must not be
  * the ANY address for that family.
  */
-static int nfs_verify_server_address(struct sockaddr *addr)
+int nfs_verify_server_address(struct sockaddr *addr)
 {
 	switch (addr->sa_family) {
 	case AF_INET: {
@@ -949,6 +878,7 @@ static int nfs_verify_server_address(struct sockaddr *addr)
 	dfprintk(MOUNT, "NFS: Invalid IP address specified\n");
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_verify_server_address);
 
 /*
  * Select between a default port value and a user-specified port value.
@@ -967,7 +897,7 @@ static void nfs_set_port(struct sockaddr *sap, int *port,
  * Sanity check the NFS transport protocol.
  *
  */
-static void nfs_validate_transport_protocol(struct nfs_parsed_mount_data *mnt)
+void nfs_validate_transport_protocol(struct nfs_parsed_mount_data *mnt)
 {
 	switch (mnt->nfs_server.protocol) {
 	case XPRT_TRANSPORT_UDP:
@@ -978,6 +908,7 @@ static void nfs_validate_transport_protocol(struct nfs_parsed_mount_data *mnt)
 		mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_validate_transport_protocol);
 
 /*
  * For text based NFSv2/v3 mounts, the mount protocol transport default
@@ -1080,8 +1011,7 @@ static int nfs_get_option_ul(substring_t args[], unsigned long *option)
  * skipped as they are encountered.  If there were no errors, return 1;
  * otherwise return 0 (zero).
  */
-static int nfs_parse_mount_options(char *raw,
-				   struct nfs_parsed_mount_data *mnt)
+int nfs_parse_mount_options(char *raw, struct nfs_parsed_mount_data *mnt)
 {
 	char *p, *string, *secdata;
 	int rc, sloppy = 0, invalid_option = 0;
@@ -1560,6 +1490,7 @@ out_security_failure:
 	printk(KERN_INFO "NFS: security options invalid: %d\n", rc);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_parse_mount_options);
 
 /*
  * Match the requested auth flavors with the list returned by
@@ -1978,8 +1909,7 @@ nfs_compare_remount_data(struct nfs_server *nfss,
 	return 0;
 }
 
-static int
-nfs_remount(struct super_block *sb, int *flags, char *raw_data)
+int nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 {
 	int error;
 	struct nfs_server *nfss = sb->s_fs_info;
@@ -2039,11 +1969,12 @@ out:
 	kfree(data);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_remount);
 
 /*
  * Initialise the common bits of the superblock
  */
-static inline void nfs_initialise_sb(struct super_block *sb)
+inline void nfs_initialise_sb(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
@@ -2061,6 +1992,7 @@ static inline void nfs_initialise_sb(struct super_block *sb)
 
 	nfs_super_set_maxbytes(sb, server->maxfilesize);
 }
+EXPORT_SYMBOL_GPL(nfs_initialise_sb);
 
 /*
  * Finish setting up an NFS2/3 superblock
@@ -2143,12 +2075,7 @@ Ebusy:
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
@@ -2162,6 +2089,7 @@ static int nfs_set_super(struct super_block *s, void *data)
 		server->s_dev = s->s_dev;
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_set_super);
 
 static int nfs_compare_super_address(struct nfs_server *server1,
 				     struct nfs_server *server2)
@@ -2200,7 +2128,7 @@ static int nfs_compare_super_address(struct nfs_server *server1,
 	return 1;
 }
 
-static int nfs_compare_super(struct super_block *sb, void *data)
+int nfs_compare_super(struct super_block *sb, void *data)
 {
 	struct nfs_sb_mountdata *sb_mntdata = data;
 	struct nfs_server *server = sb_mntdata->server, *old = NFS_SB(sb);
@@ -2215,13 +2143,14 @@ static int nfs_compare_super(struct super_block *sb, void *data)
 		return 0;
 	return nfs_compare_mount_options(sb, server, mntflags);
 }
+EXPORT_SYMBOL_GPL(nfs_compare_super);
 
 static int nfs_bdi_register(struct nfs_server *server)
 {
 	return bdi_register_dev(&server->backing_dev_info, server->s_dev);
 }
 
-static int nfs_register(struct nfs_server *server)
+int nfs_register(struct nfs_server *server)
 {
 	struct nfs_subversion *nfs_mod = get_nfs_server_version(server);
 	int err = nfs_bdi_register(server);
@@ -2229,13 +2158,15 @@ static int nfs_register(struct nfs_server *server)
 		nfs_mod->reference();
 	return err;
 }
+EXPORT_SYMBOL_GPL(nfs_register);
 
-static void nfs_unregister(struct nfs_server *server)
+void nfs_unregister(struct nfs_server *server)
 {
 	struct nfs_subversion *nfs_mod = get_nfs_server_version(server);
 	bdi_unregister(&server->backing_dev_info);
 	nfs_mod->unreference();
 }
+EXPORT_SYMBOL_GPL(nfs_unregister);
 
 struct dentry *_nfs_fs_mount(struct file_system_type *fs_type,
 			     struct nfs_server *server,
@@ -2352,10 +2283,11 @@ out:
  * Ensure that we unregister the bdi before kill_anon_super
  * releases the device name
  */
-static void nfs_put_super(struct super_block *s)
+void nfs_put_super(struct super_block *s)
 {
 	nfs_unregister(NFS_SB(s));
 }
+EXPORT_SYMBOL_GPL(nfs_put_super);
 
 /*
  * Destroy an NFS2/3 superblock
@@ -2452,7 +2384,7 @@ error_splat_bdi:
 }
 EXPORT_SYMBOL_GPL(_nfs_xdev_mount);
 
-static struct dentry *
+struct dentry *
 nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	       const char *dev_name, void *raw_data)
 {
@@ -2460,34 +2392,19 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	struct nfs_subversion *nfs_mod = get_nfs_server_version(NFS_SB(data->sb));
 	return nfs_mod->xdev_mount(flags, dev_name, data);
 }
+EXPORT_SYMBOL_GPL(nfs_xdev_mount);
 
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
 
@@ -2522,484 +2439,4 @@ static int nfs4_validate_text_mount_data(void *options,
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
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b8111cb..d906336 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1607,6 +1607,7 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 	}
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_write_inode);
 
 /*
  * flush the inode to disk.
-- 
1.7.9

