Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:37383 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932715Ab1JRPeX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 11:34:23 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V7 05/26] vfs: Add generic IS_ACL() test for acl support
Date: Tue, 18 Oct 2011 21:02:40 +0530
Message-Id: <1318951981-5508-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

When IS_POSIXACL() is true, the vfs does not apply the umask.  Other acl
models will need the same exception, so introduce a separate IS_ACL()
test.

The IS_POSIX_ACL() test is still needed so that nfsd can determine when
the underlying file system supports POSIX ACLs (as opposed to some other
kind).

Acked-by: David Howells <dhowells@redhat.com>
Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c         |    6 +++---
 include/linux/fs.h |    8 +++++++-
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 9061157..cf8b2f0 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2166,7 +2166,7 @@ static struct file *do_last(struct nameidata *nd, struct path *path,
 	/* Negative dentry, just create the file */
 	if (!dentry->d_inode) {
 		int mode = op->mode;
-		if (!IS_POSIXACL(dir->d_inode))
+		if (!IS_ACL(dir->d_inode))
 			mode &= ~current_umask();
 		/*
 		 * This write is needed to ensure that a
@@ -2484,7 +2484,7 @@ SYSCALL_DEFINE4(mknodat, int, dfd, const char __user *, filename, int, mode,
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 
-	if (!IS_POSIXACL(path.dentry->d_inode))
+	if (!IS_ACL(path.dentry->d_inode))
 		mode &= ~current_umask();
 	error = may_mknod(mode);
 	if (error)
@@ -2553,7 +2553,7 @@ SYSCALL_DEFINE3(mkdirat, int, dfd, const char __user *, pathname, int, mode)
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 
-	if (!IS_POSIXACL(path.dentry->d_inode))
+	if (!IS_ACL(path.dentry->d_inode))
 		mode &= ~current_umask();
 	error = mnt_want_write(path.mnt);
 	if (error)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c1884e9..1994b84 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -201,7 +201,7 @@ struct inodes_stat_t {
 #define MS_VERBOSE	32768	/* War is peace. Verbosity is silence.
 				   MS_VERBOSE is deprecated. */
 #define MS_SILENT	32768
-#define MS_POSIXACL	(1<<16)	/* VFS does not apply the umask */
+#define MS_POSIXACL	(1<<16) /* Supports POSIX ACLs */
 #define MS_UNBINDABLE	(1<<17)	/* change to unbindable */
 #define MS_PRIVATE	(1<<18)	/* change to private */
 #define MS_SLAVE	(1<<19)	/* change to slave */
@@ -279,6 +279,12 @@ struct inodes_stat_t {
 #define IS_AUTOMOUNT(inode)	((inode)->i_flags & S_AUTOMOUNT)
 #define IS_NOSEC(inode)		((inode)->i_flags & S_NOSEC)
 
+/*
+ * IS_ACL() tells the VFS to not apply the umask
+ * and use check_acl for acl permission checks when defined.
+ */
+#define IS_ACL(inode)		__IS_FLG(inode, MS_POSIXACL)
+
 /* the read-only stuff doesn't really belong here, but any other place is
    probably as bad and I don't want to create yet another include file. */
 
-- 
1.7.5.4

