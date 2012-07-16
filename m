Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4387 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753223Ab2GPUjd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jul 2012 16:39:33 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 11/12] NFS: Split out the NFS v4 filesystem types
Date: Mon, 16 Jul 2012 16:39:20 -0400
Message-Id: <1342471161-22452-12-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
References: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This allows me to move the v4 mounting and unmounting functions out of
the generic client and into a file that is only compiled when CONFIG_NFS_V4
is enabled.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h  |  29 ++++
 fs/nfs/nfs4_fs.h   |   2 +
 fs/nfs/nfs4super.c | 328 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/super.c     | 395 +++--------------------------------------------------
 4 files changed, 381 insertions(+), 373 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b4a3570..cfafd13 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -153,6 +153,14 @@ struct nfs_mount_request {
 	struct net		*net;
 };
 
+struct nfs_mount_info {
+	void (*fill_super)(struct super_block *, struct nfs_mount_info *);
+	int (*set_security)(struct super_block *, struct dentry *, struct nfs_mount_info *);
+	struct nfs_parsed_mount_data *parsed;
+	struct nfs_clone_mount *cloned;
+	struct nfs_fh *mntfh;
+};
+
 extern int nfs_mount(struct nfs_mount_request *info);
 extern void nfs_umount(const struct nfs_mount_request *info);
 
@@ -318,6 +326,16 @@ extern struct file_system_type nfs_xdev_fs_type;
 extern struct file_system_type nfs4_xdev_fs_type;
 extern struct file_system_type nfs4_referral_fs_type;
 #endif
+void nfs_initialise_sb(struct super_block *);
+int nfs_set_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
+int nfs_clone_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
+struct dentry *nfs_fs_mount_common(struct file_system_type *, struct nfs_server *,
+				   int, const char *, struct nfs_mount_info *);
+struct dentry *nfs_fs_mount(struct file_system_type *, int, const char *, void *);
+struct dentry * nfs_xdev_mount_common(struct file_system_type *, int,
+		const char *, struct nfs_mount_info *);
+void nfs_kill_super(struct super_block *);
+void nfs_fill_super(struct super_block *, struct nfs_mount_info *);
 
 extern struct rpc_stat nfs_rpcstat;
 
@@ -364,6 +382,17 @@ extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_readdata_release(struct nfs_read_data *rdata);
 
