Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41527 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757960Ab2FTTyI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:54:08 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 06/10] NFS: Create a free_client rpc_op
Date: Wed, 20 Jun 2012 15:53:45 -0400
Message-Id: <1340222029-18027-7-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
References: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

NFS v4 needs a way to shut down callbacks and sessions, but v2 and v3
don't.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c         | 18 +++++++++---------
 fs/nfs/internal.h       |  1 +
 fs/nfs/nfs3proc.c       |  1 +
 fs/nfs/nfs4_fs.h        |  2 ++
 fs/nfs/nfs4proc.c       |  1 +
 fs/nfs/proc.c           |  1 +
 include/linux/nfs_xdr.h |  1 +
 7 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index bf0f896..82cb8a3 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -242,6 +242,12 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 	kfree(clp->cl_implid);
 }
 
+void nfs4_free_client(struct nfs_client *clp)
+{
+	nfs4_shutdown_client(clp);
+	nfs_free_client(clp);
+}
+
 /* idr_remove_all is not needed as all id's are removed by nfs_put_client */
 void nfs_cleanup_cb_ident_idr(struct net *net)
 {
@@ -272,10 +278,6 @@ static void nfs4_destroy_server(struct nfs_server *server)
 }
 
 #else
-static void nfs4_shutdown_client(struct nfs_client *clp)
-{
-}
-
 void nfs_cleanup_cb_ident_idr(struct net *net)
 {
 }
@@ -293,12 +295,10 @@ static void pnfs_init_server(struct nfs_server *server)
 /*
  * Destroy a shared client record
  */
-static void nfs_free_client(struct nfs_client *clp)
+void nfs_free_client(struct nfs_client *clp)
 {
 	dprintk("--> nfs_free_client(%u)\n", clp->rpc_ops->version);
 
-	nfs4_shutdown_client(clp);
-
 	nfs_fscache_release_client_cookie(clp);
 
 	/* -EIO all pending I/O */
@@ -335,7 +335,7 @@ void nfs_put_client(struct nfs_client *clp)
 
 		BUG_ON(!list_empty(&clp->cl_superblocks));
 
-		nfs_free_client(clp);
+		clp->rpc_ops->free_client(clp);
 	}
 }
 EXPORT_SYMBOL_GPL(nfs_put_client);
@@ -574,7 +574,7 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 		if (clp) {
 			spin_unlock(&nn->nfs_client_lock);
 			if (new)
-				nfs_free_client(new);
+				new->rpc_ops->free_client(new);
 			return nfs_found_client(cl_init, clp);
 		}
 		if (new) {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 18f99ef..93b7325 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -151,6 +151,7 @@ extern void nfs_clients_init(struct net *net);
 
 extern void nfs_cleanup_cb_ident_idr(struct net *);
 extern void nfs_put_client(struct nfs_client *);
+extern void nfs_free_client(struct nfs_client *);
 extern struct nfs_client *nfs4_find_client_ident(struct net *, int);
 extern struct nfs_client *
 nfs4_find_client_sessionid(struct net *, const struct sockaddr *,
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 4749a32..4ccb34b 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -935,4 +935,5 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.have_delegation = nfs3_have_delegation,
 	.return_delegation = nfs3_return_delegation,
 	.init_client	= nfs_init_client,
+	.free_client	= nfs_free_client,
 };
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index cc5900a..9889ee4 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -301,6 +301,8 @@ extern const u32 nfs4_pathconf_bitmap[2];
 extern const u32 nfs4_fsinfo_bitmap[3];
 extern const u32 nfs4_fs_locations_bitmap[2];
 
+void nfs4_free_client(struct nfs_client *);
+
 /* nfs4renewd.c */
 extern void nfs4_schedule_state_renewal(struct nfs_client *);
 extern void nfs4_renewd_prepare_shutdown(struct nfs_server *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b2cd0f1..9ba482e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6805,6 +6805,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.have_delegation = nfs4_have_delegation,
 	.return_delegation = nfs4_inode_return_delegation,
 	.init_client	= nfs4_init_client,
+	.free_client	= nfs4_free_client,
 };
 
 static const struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 1663293..53620bf 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -791,4 +791,5 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.have_delegation = nfs_have_delegation,
 	.return_delegation = nfs_return_delegation,
 	.init_client	= nfs_init_client,
+	.free_client	= nfs_free_client,
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 62235be..e61dc72 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1427,6 +1427,7 @@ struct nfs_rpc_ops {
 	struct nfs_client *
 		(*init_client) (struct nfs_client *, const struct rpc_timeout *,
 				const char *, rpc_authflavor_t);
+	void	(*free_client) (struct nfs_client *);
 };
 
 /*
-- 
1.7.11

