Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:42818 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753082AbeDSNcR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:32:17 -0400
Subject: [PATCH 10/24] VFS: Remove unused code after filesystem context
 changes [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:32:14 +0100
Message-ID: <152414473491.23902.15378926165697208797.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove code that is now unused after the filesystem context changes.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/internal.h              |    2 --
 fs/super.c                 |   54 --------------------------------------------
 include/linux/lsm_hooks.h  |    3 --
 include/linux/security.h   |    7 ------
 security/security.c        |    5 ----
 security/selinux/hooks.c   |   20 ----------------
 security/smack/smack_lsm.c |   33 ---------------------------
 7 files changed, 124 deletions(-)

diff --git a/fs/internal.h b/fs/internal.h
index 91a990234488..f47ede6ace5a 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -101,8 +101,6 @@ extern struct file *get_empty_filp(void);
 extern int do_remount_sb(struct super_block *, int, void *, size_t, int,
 			 struct fs_context *);
 extern bool trylock_super(struct super_block *sb);
-extern struct dentry *mount_fs(struct file_system_type *,
-			       int, const char *, void *, size_t);
 extern struct super_block *user_get_super(dev_t);
 
 /*
diff --git a/fs/super.c b/fs/super.c
index 5d65a45ca6db..a27487e34ea4 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -1441,60 +1441,6 @@ struct dentry *mount_single(struct file_system_type *fs_type,
 }
 EXPORT_SYMBOL(mount_single);
 
-struct dentry *
-mount_fs(struct file_system_type *type, int flags, const char *name,
-	 void *data, size_t data_size)
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
-		error = security_sb_copy_data(data, data_size, secdata);
-		if (error)
-			goto out_free_secdata;
-	}
-
-	root = type->mount(type, flags, name, data, data_size);
-	if (IS_ERR(root)) {
-		error = PTR_ERR(root);
-		goto out_free_secdata;
-	}
-	sb = root->d_sb;
-	BUG_ON(!sb);
-	WARN_ON(!sb->s_bdi);
-	sb->s_flags |= SB_BORN;
-
-	error = security_sb_kern_mount(sb, flags, secdata, data_size);
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
index d533ca038604..1d6481c4f965 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -1511,8 +1511,6 @@ union security_list_options {
 	void (*sb_free_security)(struct super_block *sb);
 	int (*sb_copy_data)(char *orig, size_t orig_size, char *copy);
 	int (*sb_remount)(struct super_block *sb, void *data, size_t data_size);
-	int (*sb_kern_mount)(struct super_block *sb, int flags,
-			     void *data, size_t data_size);
 	int (*sb_show_options)(struct seq_file *m, struct super_block *sb);
 	int (*sb_statfs)(struct dentry *dentry);
 	int (*sb_mount)(const char *dev_name, const struct path *path,
@@ -1858,7 +1856,6 @@ struct security_hook_heads {
 	struct hlist_head sb_free_security;
 	struct hlist_head sb_copy_data;
 	struct hlist_head sb_remount;
-	struct hlist_head sb_kern_mount;
 	struct hlist_head sb_show_options;
 	struct hlist_head sb_statfs;
 	struct hlist_head sb_mount;
diff --git a/include/linux/security.h b/include/linux/security.h
index 22b83dc28bd3..5b9d9ffa6abd 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -245,7 +245,6 @@ int security_sb_alloc(struct super_block *sb);
 void security_sb_free(struct super_block *sb);
 int security_sb_copy_data(char *orig, size_t orig_size, char *copy);
 int security_sb_remount(struct super_block *sb, void *data, size_t data_size);
-int security_sb_kern_mount(struct super_block *sb, int flags, void *data, size_t data_size);
 int security_sb_show_options(struct seq_file *m, struct super_block *sb);
 int security_sb_statfs(struct dentry *dentry);
 int security_sb_mount(const char *dev_name, const struct path *path,
@@ -601,12 +600,6 @@ static inline int security_sb_remount(struct super_block *sb, void *data, size_t
 	return 0;
 }
 
-static inline int security_sb_kern_mount(struct super_block *sb, int flags,
-					 void *data, size_t data_size)
-{
-	return 0;
-}
-
 static inline int security_sb_show_options(struct seq_file *m,
 					   struct super_block *sb)
 {
diff --git a/security/security.c b/security/security.c
index 35abdc964724..9693a175587d 100644
--- a/security/security.c
+++ b/security/security.c
@@ -420,11 +420,6 @@ int security_sb_remount(struct super_block *sb, void *data, size_t data_size)
 	return call_int_hook(sb_remount, 0, sb, data, data_size);
 }
 
-int security_sb_kern_mount(struct super_block *sb, int flags, void *data, size_t data_size)
-{
-	return call_int_hook(sb_kern_mount, 0, sb, flags, data, data_size);
-}
-
 int security_sb_show_options(struct seq_file *m, struct super_block *sb)
 {
 	return call_int_hook(sb_show_options, 0, m, sb);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 46d31858eaba..cb76a2428926 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2909,25 +2909,6 @@ static int selinux_sb_remount(struct super_block *sb, void *data, size_t data_si
 	goto out_free_opts;
 }
 
-static int selinux_sb_kern_mount(struct super_block *sb, int flags, void *data, size_t data_size)
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
@@ -7138,7 +7119,6 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(sb_free_security, selinux_sb_free_security),
 	LSM_HOOK_INIT(sb_copy_data, selinux_sb_copy_data),
 	LSM_HOOK_INIT(sb_remount, selinux_sb_remount),
-	LSM_HOOK_INIT(sb_kern_mount, selinux_sb_kern_mount),
 	LSM_HOOK_INIT(sb_show_options, selinux_sb_show_options),
 	LSM_HOOK_INIT(sb_statfs, selinux_sb_statfs),
 	LSM_HOOK_INIT(sb_mount, selinux_mount),
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 5dc31a940961..5fe9e7948fde 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1150,38 +1150,6 @@ static int smack_set_mnt_opts(struct super_block *sb,
 	return 0;
 }
 
-/**
- * smack_sb_kern_mount - Smack specific mount processing
- * @sb: the file system superblock
- * @flags: the mount flags
- * @data: the smack mount options
- *
- * Returns 0 on success, an error code on failure
- */
-static int smack_sb_kern_mount(struct super_block *sb, int flags,
-			       void *data, size_t data_size)
-{
-	int rc = 0;
-	char *options = data;
-	struct security_mnt_opts opts;
-
-	security_init_mnt_opts(&opts);
-
-	if (!options)
-		goto out;
-
-	rc = smack_parse_opts_str(options, &opts);
-	if (rc)
-		goto out_err;
-
-out:
-	rc = smack_set_mnt_opts(sb, &opts, 0, NULL);
-
-out_err:
-	security_free_mnt_opts(&opts);
-	return rc;
-}
-
 /**
  * smack_sb_statfs - Smack check on statfs
  * @dentry: identifies the file system in question
@@ -4942,7 +4910,6 @@ static struct security_hook_list smack_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(sb_alloc_security, smack_sb_alloc_security),
 	LSM_HOOK_INIT(sb_free_security, smack_sb_free_security),
 	LSM_HOOK_INIT(sb_copy_data, smack_sb_copy_data),
-	LSM_HOOK_INIT(sb_kern_mount, smack_sb_kern_mount),
 	LSM_HOOK_INIT(sb_statfs, smack_sb_statfs),
 	LSM_HOOK_INIT(sb_set_mnt_opts, smack_set_mnt_opts),
 	LSM_HOOK_INIT(sb_parse_opts_str, smack_parse_opts_str),

