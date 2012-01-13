Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932487Ab2AMULV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:21 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 20/44] NFS: Give versions a custom return_delegation() function
Date: Fri, 13 Jan 2012 15:10:29 -0500
Message-Id: <1326485453-1350-21-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This is called by the generic NFS client to return a v4 delegation.  v2
and v3 don't have delegations, so they don't need to do anything.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c          |    1 +
 fs/nfs/inode.c           |    6 ++++++
 fs/nfs/nfs.h             |    2 ++
 fs/nfs/nfs2/module.c     |    1 +
 fs/nfs/nfs3/module.c     |    1 +
 fs/nfs/nfs4/delegation.c |    2 +-
 fs/nfs/nfs4/delegation.h |    8 +-------
 fs/nfs/nfs4/proc.c       |    4 ++--
 fs/nfs/unlink.c          |    1 +
 9 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 368aa7e..ca6ebe5 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -139,6 +139,7 @@ static struct nfs_subversion nfs_v4_mod = {
 	.init_aclclient = nfs4_init_aclclient,
 	.have_delegation = nfs4_have_delegation,
 	.have_delegated_attributes = nfs4_have_delegated_attributes,
+	.return_delegation = nfs4_inode_return_delegation,
 	.do_submount = nfs4_do_submount,
 	.do_clone_mount = nfs4_do_clone_mount,
 };
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5328b68..1bea5b7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -136,6 +136,12 @@ int nfs_have_delegated_attributes(struct inode *inode)
 	return nfs_mod->have_delegated_attributes(inode);
 }
 
+int nfs_inode_return_delegation(struct inode *inode)
+{
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(NFS_SERVER(inode));
+	return nfs_mod->return_delegation(inode);
+}
+
 /**
  * nfs_sync_mapping - helper to flush all mmapped dirty data to disk
  */
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 08950a2..c3dfb7d 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -24,6 +24,7 @@ struct nfs_subversion {
 	void (*init_aclclient)(struct nfs_server *);
 	int (*have_delegation)(struct inode *, fmode_t);
 	int (*have_delegated_attributes)(struct inode *);
+	int (*return_delegation)(struct inode *);
 	struct vfsmount *(*do_submount)(struct dentry *, struct nfs_fh *,
 					struct nfs_fattr *, rpc_authflavor_t);
 	struct vfsmount *(*do_clone_mount)(struct nfs_server *, const char *,
@@ -77,6 +78,7 @@ int nfs_setattr(struct dentry *, struct iattr *);
 int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
 int nfs_have_delegation(struct inode *, fmode_t);
 int nfs_have_delegated_attributes(struct inode *);
+int nfs_inode_return_delegation(struct inode *);
 
 /* Exported in namespace.c */
 struct vfsmount *nfs_d_automount(struct path *);
diff --git a/fs/nfs/nfs2/module.c b/fs/nfs/nfs2/module.c
index ef6dbb4..618ce83 100644
--- a/fs/nfs/nfs2/module.c
+++ b/fs/nfs/nfs2/module.c
@@ -39,6 +39,7 @@ struct nfs_subversion nfs_v2 = {
 	.init_aclclient = nfs2_init_aclclient,
 	.have_delegation = nfs2_no_delegation,
 	.have_delegated_attributes = nfs2_no_delegation2,
+	.return_delegation = nfs2_no_delegation2,
 	.do_submount = nfs_do_submount,
 	.do_clone_mount = nfs_do_clone_mount,
 };
diff --git a/fs/nfs/nfs3/module.c b/fs/nfs/nfs3/module.c
index bdd2e33..a999b2f 100644
--- a/fs/nfs/nfs3/module.c
+++ b/fs/nfs/nfs3/module.c
@@ -39,6 +39,7 @@ struct nfs_subversion nfs_v3 = {
 	.init_aclclient = nfs3_init_aclclient,
 	.have_delegation = nfs3_no_delegation,
 	.have_delegated_attributes = nfs3_no_delegation2,
+	.return_delegation = nfs3_no_delegation2,
 	.do_submount = nfs_do_submount,
 	.do_clone_mount = nfs_do_clone_mount,
 };
diff --git a/fs/nfs/nfs4/delegation.c b/fs/nfs/nfs4/delegation.c
index 272e735..e8aa4b6 100644
--- a/fs/nfs/nfs4/delegation.c
+++ b/fs/nfs/nfs4/delegation.c
@@ -387,7 +387,7 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
  *
  * Returns zero on success, or a negative errno value.
  */
-int nfs_inode_return_delegation(struct inode *inode)
+int nfs4_inode_return_delegation(struct inode *inode)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
diff --git a/fs/nfs/nfs4/delegation.h b/fs/nfs/nfs4/delegation.h
index 2c45cb6..40bd6c2 100644
--- a/fs/nfs/nfs4/delegation.h
+++ b/fs/nfs/nfs4/delegation.h
@@ -33,7 +33,7 @@ enum {
 
 int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
 void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
-int nfs_inode_return_delegation(struct inode *inode);
+int nfs4_inode_return_delegation(struct inode *inode);
 int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid);
 void nfs_inode_return_delegation_noreclaim(struct inode *inode);
 
@@ -58,11 +58,5 @@ int nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode);
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
 int nfs4_have_delegation(struct inode *inode, fmode_t flags);
 
-#else
-static inline int nfs_inode_return_delegation(struct inode *inode)
-{
-	return 0;
-}
 #endif
-
 #endif
diff --git a/fs/nfs/nfs4/proc.c b/fs/nfs/nfs4/proc.c
index c86c351..1161e70 100644
--- a/fs/nfs/nfs4/proc.c
+++ b/fs/nfs/nfs4/proc.c
@@ -1017,7 +1017,7 @@ static void nfs4_return_incompatible_delegation(struct inode *inode, fmode_t fmo
 		return;
 	}
 	rcu_read_unlock();
-	nfs_inode_return_delegation(inode);
+	nfs4_inode_return_delegation(inode);
 }
 
 static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
@@ -3671,7 +3671,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	i = buf_to_pages_noslab(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
 	if (i < 0)
 		return i;
-	nfs_inode_return_delegation(inode);
+	nfs4_inode_return_delegation(inode);
 	ret = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 
 	/*
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 1dbe14a..9f04700 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -19,6 +19,7 @@
 #include "nfs4/nfs4_fs.h"
 #include "iostat.h"
 #include "nfs4/delegation.h"
+#include "nfs.h"
 
 struct nfs_unlinkdata {
 	struct hlist_node list;
-- 
1.7.8.3

