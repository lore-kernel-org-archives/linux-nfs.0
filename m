Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:65521 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757971Ab2FTTyJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:54:09 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 07/10] NFS: Create an alloc_client rpc_op
Date: Wed, 20 Jun 2012 15:53:46 -0400
Message-Id: <1340222029-18027-8-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
References: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This gives NFS v4 a way to set up callbacks and sessions without v2 or
v3 having to do them as well.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c         | 40 ++++++++++++++++++++++++++--------------
 fs/nfs/internal.h       |  1 +
 fs/nfs/nfs3proc.c       |  1 +
 fs/nfs/nfs4_fs.h        |  2 ++
 fs/nfs/nfs4proc.c       |  1 +
 fs/nfs/proc.c           |  1 +
 include/linux/nfs_xdr.h |  2 ++
 7 files changed, 34 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 82cb8a3..254719c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -147,7 +147,7 @@ struct nfs_client_initdata {
  * Since these are allocated/deallocated very rarely, we don't
  * bother putting them in a slab cache...
  */
-static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
+struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 {
 	struct nfs_client *clp;
 	struct rpc_cred *cred;
@@ -177,18 +177,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_proto = cl_init->proto;
 	clp->cl_net = get_net(cl_init->net);
 
-#ifdef CONFIG_NFS_V4
-	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
-	if (err)
-		goto error_cleanup;
-
-	spin_lock_init(&clp->cl_lock);
-	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
-	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
-	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
-	clp->cl_minorversion = cl_init->minorversion;
-	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
-#endif
 	cred = rpc_lookup_machine_cred("*");
 	if (!IS_ERR(cred))
 		clp->cl_machine_cred = cred;
@@ -218,6 +206,30 @@ static void nfs4_shutdown_session(struct nfs_client *clp)
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
+{
+	int err;
+	struct nfs_client *clp = nfs_alloc_client(cl_init);
+	if (IS_ERR(clp))
+		return clp;
+
+	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
+	if (err)
+		goto error;
+
+	spin_lock_init(&clp->cl_lock);
+	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
+	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
+	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
+	clp->cl_minorversion = cl_init->minorversion;
+	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
+	return clp;
+
+error:
+	kfree(clp);
+	return ERR_PTR(err);
+}
+
 /*
  * Destroy the NFS4 callback service
  */
@@ -588,7 +600,7 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 
 		spin_unlock(&nn->nfs_client_lock);
 
-		new = nfs_alloc_client(cl_init);
+		new = cl_init->rpc_ops->alloc_client(cl_init);
 	} while (!IS_ERR(new));
 
 	dprintk("<-- nfs_get_client() Failed to find %s (%ld)\n",
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 93b7325..633af81 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -148,6 +148,7 @@ extern void nfs_umount(const struct nfs_mount_request *info);
 /* client.c */
 extern const struct rpc_program nfs_program;
 extern void nfs_clients_init(struct net *net);
+extern struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *);
 
 extern void nfs_cleanup_cb_ident_idr(struct net *);
 extern void nfs_put_client(struct nfs_client *);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 4ccb34b..77c7aac 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -934,6 +934,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.close_context	= nfs_close_context,
 	.have_delegation = nfs3_have_delegation,
 	.return_delegation = nfs3_return_delegation,
+	.alloc_client	= nfs_alloc_client,
 	.init_client	= nfs_init_client,
 	.free_client	= nfs_free_client,
 };
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9889ee4..a0be2d1a 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -303,6 +303,8 @@ extern const u32 nfs4_fs_locations_bitmap[2];
 
 void nfs4_free_client(struct nfs_client *);
 
+struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *);
+
 /* nfs4renewd.c */
 extern void nfs4_schedule_state_renewal(struct nfs_client *);
 extern void nfs4_renewd_prepare_shutdown(struct nfs_server *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9ba482e..9ed2cc3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6804,6 +6804,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.open_context	= nfs4_atomic_open,
 	.have_delegation = nfs4_have_delegation,
 	.return_delegation = nfs4_inode_return_delegation,
+	.alloc_client	= nfs4_alloc_client,
 	.init_client	= nfs4_init_client,
 	.free_client	= nfs4_free_client,
 };
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 53620bf..99a0025 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -790,6 +790,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.close_context	= nfs_close_context,
 	.have_delegation = nfs_have_delegation,
 	.return_delegation = nfs_return_delegation,
+	.alloc_client	= nfs_alloc_client,
 	.init_client	= nfs_init_client,
 	.free_client	= nfs_free_client,
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index e61dc72..4d62b77 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1353,6 +1353,7 @@ struct nfs_renamedata {
 struct nfs_access_entry;
 struct nfs_client;
 struct rpc_timeout;
+struct nfs_client_initdata;
 
 /*
  * RPC procedure vector for NFSv2/NFSv3 demuxing
@@ -1424,6 +1425,7 @@ struct nfs_rpc_ops {
 				struct iattr *iattr);
 	int (*have_delegation)(struct inode *, fmode_t);
 	int (*return_delegation)(struct inode *);
+	struct nfs_client *(*alloc_client) (const struct nfs_client_initdata *);
 	struct nfs_client *
 		(*init_client) (struct nfs_client *, const struct rpc_timeout *,
 				const char *, rpc_authflavor_t);
-- 
1.7.11

