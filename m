Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60983 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751990AbdEPKSY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 May 2017 06:18:24 -0400
From: Jan Kara <jack@suse.cz>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>
Subject: [PATCH] nfs: Mark unnecessarily extern functions as static
Date: Tue, 16 May 2017 12:18:11 +0200
Message-Id: <20170516101811.27425-1-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_initialise_sb() and nfs_clone_super() are declared as extern even
though they are used only in fs/nfs/super.c. Mark them as static.

Also remove explicit 'inline' directive from nfs_initialise_sb() and
leave it upto compiler to decide whether inlining is worth it.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/nfs/internal.h | 2 --
 fs/nfs/super.c    | 5 +++--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index e9b4c3320e37..3e24392f2caa 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -398,7 +398,6 @@ extern struct file_system_type nfs4_referral_fs_type;
 bool nfs_auth_info_match(const struct nfs_auth_info *, rpc_authflavor_t);
 struct dentry *nfs_try_mount(int, const char *, struct nfs_mount_info *,
 			struct nfs_subversion *);
-void nfs_initialise_sb(struct super_block *);
 int nfs_set_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
 int nfs_clone_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
 struct dentry *nfs_fs_mount_common(struct nfs_server *, int, const char *,
@@ -458,7 +457,6 @@ extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 
 /* super.c */
-void nfs_clone_super(struct super_block *, struct nfs_mount_info *);
 void nfs_umount_begin(struct super_block *);
 int  nfs_statfs(struct dentry *, struct kstatfs *);
 int  nfs_show_options(struct seq_file *, struct dentry *);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2f3822a4a7d5..eceb4eabb064 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2301,7 +2301,7 @@ EXPORT_SYMBOL_GPL(nfs_remount);
 /*
  * Initialise the common bits of the superblock
  */
-inline void nfs_initialise_sb(struct super_block *sb)
+static void nfs_initialise_sb(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
@@ -2348,7 +2348,8 @@ EXPORT_SYMBOL_GPL(nfs_fill_super);
 /*
  * Finish setting up a cloned NFS2/3/4 superblock
  */
-void nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
+static void nfs_clone_super(struct super_block *sb,
+			    struct nfs_mount_info *mount_info)
 {
 	const struct super_block *old_sb = mount_info->cloned->sb;
 	struct nfs_server *server = NFS_SB(sb);
-- 
2.12.0

