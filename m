Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56034 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726277AbeJDHyO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Oct 2018 03:54:14 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Date: Thu, 04 Oct 2018 11:02:43 +1000
Subject: [PATCH 1/3] VFS: introduce MAY_ACT_AS_OWNER
Cc: Jan Harkes <jaharkes@cs.cmu.edu>, linux-nfs@vger.kernel.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, David Howells <dhowells@redhat.com>,
        coda@cs.cmu.edu, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>
Message-ID: <153861496327.30373.10501882399296347125.stgit@noble>
In-Reply-To: <153861471803.30373.6184444014227748848.stgit@noble>
References: <153861471803.30373.6184444014227748848.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A few places in VFS, particularly set_posix_acl(), use
inode_owner_or_capable() to check if the caller has "owner"
access to the inode.
This assumes that it is valid to test inode->i_uid, which is not
always the case.  Particularly in the case of NFS it is not valid to
us i_uid (or i_mode) for permission tests - the server needs to make
the decision.

As a result if the server is remapping uids
(e.g. all-squash,anon_uid=1000),
then all users should have ownership access, but most users will not
be able to set acls.

This patch moves the ownership test to inode_permission and
i_op->permission.
A new flag for these functions, MAY_ACT_AS_OWNER is introduced.
generic_permission() now handles this correctly and many
i_op->permission functions call this function() and don't need any
changes.  A few are changed to handle MAY_ACT_AS_OWNER exactly
as generic_permission() does, using inode_owner_or_capable().
For these filesystems, no behavioural change should be noticed.

For NFS, nfs_permission is changed to always return 0 (success) if
MAY_ACT_AS_OWNER.  For NFS, any operations which use this flag should
be sent to the server, and the server will succeed or fail as
appropriate.

Fixes: 013cdf1088d7 ("nfs: use generic posix ACL infrastructure for v3 Posix ACLs")
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/afs/security.c  |   10 ++++++++++
 fs/attr.c          |   12 +++++-------
 fs/coda/dir.c      |   10 ++++++++++
 fs/fcntl.c         |    2 +-
 fs/fuse/dir.c      |   10 ++++++++++
 fs/namei.c         |    9 +++++++++
 fs/nfs/dir.c       |    8 ++++++++
 fs/posix_acl.c     |    2 +-
 fs/xattr.c         |    2 +-
 include/linux/fs.h |    8 ++++++++
 10 files changed, 63 insertions(+), 10 deletions(-)

diff --git a/fs/afs/security.c b/fs/afs/security.c
index 81dfedb7879f..ac2e39de8bff 100644
--- a/fs/afs/security.c
+++ b/fs/afs/security.c
@@ -349,6 +349,16 @@ int afs_permission(struct inode *inode, int mask)
 	if (mask & MAY_NOT_BLOCK)
 		return -ECHILD;
 
+	/* Short-circuit for owner */
+	if (mask & MAY_ACT_AS_OWNER) {
+		if (inode_owner_or_capable(inode))
+			return 0;
+		mask &= ~MAY_ACT_AS_OWNER;
+		if (!mask)
+			/* No other permission will suffice */
+			return -EACCES;
+	}
+
 	_enter("{{%x:%u},%lx},%x,",
 	       vnode->fid.vid, vnode->fid.vnode, vnode->flags, mask);
 
