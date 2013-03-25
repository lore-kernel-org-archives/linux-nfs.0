Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63963 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756577Ab3CYLoO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 07:44:14 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 03/14] LSM: Add flags field to security_sb_set_mnt_opts for in kernel mount data.
Date: Mon, 25 Mar 2013 07:42:47 -0400
Message-Id: <1364211778-29172-4-git-send-email-SteveD@redhat.com>
In-Reply-To: <1364211778-29172-1-git-send-email-SteveD@redhat.com>
References: <1364211778-29172-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

There is no way to differentiate if a text mount option is passed from user
space or the kernel. A flags field is being added to the
security_sb_set_mnt_opts hook to allow for in kernel security flags to be sent
to the LSM for processing in addition to the text options received from mount.
This patch also updated existing code to fix compilation errors.

Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
---
 fs/nfs/super.c           |  3 ++-
 include/linux/security.h | 13 ++++++++++---
 security/capability.c    |  5 ++++-
 security/security.c      |  7 +++++--
 security/selinux/hooks.c | 12 ++++++++++--
 5 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2f8a29d..56e9963 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2373,7 +2373,8 @@ static int nfs_bdi_register(struct nfs_server *server)
 int nfs_set_sb_security(struct super_block *s, struct dentry *mntroot,
 			struct nfs_mount_info *mount_info)
 {
-	return security_sb_set_mnt_opts(s, &mount_info->parsed->lsm_opts);
+	return security_sb_set_mnt_opts(s, &mount_info->parsed->lsm_opts,
+								0, NULL);
 }
 EXPORT_SYMBOL_GPL(nfs_set_sb_security);
 
diff --git a/include/linux/security.h b/include/linux/security.h
index 8a6faff..5c4179a 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1452,7 +1452,9 @@ struct security_operations {
 	int (*sb_pivotroot) (struct path *old_path,
 			     struct path *new_path);
 	int (*sb_set_mnt_opts) (struct super_block *sb,
-				struct security_mnt_opts *opts);
+				struct security_mnt_opts *opts,
+				unsigned long kern_flags,
+				unsigned long *set_kern_flags);
 	void (*sb_clone_mnt_opts) (const struct super_block *oldsb,
 				   struct super_block *newsb);
 	int (*sb_parse_opts_str) (char *options, struct security_mnt_opts *opts);
@@ -1742,7 +1744,10 @@ int security_sb_mount(const char *dev_name, struct path *path,
 		      const char *type, unsigned long flags, void *data);
 int security_sb_umount(struct vfsmount *mnt, int flags);
 int security_sb_pivotroot(struct path *old_path, struct path *new_path);
-int security_sb_set_mnt_opts(struct super_block *sb, struct security_mnt_opts *opts);
+int security_sb_set_mnt_opts(struct super_block *sb,
+				struct security_mnt_opts *opts,
+				unsigned long kern_flags,
+				unsigned long *set_kern_flags);
 void security_sb_clone_mnt_opts(const struct super_block *oldsb,
 				struct super_block *newsb);
 int security_sb_parse_opts_str(char *options, struct security_mnt_opts *opts);
@@ -2032,7 +2037,9 @@ static inline int security_sb_pivotroot(struct path *old_path,
 }
 
 static inline int security_sb_set_mnt_opts(struct super_block *sb,
-					   struct security_mnt_opts *opts)
+					   struct security_mnt_opts *opts,
+					   unsigned long kern_flags,
+					   unsigned long *set_kern_flags)
 {
 	return 0;
 }
diff --git a/security/capability.c b/security/capability.c
index 07a6484..59b82d0 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -91,7 +91,10 @@ static int cap_sb_pivotroot(struct path *old_path, struct path *new_path)
 }
 
 static int cap_sb_set_mnt_opts(struct super_block *sb,
-			       struct security_mnt_opts *opts)
+			       struct security_mnt_opts *opts,
+			       unsigned long kern_flags,
+			       unsigned long *set_kern_flags)
+
 {
 	if (unlikely(opts->num_mnt_opts))
 		return -EOPNOTSUPP;
diff --git a/security/security.c b/security/security.c
index 6d7389c..dd9e4c8 100644
--- a/security/security.c
+++ b/security/security.c
@@ -294,9 +294,12 @@ int security_sb_pivotroot(struct path *old_path, struct path *new_path)
 }
 
 int security_sb_set_mnt_opts(struct super_block *sb,
-				struct security_mnt_opts *opts)
+				struct security_mnt_opts *opts,
+				unsigned long kern_flags,
+				unsigned long *set_kern_flags)
 {
-	return security_ops->sb_set_mnt_opts(sb, opts);
+	return security_ops->sb_set_mnt_opts(sb, opts, kern_flags,
+						set_kern_flags);
 }
 EXPORT_SYMBOL(security_sb_set_mnt_opts);
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 97231a0..f9db857 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -551,7 +551,9 @@ static int bad_option(struct superblock_security_struct *sbsec, char flag,
  * labeling information.
  */
 static int selinux_set_mnt_opts(struct super_block *sb,
-				struct security_mnt_opts *opts)
+				struct security_mnt_opts *opts,
+				unsigned long kern_flags,
+				unsigned long *set_kern_flags)
 {
 	const struct cred *cred = current_cred();
 	int rc = 0, i;
@@ -579,6 +581,12 @@ static int selinux_set_mnt_opts(struct super_block *sb,
 			"before the security server is initialized\n");
 		goto out;
 	}
+	if (kern_flags && !set_kern_flags) {
+		/* Specifying internal flags without providing a place to
+		 * place the results is not allowed */
+		rc = -EINVAL;
+		goto out;
+	}
 
 	/*
 	 * Binary mount data FS will come through this function twice.  Once
@@ -948,7 +956,7 @@ static int superblock_doinit(struct super_block *sb, void *data)
 		goto out_err;
 
 out:
-	rc = selinux_set_mnt_opts(sb, &opts);
+	rc = selinux_set_mnt_opts(sb, &opts, 0, NULL);
 
 out_err:
 	security_free_mnt_opts(&opts);
-- 
1.8.1.4

