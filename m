Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31911 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759034Ab2CUPVV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:21 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 17/23] NFS: Deal with delegations
Date: Wed, 21 Mar 2012 11:20:47 -0400
Message-Id: <1332343253-24970-18-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
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
 fs/nfs/inode.c      |   39 +++++++++++++++++----------------------
 fs/nfs/internal.h   |    3 ---
 fs/nfs/nfs.h        |    7 +++++++
 fs/nfs/nfs4proc.c   |    8 ++++----
 fs/nfs/nfs4super.c  |   18 ++++++++++++++++++
 fs/nfs/unlink.c     |    2 +-
 fs/nfs/write.c      |    2 +-
 9 files changed, 57 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 89af1d2..b950630 100644
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
@@ -377,12 +377,12 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
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
index cd6a7a8..26f77ca 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -8,6 +8,7 @@
 #ifndef FS_NFS_DELEGATION_H
 #define FS_NFS_DELEGATION_H
 
+#include "nfs.h"
 #if defined(CONFIG_NFS_V4)
 /*
  * NFSv4 delegation
@@ -33,7 +34,7 @@ enum {
 
 int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
 void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
-int nfs_inode_return_delegation(struct inode *inode);
+int nfs4_inode_return_delegation(struct inode *inode);
 int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid);
 void nfs_inode_return_delegation_noreclaim(struct inode *inode);
 
@@ -56,15 +57,15 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl);
 bool nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode, fmode_t flags);
 
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
index 30c7103..35f4175 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -108,7 +108,7 @@ u64 nfs_compat_user_ino64(u64 fileid)
 	return ino;
 }
 
-static void nfs_clear_inode(struct inode *inode)
+void nfs_clear_inode(struct inode *inode)
 {
 	/*
 	 * The following should never happen...
@@ -208,6 +208,22 @@ static void nfs_invalidate_inode(struct inode *inode)
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
@@ -1504,27 +1520,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
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
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 2476dc6..bd335bb 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -256,9 +256,6 @@ extern struct inode *nfs_alloc_inode(struct super_block *sb);
 extern void nfs_destroy_inode(struct inode *);
 extern int nfs_write_inode(struct inode *, struct writeback_control *);
 extern void nfs_evict_inode(struct inode *);
-#ifdef CONFIG_NFS_V4
-extern void nfs4_evict_inode(struct inode *);
-#endif
 void nfs_zap_acl_cache(struct inode *inode);
 extern int nfs_wait_bit_killable(void *word);
 
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 877ca24..fa0b531 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -38,6 +38,8 @@ struct nfs_subversion {
 				   struct nfs_fh *, struct nfs_parsed_mount_data *);
 	struct dentry *(*xdev_mount)(int, const char *, struct nfs_clone_mount *);
 	struct vfsmount *(*submount)(struct dentry *, struct nfs_fh *, struct nfs_fattr *, rpc_authflavor_t);
+	int (*have_delegation)(struct inode *, fmode_t);
+	int (*return_delegation)(struct inode *);
 };
 
 struct nfs_sb_mountdata {
@@ -86,6 +88,11 @@ int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *)
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
index b76dd0e..cc3fd43 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -270,8 +270,8 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 		case 0:
 			return 0;
 		case -NFS4ERR_OPENMODE:
-			if (nfs_have_delegation(inode, FMODE_READ)) {
-				nfs_inode_return_delegation(inode);
+			if (nfs4_have_delegation(inode, FMODE_READ)) {
+				nfs4_inode_return_delegation(inode);
 				exception->retry = 1;
 				return 0;
 			}
@@ -1044,7 +1044,7 @@ static void nfs4_return_incompatible_delegation(struct inode *inode, fmode_t fmo
 		return;
 	}
 	rcu_read_unlock();
-	nfs_inode_return_delegation(inode);
+	nfs4_inode_return_delegation(inode);
 }
 
 static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
@@ -3779,7 +3779,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	i = buf_to_pages_noslab(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
 	if (i < 0)
 		return i;
-	nfs_inode_return_delegation(inode);
+	nfs4_inode_return_delegation(inode);
 	ret = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 
 	/*
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index b0beba9..f463a2c 100644
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
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 3210a03..05abd34 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -18,7 +18,7 @@
 #include "internal.h"
 #include "nfs4_fs.h"
 #include "iostat.h"
-#include "delegation.h"
+#include "nfs.h"
 
 /**
  * nfs_free_unlinkdata - release data from a sillydelete operation.
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0f28bd2..5e30b57 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -24,12 +24,12 @@
 
 #include <asm/uaccess.h>
 
-#include "delegation.h"
 #include "internal.h"
 #include "iostat.h"
 #include "nfs4_fs.h"
 #include "fscache.h"
 #include "pnfs.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
-- 
1.7.9.4

