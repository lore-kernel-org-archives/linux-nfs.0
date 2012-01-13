Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47039 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932729Ab2AMULc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:32 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 32/44] NFS: Move a v4 block from inode.c
Date: Fri, 13 Jan 2012 15:10:41 -0500
Message-Id: <1326485453-1350-33-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile     |    2 +-
 fs/nfs/inode.c      |   24 ++----------------------
 fs/nfs/nfs.h        |    1 +
 fs/nfs/nfs4/inode.c |   27 +++++++++++++++++++++++++++
 4 files changed, 31 insertions(+), 23 deletions(-)
 create mode 100644 fs/nfs/nfs4/inode.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 5335ce2..94d8631 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -14,7 +14,7 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4/proc.o nfs4/xdr.o nfs4/state.o nfs4/renewd.o \
 			   nfs4/callback.o nfs4/callback_xdr.o \
 			   nfs4/callback_proc.o nfs4/namespace.o \
 			   nfs4/client.o nfs4/module.o nfs4/sysctl.o \
-			   nfs4/getroot.o
+			   nfs4/getroot.o nfs4/inode.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 29673ac..a8d138b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -105,7 +105,7 @@ u64 nfs_compat_user_ino64(u64 fileid)
 	return ino;
 }
 
-static void nfs_clear_inode(struct inode *inode)
+void nfs_clear_inode(struct inode *inode)
 {
 	/*
 	 * The following should never happen...
@@ -116,6 +116,7 @@ static void nfs_clear_inode(struct inode *inode)
 	nfs_access_zap_cache(inode);
 	nfs_fscache_release_inode_cookie(inode);
 }
+EXPORT_SYMBOL_GPL(nfs_clear_inode);
 
 void nfs_evict_inode(struct inode *inode)
 {
@@ -1455,27 +1456,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	goto out_err;
 }
 
-
-#ifdef CONFIG_NFS_V4
-
-/*
- * Clean out any remaining NFSv4 state that might be left over due
- * to open() calls that passed nfs_atomic_lookup, but failed to call
- * nfs_open().
- */
-void nfs4_evict_inode(struct inode *inode)
-{
-	truncate_inode_pages(&inode->i_data, 0);
-	end_writeback(inode);
-	pnfs_return_layout(inode);
-	pnfs_destroy_layout(NFS_I(inode));
-	/* If we are holding a delegation, return it! */
-	nfs_inode_return_delegation_noreclaim(inode);
-	/* First call standard NFS clear_inode() code */
-	nfs_clear_inode(inode);
-}
-#endif
-
 struct inode *nfs_alloc_inode(struct super_block *sb)
 {
 	struct nfs_inode *nfsi;
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 5fee8ec..cff0f23 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -100,6 +100,7 @@ int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
 int nfs_have_delegation(struct inode *, fmode_t);
 int nfs_have_delegated_attributes(struct inode *);
 int nfs_inode_return_delegation(struct inode *);
+void nfs_clear_inode(struct inode *);
 
 /* Exported in namespace.c */
 struct vfsmount *nfs_d_automount(struct path *);
diff --git a/fs/nfs/nfs4/inode.c b/fs/nfs/nfs4/inode.c
new file mode 100644
index 0000000..65496c1
--- /dev/null
+++ b/fs/nfs/nfs4/inode.c
@@ -0,0 +1,27 @@
+/*
+ *  Copyright (C) 1992  Rick Sladkey
+ */
+#include <linux/fs.h>
+#include <linux/sunrpc/sched.h>
+#include <linux/nfs_fs.h>
+
+#include "delegation.h"
+#include "../nfs.h"
+#include "../pnfs.h"
+
+/*
+ * Clean out any remaining NFSv4 state that might be left over due
+ * to open() calls that passed nfs_atomic_lookup, but failed to call
+ * nfs_open().
+ */
+void nfs4_evict_inode(struct inode *inode)
+{
+	truncate_inode_pages(&inode->i_data, 0);
+	end_writeback(inode);
+	pnfs_return_layout(inode);
+	pnfs_destroy_layout(NFS_I(inode));
+	/* If we are holding a delegation, return it! */
+	nfs_inode_return_delegation_noreclaim(inode);
+	/* First call standard NFS clear_inode() code */
+	nfs_clear_inode(inode);
+}
-- 
1.7.8.3

