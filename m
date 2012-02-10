Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11202 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760264Ab2BJWC2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:28 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 17/21] NFS: Deal with delegations
Date: Fri, 10 Feb 2012 17:02:01 -0500
Message-Id: <1328911325-1566-17-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Modules can implement their own have_delegation and return_delegation
functions.  If not, then a default value is returned.  I also moved over
the nfs4_evict_inode() function so it can find the
return_delegation_noreclaim function.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/delegation.c |    8 ++++----
 fs/nfs/delegation.h |    9 +++++----
 fs/nfs/inode.c      |   41 ++++++++++++++++++-----------------------
 fs/nfs/internal.h   |    3 ---
 fs/nfs/nfs.h        |    7 +++++++
 fs/nfs/nfs4proc.c   |    4 ++--
 fs/nfs/nfs4super.c  |   18 ++++++++++++++++++
 7 files changed, 54 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 7f26540..0430513 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -41,13 +41,13 @@ void nfs_mark_delegation_referenced(struct nfs_delegation *delegation)
 }
 
 /**
- * nfs_have_delegation - check if inode has a delegation
+ * nfs4_have_delegation - check if inode has a delegation
  * @inode: inode to check
  * @flags: delegation types to check for
  *
  * Returns one if inode has the indicated delegation, otherwise zero.
  */
-int nfs_have_delegation(struct inode *inode, fmode_t flags)
+int nfs4_have_delegation(struct inode *inode, fmode_t flags)
 {
 	struct nfs_delegation *delegation;
 	int ret = 0;
@@ -376,12 +376,12 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
 }
 
 /**
- * nfs_inode_return_delegation - synchronously return a delegation
+ * nfs4_inode_return_delegation - synchronously return a delegation
  * @inode: inode to process
  *
  * Returns zero on success, or a negative errno value.
  */
-int nfs_inode_return_delegation(struct inode *inode)
+int nfs4_inode_return_delegation(struct inode *inode)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index d9322e4..0b388d7 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -9,6 +9,7 @@
 #define FS_NFS_DELEGATION_H
 
 #if defined(CONFIG_NFS_V4)
+#include "nfs.h"
 /*
  * NFSv4 delegation
  */
@@ -33,7 +34,7 @@ enum {
 
 int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
 void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
-int nfs_inode_return_delegation(struct inode *inode);
+int nfs4_inode_return_delegation(struct inode *inode);
 int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid);
 void nfs_inode_return_delegation_noreclaim(struct inode *inode);
 
@@ -56,15 +57,15 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl);
 int nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode);
 
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
-int nfs_have_delegation(struct inode *inode, fmode_t flags);
+int nfs4_have_delegation(struct inode *inode, fmode_t flags);
 
 #else
-static inline int nfs_have_delegation(struct inode *inode, fmode_t flags)
+static inline int nfs4_have_delegation(struct inode *inode, fmode_t flags)
 {
 	return 0;
 }
 
-static inline int nfs_inode_return_delegation(struct inode *inode)
+static inline int nfs4_inode_return_delegation(struct inode *inode)
 {
 	return 0;
 }
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 53bb916..2f48355 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -107,7 +107,7 @@ u64 nfs_compat_user_ino64(u64 fileid)
 	return ino;
 }
 
-static void nfs_clear_inode(struct inode *inode)
+void nfs_clear_inode(struct inode *inode)
 {
 	/*
 	 * The following should never happen...
@@ -118,6 +118,7 @@ static void nfs_clear_inode(struct inode *inode)
 	nfs_access_zap_cache(inode);
 	nfs_fscache_release_inode_cookie(inode);
 }
+EXPORT_SYMBOL_GPL(nfs_clear_inode);
 
 void nfs_evict_inode(struct inode *inode)
 {
@@ -207,6 +208,22 @@ static void nfs_invalidate_inode(struct inode *inode)
 	nfs_zap_caches_locked(inode);
 }
 
+int nfs_have_delegation(struct inode *inode, fmode_t flags)
+{
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(NFS_SERVER(inode));
+	if (!nfs_mod->have_delegation)
+		return 0;
+	return nfs_mod->have_delegation(inode, flags);
+}
+
+int nfs_inode_return_delegation(struct inode *inode)
+{
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(NFS_SERVER(inode));
+	if (!nfs_mod->return_delegation)
+		return 0;
+	return nfs_mod->return_delegation(inode);
+}
+
 struct nfs_find_desc {
 	struct nfs_fh		*fh;
 	struct nfs_fattr	*fattr;
@@ -1440,28 +1457,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
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
-EXPORT_SYMBOL_GPL(nfs4_evict_inode);
-#endif
-
 struct inode *nfs_alloc_inode(struct super_block *sb)
 {
 	struct nfs_inode *nfsi;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index cdb121d..4ea1b93 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -258,9 +258,6 @@ extern struct inode *nfs_alloc_inode(struct super_block *sb);
 extern void nfs_destroy_inode(struct inode *);
 extern int nfs_write_inode(struct inode *, struct writeback_control *);
 extern void nfs_evict_inode(struct inode *);
-#ifdef CONFIG_NFS_V4
-extern void nfs4_evict_inode(struct inode *);
-#endif
 void nfs_zap_acl_cache(struct inode *inode);
 extern int nfs_wait_bit_killable(void *word);
 
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 0c05f14..a83e154 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -40,6 +40,8 @@ struct nfs_subversion {
 				   struct nfs_fh *, struct nfs_parsed_mount_data *);
 	struct dentry *(*xdev_mount)(int, const char *, struct nfs_clone_mount *);
 	struct vfsmount *(*submount)(struct dentry *, struct nfs_fh *, struct nfs_fattr *, rpc_authflavor_t);
+	int (*have_delegation)(struct inode *, fmode_t);
+	int (*return_delegation)(struct inode *);
 };
 
 struct nfs_sb_mountdata {
@@ -88,6 +90,11 @@ int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *)
 /* Exported in getroot.c */
 int nfs_superblock_set_dummy_root(struct super_block *, struct inode *);
 
+/* inode.c */
+void nfs_clear_inode(struct inode *);
+int nfs_have_delegation(struct inode *, fmode_t);
+int nfs_inode_return_delegation(struct inode *);
+
 /* Exported in namespace.c */
 struct vfsmount *_nfs_do_submount(struct file_system_type *, struct dentry *,
 				  struct nfs_fh *, struct nfs_fattr *, rpc_authflavor_t);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1bb0be3..3ae8485 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1028,7 +1028,7 @@ static void nfs4_return_incompatible_delegation(struct inode *inode, fmode_t fmo
 		return;
 	}
 	rcu_read_unlock();
-	nfs_inode_return_delegation(inode);
+	nfs4_inode_return_delegation(inode);
 }
 
 static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
@@ -3694,7 +3694,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	i = buf_to_pages_noslab(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
 	if (i < 0)
 		return i;
-	nfs_inode_return_delegation(inode);
+	nfs4_inode_return_delegation(inode);
 	ret = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 
 	/*
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index d874d2f..2764c28 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -10,6 +10,7 @@
 #include "delegation.h"
 #include "fscache.h"
 #include "nfs4_fs.h"
+#include "pnfs.h"
 #include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
@@ -26,6 +27,23 @@ static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_typ
 	int flags, const char *dev_name, void *raw_data);
 static void nfs4_kill_super(struct super_block *sb);
 
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
+
 struct file_system_type nfs4_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
-- 
1.7.9

