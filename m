Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:39388 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757169Ab2EVCqK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 22:46:10 -0400
Received: by yhmm54 with SMTP id m54so5054100yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 19:46:09 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/14] NFS: Add nfs_client behavior flags
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 21 May 2012 22:46:07 -0400
Message-ID: <20120522024607.1787.96120.stgit@degas.1015granger.net>
In-Reply-To: <20120522022702.1787.45940.stgit@degas.1015granger.net>
References: <20120522022702.1787.45940.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"noresvport" and "discrtry" can be passed to nfs_create_rpc_client()
by setting flags in the passed-in nfs_client.  This change makes it
easy to add new flags.

Note that these settings are now "sticky" over the lifetime of a
struct nfs_client, and may even be copied when an nfs_client is
cloned.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |   42 ++++++++++++++++++++----------------------
 fs/nfs/internal.h         |    6 ++----
 include/linux/nfs_fs_sb.h |    3 +++
 include/linux/nfs_xdr.h   |    2 +-
 4 files changed, 26 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8a4b3c2..34b2e68 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -131,6 +131,7 @@ const struct rpc_program nfsacl_program = {
 #endif  /* CONFIG_NFS_V3_ACL */
 
 struct nfs_client_initdata {
+	unsigned long init_flags;
 	const char *hostname;
 	const struct sockaddr *addr;
 	size_t addrlen;
@@ -542,8 +543,7 @@ static struct nfs_client *
 nfs_get_client(const struct nfs_client_initdata *cl_init,
 	       const struct rpc_timeout *timeparms,
 	       const char *ip_addr,
-	       rpc_authflavor_t authflavour,
-	       int noresvport)
+	       rpc_authflavor_t authflavour)
 {
 	struct nfs_client *clp, *new = NULL;
 	struct nfs_net *nn = net_generic(cl_init->net, nfs_net_id);
@@ -565,9 +565,10 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 		if (new) {
 			list_add(&new->cl_share_link, &nn->nfs_client_list);
 			spin_unlock(&nn->nfs_client_lock);
+			new->cl_flags = cl_init->init_flags;
 			return cl_init->rpc_ops->init_client(new,
 						timeparms, ip_addr,
-						authflavour, noresvport);
+						authflavour);
 		}
 
 		spin_unlock(&nn->nfs_client_lock);
@@ -651,8 +652,7 @@ static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
  */
 static int nfs_create_rpc_client(struct nfs_client *clp,
 				 const struct rpc_timeout *timeparms,
-				 rpc_authflavor_t flavor,
-				 int discrtry, int noresvport)
+				 rpc_authflavor_t flavor)
 {
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
@@ -667,9 +667,9 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 		.authflavor	= flavor,
 	};
 
-	if (discrtry)
+	if (test_bit(NFS_CS_DISCRTRY, &clp->cl_flags))
 		args.flags |= RPC_CLNT_CREATE_DISCRTRY;
-	if (noresvport)
+	if (test_bit(NFS_CS_NORESVPORT, &clp->cl_flags))
 		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 
 	if (!IS_ERR(clp->cl_rpcclient))
