Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:18870 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757606Ab3HMVsA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 17:48:00 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 2/3] NFS Share RPC_AUTH_GSS rpc clients
Date: Tue, 13 Aug 2013 17:47:48 -0400
Message-ID: <1376430469-3773-3-git-send-email-andros@netapp.com>
In-Reply-To: <1376430469-3773-1-git-send-email-andros@netapp.com>
References: <1376430469-3773-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The current use of __rpc_clone_client results in multiple rpc clients with
the same GSS rpc_auth type, each with it's own gss_context cache.
This can result in multiple gss_contexts for <user, pseudoflavor, server> tuple.

To avoid multiple gss_contexts share per server/pseudoflavor clients and the resultant gss_context cache.

We also add the RPC_AUTH_UNIX client for the pNFS Data Server case used in
a subsequent patch, even though the RPC_AUTH_UNIX auth cache is already shared.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c                 | 80 ++++++++++++++++++++++++++++++++++++++---
 fs/nfs/internal.h               |  4 +++
 fs/nfs/nfs4namespace.c          |  5 +--
 fs/nfs/nfs4proc.c               |  9 +++--
 fs/nfs/nfs4state.c              |  4 +--
 include/linux/nfs_fs_sb.h       |  1 +
 include/linux/sunrpc/msg_prot.h |  3 ++
 7 files changed, 94 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2dceee4..1b4967f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -152,7 +152,7 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 {
 	struct nfs_client *clp;
 	struct rpc_cred *cred;
-	int err = -ENOMEM;
+	int err = -ENOMEM, i;
 
 	if ((clp = kzalloc(sizeof(*clp), GFP_KERNEL)) == NULL)
 		goto error_0;
@@ -178,6 +178,10 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 	INIT_LIST_HEAD(&clp->cl_superblocks);
 	clp->cl_rpcclient = ERR_PTR(-EINVAL);
 
+	/* The three Kerberos pseudoflavors plus RPC_AUTH_UNIX */
+	for (i = 0; i < RPC_AUTH_MAX_PSEUDO_FLAVOR + 1; i++)
+		clp->cl_rpc_clnt[i] = ERR_PTR(-EINVAL);
+
 	clp->cl_proto = cl_init->proto;
 	clp->cl_net = get_net(cl_init->net);
 
@@ -244,7 +248,7 @@ void nfs_free_client(struct nfs_client *clp)
 
 	/* -EIO all pending I/O */
 	if (!IS_ERR(clp->cl_rpcclient))
-		rpc_shutdown_client(clp->cl_rpcclient);
+		nfs_shutdown_rpc_client(clp, clp->cl_rpcclient);
 
 	if (clp->cl_machine_cred != NULL)
 		put_rpccred(clp->cl_machine_cred);
@@ -568,6 +572,68 @@ void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 }
 EXPORT_SYMBOL_GPL(nfs_init_timeout_values);
 
