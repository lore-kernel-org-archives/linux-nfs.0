Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:35018 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755450Ab1BWNxI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 08:53:08 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: sfrench@us.ibm.com, agruen@linbit.com, dilger.kernel@dilger.ca,
        sandeen@redhat.com, tytso@mit.edu, bfields@fieldses.org,
        jlayton@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, Andreas Gruenbacher <agruen@suse.de>
Subject: [PATCH -V5 04/24] vfs: Add generic IS_ACL() test for acl support
Date: Wed, 23 Feb 2011 19:21:51 +0530
Message-Id: <1298469131-16555-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andreas Gruenbacher <agruen@suse.de>

When IS_POSIXACL() is true, the vfs does not apply the umask.  Other acl
models will need the same exception, so introduce a separate IS_ACL()
test.

The IS_POSIX_ACL() test is still needed so that nfsd can determine when
the underlying file system supports POSIX ACLs (as opposed to some other
kind).

Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c         |    6 +++---
 include/linux/fs.h |    8 +++++++-
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 0bfc546..b1e5104 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2161,7 +2161,7 @@ static int __open_namei_create(struct nameidata *nd, struct path *path,
 	int error;
 	struct dentry *dir = nd->path.dentry;
 
-	if (!IS_POSIXACL(dir->d_inode))
+	if (!IS_ACL(dir->d_inode))
 		mode &= ~current_umask();
 	error = security_path_mknod(&nd->path, path->dentry, mode, 0);
 	if (error)
@@ -2691,7 +2691,7 @@ SYSCALL_DEFINE4(mknodat, int, dfd, const char __user *, filename, int, mode,
 		error = PTR_ERR(dentry);
 		goto out_unlock;
 	}
-	if (!IS_POSIXACL(nd.path.dentry->d_inode))
+	if (!IS_ACL(nd.path.dentry->d_inode))
 		mode &= ~current_umask();
 	error = may_mknod(mode);
 	if (error)
@@ -2768,7 +2768,7 @@ SYSCALL_DEFINE3(mkdirat, int, dfd, const char __user *, pathname, int, mode)
 	if (IS_ERR(dentry))
 		goto out_unlock;
 
-	if (!IS_POSIXACL(nd.path.dentry->d_inode))
+	if (!IS_ACL(nd.path.dentry->d_inode))
 		mode &= ~current_umask();
 	error = mnt_want_write(nd.path.mnt);
 	if (error)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index bd32159..70c7779 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -205,7 +205,7 @@ struct inodes_stat_t {
 #define MS_VERBOSE	32768	/* War is peace. Verbosity is silence.
 				   MS_VERBOSE is deprecated. */
 #define MS_SILENT	32768
-#define MS_POSIXACL	(1<<16)	/* VFS does not apply the umask */
+#define MS_POSIXACL	(1<<16) /* Supports POSIX ACLs */
 #define MS_UNBINDABLE	(1<<17)	/* change to unbindable */
 #define MS_PRIVATE	(1<<18)	/* change to private */
 #define MS_SLAVE	(1<<19)	/* change to slave */
@@ -280,6 +280,12 @@ struct inodes_stat_t {
 #define IS_IMA(inode)		((inode)->i_flags & S_IMA)
 #define IS_AUTOMOUNT(inode)	((inode)->i_flags & S_AUTOMOUNT)
 
+/*
+ * IS_ACL() tells the VFS to not apply the umask
+ * and use iop->check_acl for acl permission checks when defined.
+ */
+#define IS_ACL(inode)		__IS_FLG(inode, MS_POSIXACL)
+
 /* the read-only stuff doesn't really belong here, but any other place is
    probably as bad and I don't want to create yet another include file. */
 
-- 
1.7.1

