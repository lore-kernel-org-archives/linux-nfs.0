From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/15] NFSv41: Clean up the NFSv4.1 minor version specific operations
Date: Mon, 14 Jun 2010 17:51:33 -0400
Message-ID: <1276552299-6625-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-4-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-5-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-6-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-7-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-8-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34599 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756809Ab0FNVvp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:45 -0400
In-Reply-To: <1276552299-6625-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c           |   14 ++++++--------
 fs/nfs/nfs4_fs.h          |   11 +++++++++++
 fs/nfs/nfs4proc.c         |   21 ++++++++++++++++++++-
 include/linux/nfs_fs_sb.h |    7 ++-----
 4 files changed, 39 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 7ec9b34..123fcbd 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -150,6 +150,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_boot_time = CURRENT_TIME;
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
 	clp->cl_minorversion = cl_init->minorversion;
+	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
 #endif
 	cred = rpc_lookup_machine_cred();
 	if (!IS_ERR(cred))
@@ -178,7 +179,7 @@ static void nfs4_clear_client_minor_version(struct nfs_client *clp)
 		clp->cl_session = NULL;
 	}
 
-	clp->cl_call_sync = _nfs4_call_sync;
+	clp->cl_mvops = nfs_v4_minor_ops[0];
 #endif /* CONFIG_NFS_V4_1 */
 }
 
@@ -188,7 +189,7 @@ static void nfs4_clear_client_minor_version(struct nfs_client *clp)
 static void nfs4_destroy_callback(struct nfs_client *clp)
 {
 	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
-		nfs_callback_down(clp->cl_minorversion);
+		nfs_callback_down(clp->cl_mvops->minor_version);
 }
 
 static void nfs4_shutdown_client(struct nfs_client *clp)
@@ -1126,7 +1127,7 @@ static int nfs4_init_callback(struct nfs_client *clp)
 				return error;
 		}
 
-		error = nfs_callback_up(clp->cl_minorversion,
+		error = nfs_callback_up(clp->cl_mvops->minor_version,
 					clp->cl_rpcclient->cl_xprt);
 		if (error < 0) {
 			dprintk("%s: failed to start callback. Error = %d\n",
@@ -1143,10 +1144,8 @@ static int nfs4_init_callback(struct nfs_client *clp)
  */
 static int nfs4_init_client_minor_version(struct nfs_client *clp)
 {
-	clp->cl_call_sync = _nfs4_call_sync;
-
 #if defined(CONFIG_NFS_V4_1)
-	if (clp->cl_minorversion) {
+	if (clp->cl_mvops->minor_version) {
 		struct nfs4_session *session = NULL;
 		/*
 		 * Create the session and mark it expired.
@@ -1158,7 +1157,6 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
 			return -ENOMEM;
 
 		clp->cl_session = session;
-		clp->cl_call_sync = _nfs4_call_sync_session;
 	}
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -1448,7 +1446,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				data->authflavor,
 				parent_server->client->cl_xprt->prot,
 				parent_server->client->cl_timeout,
-				parent_client->cl_minorversion);
+				parent_client->cl_mvops->minor_version);
 	if (error < 0)
 		goto error;
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index bb1e955..5b01705 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -52,6 +52,16 @@ enum nfs4_session_state {
 	NFS4_SESSION_DRAINING,
 };
 
+struct nfs4_minor_version_ops {
+	u32	minor_version;
+
+	int	(*call_sync)(struct nfs_server *server,
+			struct rpc_message *msg,
+			struct nfs4_sequence_args *args,
+			struct nfs4_sequence_res *res,
+			int cache_reply);
+};
+
 /*
  * struct rpc_sequence ensures that RPC calls are sent in the exact
  * order that they appear on the list.
@@ -260,6 +270,7 @@ static inline int nfs4_init_session(struct nfs_server *server)
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
 extern struct nfs4_state_maintenance_ops *nfs4_state_renewal_ops[];
 
 extern const u32 nfs4_fattr_bitmap[2];
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7e0483c..8530782 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -667,7 +667,7 @@ int _nfs4_call_sync(struct nfs_server *server,
 }
 
 #define nfs4_call_sync(server, msg, args, res, cache_reply) \
-	(server)->nfs_client->cl_call_sync((server), (msg), &(args)->seq_args, \
+	(server)->nfs_client->cl_mvops->call_sync((server), (msg), &(args)->seq_args, \
 			&(res)->seq_res, (cache_reply))
 
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
@@ -5352,6 +5352,18 @@ struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 };
 #endif
 
+static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
+	.minor_version = 0,
+	.call_sync = _nfs4_call_sync,
+};
+
+#if defined(CONFIG_NFS_V4_1)
+static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
+	.minor_version = 1,
+	.call_sync = _nfs4_call_sync_session,
+};
+#endif
+
 /*
  * Per minor version reboot and network partition recovery ops
  */
@@ -5377,6 +5389,13 @@ struct nfs4_state_maintenance_ops *nfs4_state_renewal_ops[] = {
 #endif
 };
 
+const struct nfs4_minor_version_ops *nfs_v4_minor_ops[] = {
+	[0] = &nfs_v4_0_minor_ops,
+#if defined(CONFIG_NFS_V4_1)
+	[1] = &nfs_v4_1_minor_ops,
+#endif
+};
+
 static const struct inode_operations nfs4_file_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index d6e10a4..c82ee7c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -15,6 +15,7 @@ struct nlm_host;
 struct nfs4_sequence_args;
 struct nfs4_sequence_res;
 struct nfs_server;
+struct nfs4_minor_version_ops;
 
 /*
  * The nfs_client identifies our client state to the server.
@@ -70,11 +71,7 @@ struct nfs_client {
 	 */
 	char			cl_ipaddr[48];
 	unsigned char		cl_id_uniquifier;
-	int		     (* cl_call_sync)(struct nfs_server *server,
-					      struct rpc_message *msg,
-					      struct nfs4_sequence_args *args,
-					      struct nfs4_sequence_res *res,
-					      int cache_reply);
+	const struct nfs4_minor_version_ops *cl_mvops;
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_V4_1
-- 
1.7.0.1