+/**
+ * Translate an authflavor into an nfs_client cl_rpc_clnt array index.
+ * Note cl_gss_array is of RPC_AUTH_MAX_PSEUDO_FLAVOR + 1 size.
+ */
+static inline
+int nfs_flavor_to_index(rpc_authflavor_t flavor)
+{
+	switch (flavor) {
+	case RPC_AUTH_UNIX:
+		return 0;
+	case RPC_AUTH_GSS_KRB5:
+		return 1;
+	case RPC_AUTH_GSS_KRB5I:
+		return 2;
+	case RPC_AUTH_GSS_KRB5P:
+		return 3;
+	default:
+		return -EINVAL;
+	}
+}
+
+struct rpc_clnt *
+nfs_get_auth_rpc_client(struct nfs_client *clp, rpc_authflavor_t flavor)
+{
+	struct rpc_clnt *clnt = clp->cl_rpcclient;
+	int idx;
+
+	dprintk("--> %s cl_rpcclient %p flavor %d\n", __func__, clnt, flavor);
+
+	idx = nfs_flavor_to_index(flavor);
+	if (idx < 0)
+		return ERR_PTR(idx);
+
+	if (IS_ERR(clp->cl_rpc_clnt[idx]))
+		clp->cl_rpc_clnt[idx] = rpc_clone_client_set_auth(clnt, flavor);
+	else
+		atomic_inc(&clp->cl_rpc_clnt[idx]->cl_count);
+
+	return clp->cl_rpc_clnt[idx];
+}
+EXPORT_SYMBOL_GPL(nfs_get_auth_rpc_client);
+
+void
+nfs_shutdown_rpc_client(struct nfs_client *clp, struct rpc_clnt *clnt)
+{
+	int idx;
+
+	dprintk("--> %s clnt %p flavor %d rpc clnt cl_count (%d)\n", __func__,
+		clnt, clnt->cl_auth->au_flavor, atomic_read(&clnt->cl_count));
+
+	/* rpc client creation checked the validity of the flavor */
+	idx = nfs_flavor_to_index(clnt->cl_auth->au_flavor);
+
+	/* Dec the refcount unless it is 1 in which case call shutdown */
+	if (atomic_add_unless(&clp->cl_rpc_clnt[idx]->cl_count, -1, 1) == 0) {
+		rpc_shutdown_client(clnt);
+		clp->cl_rpc_clnt[idx] = ERR_PTR(-EINVAL);
+		return;
+	}
+}
+EXPORT_SYMBOL_GPL(nfs_shutdown_rpc_client);
+
 /*
  * Create an RPC client handle
  */
@@ -587,6 +653,7 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 		.version	= clp->rpc_ops->version,
 		.authflavor	= flavor,
 	};
+	int idx;
 
 	if (test_bit(NFS_CS_DISCRTRY, &clp->cl_flags))
 		args.flags |= RPC_CLNT_CREATE_DISCRTRY;
@@ -605,7 +672,11 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 		return PTR_ERR(clnt);
 	}
 
+	/* rpcauth_create has verified the validity of the authflavor. */
+	idx = nfs_flavor_to_index(flavor);
+	clp->cl_rpc_clnt[idx] = clnt;
 	clp->cl_rpcclient = clnt;
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nfs_create_rpc_client);
@@ -668,8 +739,7 @@ int nfs_init_server_rpcclient(struct nfs_server *server,
 {
 	struct nfs_client *clp = server->nfs_client;
 
-	server->client = rpc_clone_client_set_auth(clp->cl_rpcclient,
-							pseudoflavour);
+	server->client = nfs_get_auth_rpc_client(clp, pseudoflavour);
 	if (IS_ERR(server->client)) {
 		dprintk("%s: couldn't create rpc_client!\n", __func__);
 		return PTR_ERR(server->client);
@@ -1018,7 +1088,7 @@ void nfs_free_server(struct nfs_server *server)
 	if (!IS_ERR(server->client_acl))
 		rpc_shutdown_client(server->client_acl);
 	if (!IS_ERR(server->client))
-		rpc_shutdown_client(server->client);
+		nfs_shutdown_rpc_client(server->nfs_client, server->client);
 
 	nfs_put_client(server->nfs_client);
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9b694f1..4aa20ba 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -185,6 +185,10 @@ extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 					     int ds_addrlen, int ds_proto,
 					     unsigned int ds_timeo,
 					     unsigned int ds_retrans);
+extern struct rpc_clnt *nfs_get_auth_rpc_client(struct nfs_client *clp,
+					rpc_authflavor_t flavor);
+extern void nfs_shutdown_rpc_client(struct nfs_client *clp,
+					struct rpc_clnt *clnt);
 #ifdef CONFIG_PROC_FS
 extern int __init nfs_fs_proc_init(void);
 extern void nfs_fs_proc_exit(void);
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index cdb0b41..b274427 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -205,7 +205,7 @@ struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *clnt, struct inode *ino
 	if ((int)flavor < 0)
 		return ERR_PTR((int)flavor);
 
-	return rpc_clone_client_set_auth(clnt, flavor);
+	return nfs_get_auth_rpc_client(NFS_SERVER(inode)->nfs_client, flavor);
 }
 
 static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
@@ -370,6 +370,7 @@ struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
 			       struct nfs_fh *fh, struct nfs_fattr *fattr)
 {
 	struct dentry *parent = dget_parent(dentry);
+	struct nfs_client *clp = NFS_SERVER(parent->d_inode)->nfs_client;
 	struct rpc_clnt *client;
 	struct vfsmount *mnt;
 
@@ -384,6 +385,6 @@ struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
 	else
 		mnt = nfs_do_submount(dentry, fh, fattr, client->cl_auth->au_flavor);
 
-	rpc_shutdown_client(client);
+	nfs_shutdown_rpc_client(clp, client);
 	return mnt;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f672c34..9160fcb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3047,7 +3047,7 @@ out:
 	if (err == 0)
 		*clnt = client;
 	else if (client != *clnt)
-		rpc_shutdown_client(client);
+		nfs_shutdown_rpc_client(NFS_SERVER(dir)->nfs_client, client);
 
 	return err;
 }
