Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932739Ab2AMUL2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:28 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 28/44] NFS: Create a custom put_client() function
Date: Fri, 13 Jan 2012 15:10:37 -0500
Message-Id: <1326485453-1350-29-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This gives v4 a chance to clean up the client idr structure.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c      |   10 +++++++++-
 fs/nfs/nfs.h         |    1 +
 fs/nfs/nfs2/client.c |    4 ++++
 fs/nfs/nfs2/module.c |    1 +
 fs/nfs/nfs2/nfs2.h   |    1 +
 fs/nfs/nfs3/client.c |    4 ++++
 fs/nfs/nfs3/module.c |    1 +
 fs/nfs/nfs3/nfs3.h   |    1 +
 fs/nfs/nfs4/nfs4.h   |    1 +
 9 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index a4b7634..1b84962 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -140,6 +140,7 @@ static struct nfs_subversion nfs_v4_mod = {
 	.validate_mount_data = nfs4_validate_text_mount_data,
 	.init_aclclient = nfs4_init_aclclient,
 	.alloc_client = nfs4_alloc_client,
+	.put_client = nfs4_put_client,
 	.try_mount = nfs4_try_mount,
 	.shutdown_client = nfs4_shutdown_client,
 	.have_delegation = nfs4_have_delegation,
@@ -314,6 +315,11 @@ static void nfs4_destroy_server(struct nfs_server *server)
 	nfs4_purge_state_owners(server);
 }
 
+void nfs4_put_client(struct nfs_client *clp)
+{
+	nfs_cb_idr_remove(clp);
+}
+
 #else
 
 void nfs_cleanup_cb_ident_idr(void)
@@ -363,6 +369,7 @@ static void nfs_free_client(struct nfs_client *clp)
  */
 void nfs_put_client(struct nfs_client *clp)
 {
+	struct nfs_subversion *nfs_mod;
 	if (!clp)
 		return;
 
@@ -370,7 +377,8 @@ void nfs_put_client(struct nfs_client *clp)
 
 	if (atomic_dec_and_lock(&clp->cl_count, &nfs_client_lock)) {
 		list_del(&clp->cl_share_link);
-		nfs_cb_idr_remove(clp);
+		nfs_mod = get_nfs_client_version(clp);
+		nfs_mod->put_client(clp);
 		spin_unlock(&nfs_client_lock);
 
 		BUG_ON(!list_empty(&clp->cl_superblocks));
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index b2a930d..455bacf 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -37,6 +37,7 @@ struct nfs_subversion {
 				   const char *);
 	void (*init_aclclient)(struct nfs_server *);
 	int (*alloc_client)(struct nfs_client *, const struct nfs_client_initdata *);
+	void (*put_client)(struct nfs_client *);
 	struct dentry *(*try_mount)(struct file_system_type *, int,
 				    const char *, struct nfs_fh *,
 				    struct nfs_parsed_mount_data *);
diff --git a/fs/nfs/nfs2/client.c b/fs/nfs/nfs2/client.c
index 36d6499..935473f 100644
--- a/fs/nfs/nfs2/client.c
+++ b/fs/nfs/nfs2/client.c
@@ -16,3 +16,7 @@ int nfs2_alloc_client(struct nfs_client *clp, const struct nfs_client_initdata *
 {
 	return 0;
 }
+
+void nfs2_put_client(struct nfs_client *clp)
+{
+}
diff --git a/fs/nfs/nfs2/module.c b/fs/nfs/nfs2/module.c
index e527001..1d68721 100644
--- a/fs/nfs/nfs2/module.c
+++ b/fs/nfs/nfs2/module.c
@@ -43,6 +43,7 @@ struct nfs_subversion nfs_v2 = {
 	.validate_mount_data = nfs_validate_text_mount_data,
 	.init_aclclient = nfs2_init_aclclient,
 	.alloc_client = nfs2_alloc_client,
+	.put_client = nfs2_put_client,
 	.try_mount = generic_nfs_fs_mount,
 	.shutdown_client = nfs2_shutdown_client,
 	.have_delegation = nfs2_no_delegation,
diff --git a/fs/nfs/nfs2/nfs2.h b/fs/nfs/nfs2/nfs2.h
index 2ce1245..838d6f1 100644
--- a/fs/nfs/nfs2/nfs2.h
+++ b/fs/nfs/nfs2/nfs2.h
@@ -11,6 +11,7 @@ extern const struct nfs_rpc_ops nfs_v2_clientops;
 
 void nfs2_init_aclclient(struct nfs_server *);
 int nfs2_alloc_client(struct nfs_client *, const struct nfs_client_initdata *);
+void nfs2_put_client(struct nfs_client *);
 
 extern const struct inode_operations nfs_file_inode_operations;
 extern const struct file_operations nfs_file_operations;
diff --git a/fs/nfs/nfs3/client.c b/fs/nfs/nfs3/client.c
index 4aa2024..1e9ac0e 100644
--- a/fs/nfs/nfs3/client.c
+++ b/fs/nfs/nfs3/client.c
@@ -60,3 +60,7 @@ int nfs3_alloc_client(struct nfs_client *clp, const struct nfs_client_initdata *
 {
 	return 0;
 }
+
+void nfs3_put_client(struct nfs_client *clp)
+{
+}
diff --git a/fs/nfs/nfs3/module.c b/fs/nfs/nfs3/module.c
index a63dbe7..a6b62b2 100644
--- a/fs/nfs/nfs3/module.c
+++ b/fs/nfs/nfs3/module.c
@@ -43,6 +43,7 @@ struct nfs_subversion nfs_v3 = {
 	.validate_mount_data = nfs_validate_text_mount_data,
 	.init_aclclient = nfs3_init_aclclient,
 	.alloc_client = nfs3_alloc_client,
+	.put_client = nfs3_put_client,
 	.try_mount = generic_nfs_fs_mount,
 	.shutdown_client = nfs3_shutdown_client,
 	.have_delegation = nfs3_no_delegation,
diff --git a/fs/nfs/nfs3/nfs3.h b/fs/nfs/nfs3/nfs3.h
index d43df84..091cf79 100644
--- a/fs/nfs/nfs3/nfs3.h
+++ b/fs/nfs/nfs3/nfs3.h
@@ -11,6 +11,7 @@ extern struct nfs_rpc_ops nfs_v3_clientops;
 
 void nfs3_init_aclclient(struct nfs_server *);
 int nfs3_alloc_client(struct nfs_client *, const struct nfs_client_initdata *);
+void nfs3_put_client(struct nfs_client *);
 
 extern const struct inode_operations nfs3_file_inode_operations;
 extern const struct file_operations nfs3_file_operations;
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
index 37f12d6..0b1cf87 100644
--- a/fs/nfs/nfs4/nfs4.h
+++ b/fs/nfs/nfs4/nfs4.h
@@ -15,5 +15,6 @@ struct dentry *nfs4_try_mount(struct file_system_type *, int, const char *,
 int nfs4_validate_text_mount_data(void *, struct nfs_parsed_mount_data *,
 				  struct nfs_fh *, const char *);
 int nfs4_alloc_client(struct nfs_client *, const struct nfs_client_initdata *);
+void nfs4_put_client(struct nfs_client *);
 
 #endif /* __LINUX_FS_NFS_NFS4_H */
-- 
1.7.8.3