+/* super.c */
+void nfs_clone_super(struct super_block *, struct nfs_mount_info *);
+void nfs_umount_begin(struct super_block *);
+int  nfs_statfs(struct dentry *, struct kstatfs *);
+int  nfs_show_options(struct seq_file *, struct dentry *);
+int  nfs_show_devname(struct seq_file *, struct dentry *);
+int  nfs_show_path(struct seq_file *, struct dentry *);
+int  nfs_show_stats(struct seq_file *, struct dentry *);
+void nfs_put_super(struct super_block *);
+int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
+
 /* write.c */
 extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 			struct inode *inode, int ioflags,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b508fef..b1ecacd 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -365,6 +365,8 @@ extern void nfs4_free_lock_state(struct nfs_server *server, struct nfs4_lock_sta
 extern const nfs4_stateid zero_stateid;
 
 /* nfs4super.c */
+struct nfs_mount_info;
+struct dentry *nfs4_try_mount(int, const char *, struct nfs_mount_info *);
 int init_nfs_v4(void);
 void exit_nfs_v4(void);
 
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 70c394e..2af2691 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -2,10 +2,331 @@
  * Copyright (c) 2012 Bryan Schumaker <bjschuma@netapp.com>
  */
 #include <linux/init.h>
+#include <linux/module.h>
 #include <linux/nfs_idmap.h>
+#include <linux/nfs4_mount.h>
 #include <linux/nfs_fs.h>
+#include "internal.h"
 #include "nfs4_fs.h"
 
+#define NFSDBG_FACILITY		NFSDBG_VFS
+
+static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data);
+static struct dentry *nfs4_xdev_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data);
+static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data);
+static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data);
+
+static struct file_system_type nfs4_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.mount		= nfs_fs_mount,
+	.kill_sb	= nfs_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+static struct file_system_type nfs4_remote_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.mount		= nfs4_remote_mount,
+	.kill_sb	= nfs_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+struct file_system_type nfs4_xdev_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.mount		= nfs4_xdev_mount,
+	.kill_sb	= nfs_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+static struct file_system_type nfs4_remote_referral_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.mount		= nfs4_remote_referral_mount,
+	.kill_sb	= nfs_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+struct file_system_type nfs4_referral_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.mount		= nfs4_referral_mount,
+	.kill_sb	= nfs_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+static const struct super_operations nfs4_sops = {
+	.alloc_inode	= nfs_alloc_inode,
+	.destroy_inode	= nfs_destroy_inode,
+	.write_inode	= nfs4_write_inode,
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
+static void nfs4_fill_super(struct super_block *sb,
+			    struct nfs_mount_info *mount_info)
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
+		  const char *dev_name, void *info)
+{
+	struct nfs_mount_info *mount_info = info;
+	struct nfs_server *server;
+	struct dentry *mntroot = ERR_PTR(-ENOMEM);
+
+	mount_info->fill_super = nfs4_fill_super;
+	mount_info->set_security = nfs_set_sb_security;
+
+	/* Get a volume representation */
+	server = nfs4_create_server(mount_info->parsed, mount_info->mntfh);
+	if (IS_ERR(server)) {
+		mntroot = ERR_CAST(server);
+		goto out;
+	}
+
+	mntroot = nfs_fs_mount_common(fs_type, server, flags, dev_name, mount_info);
+
+out:
+	return mntroot;
+}
+
+static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
+		int flags, void *data, const char *hostname)
+{
+	struct vfsmount *root_mnt;
+	char *root_devname;
+	size_t len;
+
+	len = strlen(hostname) + 5;
+	root_devname = kmalloc(len, GFP_KERNEL);
+	if (root_devname == NULL)
+		return ERR_PTR(-ENOMEM);
+	/* Does hostname needs to be enclosed in brackets? */
+	if (strchr(hostname, ':'))
+		snprintf(root_devname, len, "[%s]:/", hostname);
+	else
+		snprintf(root_devname, len, "%s:/", hostname);
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
+			 struct nfs_mount_info *mount_info)
+{
+	char *export_path;
+	struct vfsmount *root_mnt;
+	struct dentry *res;
+	struct nfs_parsed_mount_data *data = mount_info->parsed;
+
+	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
+
+	mount_info->fill_super = nfs4_fill_super;
+
+	export_path = data->nfs_server.export_path;
+	data->nfs_server.export_path = "/";
+	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, mount_info,
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
+ * Clone an NFS4 server record on xdev traversal (FSID-change)
+ */
+static struct dentry *
+nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
+		 const char *dev_name, void *raw_data)
+{
+	struct nfs_mount_info mount_info = {
+		.fill_super = nfs_clone_super,
+		.set_security = nfs_clone_sb_security,
+		.cloned = raw_data,
+	};
+	return nfs_xdev_mount_common(&nfs4_fs_type, flags, dev_name, &mount_info);
+}
+
+static struct dentry *
+nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
+			   const char *dev_name, void *raw_data)
+{
+	struct nfs_mount_info mount_info = {
+		.fill_super = nfs4_fill_super,
+		.set_security = nfs_clone_sb_security,
+		.cloned = raw_data,
+	};
+	struct nfs_server *server;
+	struct dentry *mntroot = ERR_PTR(-ENOMEM);
+
+	dprintk("--> nfs4_referral_get_sb()\n");
+
+	mount_info.mntfh = nfs_alloc_fhandle();
+	if (mount_info.cloned == NULL || mount_info.mntfh == NULL)
+		goto out;
+
+	/* create a new volume representation */
+	server = nfs4_create_referral_server(mount_info.cloned, mount_info.mntfh);
+	if (IS_ERR(server)) {
+		mntroot = ERR_CAST(server);
+		goto out;
+	}
+
+	mntroot = nfs_fs_mount_common(&nfs4_fs_type, server, flags, dev_name, &mount_info);
+out:
+	nfs_free_fhandle(mount_info.mntfh);
+	return mntroot;
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
+
 int __init init_nfs_v4(void)
 {
 	int err;
@@ -18,7 +339,13 @@ int __init init_nfs_v4(void)
 	if (err)
 		goto out1;
 
+	err = register_filesystem(&nfs4_fs_type);
+	if (err < 0)
+		goto out2;
+
 	return 0;
+out2:
+	nfs4_unregister_sysctl();
 out1:
 	nfs_idmap_quit();
 out:
@@ -27,6 +354,7 @@ out:
 
 void __exit exit_nfs_v4(void)
 {
+	unregister_filesystem(&nfs4_fs_type);
 	nfs4_unregister_sysctl();
 	nfs_idmap_quit();
 }
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ca3c0e8..95866a8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -278,29 +278,8 @@ static match_table_t nfs_vers_tokens = {
 	{ Opt_vers_err, NULL }
 };
 
-struct nfs_mount_info {
-	void (*fill_super)(struct super_block *, struct nfs_mount_info *);
-	int (*set_security)(struct super_block *, struct dentry *, struct nfs_mount_info *);
-	struct nfs_parsed_mount_data *parsed;
-	struct nfs_clone_mount *cloned;
-	struct nfs_fh *mntfh;
-};
-
-static void nfs_umount_begin(struct super_block *);
-static int  nfs_statfs(struct dentry *, struct kstatfs *);
-static int  nfs_show_options(struct seq_file *, struct dentry *);
-static int  nfs_show_devname(struct seq_file *, struct dentry *);
-static int  nfs_show_path(struct seq_file *, struct dentry *);
-static int  nfs_show_stats(struct seq_file *, struct dentry *);
-static struct dentry *nfs_fs_mount_common(struct file_system_type *,
-		struct nfs_server *, int, const char *, struct nfs_mount_info *);
-static struct dentry *nfs_fs_mount(struct file_system_type *,
-		int, const char *, void *);
 static struct dentry *nfs_xdev_mount(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data);
-static void nfs_put_super(struct super_block *);
-static void nfs_kill_super(struct super_block *);
-static int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 
 static struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
@@ -337,71 +316,6 @@ static const struct super_operations nfs_sops = {
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *);
 static int nfs4_validate_mount_data(void *options,
 	struct nfs_parsed_mount_data *args, const char *dev_name);
-static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
-	struct nfs_mount_info *mount_info);
-static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
-static struct dentry *nfs4_xdev_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
-static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
-static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
-
-static struct file_system_type nfs4_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs_fs_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
-static struct file_system_type nfs4_remote_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_remote_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
-struct file_system_type nfs4_xdev_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_xdev_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
-static struct file_system_type nfs4_remote_referral_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_remote_referral_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
-struct file_system_type nfs4_referral_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_referral_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
-static const struct super_operations nfs4_sops = {
-	.alloc_inode	= nfs_alloc_inode,
-	.destroy_inode	= nfs_destroy_inode,
-	.write_inode	= nfs4_write_inode,
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
 #endif
 
 static struct shrinker acl_shrinker = {
@@ -423,18 +337,9 @@ int __init register_nfs_fs(void)
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
@@ -447,9 +352,6 @@ error_0:
 void __exit unregister_nfs_fs(void)
 {
 	unregister_shrinker(&acl_shrinker);
-#ifdef CONFIG_NFS_V4
-	unregister_filesystem(&nfs4_fs_type);
-#endif
 	nfs_unregister_sysctl();
 	unregister_filesystem(&nfs_fs_type);
 }
@@ -473,7 +375,7 @@ void nfs_sb_deactive(struct super_block *sb)
 /*
  * Deliver file system statistics to userspace
  */
-static int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
+int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
 	struct nfs_server *server = NFS_SB(dentry->d_sb);
 	unsigned char blockbits;
@@ -756,7 +658,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 /*
  * Describe the mount options on this VFS mountpoint
  */
-static int nfs_show_options(struct seq_file *m, struct dentry *root)
+int nfs_show_options(struct seq_file *m, struct dentry *root)
 {
 	struct nfs_server *nfss = NFS_SB(root->d_sb);
 
@@ -814,7 +716,7 @@ static void show_implementation_id(struct seq_file *m, struct nfs_server *nfss)
 }
 #endif
 
-static int nfs_show_devname(struct seq_file *m, struct dentry *root)
+int nfs_show_devname(struct seq_file *m, struct dentry *root)
 {
 	char *page = (char *) __get_free_page(GFP_KERNEL);
 	char *devname, *dummy;
@@ -830,7 +732,7 @@ static int nfs_show_devname(struct seq_file *m, struct dentry *root)
 	return err;
 }
 
-static int nfs_show_path(struct seq_file *m, struct dentry *dentry)
+int nfs_show_path(struct seq_file *m, struct dentry *dentry)
 {
 	seq_puts(m, "/");
 	return 0;
@@ -839,7 +741,7 @@ static int nfs_show_path(struct seq_file *m, struct dentry *dentry)
 /*
  * Present statistical information for this VFS mountpoint
  */
-static int nfs_show_stats(struct seq_file *m, struct dentry *root)
+int nfs_show_stats(struct seq_file *m, struct dentry *root)
 {
 	int i, cpu;
 	struct nfs_server *nfss = NFS_SB(root->d_sb);
@@ -932,7 +834,7 @@ static int nfs_show_stats(struct seq_file *m, struct dentry *root)
  * Begin unmount by attempting to remove all automounted mountpoints we added
  * in response to xdev traversals and referrals
  */
-static void nfs_umount_begin(struct super_block *sb)
+void nfs_umount_begin(struct super_block *sb)
 {
 	struct nfs_server *server;
 	struct rpc_clnt *rpc;
@@ -2107,7 +2009,7 @@ nfs_compare_remount_data(struct nfs_server *nfss,
 	return 0;
 }
 
-static int
+int
 nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 {
 	int error;
@@ -2172,7 +2074,7 @@ out:
 /*
  * Initialise the common bits of the superblock
  */
-static inline void nfs_initialise_sb(struct super_block *sb)
+inline void nfs_initialise_sb(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
@@ -2194,8 +2096,7 @@ static inline void nfs_initialise_sb(struct super_block *sb)
 /*
  * Finish setting up an NFS2/3 superblock
  */
-static void nfs_fill_super(struct super_block *sb,
-			   struct nfs_mount_info *mount_info)
+void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 {
 	struct nfs_parsed_mount_data *data = mount_info->parsed;
 	struct nfs_server *server = NFS_SB(sb);
@@ -2220,8 +2121,7 @@ static void nfs_fill_super(struct super_block *sb,
 /*
  * Finish setting up a cloned NFS2/3/4 superblock
  */
-static void nfs_clone_super(struct super_block *sb,
-			    struct nfs_mount_info *mount_info)
+void nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 {
 	const struct super_block *old_sb = mount_info->cloned->sb;
 	struct nfs_server *server = NFS_SB(sb);
@@ -2381,14 +2281,14 @@ static int nfs_bdi_register(struct nfs_server *server)
 	return bdi_register_dev(&server->backing_dev_info, server->s_dev);
 }
 
-static int nfs_set_sb_security(struct super_block *s, struct dentry *mntroot,
-			       struct nfs_mount_info *mount_info)
+int nfs_set_sb_security(struct super_block *s, struct dentry *mntroot,
+			struct nfs_mount_info *mount_info)
 {
 	return security_sb_set_mnt_opts(s, &mount_info->parsed->lsm_opts);
 }
 
-static int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
-				 struct nfs_mount_info *mount_info)
+int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
+			  struct nfs_mount_info *mount_info)
 {
 	/* clone any lsm security options from the parent to the new sb */
 	security_sb_clone_mnt_opts(mount_info->cloned->sb, s);
@@ -2397,10 +2297,10 @@ static int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
 	return 0;
 }
 
-static struct dentry *nfs_fs_mount_common(struct file_system_type *fs_type,
-					  struct nfs_server *server,
-					  int flags, const char *dev_name,
-					  struct nfs_mount_info *mount_info)
+struct dentry *nfs_fs_mount_common(struct file_system_type *fs_type,
+				   struct nfs_server *server,
+				   int flags, const char *dev_name,
+				   struct nfs_mount_info *mount_info)
 {
 	struct super_block *s;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
@@ -2470,7 +2370,7 @@ error_splat_bdi:
 	goto out;
 }
 
-static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
+struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data)
 {
 	struct nfs_mount_info mount_info = {
@@ -2511,7 +2411,7 @@ out:
  * Ensure that we unregister the bdi before kill_anon_super
  * releases the device name
  */
-static void nfs_put_super(struct super_block *s)
+void nfs_put_super(struct super_block *s)
 {
 	struct nfs_server *server = NFS_SB(s);
 
@@ -2521,7 +2421,7 @@ static void nfs_put_super(struct super_block *s)
 /*
  * Destroy an NFS2/3 superblock
  */
-static void nfs_kill_super(struct super_block *s)
+void nfs_kill_super(struct super_block *s)
 {
 	struct nfs_server *server = NFS_SB(s);
 
@@ -2533,7 +2433,7 @@ static void nfs_kill_super(struct super_block *s)
 /*
  * Clone an NFS2/3/4 server record on xdev traversal (FSID-change)
  */
-static struct dentry *
+struct dentry *
 nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
 		const char *dev_name, struct nfs_mount_info *mount_info)
 {
@@ -2580,23 +2480,6 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 
 #ifdef CONFIG_NFS_V4
 
-/*
- * Set up an NFS4 superblock
- */
-static void nfs4_fill_super(struct super_block *sb,
-			    struct nfs_mount_info *mount_info)
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
@@ -2694,238 +2577,4 @@ out_no_address:
 	return -EINVAL;
 }
 
-/*
- * Get the superblock for the NFS4 root partition
- */
-static struct dentry *
-nfs4_remote_mount(struct file_system_type *fs_type, int flags,
-		  const char *dev_name, void *info)
-{
-	struct nfs_mount_info *mount_info = info;
-	struct nfs_server *server;
-	struct dentry *mntroot = ERR_PTR(-ENOMEM);
-
-	mount_info->fill_super = nfs4_fill_super;
-	mount_info->set_security = nfs_set_sb_security;
-
-	/* Get a volume representation */
-	server = nfs4_create_server(mount_info->parsed, mount_info->mntfh);
-	if (IS_ERR(server)) {
-		mntroot = ERR_CAST(server);
-		goto out;
-	}
-
-	mntroot = nfs_fs_mount_common(fs_type, server, flags, dev_name, mount_info);
-
-out:
-	return mntroot;
-}
-
-static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
-		int flags, void *data, const char *hostname)
-{
-	struct vfsmount *root_mnt;
-	char *root_devname;
-	size_t len;
-
-	len = strlen(hostname) + 5;
-	root_devname = kmalloc(len, GFP_KERNEL);
-	if (root_devname == NULL)
-		return ERR_PTR(-ENOMEM);
-	/* Does hostname needs to be enclosed in brackets? */
-	if (strchr(hostname, ':'))
-		snprintf(root_devname, len, "[%s]:/", hostname);
-	else
-		snprintf(root_devname, len, "%s:/", hostname);
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
-static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
-			 struct nfs_mount_info *mount_info)
-{
-	char *export_path;
-	struct vfsmount *root_mnt;
-	struct dentry *res;
-	struct nfs_parsed_mount_data *data = mount_info->parsed;
-
-	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
-
-	mount_info->fill_super = nfs4_fill_super;
-
-	export_path = data->nfs_server.export_path;
-	data->nfs_server.export_path = "/";
-	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, mount_info,
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
- * Clone an NFS4 server record on xdev traversal (FSID-change)
- */
-static struct dentry *
-nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
-		 const char *dev_name, void *raw_data)
-{
-	struct nfs_mount_info mount_info = {
-		.fill_super = nfs_clone_super,
-		.set_security = nfs_clone_sb_security,
-		.cloned = raw_data,
-	};
-	return nfs_xdev_mount_common(&nfs4_fs_type, flags, dev_name, &mount_info);
-}
-
-static struct dentry *
-nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
-			   const char *dev_name, void *raw_data)
-{
-	struct nfs_mount_info mount_info = {
-		.fill_super = nfs4_fill_super,
-		.set_security = nfs_clone_sb_security,
-		.cloned = raw_data,
-	};
-	struct nfs_server *server;
-	struct dentry *mntroot = ERR_PTR(-ENOMEM);
-
-	dprintk("--> nfs4_referral_get_sb()\n");
-
-	mount_info.mntfh = nfs_alloc_fhandle();
-	if (mount_info.cloned == NULL || mount_info.mntfh == NULL)
-		goto out;
-
-	/* create a new volume representation */
-	server = nfs4_create_referral_server(mount_info.cloned, mount_info.mntfh);
-	if (IS_ERR(server)) {
-		mntroot = ERR_CAST(server);
-		goto out;
-	}
-
-	mntroot = nfs_fs_mount_common(&nfs4_fs_type, server, flags, dev_name, &mount_info);
-out:
-	nfs_free_fhandle(mount_info.mntfh);
-	return mntroot;
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
1.7.11.2

