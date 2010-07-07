From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: [PATCH 03/10] LSM: Add flags field to security_sb_set_mnt_opts for in kernel mount data.
Date: Wed,  7 Jul 2010 10:31:19 -0400
Message-ID: <1278513086-23964-4-git-send-email-dpquigl@tycho.nsa.gov>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-nfs@vger.kernel.org,
	"David P. Quigley" <dpquigl@tycho.nsa.gov>
To: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
	sds@tycho.nsa.gov, matthew.dodd@sparta.com,
	trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no way to differentiate if a text mount option is passed from user
space or the kernel. A flags field is being added to the
security_sb_set_mnt_opts hook to allow for in kernel security flags to be sent
to the LSM for processing in addition to the text options received from mount.
This patch also updated existing code to fix compilation errors.

Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
---
 fs/nfs/super.c           |    4 ++--
 include/linux/security.h |   11 ++++++++---
 security/capability.c    |    5 ++++-
 security/security.c      |    6 ++++--
 security/selinux/hooks.c |   12 ++++++++++--
 5 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b4148fc..054bcaa 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2232,7 +2232,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 		goto error_splat_super;
 	}
 
-	error = security_sb_set_mnt_opts(s, &data->lsm_opts);
+	error = security_sb_set_mnt_opts(s, &data->lsm_opts, 0, NULL);
 	if (error)
 		goto error_splat_root;
 
@@ -2602,7 +2602,7 @@ static int nfs4_remote_get_sb(struct file_system_type *fs_type,
 		goto error_splat_super;
 	}
 
-	error = security_sb_set_mnt_opts(s, &data->lsm_opts);
+	error = security_sb_set_mnt_opts(s, &data->lsm_opts, 0, NULL);
 	if (error)
 		goto error_splat_root;
 
diff --git a/include/linux/security.h b/include/linux/security.h
index 9597620..4bb5db7 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1509,7 +1509,9 @@ struct security_operations {
 	void (*sb_post_pivotroot) (struct path *old_path,
 				   struct path *new_path);
 	int (*sb_set_mnt_opts) (struct super_block *sb,
-				struct security_mnt_opts *opts);
+				struct security_mnt_opts *opts,
+				unsigned long kern_flags,
+				unsigned long *set_kern_flags);
 	void (*sb_clone_mnt_opts) (const struct super_block *oldsb,
 				   struct super_block *newsb);
 	int (*sb_parse_opts_str) (char *options, struct security_mnt_opts *opts);
@@ -1807,7 +1809,8 @@ void security_sb_post_remount(struct vfsmount *mnt, unsigned long flags, void *d
 void security_sb_post_addmount(struct vfsmount *mnt, struct path *mountpoint);
 int security_sb_pivotroot(struct path *old_path, struct path *new_path);
 void security_sb_post_pivotroot(struct path *old_path, struct path *new_path);
-int security_sb_set_mnt_opts(struct super_block *sb, struct security_mnt_opts *opts);
+int security_sb_set_mnt_opts(struct super_block *sb, struct security_mnt_opts *opts, 
+				unsigned long kern_flags, unsigned long *set_kern_flags);
 void security_sb_clone_mnt_opts(const struct super_block *oldsb,
 				struct super_block *newsb);
 int security_sb_parse_opts_str(char *options, struct security_mnt_opts *opts);
@@ -2154,7 +2157,9 @@ static inline void security_sb_post_pivotroot(struct path *old_path,
 { }
 
 static inline int security_sb_set_mnt_opts(struct super_block *sb,
-					   struct security_mnt_opts *opts)
+					   struct security_mnt_opts *opts,
+					   unsigned long kern_flags,
+					   unsigned long *set_kern_flags)
 {
 	return 0;
 }
diff --git a/security/capability.c b/security/capability.c
index 0d8f7e9..46f5e78 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -117,7 +117,10 @@ static void cap_sb_post_pivotroot(struct path *old_path, struct path *new_path)
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
index 1f0765c..2246b5a 100644
--- a/security/security.c
+++ b/security/security.c
@@ -347,9 +347,11 @@ void security_sb_post_pivotroot(struct path *old_path, struct path *new_path)
 }
 
 int security_sb_set_mnt_opts(struct super_block *sb,
-				struct security_mnt_opts *opts)
+				struct security_mnt_opts *opts,
+				unsigned long kern_flags,
+				unsigned long *set_kern_flags)
 {
-	return security_ops->sb_set_mnt_opts(sb, opts);
+	return security_ops->sb_set_mnt_opts(sb, opts, kern_flags, set_kern_flags);
 }
 EXPORT_SYMBOL(security_sb_set_mnt_opts);
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 8239f5c..d150fb4 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -591,7 +591,9 @@ static int bad_option(struct superblock_security_struct *sbsec, char flag,
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
@@ -623,6 +625,12 @@ static int selinux_set_mnt_opts(struct super_block *sb,
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
@@ -998,7 +1006,7 @@ static int superblock_doinit(struct super_block *sb, void *data)
 		goto out_err;
 
 out:
-	rc = selinux_set_mnt_opts(sb, &opts);
+	rc = selinux_set_mnt_opts(sb, &opts, 0, NULL);
 
 out_err:
 	security_free_mnt_opts(&opts);
-- 
1.6.2.5