@@ -3061,7 +3061,7 @@ static int nfs4_proc_lookup(struct inode *dir, struct qstr *name,
 
 	status = nfs4_proc_lookup_common(&client, dir, name, fhandle, fattr, label);
 	if (client != NFS_CLIENT(dir)) {
-		rpc_shutdown_client(client);
+		nfs_shutdown_rpc_client(NFS_SERVER(dir)->nfs_client, client);
 		nfs_fixup_secinfo_attributes(fattr);
 	}
 	return status;
@@ -3072,12 +3072,15 @@ nfs4_proc_lookup_mountpoint(struct inode *dir, struct qstr *name,
 			    struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	struct rpc_clnt *client = NFS_CLIENT(dir);
+	rpc_authflavor_t flavor = client->cl_auth->au_flavor;
+	struct nfs_client *clp = NFS_SERVER(dir)->nfs_client;
 	int status;
 
 	status = nfs4_proc_lookup_common(&client, dir, name, fhandle, fattr, NULL);
 	if (status < 0)
 		return ERR_PTR(status);
-	return (client == NFS_CLIENT(dir)) ? rpc_clone_client(client) : client;
+	return (client == NFS_CLIENT(dir)) ?
+				nfs_get_auth_rpc_client(clp, flavor) : client;
 }
 
 static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6818964..f7815ce 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1876,7 +1876,7 @@ again:
 			break;
 	case -NFS4ERR_CLID_INUSE:
 	case -NFS4ERR_WRONGSEC:
-		clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_UNIX);
+		clnt = nfs_get_auth_rpc_client(clp, RPC_AUTH_UNIX);
 		if (IS_ERR(clnt)) {
 			status = PTR_ERR(clnt);
 			break;
@@ -1886,7 +1886,7 @@ again:
 		 * clp->cl_rpcclient
 		 */
 		clnt = xchg(&clp->cl_rpcclient, clnt);
-		rpc_shutdown_client(clnt);
+		nfs_shutdown_rpc_client(clp, clnt);
 		clnt = clp->cl_rpcclient;
 		goto again;
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index d221243..e112cf2 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -56,6 +56,7 @@ struct nfs_client {
 	struct rpc_cred		*cl_machine_cred;
 
 #if IS_ENABLED(CONFIG_NFS_V4)
+	struct rpc_clnt *	cl_rpc_clnt[RPC_AUTH_MAX_PSEUDO_FLAVOR + 1];
 	u64			cl_clientid;	/* constant */
 	nfs4_verifier		cl_confirm;	/* Clientid verifier */
 	unsigned long		cl_state;
diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index 1666da0..53c9a13 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -17,6 +17,9 @@
 /* spec defines authentication flavor as an unsigned 32 bit integer */
 typedef u32	rpc_authflavor_t;
 
+/* The number of supported pseudoflavors */
+#define RPC_AUTH_MAX_PSEUDO_FLAVOR	3
+
 enum rpc_auth_flavors {
 	RPC_AUTH_NULL  = 0,
 	RPC_AUTH_UNIX  = 1,
-- 
1.8.3.1

