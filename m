From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/3] NFS: Ensure we support selinux xattrs
Date: Wed, 24 Jan 2007 11:54:57 -0800
Message-ID: <20070124195457.21259.53047.stgit@lade.trondhjem.org>
References: <20070124195307.21259.64156.stgit@lade.trondhjem.org>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
	sds@tycho.nsa.gov
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932477AbXAXUUl@vger.kernel.org>
In-Reply-To: <20070124195307.21259.64156.stgit@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Some programs (e.g. GNU "cp") are currently crashing because NFS
allows you to inquire about SELinux security attributes (vfs_getxattr()
automatically handles this), but returns -EOPNOTSUPP when they later
attempt to set the SELinux security attributes.

The following patch just ensures that we pass the request to set security
attributes on to the default SELinux handler.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs3acl.c  |   13 +++++++++++++
 fs/nfs/nfs4proc.c |   14 ++++++++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 7322da4..5970e7b 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -4,6 +4,9 @@ #include <linux/nfs3.h>
 #include <linux/nfs_fs.h>
 #include <linux/posix_acl_xattr.h>
 #include <linux/nfsacl.h>
+#include <linux/security.h>
+#include <linux/xattr.h>
+#include <linux/fsnotify.h>
 
 #define NFSDBG_FACILITY	NFSDBG_PROC
 
@@ -82,6 +85,16 @@ int nfs3_setxattr(struct dentry *dentry,
 	struct posix_acl *acl;
 	int type, error;
 
+	/* Selinux support */
+	if (!strncmp(name, XATTR_SECURITY_PREFIX, XATTR_SECURITY_PREFIX_LEN)) {
+		const char *suffix = name + XATTR_SECURITY_PREFIX_LEN;
+		error = security_inode_setsecurity(inode, suffix, value,
+				size, flags);
+		if (!error)
+			fsnotify_xattr(dentry);
+		return error;
+	}
+
 	if (strcmp(name, POSIX_ACL_XATTR_ACCESS) == 0)
 		type = ACL_TYPE_ACCESS;
 	else if (strcmp(name, POSIX_ACL_XATTR_DEFAULT) == 0)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b3fd29b..ac1082b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -48,6 +48,9 @@ #include <linux/nfs_page.h>
 #include <linux/smp_lock.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
+#include <linux/security.h>
+#include <linux/xattr.h>
+#include <linux/fsnotify.h>
 
 #include "nfs4_fs.h"
 #include "delegation.h"
@@ -3547,6 +3550,17 @@ int nfs4_setxattr(struct dentry *dentry,
 {
 	struct inode *inode = dentry->d_inode;
 
+	/* Selinux support */
+	if (!strncmp(key, XATTR_SECURITY_PREFIX, XATTR_SECURITY_PREFIX_LEN)) {
+		const char *suffix = key + XATTR_SECURITY_PREFIX_LEN;
+		int error;
+		error = security_inode_setsecurity(inode, suffix, buf,
+				buflen, flags);
+		if (!error)
+			fsnotify_xattr(dentry);
+		return error;
+	}
+
 	if (strcmp(key, XATTR_NAME_NFSV4_ACL) != 0)
 		return -EOPNOTSUPP;
 
