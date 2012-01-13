Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:56184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932729Ab2AMULV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:21 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 19/44] NFS: Give versions a custom have_delegated_attributes() function
Date: Fri, 13 Jan 2012 15:10:28 -0500
Message-Id: <1326485453-1350-20-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This is for use with v4 delegations, so once again v2 and v3 can leave
it empty.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c          |    1 +
 fs/nfs/inode.c           |    6 ++++++
 fs/nfs/nfs.h             |    2 ++
 fs/nfs/nfs2/module.c     |    6 ++++++
 fs/nfs/nfs3/module.c     |    6 ++++++
 fs/nfs/nfs4/delegation.c |    6 ++++++
 fs/nfs/nfs4/delegation.h |    6 ------
 fs/nfs/nfs4/nfs4.h       |    1 +
 8 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index e00f268..368aa7e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -138,6 +138,7 @@ static struct nfs_subversion nfs_v4_mod = {
 	.unreference = nfs_module_null_function,
 	.init_aclclient = nfs4_init_aclclient,
 	.have_delegation = nfs4_have_delegation,
+	.have_delegated_attributes = nfs4_have_delegated_attributes,
 	.do_submount = nfs4_do_submount,
 	.do_clone_mount = nfs4_do_clone_mount,
 };
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1c7e24f..5328b68 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -130,6 +130,12 @@ int nfs_have_delegation(struct inode *inode, fmode_t flags)
 	return nfs_mod->have_delegation(inode, flags);
 }
 
+int nfs_have_delegated_attributes(struct inode *inode)
+{
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(NFS_SERVER(inode));
+	return nfs_mod->have_delegated_attributes(inode);
+}
+
 /**
  * nfs_sync_mapping - helper to flush all mmapped dirty data to disk
  */
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 7be27f4..08950a2 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -23,6 +23,7 @@ struct nfs_subversion {
 	void (*unreference)(void);	/* Also for reference counting */
 	void (*init_aclclient)(struct nfs_server *);
 	int (*have_delegation)(struct inode *, fmode_t);
+	int (*have_delegated_attributes)(struct inode *);
 	struct vfsmount *(*do_submount)(struct dentry *, struct nfs_fh *,
 					struct nfs_fattr *, rpc_authflavor_t);
 	struct vfsmount *(*do_clone_mount)(struct nfs_server *, const char *,
@@ -75,6 +76,7 @@ int nfs_setlease(struct file *, long, struct file_lock **);
 int nfs_setattr(struct dentry *, struct iattr *);
 int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
 int nfs_have_delegation(struct inode *, fmode_t);
+int nfs_have_delegated_attributes(struct inode *);
 
 /* Exported in namespace.c */
 struct vfsmount *nfs_d_automount(struct path *);
diff --git a/fs/nfs/nfs2/module.c b/fs/nfs/nfs2/module.c
index ccbb759..ef6dbb4 100644
--- a/fs/nfs/nfs2/module.c
+++ b/fs/nfs/nfs2/module.c
@@ -24,6 +24,11 @@ static int nfs2_no_delegation(struct inode *inode, fmode_t flags)
 	return 0;
 }
 
+static int nfs2_no_delegation2(struct inode *inode)
+{
+	return 0;
+}
+
 struct nfs_subversion nfs_v2 = {
 	.version  = 2,
 	.rpc_vers = &nfs_version2,
@@ -33,6 +38,7 @@ struct nfs_subversion nfs_v2 = {
 	.unreference = nfs2_unreference,
 	.init_aclclient = nfs2_init_aclclient,
 	.have_delegation = nfs2_no_delegation,
+	.have_delegated_attributes = nfs2_no_delegation2,
 	.do_submount = nfs_do_submount,
 	.do_clone_mount = nfs_do_clone_mount,
 };
diff --git a/fs/nfs/nfs3/module.c b/fs/nfs/nfs3/module.c
index 10cfab8..bdd2e33 100644
--- a/fs/nfs/nfs3/module.c
+++ b/fs/nfs/nfs3/module.c
@@ -24,6 +24,11 @@ static int nfs3_no_delegation(struct inode *inode, fmode_t flags)
 	return 0;
 }
 
+static int nfs3_no_delegation2(struct inode *inode)
+{
+	return 0;
+}
+
 struct nfs_subversion nfs_v3 = {
 	.version  = 3,
 	.rpc_vers = &nfs_version3,
@@ -33,6 +38,7 @@ struct nfs_subversion nfs_v3 = {
 	.unreference = nfs3_unreference,
 	.init_aclclient = nfs3_init_aclclient,
 	.have_delegation = nfs3_no_delegation,
+	.have_delegated_attributes = nfs3_no_delegation2,
 	.do_submount = nfs_do_submount,
 	.do_clone_mount = nfs_do_clone_mount,
 };
diff --git a/fs/nfs/nfs4/delegation.c b/fs/nfs/nfs4/delegation.c
index 800f44e..272e735 100644
--- a/fs/nfs/nfs4/delegation.c
+++ b/fs/nfs/nfs4/delegation.c
@@ -63,6 +63,12 @@ int nfs4_have_delegation(struct inode *inode, fmode_t flags)
 	return ret;
 }
 
+int nfs4_have_delegated_attributes(struct inode *inode)
+{
+	return nfs4_have_delegation(inode, FMODE_READ) &&
+		!(NFS_I(inode)->cache_validity & NFS_INO_REVAL_FORCED);
+}
+
 static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_state *state)
 {
 	struct inode *inode = state->inode;
diff --git a/fs/nfs/nfs4/delegation.h b/fs/nfs/nfs4/delegation.h
index 675ceea..2c45cb6 100644
--- a/fs/nfs/nfs4/delegation.h
+++ b/fs/nfs/nfs4/delegation.h
@@ -65,10 +65,4 @@ static inline int nfs_inode_return_delegation(struct inode *inode)
 }
 #endif
 
-static inline int nfs_have_delegated_attributes(struct inode *inode)
-{
-	return nfs4_have_delegation(inode, FMODE_READ) &&
-		!(NFS_I(inode)->cache_validity & NFS_INO_REVAL_FORCED);
-}
-
 #endif
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
index f6694b9..6d5cf57 100644
--- a/fs/nfs/nfs4/nfs4.h
+++ b/fs/nfs/nfs4/nfs4.h
@@ -8,5 +8,6 @@ struct vfsmount *nfs4_do_submount(struct dentry *, struct nfs_fh *,
 				  struct nfs_fattr *, rpc_authflavor_t);
 struct vfsmount *nfs4_do_clone_mount(struct nfs_server *, const char *,
 				     struct nfs_clone_mount *);
+int nfs4_have_delegated_attributes(struct inode *);
 
 #endif /* __LINUX_FS_NFS_NFS4_H */
-- 
1.7.8.3

