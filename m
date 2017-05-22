Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41714 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757305AbdEVPxR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 11:53:17 -0400
Subject: [PATCH 10/23] VFS: Remove unused code after superblock config
 context changes [ver #4]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 22 May 2017 16:53:09 +0100
Message-ID: <149546838884.9289.16993745189196363868.stgit@warthog.procyon.org.uk>
In-Reply-To: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
References: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove code that is now unused after the superblock config context changes.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/internal.h             |    2 --
 fs/super.c                |   53 ---------------------------------------------
 include/linux/lsm_hooks.h |    2 --
 include/linux/security.h  |    6 -----
 security/security.c       |    5 ----
 security/selinux/hooks.c  |   20 -----------------
 6 files changed, 88 deletions(-)

diff --git a/fs/internal.h b/fs/internal.h
index 39121a99d930..de9b31568f15 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -89,8 +89,6 @@ extern struct file *get_empty_filp(void);
  */
 extern int do_remount_sb(struct super_block *, int, void *, int, struct sb_config *);
 extern bool trylock_super(struct super_block *sb);
-extern struct dentry *mount_fs(struct file_system_type *,
-			       int, const char *, void *);
 extern struct super_block *user_get_super(dev_t);
 
 /*
diff --git a/fs/super.c b/fs/super.c
index e4b47d481679..7ca217552977 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -1249,59 +1249,6 @@ struct dentry *mount_single(struct file_system_type *fs_type,
 }
 EXPORT_SYMBOL(mount_single);
 
-struct dentry *
-mount_fs(struct file_system_type *type, int flags, const char *name, void *data)
-{
-	struct dentry *root;
-	struct super_block *sb;
-	char *secdata = NULL;
-	int error = -ENOMEM;
-
-	if (data && !(type->fs_flags & FS_BINARY_MOUNTDATA)) {
-		secdata = alloc_secdata();
-		if (!secdata)
-			goto out;
-
-		error = security_sb_copy_data(data, secdata);
-		if (error)
-			goto out_free_secdata;
-	}
-
-	root = type->mount(type, flags, name, data);
-	if (IS_ERR(root)) {
-		error = PTR_ERR(root);
-		goto out_free_secdata;
-	}
-	sb = root->d_sb;
-	BUG_ON(!sb);
-	WARN_ON(!sb->s_bdi);
-	sb->s_flags |= MS_BORN;
-
-	error = security_sb_kern_mount(sb, flags, secdata);
-	if (error)
-		goto out_sb;
-
-	/*
-	 * filesystems should never set s_maxbytes larger than MAX_LFS_FILESIZE
-	 * but s_maxbytes was an unsigned long long for many releases. Throw
-	 * this warning for a little while to try and catch filesystems that
-	 * violate this rule.
-	 */
-	WARN((sb->s_maxbytes < 0), "%s set sb->s_maxbytes to "
-		"negative value (%lld)\n", type->name, sb->s_maxbytes);
-
-	up_write(&sb->s_umount);
-	free_secdata(secdata);
-	return root;
-out_sb:
-	dput(root);
-	deactivate_locked_super(sb);
-out_free_secdata:
-	free_secdata(secdata);
-out:
-	return ERR_PTR(error);
-}
-
 /*
  * Setup private BDI for given superblock. It gets automatically cleaned up
  * in generic_shutdown_super().
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index c2bbd9e92b0a..e95a918e61ca 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -1410,7 +1410,6 @@ union security_list_options {
 	void (*sb_free_security)(struct super_block *sb);
 	int (*sb_copy_data)(char *orig, char *copy);
 	int (*sb_remount)(struct super_block *sb, void *data);
-	int (*sb_kern_mount)(struct super_block *sb, int flags, void *data);
 	int (*sb_show_options)(struct seq_file *m, struct super_block *sb);
 	int (*sb_statfs)(struct dentry *dentry);
 	int (*sb_mount)(const char *dev_name, const struct path *path,
@@ -1726,7 +1725,6 @@ struct security_hook_heads {
 	struct list_head sb_free_security;
 	struct list_head sb_copy_data;
 	struct list_head sb_remount;
-	struct list_head sb_kern_mount;
 	struct list_head sb_show_options;
 	struct list_head sb_statfs;
 	struct list_head sb_mount;
diff --git a/include/linux/security.h b/include/linux/security.h
index d1dfb6abd4f7..f6eb735987d1 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -234,7 +234,6 @@ int security_sb_alloc(struct super_block *sb);
 void security_sb_free(struct super_block *sb);
 int security_sb_copy_data(char *orig, char *copy);
 int security_sb_remount(struct super_block *sb, void *data);
-int security_sb_kern_mount(struct super_block *sb, int flags, void *data);
 int security_sb_show_options(struct seq_file *m, struct super_block *sb);
 int security_sb_statfs(struct dentry *dentry);
 int security_sb_mount(const char *dev_name, const struct path *path,
@@ -566,11 +565,6 @@ static inline int security_sb_remount(struct super_block *sb, void *data)
 	return 0;
 }
 
-static inline int security_sb_kern_mount(struct super_block *sb, int flags, void *data)
-{
-	return 0;
-}
-
 static inline int security_sb_show_options(struct seq_file *m,
 					   struct super_block *sb)
 {
diff --git a/security/security.c b/security/security.c
index 951f28487719..ed086c6c8f0b 100644
--- a/security/security.c
+++ b/security/security.c
@@ -362,11 +362,6 @@ int security_sb_remount(struct super_block *sb, void *data)
 	return call_int_hook(sb_remount, 0, sb, data);
 }
 
-int security_sb_kern_mount(struct super_block *sb, int flags, void *data)
-{
-	return call_int_hook(sb_kern_mount, 0, sb, flags, data);
-}
-
 int security_sb_show_options(struct seq_file *m, struct super_block *sb)
 {
 	return call_int_hook(sb_show_options, 0, m, sb);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 420bfa955fb4..1deafdbf8716 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2775,25 +2775,6 @@ static int selinux_sb_remount(struct super_block *sb, void *data)
 	goto out_free_opts;
 }
 
-static int selinux_sb_kern_mount(struct super_block *sb, int flags, void *data)
-{
-	const struct cred *cred = current_cred();
-	struct common_audit_data ad;
-	int rc;
-
-	rc = superblock_doinit(sb, data);
-	if (rc)
-		return rc;
-
-	/* Allow all mounts performed by the kernel */
-	if (flags & MS_KERNMOUNT)
-		return 0;
-
-	ad.type = LSM_AUDIT_DATA_DENTRY;
-	ad.u.dentry = sb->s_root;
-	return superblock_has_perm(cred, sb, FILESYSTEM__MOUNT, &ad);
-}
-
 static int selinux_sb_statfs(struct dentry *dentry)
 {
 	const struct cred *cred = current_cred();
@@ -6327,7 +6308,6 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(sb_free_security, selinux_sb_free_security),
 	LSM_HOOK_INIT(sb_copy_data, selinux_sb_copy_data),
 	LSM_HOOK_INIT(sb_remount, selinux_sb_remount),
-	LSM_HOOK_INIT(sb_kern_mount, selinux_sb_kern_mount),
 	LSM_HOOK_INIT(sb_show_options, selinux_sb_show_options),
 	LSM_HOOK_INIT(sb_statfs, selinux_sb_statfs),
 	LSM_HOOK_INIT(sb_mount, selinux_mount),