@@ -809,14 +809,12 @@ static int nfs_init_server_rpcclient(struct nfs_server *server,
  * @timeparms: timeout parameters for underlying RPC transport
  * @ip_addr: IP presentation address (not used)
  * @authflavor: authentication flavor for underlying RPC transport
- * @noresvport: set if RPC transport can use an ephemeral source port
  *
  * Returns pointer to an NFS client, or an ERR_PTR value.
  */
 struct nfs_client *nfs_init_client(struct nfs_client *clp,
 		    const struct rpc_timeout *timeparms,
-		    const char *ip_addr, rpc_authflavor_t authflavour,
-		    int noresvport)
+		    const char *ip_addr, rpc_authflavor_t authflavour)
 {
 	int error;
 
@@ -830,8 +828,7 @@ struct nfs_client *nfs_init_client(struct nfs_client *clp,
 	 * Create a client RPC handle for doing FSSTAT with UNIX auth only
 	 * - RFC 2623, sec 2.3.2
 	 */
-	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX,
-				      0, noresvport);
+	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
 	if (error < 0)
 		goto error;
 	nfs_mark_client_ready(clp, NFS_CS_READY);
@@ -881,10 +878,11 @@ static int nfs_init_server(struct nfs_server *server,
 
 	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
 			data->timeo, data->retrans);
+	if (data->flags & NFS_MOUNT_NORESVPORT)
+		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(&cl_init, &timeparms, NULL, RPC_AUTH_UNIX,
-			     data->flags & NFS_MOUNT_NORESVPORT);
+	clp = nfs_get_client(&cl_init, &timeparms, NULL, RPC_AUTH_UNIX);
 	if (IS_ERR(clp)) {
 		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
 		return PTR_ERR(clp);
@@ -1364,15 +1362,13 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
  * @timeparms: timeout parameters for underlying RPC transport
  * @ip_addr: callback IP address in presentation format
  * @authflavor: authentication flavor for underlying RPC transport
- * @noresvport: set if RPC transport can use an ephemeral source port
  *
  * Returns pointer to an NFS client, or an ERR_PTR value.
  */
 struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 				    const struct rpc_timeout *timeparms,
 				    const char *ip_addr,
-				    rpc_authflavor_t authflavour,
-				    int noresvport)
+				    rpc_authflavor_t authflavour)
 {
 	char buf[INET6_ADDRSTRLEN + 1];
 	int error;
@@ -1386,8 +1382,8 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	/* Check NFS protocol revision and initialize RPC op vector */
 	clp->rpc_ops = &nfs_v4_clientops;
 
-	error = nfs_create_rpc_client(clp, timeparms, authflavour,
-				      1, noresvport);
+	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
+	error = nfs_create_rpc_client(clp, timeparms, authflavour);
 	if (error < 0)
 		goto error;
 
@@ -1455,9 +1451,11 @@ static int nfs4_set_client(struct nfs_server *server,
 
 	dprintk("--> nfs4_set_client()\n");
 
+	if (server->flags & NFS_MOUNT_NORESVPORT)
+		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
+
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(&cl_init, timeparms, ip_addr, authflavour,
-			     server->flags & NFS_MOUNT_NORESVPORT);
+	clp = nfs_get_client(&cl_init, timeparms, ip_addr, authflavour);
 	if (IS_ERR(clp)) {
 		error = PTR_ERR(clp);
 		goto error;
@@ -1512,7 +1510,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 	 */
 	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
 	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
-			     mds_clp->cl_rpcclient->cl_auth->au_flavor, 0);
+			     mds_clp->cl_rpcclient->cl_auth->au_flavor);
 
 	dprintk("<-- %s %p\n", __func__, clp);
 	return clp;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 3a9e80c..547f24f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -240,8 +240,7 @@ extern int nfs4_init_ds_session(struct nfs_client *clp);
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
 extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
 			   const struct rpc_timeout *timeparms,
-			   const char *ip_addr, rpc_authflavor_t authflavour,
-			   int noresvport);
+			   const char *ip_addr, rpc_authflavor_t authflavour);
 
 /* dir.c */
 extern int nfs_access_cache_shrinker(struct shrinker *shrink,
@@ -376,8 +375,7 @@ extern void __nfs4_read_done_cb(struct nfs_read_data *);
 extern struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 			    const struct rpc_timeout *timeparms,
 			    const char *ip_addr,
-			    rpc_authflavor_t authflavour,
-			    int noresvport);
+			    rpc_authflavor_t authflavour);
 extern int _nfs4_call_sync(struct rpc_clnt *clnt,
 			   struct nfs_server *server,
 			   struct rpc_message *msg,
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index fbec57d..3a99f52 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -35,6 +35,9 @@ struct nfs_client {
 #define NFS_CS_RENEWD		3		/* - renewd started */
 #define NFS_CS_STOP_RENEW	4		/* no more state to renew */
 #define NFS_CS_CHECK_LEASE_TIME	5		/* need to check lease time */
+	unsigned long		cl_flags;	/* behavior switches */
+#define NFS_CS_NORESVPORT	0		/* - use ephemeral src port */
+#define NFS_CS_DISCRTRY		1		/* - disconnect on RPC retry */
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0c521cd..07048c0 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1399,7 +1399,7 @@ struct nfs_rpc_ops {
 				struct iattr *iattr);
 	struct nfs_client *
 		(*init_client) (struct nfs_client *, const struct rpc_timeout *,
-				const char *, rpc_authflavor_t, int);
+				const char *, rpc_authflavor_t);
 };
 
 /*

