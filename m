Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32816 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933461AbdEKOBq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 May 2017 10:01:46 -0400
Subject: [PATCH 13/14] Support legacy filesystems [ver #2]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 11 May 2017 15:01:43 +0100
Message-ID: <149451130331.4599.4235079818047711927.stgit@warthog.procyon.org.uk>
In-Reply-To: <149451118535.4599.16084557087363834548.stgit@warthog.procyon.org.uk>
References: <149451118535.4599.16084557087363834548.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support legacy filesystems by creating a set of legacy sb_config operations
that builds up a list of mount options and then invokes fs_type->mount()
within the sb_config mount operation.

All filesystems can then be accessed using sb_config and the
fs_type->mount() call is _only_ used from within legacy_mount().  This
allows some simplification to take place in the core mount code.
---

 fs/namespace.c |   36 ++-----------
 fs/sb_config.c |  160 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 161 insertions(+), 35 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 6e43657d78bd..bb339252c592 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2577,7 +2577,6 @@ static int do_new_mount(struct path *mountpoint, const char *fstype, int flags,
 			int mnt_flags, const char *name, void *data)
 {
 	struct sb_config *sc;
-	struct vfsmount *mnt;
 	int err;
 
 	if (!fstype)
@@ -2593,40 +2592,17 @@ static int do_new_mount(struct path *mountpoint, const char *fstype, int flags,
 	if (!sc->device)
 		goto err_sc;
 
-	if (sc->ops) {
-		err = parse_monolithic_mount_data(sc, data);
-		if (err < 0)
-			goto err_sc;
-
-		err = do_new_mount_sc(sc, mountpoint, mnt_flags);
-		if (err)
-			goto err_sc;
-
-	} else {
-		mnt = vfs_kern_mount(sc->fs_type, flags, name, data);
-		if (!IS_ERR(mnt) && (sc->fs_type->fs_flags & FS_HAS_SUBTYPE) &&
-		    !mnt->mnt_sb->s_subtype)
-			mnt = fs_set_subtype(mnt, fstype);
-
-		if (IS_ERR(mnt)) {
-			err = PTR_ERR(mnt);
-			goto err_sc;
-		}
-
-		err = -EPERM;
-		if (mount_too_revealing(mnt, &mnt_flags))
-			goto err_mnt;
+	err = parse_monolithic_mount_data(sc, data);
+	if (err < 0)
+		goto err_sc;
 
-		err = do_add_mount(real_mount(mnt), mountpoint, mnt_flags);
-		if (err)
-			goto err_mnt;
-	}
+	err = do_new_mount_sc(sc, mountpoint, mnt_flags);
+	if (err)
+		goto err_sc;
 
 	put_sb_config(sc);
 	return 0;
 
-err_mnt:
-	mntput(mnt);
 err_sc:
 	if (sc->error_msg)
 		pr_info("Mount failed: %s\n", sc->error_msg);
diff --git a/fs/sb_config.c b/fs/sb_config.c
index 9c45e269b3cc..62e309cd62ef 100644
--- a/fs/sb_config.c
+++ b/fs/sb_config.c
@@ -25,6 +25,15 @@
 #include <net/net_namespace.h>
 #include "mount.h"
 
+struct legacy_sb_config {
+	struct sb_config	sc;
+	char			*legacy_data;	/* Data page for legacy filesystems */
+	char			*secdata;
+	unsigned int		data_usage;
+};
+
+static const struct sb_config_operations legacy_sb_config_ops;
+
 static const match_table_t common_set_mount_options = {
 	{ MS_DIRSYNC,		"dirsync" },
 	{ MS_I_VERSION,		"iversion" },
@@ -186,13 +195,15 @@ struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
 				      enum sb_config_purpose purpose)
 {
 	struct sb_config *sc;
+	size_t sc_size = fs_type->sb_config_size;
 	int ret;
 
-	BUG_ON(fs_type->init_sb_config &&
-	       fs_type->sb_config_size < sizeof(*sc));
+	BUG_ON(fs_type->init_sb_config && sc_size < sizeof(*sc));
+
+	if (!fs_type->init_sb_config)
+		sc_size = sizeof(struct legacy_sb_config);
 
-	sc = kzalloc(max_t(size_t, fs_type->sb_config_size, sizeof(*sc)),
-		     GFP_KERNEL);
+	sc = kzalloc(sc_size, GFP_KERNEL);
 	if (!sc)
 		return ERR_PTR(-ENOMEM);
 
@@ -208,9 +219,11 @@ struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
 		ret = sc->fs_type->init_sb_config(sc, src_sb);
 		if (ret < 0)
 			goto err_sc;
+	} else {
+		sc->ops = &legacy_sb_config_ops;
 	}
 
-	/* Do the security check last because ->fsopen may change the
+	/* Do the security check last because ->init_sb_config may change the
 	 * namespace subscriptions.
 	 */
 	ret = security_sb_config_alloc(sc, src_sb);
@@ -272,11 +285,16 @@ struct sb_config *vfs_sb_reconfig(struct vfsmount *mnt,
 struct sb_config *vfs_dup_sb_config(struct sb_config *src_sc)
 {
 	struct sb_config *sc;
+	size_t sc_size;
 	int ret;
 
 	if (!src_sc->ops->dup)
 		return ERR_PTR(-ENOTSUPP);
 
+	sc_size = src_sc->fs_type->sb_config_size;
+	if (!src_sc->fs_type->init_sb_config)
+		sc_size = sizeof(struct legacy_sb_config);
+
 	sc = kmemdup(src_sc, src_sc->fs_type->sb_config_size, GFP_KERNEL);
 	if (!sc)
 		return ERR_PTR(-ENOMEM);
@@ -324,3 +342,135 @@ void put_sb_config(struct sb_config *sc)
 	kfree(sc);
 }
 EXPORT_SYMBOL(put_sb_config);
+
+/*
+ * Free the config for a filesystem that doesn't support sb_config.
+ */
+static void legacy_sb_config_free(struct sb_config *sc)
+{
+	struct legacy_sb_config *cfg = container_of(sc, struct legacy_sb_config, sc);
+
+	free_secdata(cfg->secdata);
+	kfree(cfg->legacy_data);
+}
+
+/*
+ * Duplicate a legacy config.
+ */
+static int legacy_sb_config_dup(struct sb_config *sc, struct sb_config *src_sc)
+{
+	struct legacy_sb_config *cfg = container_of(sc, struct legacy_sb_config, sc);
+	struct legacy_sb_config *src_cfg = container_of(src_sc, struct legacy_sb_config, sc);
+
+	cfg->legacy_data = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!cfg->legacy_data)
+		return -ENOMEM;
+	memcpy(cfg->legacy_data, src_cfg->legacy_data, sizeof(PAGE_SIZE));
+	return 0;
+}
+
+/*
+ * Add an option to a legacy config.  We build up a comma-separated list of
+ * options.
+ */
+static int legacy_parse_option(struct sb_config *sc, char *p)
+{
+	struct legacy_sb_config *cfg = container_of(sc, struct legacy_sb_config, sc);
+	unsigned int usage = cfg->data_usage;
+	size_t len = strlen(p);
+
+	if (len > PAGE_SIZE - 2 - usage)
+		return sb_cfg_inval(sc, "VFS: Insufficient data buffer space");
+	if (memchr(p, ',', len) != NULL)
+		return sb_cfg_inval(sc, "VFS: Options cannot contain commas");
+	if (!cfg->legacy_data) {
+		cfg->legacy_data = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		if (!cfg->legacy_data)
+			return -ENOMEM;
+	}
+
+	cfg->legacy_data[usage++] = ',';
+	memcpy(cfg->legacy_data + usage, p, len);
+	usage += len;
+	cfg->legacy_data[usage] = '\0';
+	cfg->data_usage = usage;
+	return 0;
+}
+
+/*
+ * Add monolithic mount data.
+ */
+static int legacy_monolithic_mount_data(struct sb_config *sc, void *data)
+{
+	struct legacy_sb_config *cfg = container_of(sc, struct legacy_sb_config, sc);
+
+	if (cfg->data_usage != 0)
+		return sb_cfg_inval(sc, "VFS: Can't mix monolithic and individual options");
+	if (!data)
+		return 0;
+	if (!cfg->legacy_data) {
+		cfg->legacy_data = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		if (!cfg->legacy_data)
+			return -ENOMEM;
+	}
+
+	memcpy(cfg->legacy_data, data, PAGE_SIZE);
+	cfg->data_usage = PAGE_SIZE;
+	return 0;
+}
+
+/*
+ * Use the legacy mount validation step to strip out and process security
+ * config options.
+ */
+static int legacy_validate(struct sb_config *sc)
+{
+	struct legacy_sb_config *cfg = container_of(sc, struct legacy_sb_config, sc);
+
+	if (!cfg->legacy_data || cfg->sc.fs_type->fs_flags & FS_BINARY_MOUNTDATA)
+		return 0;
+
+	cfg->secdata = alloc_secdata();
+	if (!cfg->secdata)
+		return -ENOMEM;
+
+	return security_sb_copy_data(cfg->legacy_data, cfg->secdata);
+}
+
+/*
+ * Perform a legacy mount.
+ */
+static struct dentry *legacy_mount(struct sb_config *sc)
+{
+	struct legacy_sb_config *cfg = container_of(sc, struct legacy_sb_config, sc);
+	struct super_block *sb;
+	struct dentry *root;
+	int ret;
+
+	root = cfg->sc.fs_type->mount(cfg->sc.fs_type, cfg->sc.ms_flags,
+				     cfg->sc.device, cfg->legacy_data);
+	if (IS_ERR(root))
+		return ERR_CAST(root);
+
+	sb = root->d_sb;
+	BUG_ON(!sb);
+	ret = security_sb_kern_mount(sb, cfg->sc.ms_flags, cfg->secdata);
+	if (ret < 0)
+		goto err_sb;
+
+	return root;
+
+err_sb:
+	dput(root);
+	deactivate_locked_super(sb);
+	return ERR_PTR(ret);
+}
+
+static const struct sb_config_operations legacy_sb_config_ops = {
+	.free			= legacy_sb_config_free,
+	.dup			= legacy_sb_config_dup,
+	.parse_option		= legacy_parse_option,
+	.monolithic_mount_data	= legacy_monolithic_mount_data,
+	.validate		= legacy_validate,
+	.mount			= legacy_mount,
+};