diff --git a/fs/attr.c b/fs/attr.c
index d22e8187477f..c1160bd9416b 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -87,7 +87,7 @@ int setattr_prepare(struct dentry *dentry, struct iattr *attr)
 
 	/* Make sure a caller can chmod. */
 	if (ia_valid & ATTR_MODE) {
-		if (!inode_owner_or_capable(inode))
+		if (inode_permission(inode, MAY_ACT_AS_OWNER) < 0)
 			return -EPERM;
 		/* Also check the setgid bit! */
 		if (!in_group_p((ia_valid & ATTR_GID) ? attr->ia_gid :
@@ -98,7 +98,7 @@ int setattr_prepare(struct dentry *dentry, struct iattr *attr)
 
 	/* Check for setting the inode time. */
 	if (ia_valid & (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)) {
-		if (!inode_owner_or_capable(inode))
+		if (inode_permission(inode, MAY_ACT_AS_OWNER) < 0)
 			return -EPERM;
 	}
 
@@ -246,11 +246,9 @@ int notify_change(struct dentry * dentry, struct iattr * attr, struct inode **de
 		if (IS_IMMUTABLE(inode))
 			return -EPERM;
 
-		if (!inode_owner_or_capable(inode)) {
-			error = inode_permission(inode, MAY_WRITE);
-			if (error)
-				return error;
-		}
+		error = inode_permission(inode, MAY_ACT_AS_OWNER | MAY_WRITE);
+		if (error)
+			return error;
 	}
 
 	if ((ia_valid & ATTR_MODE)) {
diff --git a/fs/coda/dir.c b/fs/coda/dir.c
index 00876ddadb43..7e31f68d4973 100644
--- a/fs/coda/dir.c
+++ b/fs/coda/dir.c
@@ -80,6 +80,16 @@ int coda_permission(struct inode *inode, int mask)
 	if (mask & MAY_NOT_BLOCK)
 		return -ECHILD;
 
+	/* Short-circuit for owner */
+	if (mask & MAY_ACT_AS_OWNER) {
+		if (inode_owner_or_capable(inode))
+			return 0;
+		mask &= ~MAY_ACT_AS_OWNER;
+		if (!mask)
+			/* No other permission will suffice */
+			return -EACCES;
+	}
+
 	mask &= MAY_READ | MAY_WRITE | MAY_EXEC;
  
 	if (!mask)
diff --git a/fs/fcntl.c b/fs/fcntl.c
index 4137d96534a6..cc1d51150584 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -46,7 +46,7 @@ static int setfl(int fd, struct file * filp, unsigned long arg)
 
 	/* O_NOATIME can only be set by the owner or superuser */
 	if ((arg & O_NOATIME) && !(filp->f_flags & O_NOATIME))
-		if (!inode_owner_or_capable(inode))
+		if (inode_permission(inode, MAY_ACT_AS_OWNER) < 0)
 			return -EPERM;
 
 	/* required for strict SunOS emulation */
diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index 0979609d6eba..3ff5a8f3a086 100644
--- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -1118,6 +1118,16 @@ static int fuse_permission(struct inode *inode, int mask)
 	if (!fuse_allow_current_process(fc))
 		return -EACCES;
 
+	/* Short-circuit for owner */
+	if (mask & MAY_ACT_AS_OWNER) {
+		if (inode_owner_or_capable(inode))
+			return 0;
+		mask &= ~MAY_ACT_AS_OWNER;
+		if (!mask)
+			/* No other permission will suffice */
+			return -EACCES;
+	}
+
 	/*
 	 * If attributes are needed, refresh them before proceeding
 	 */
diff --git a/fs/namei.c b/fs/namei.c
index 0cab6494978c..a033a0f5c284 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -335,6 +335,15 @@ int generic_permission(struct inode *inode, int mask)
 {
 	int ret;
 
+	/* Short-circuit for owner */
+	if (mask & MAY_ACT_AS_OWNER) {
+		if (inode_owner_or_capable(inode))
+			return 0;
+		mask &= ~MAY_ACT_AS_OWNER;
+		if (!mask)
+			/* No other permission will suffice */
+			return -EACCES;
+	}
 	/*
 	 * Do the basic permission checks.
 	 */
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8bfaa658b2c1..1fe54374b7c9 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2524,6 +2524,14 @@ int nfs_permission(struct inode *inode, int mask)
 
 	nfs_inc_stats(inode, NFSIOS_VFSACCESS);
 
+	/* Short-circuit for owner */
+	if (mask & MAY_ACT_AS_OWNER)
+		/*
+		 * Ownership will be tested by server when we
+		 * actually try operation.
+		 */
+		return 0;
+
 	if ((mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) == 0)
 		goto out;
 	/* Is this sys_access() ? */
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 2fd0fde16fe1..a90c7dca892a 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -863,7 +863,7 @@ set_posix_acl(struct inode *inode, int type, struct posix_acl *acl)
 
 	if (type == ACL_TYPE_DEFAULT && !S_ISDIR(inode->i_mode))
 		return acl ? -EACCES : 0;
-	if (!inode_owner_or_capable(inode))
+	if (inode_permission(inode, MAY_ACT_AS_OWNER) < 0)
 		return -EPERM;
 
 	if (acl) {
diff --git a/fs/xattr.c b/fs/xattr.c
index daa732550088..78faa09a577b 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -126,7 +126,7 @@ xattr_permission(struct inode *inode, const char *name, int mask)
 		if (!S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
 			return (mask & MAY_WRITE) ? -EPERM : -ENODATA;
 		if (S_ISDIR(inode->i_mode) && (inode->i_mode & S_ISVTX) &&
-		    (mask & MAY_WRITE) && !inode_owner_or_capable(inode))
+		    (mask & MAY_WRITE) && inode_permission(inode, MAY_ACT_AS_OWNER) < 0)
 			return -EPERM;
 	}
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 551cbc5574d7..5a8878a88cbb 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -94,6 +94,14 @@ typedef int (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 #define MAY_CHDIR		0x00000040
 /* called from RCU mode, don't block */
 #define MAY_NOT_BLOCK		0x00000080
+/*
+ * File Owner is always allowed to perform pending
+ * operation.  If current user is an owner, or if
+ * filesystem performs permission check at time-of-operation,
+ * then succeed, else require some other permission
+ * if listed.
+ */
+#define MAY_ACT_AS_OWNER	0x00000100
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
