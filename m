Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932748Ab2AMULU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:20 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 18/44] NFS: Give versions a custom have_delegation() function
Date: Fri, 13 Jan 2012 15:10:27 -0500
Message-Id: <1326485453-1350-19-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

v2 and v3 don't have delegations, so this is an empty function in those
cases and only defined for v4.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c          |    1 +
 fs/nfs/inode.c           |    6 ++++++
 fs/nfs/nfs.h             |    2 ++
 fs/nfs/nfs2/module.c     |    6 ++++++
 fs/nfs/nfs3/module.c     |    6 ++++++
 fs/nfs/nfs4/delegation.c |    2 +-
 fs/nfs/nfs4/delegation.h |    9 ++-------
 fs/nfs/write.c           |    1 +
 8 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 6091414..e00f268 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -137,6 +137,7 @@ static struct nfs_subversion nfs_v4_mod = {
 	.reference = nfs_module_null_function,
 	.unreference = nfs_module_null_function,
 	.init_aclclient = nfs4_init_aclclient,
+	.have_delegation = nfs4_have_delegation,
 	.do_submount = nfs4_do_submount,
 	.do_clone_mount = nfs4_do_clone_mount,
 };
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3588727..1c7e24f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -124,6 +124,12 @@ void nfs_evict_inode(struct inode *inode)
 	nfs_clear_inode(inode);
 }
 
+int nfs_have_delegation(struct inode *inode, fmode_t flags)
+{
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(NFS_SERVER(inode));
+	return nfs_mod->have_delegation(inode, flags);
+}
+
 /**
  * nfs_sync_mapping - helper to flush all mmapped dirty data to disk
  */
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 0f119ab..7be27f4 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -22,6 +22,7 @@ struct nfs_subversion {
 	void (*reference)(void);	/* For reference counting */
 	void (*unreference)(void);	/* Also for reference counting */
 	void (*init_aclclient)(struct nfs_server *);
+	int (*have_delegation)(struct inode *, fmode_t);
 	struct vfsmount *(*do_submount)(struct dentry *, struct nfs_fh *,
 					struct nfs_fattr *, rpc_authflavor_t);
 	struct vfsmount *(*do_clone_mount)(struct nfs_server *, const char *,
@@ -73,6 +74,7 @@ int nfs_setlease(struct file *, long, struct file_lock **);
 /* Exported in inode.c */
 int nfs_setattr(struct dentry *, struct iattr *);
 int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+int nfs_have_delegation(struct inode *, fmode_t);
 
 /* Exported in namespace.c */
 struct vfsmount *nfs_d_automount(struct path *);
diff --git a/fs/nfs/nfs2/module.c b/fs/nfs/nfs2/module.c
index 768c375..ccbb759 100644
--- a/fs/nfs/nfs2/module.c
+++ b/fs/nfs/nfs2/module.c
@@ -19,6 +19,11 @@ static void nfs2_unreference(void)
 	module_put(THIS_MODULE);
 }
 
+static int nfs2_no_delegation(struct inode *inode, fmode_t flags)
+{
+	return 0;
+}
+
 struct nfs_subversion nfs_v2 = {
 	.version  = 2,
 	.rpc_vers = &nfs_version2,
@@ -27,6 +32,7 @@ struct nfs_subversion nfs_v2 = {
 	.reference = nfs2_reference,
 	.unreference = nfs2_unreference,
 	.init_aclclient = nfs2_init_aclclient,
+	.have_delegation = nfs2_no_delegation,
 	.do_submount = nfs_do_submount,
 	.do_clone_mount = nfs_do_clone_mount,
 };
diff --git a/fs/nfs/nfs3/module.c b/fs/nfs/nfs3/module.c
index 0898339..10cfab8 100644
--- a/fs/nfs/nfs3/module.c
+++ b/fs/nfs/nfs3/module.c
@@ -19,6 +19,11 @@ static void nfs3_unreference(void)
 	module_put(THIS_MODULE);
 }
 
+static int nfs3_no_delegation(struct inode *inode, fmode_t flags)
+{
+	return 0;
+}
+
 struct nfs_subversion nfs_v3 = {
 	.version  = 3,
 	.rpc_vers = &nfs_version3,
@@ -27,6 +32,7 @@ struct nfs_subversion nfs_v3 = {
 	.reference = nfs3_reference,
 	.unreference = nfs3_unreference,
 	.init_aclclient = nfs3_init_aclclient,
+	.have_delegation = nfs3_no_delegation,
 	.do_submount = nfs_do_submount,
 	.do_clone_mount = nfs_do_clone_mount,
 };
diff --git a/fs/nfs/nfs4/delegation.c b/fs/nfs/nfs4/delegation.c
index 2f3dc3e..800f44e 100644
--- a/fs/nfs/nfs4/delegation.c
+++ b/fs/nfs/nfs4/delegation.c
@@ -47,7 +47,7 @@ void nfs_mark_delegation_referenced(struct nfs_delegation *delegation)
  *
  * Returns one if inode has the indicated delegation, otherwise zero.
  */
-int nfs_have_delegation(struct inode *inode, fmode_t flags)
+int nfs4_have_delegation(struct inode *inode, fmode_t flags)
 {
 	struct nfs_delegation *delegation;
 	int ret = 0;
diff --git a/fs/nfs/nfs4/delegation.h b/fs/nfs/nfs4/delegation.h
index d9322e4..675ceea 100644
--- a/fs/nfs/nfs4/delegation.h
+++ b/fs/nfs/nfs4/delegation.h
@@ -56,14 +56,9 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl);
 int nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode);
 
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
-int nfs_have_delegation(struct inode *inode, fmode_t flags);
+int nfs4_have_delegation(struct inode *inode, fmode_t flags);
 
 #else
-static inline int nfs_have_delegation(struct inode *inode, fmode_t flags)
-{
-	return 0;
-}
-
 static inline int nfs_inode_return_delegation(struct inode *inode)
 {
 	return 0;
@@ -72,7 +67,7 @@ static inline int nfs_inode_return_delegation(struct inode *inode)
 
 static inline int nfs_have_delegated_attributes(struct inode *inode)
 {
-	return nfs_have_delegation(inode, FMODE_READ) &&
+	return nfs4_have_delegation(inode, FMODE_READ) &&
 		!(NFS_I(inode)->cache_validity & NFS_INO_REVAL_FORCED);
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d5f61af..f9ca30c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -30,6 +30,7 @@
 #include "nfs4/nfs4_fs.h"
 #include "fscache.h"
 #include "pnfs.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
-- 
1.7.8.3

