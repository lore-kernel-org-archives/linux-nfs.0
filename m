Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:41181 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757020Ab2EVCoe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 22:44:34 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so4992272ggl.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 19:44:33 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/14] NFS: Use proper naming conventions for NFSv4.1 server
 scope fields
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 21 May 2012 22:44:31 -0400
Message-ID: <20120522024431.1787.43259.stgit@degas.1015granger.net>
In-Reply-To: <20120522022702.1787.45940.stgit@degas.1015granger.net>
References: <20120522022702.1787.45940.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  When naming fields and data types, follow established
conventions to facilitate accurate grep/cscope searches.

Additionally, for consistency, move the scope field into the NFSv4-
specific part of the nfs_client, and free that memory in the logic
that shuts down NFSv4 nfs_clients.

Introduced by commit 99fe60d0 "nfs41: exchange_id operation", April
1 2009.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |    2 +-
 fs/nfs/nfs4_fs.h          |    2 +-
 fs/nfs/nfs4proc.c         |   18 ++++++++++--------
 include/linux/nfs_fs_sb.h |    4 ++--
 include/linux/nfs_xdr.h   |    4 ++--
 5 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index b4e2199..471fc9b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -237,6 +237,7 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 		nfs_idmap_delete(clp);
 
 	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
+	kfree(clp->cl_serverscope);
 }
 
 /* idr_remove_all is not needed as all id's are removed by nfs_put_client */
@@ -305,7 +306,6 @@ static void nfs_free_client(struct nfs_client *clp)
 
 	put_net(clp->net);
 	kfree(clp->cl_hostname);
-	kfree(clp->server_scope);
 	kfree(clp->impl_id);
 	kfree(clp);
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index edeef71..b14bcc3 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -338,7 +338,7 @@ extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs41_handle_recall_slot(struct nfs_client *clp);
 extern void nfs41_handle_server_scope(struct nfs_client *,
-				      struct server_scope **);
+				      struct nfs41_server_scope **);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
 extern void nfs4_select_rw_stateid(nfs4_stateid *, struct nfs4_state *,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 78784e5..2c1e57e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5052,7 +5052,8 @@ out_inval:
 }
 
 static bool
-nfs41_same_server_scope(struct server_scope *a, struct server_scope *b)
+nfs41_same_server_scope(struct nfs41_server_scope *a,
+			struct nfs41_server_scope *b)
 {
 	if (a->server_scope_sz == b->server_scope_sz &&
 	    memcmp(a->server_scope, b->server_scope, a->server_scope_sz) == 0)
@@ -5099,7 +5100,8 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 				clp->cl_rpcclient->cl_nodename,
 				clp->cl_rpcclient->cl_auth->au_flavor);
 
-	res.server_scope = kzalloc(sizeof(struct server_scope), GFP_KERNEL);
+	res.server_scope = kzalloc(sizeof(struct nfs41_server_scope),
+					GFP_KERNEL);
 	if (unlikely(!res.server_scope)) {
 		status = -ENOMEM;
 		goto out;
@@ -5123,18 +5125,18 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 		kfree(res.impl_id);
 
 	if (!status) {
-		if (clp->server_scope &&
-		    !nfs41_same_server_scope(clp->server_scope,
+		if (clp->cl_serverscope &&
+		    !nfs41_same_server_scope(clp->cl_serverscope,
 					     res.server_scope)) {
 			dprintk("%s: server_scope mismatch detected\n",
 				__func__);
 			set_bit(NFS4CLNT_SERVER_SCOPE_MISMATCH, &clp->cl_state);
-			kfree(clp->server_scope);
-			clp->server_scope = NULL;
+			kfree(clp->cl_serverscope);
+			clp->cl_serverscope = NULL;
 		}
 
-		if (!clp->server_scope) {
-			clp->server_scope = res.server_scope;
+		if (!clp->cl_serverscope) {
+			clp->cl_serverscope = res.server_scope;
 			goto out;
 		}
 	}
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 5498e9d..900d733 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -17,7 +17,7 @@ struct nfs4_sequence_args;
 struct nfs4_sequence_res;
 struct nfs_server;
 struct nfs4_minor_version_ops;
-struct server_scope;
+struct nfs41_server_scope;
 struct nfs41_impl_id;
 
 /*
@@ -80,13 +80,13 @@ struct nfs_client {
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session;	/* shared session */
+	struct nfs41_server_scope *cl_serverscope;
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;	/* client index cache cookie */
 #endif
 
-	struct server_scope	*server_scope;	/* from exchange_id */
 	struct nfs41_impl_id	*impl_id;	/* from exchange_id */
 	struct net		*net;
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2e53a3f..c420b8d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1104,7 +1104,7 @@ struct server_owner {
 	char				major_id[NFS4_OPAQUE_LIMIT];
 };
 
-struct server_scope {
+struct nfs41_server_scope {
 	uint32_t			server_scope_sz;
 	char 				server_scope[NFS4_OPAQUE_LIMIT];
 };
@@ -1118,7 +1118,7 @@ struct nfs41_impl_id {
 struct nfs41_exchange_id_res {
 	struct nfs_client		*client;
 	u32				flags;
-	struct server_scope		*server_scope;
+	struct nfs41_server_scope	*server_scope;
 	struct nfs41_impl_id		*impl_id;
 };
 

