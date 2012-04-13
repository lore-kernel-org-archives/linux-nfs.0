Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:57233 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372Ab2DMLZR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Apr 2012 07:25:17 -0400
Received: by yenl12 with SMTP id l12so1536818yen.19
        for <linux-nfs@vger.kernel.org>; Fri, 13 Apr 2012 04:25:16 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: pstaubach@exagrid.com, miklos@szeredi.hu, viro@ZenIV.linux.org.uk,
        hch@infradead.org, michael.brantley@deshaw.com
Subject: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from getattr call
Date: Fri, 13 Apr 2012 07:25:11 -0400
Message-Id: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ESTALE errors are a source of pain for many users of NFS. Often they
occur when a lookup is satisfied out of the dcache, but the associated
inode has been removed on the server. In the case where a file is
renamed on top of another, the call would ordinarily have succeeded had
we issued an on the wire lookup instead. There are also other situations
that can lead to ESTALE errors, and the remedy is usually to retry the
lookup and call. If this is handled correctly in the kernel, then
userspace should only rarely see an ESTALE error.

This is an RFC patch showing the general approach to addressing this
problem that I'm suggesting. In order to solve this completely we'll
need to fix most of the path-based syscalls in a similar way.

This is not the first attempt at fixing this. Peter Staubach made a
similar attempt several years ago:

    https://lkml.org/lkml/2008/3/10/267

This patch attempts to address the problem by having the VFS retry
the lookup (with LOOKUP_REVAL set) and the getattr call whenever the
getattr returns ESTALE.

A new fs flag is specified that allows filesystems to opt-in to
this behavior. That should address many of the concerns about whether
it's ok to retry indefinitely, but it does mean that we're only
going to do retry the call when the lookup succeeds.

However, basing this on a flag does give us a bit of a discrepancy in
retry behavior between the lookup and other operations. The path-walking
code already will reattempt the lookup once on an ESTALE error. The
proposed patch here however will make it retry indefinitely when the
getattr call returns ESTALE.

Since fixing this means touching a lot of code, it's pretty important
that we get the semantics correct here. I'm quite open to suggestion
about how we should make this behave as long as it resolves most of
these sorts of problems.

The main questions I have are:

1) should we retry these calls on all filesystems, or attempt to have
them "opt-in" in some fashion? This patch adds a flag for that, but
we could just treat all filesystems the same way.

2) How many times should we retry on an ESTALE error? Once?
Indefinitely? Some amount in between? Retrying once would probably
fix the bulk of the real world problems with this, but there will
still be cases where that's not sufficient.

3) Should we consider also changing the path-walking code to retry
more than once on an ESTALE error?

Once we nail down some acceptable semantics for this, I should be
able to make a more comprehensive patch that fixes this for all
path-based syscalls. I don't really want to dive into that work
however until we've come to some agreement about it.

Thanks to Michael Brantley for his initial work and patch for this
problem.

Reported-by: Michael Brantley <michael.brantley@deshaw.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c     |   14 +++++++-------
 fs/stat.c          |    9 ++++++++-
 include/linux/fs.h |    3 +++
 3 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 37412f7..b22aaba 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -296,7 +296,7 @@ static struct file_system_type nfs_fs_type = {
 	.name		= "nfs",
 	.mount		= nfs_fs_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA|FS_RETRY_ESTALE,
 };
 
 struct file_system_type nfs_xdev_fs_type = {
@@ -304,7 +304,7 @@ struct file_system_type nfs_xdev_fs_type = {
 	.name		= "nfs",
 	.mount		= nfs_xdev_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA|FS_RETRY_ESTALE,
 };
 
 static const struct super_operations nfs_sops = {
@@ -344,7 +344,7 @@ static struct file_system_type nfs4_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_mount,
 	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA|FS_RETRY_ESTALE,
 };
 
 static struct file_system_type nfs4_remote_fs_type = {
@@ -352,7 +352,7 @@ static struct file_system_type nfs4_remote_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_remote_mount,
 	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA|FS_RETRY_ESTALE,
 };
 
 struct file_system_type nfs4_xdev_fs_type = {
@@ -360,7 +360,7 @@ struct file_system_type nfs4_xdev_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_xdev_mount,
 	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA|FS_RETRY_ESTALE,
 };
 
 static struct file_system_type nfs4_remote_referral_fs_type = {
@@ -368,7 +368,7 @@ static struct file_system_type nfs4_remote_referral_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_remote_referral_mount,
 	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA|FS_RETRY_ESTALE,
 };
 
 struct file_system_type nfs4_referral_fs_type = {
@@ -376,7 +376,7 @@ struct file_system_type nfs4_referral_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_referral_mount,
 	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA|FS_RETRY_ESTALE,
 };
 
 static const struct super_operations nfs4_sops = {
diff --git a/fs/stat.c b/fs/stat.c
index c733dc5..02ce590 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -73,7 +73,8 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 {
 	struct path path;
 	int error = -EINVAL;
-	int lookup_flags = 0;
+	unsigned int lookup_flags = 0;
+	bool should_retry;
 
 	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
 		      AT_EMPTY_PATH)) != 0)
@@ -84,12 +85,18 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 	if (flag & AT_EMPTY_PATH)
 		lookup_flags |= LOOKUP_EMPTY;
 
+retry:
 	error = user_path_at(dfd, filename, lookup_flags, &path);
 	if (error)
 		goto out;
 
 	error = vfs_getattr(path.mnt, path.dentry, stat);
+	should_retry = error == -ESTALE ? retry_estale(path.dentry) : false;
 	path_put(&path);
+	if (should_retry) {
+		lookup_flags |= LOOKUP_REVAL;
+		goto retry;
+	}
 out:
 	return error;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8de6755..36fd4fa 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -181,11 +181,14 @@ struct inodes_stat_t {
 #define FS_REQUIRES_DEV 1 
 #define FS_BINARY_MOUNTDATA 2
 #define FS_HAS_SUBTYPE 4
+#define FS_RETRY_ESTALE 8	/* retry operation on ESTALE error */
 #define FS_REVAL_DOT	16384	/* Check the paths ".", ".." for staleness */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move()
 					 * during rename() internally.
 					 */
 
+#define retry_estale(dentry) (dentry->d_sb->s_type->fs_flags & FS_RETRY_ESTALE)
+
 /*
  * These are the fs-independent mount-flags: up to 32 flags are supported
  */
-- 
1.7.7.6

