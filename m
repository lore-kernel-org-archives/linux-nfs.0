Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:55320 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753437AbaICQTe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Sep 2014 12:19:34 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/4] NFS: Move NFS v3 acl functions to nfs3_fs.h
Date: Wed, 3 Sep 2014 12:19:10 -0400
Message-ID: <1409761150-30257-5-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1409761150-30257-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1409761150-30257-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This code is internal to the v3 module, so other parts of the client
shouldn't have any knowledge of it.

nfs3_getxattr(), nfs3_setxattr(), and nfs3_removexattr() no longer exist
anywhere so I remove the declarations while I'm here.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs3_fs.h       | 19 +++++++++++++++++++
 fs/nfs/nfs3super.c     |  1 +
 include/linux/nfs_fs.h | 33 ---------------------------------
 3 files changed, 20 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/nfs3_fs.h b/fs/nfs/nfs3_fs.h
index 6599e0d..333ae40 100644
--- a/fs/nfs/nfs3_fs.h
+++ b/fs/nfs/nfs3_fs.h
@@ -6,6 +6,25 @@
 #ifndef __LINUX_FS_NFS_NFS3_FS_H
 #define __LINUX_FS_NFS_NFS3_FS_H
 
+/*
+ * nfs3acl.c
+ */
+#ifdef CONFIG_NFS_V3_ACL
+extern struct posix_acl *nfs3_get_acl(struct inode *inode, int type);
+extern int nfs3_set_acl(struct inode *inode, struct posix_acl *acl, int type);
+extern int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
+		struct posix_acl *dfacl);
+extern ssize_t nfs3_listxattr(struct dentry *, char *, size_t);
+extern const struct xattr_handler *nfs3_xattr_handlers[];
+#else
+static inline int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
+		struct posix_acl *dfacl)
+{
+	return 0;
+}
+#define nfs3_listxattr NULL
+#endif /* CONFIG_NFS_V3_ACL */
+
 /* nfs3client.c */
 struct nfs_server *nfs3_create_server(struct nfs_mount_info *, struct nfs_subversion *);
 struct nfs_server *nfs3_clone_server(struct nfs_server *, struct nfs_fh *,
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
index d6a9894..6af29c2 100644
--- a/fs/nfs/nfs3super.c
+++ b/fs/nfs/nfs3super.c
@@ -4,6 +4,7 @@
 #include <linux/module.h>
 #include <linux/nfs_fs.h>
 #include "internal.h"
+#include "nfs3_fs.h"
 #include "nfs.h"
 
 static struct nfs_subversion nfs_v3 = {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index fd334d4..28d6490 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -443,22 +443,6 @@ static inline struct rpc_cred *nfs_file_cred(struct file *file)
 }
 
 /*
- * linux/fs/nfs/xattr.c
- */
-#ifdef CONFIG_NFS_V3_ACL
-extern ssize_t nfs3_listxattr(struct dentry *, char *, size_t);
-extern ssize_t nfs3_getxattr(struct dentry *, const char *, void *, size_t);
-extern int nfs3_setxattr(struct dentry *, const char *,
-			const void *, size_t, int);
-extern int nfs3_removexattr (struct dentry *, const char *name);
-#else
-# define nfs3_listxattr NULL
-# define nfs3_getxattr NULL
-# define nfs3_setxattr NULL
-# define nfs3_removexattr NULL
-#endif
-
-/*
  * linux/fs/nfs/direct.c
  */
 extern ssize_t nfs_direct_IO(int, struct kiocb *, struct iov_iter *, loff_t);
@@ -549,23 +533,6 @@ extern int  nfs_readpage_async(struct nfs_open_context *, struct inode *,
 			       struct page *);
 
 /*
- * linux/fs/nfs3proc.c
- */
-#ifdef CONFIG_NFS_V3_ACL
-extern struct posix_acl *nfs3_get_acl(struct inode *inode, int type);
-extern int nfs3_set_acl(struct inode *inode, struct posix_acl *acl, int type);
-extern int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
-		struct posix_acl *dfacl);
-extern const struct xattr_handler *nfs3_xattr_handlers[];
-#else
-static inline int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
-		struct posix_acl *dfacl)
-{
-	return 0;
-}
-#endif /* CONFIG_NFS_V3_ACL */
-
-/*
  * inline functions
  */
 
-- 
2.1.0

