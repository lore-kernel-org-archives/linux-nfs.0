Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41527 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757960Ab2FTTyH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:54:07 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 02/10] NFS: Use nfs4_destroy_server() to clean up NFS v4
Date: Wed, 20 Jun 2012 15:53:41 -0400
Message-Id: <1340222029-18027-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
References: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I can use this function to return delegations and unset the pnfs layout
driver rather than continuing to do these things in the generic client.
With this change, we no longer need an nfs4_kill_super().

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c     |  3 ++-
 fs/nfs/delegation.c |  3 +--
 fs/nfs/delegation.h |  2 +-
 fs/nfs/super.c      | 23 +++++------------------
 4 files changed, 9 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index e646b14..bf0f896 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -266,6 +266,8 @@ static void pnfs_init_server(struct nfs_server *server)
 
 static void nfs4_destroy_server(struct nfs_server *server)
 {
+	nfs_server_return_all_delegations(server);
+	unset_pnfs_layoutdriver(server);
 	nfs4_purge_state_owners(server);
 }
 
@@ -1137,7 +1139,6 @@ void nfs_free_server(struct nfs_server *server)
 	dprintk("--> nfs_free_server()\n");
 
 	nfs_server_remove_lists(server);
-	unset_pnfs_layoutdriver(server);
 
 	if (server->destroy != NULL)
 		server->destroy(server);
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index bd3a960..9a7a1b4 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -417,9 +417,8 @@ static void nfs_mark_return_delegation(struct nfs_server *server,
  * @sb: sb to process
  *
  */
-void nfs_super_return_all_delegations(struct super_block *sb)
+void nfs_server_return_all_delegations(struct nfs_server *server)
 {
-	struct nfs_server *server = NFS_SB(sb);
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs_delegation *delegation;
 
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 72709c4..206db56 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -38,7 +38,7 @@ int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *s
 void nfs_inode_return_delegation_noreclaim(struct inode *inode);
 
 struct inode *nfs_delegation_find_inode(struct nfs_client *clp, const struct nfs_fh *fhandle);
-void nfs_super_return_all_delegations(struct super_block *sb);
+void nfs_server_return_all_delegations(struct nfs_server *);
 void nfs_expire_all_delegations(struct nfs_client *clp);
 void nfs_expire_all_delegation_types(struct nfs_client *clp, fmode_t flags);
 void nfs_expire_unreferenced_delegations(struct nfs_client *clp);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 906f09c..5a1c860 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -347,13 +347,12 @@ static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
 static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
-static void nfs4_kill_super(struct super_block *sb);
 
 static struct file_system_type nfs4_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
 	.mount		= nfs_fs_mount,
-	.kill_sb	= nfs4_kill_super,
+	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
@@ -361,7 +360,7 @@ static struct file_system_type nfs4_remote_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
 	.mount		= nfs4_remote_mount,
-	.kill_sb	= nfs4_kill_super,
+	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
@@ -369,7 +368,7 @@ struct file_system_type nfs4_xdev_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
 	.mount		= nfs4_xdev_mount,
-	.kill_sb	= nfs4_kill_super,
+	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
@@ -377,7 +376,7 @@ static struct file_system_type nfs4_remote_referral_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
 	.mount		= nfs4_remote_referral_mount,
-	.kill_sb	= nfs4_kill_super,
+	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
@@ -385,7 +384,7 @@ struct file_system_type nfs4_referral_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
 	.mount		= nfs4_referral_mount,
-	.kill_sb	= nfs4_kill_super,
+	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
@@ -2874,18 +2873,6 @@ static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 	return res;
 }
 
-static void nfs4_kill_super(struct super_block *sb)
-{
-	struct nfs_server *server = NFS_SB(sb);
-
-	dprintk("--> %s\n", __func__);
-	nfs_super_return_all_delegations(sb);
-	kill_anon_super(sb);
-	nfs_fscache_release_super_cookie(sb);
-	nfs_free_server(server);
-	dprintk("<-- %s\n", __func__);
-}
-
 /*
  * Clone an NFS4 server record on xdev traversal (FSID-change)
  */
-- 
1.7.11

