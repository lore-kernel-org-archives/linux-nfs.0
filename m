Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755172Ab2DWUzR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:55:17 -0400
Received: by mail-iy0-f174.google.com with SMTP id i9so2498807iad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:55:17 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/20] NFS: Add nfs_client behavior flags
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:55:15 -0400
Message-ID: <20120423205514.11446.33520.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
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

 fs/nfs/client.c           |   40 ++++++++++++++++++++--------------------
 fs/nfs/internal.h         |    6 ++----
 include/linux/nfs_fs_sb.h |    3 +++
 include/linux/nfs_xdr.h   |    2 +-
 4 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d62f7e4..76dec6a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -129,6 +129,7 @@ const struct rpc_program nfsacl_program = {
 #endif  /* CONFIG_NFS_V3_ACL */
 
 struct nfs_client_initdata {
+	unsigned long init_flags;
 	const char *hostname;
 	const struct sockaddr *addr;
 	size_t addrlen;
@@ -544,8 +545,7 @@ static struct nfs_client *
 nfs_get_client(const struct nfs_client_initdata *cl_init,
 	       const struct rpc_timeout *timeparms,
 	       const char *ip_addr,
-	       rpc_authflavor_t authflavour,
-	       int noresvport)
+	       rpc_authflavor_t authflavour)
 {
 	struct nfs_client *clp, *new = NULL;
 	struct nfs_net *nn = net_generic(cl_init->net, nfs_net_id);
@@ -567,9 +567,10 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
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
@@ -653,8 +654,7 @@ static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
  */
 static int nfs_create_rpc_client(struct nfs_client *clp,
 				 const struct rpc_timeout *timeparms,
-				 rpc_authflavor_t flavor,
-				 int discrtry, int noresvport)
+				 rpc_authflavor_t flavor)
 {
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
@@ -669,9 +669,9 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 		.authflavor	= flavor,
 	};
 
-	if (discrtry)
+	if (test_bit(NFS_CS_DISCRTRY, &clp->cl_flags))
 		args.flags |= RPC_CLNT_CREATE_DISCRTRY;
-	if (noresvport)
+	if (test_bit(NFS_CS_NORESVPORT, &clp->cl_flags))
 		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 
 	if (!IS_ERR(clp->cl_rpcclient))
@@ -809,8 +809,7 @@ static int nfs_init_server_rpcclient(struct nfs_server *server,
  */
 struct nfs_client *nfs_init_client(struct nfs_client *clp,
 		    const struct rpc_timeout *timeparms,
-		    const char *ip_addr, rpc_authflavor_t authflavour,
-		    int noresvport)
+		    const char *ip_addr, rpc_authflavor_t authflavour)
 {
 	int error;
 
@@ -824,8 +823,7 @@ struct nfs_client *nfs_init_client(struct nfs_client *clp,
 	 * Create a client RPC handle for doing FSSTAT with UNIX auth only
 	 * - RFC 2623, sec 2.3.2
 	 */
-	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX,
-				      0, noresvport);
+	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
 	if (error < 0)
 		goto error;
 	nfs_mark_client_ready(clp, NFS_CS_READY);
@@ -865,10 +863,11 @@ static int nfs_init_server(struct nfs_server *server,
 
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
@@ -1347,8 +1346,7 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
 struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 				    const struct rpc_timeout *timeparms,
 				    const char *ip_addr,
-				    rpc_authflavor_t authflavour,
-				    int noresvport)
+				    rpc_authflavor_t authflavour)
 {
 	char buf[INET6_ADDRSTRLEN + 1];
 	int error;
@@ -1362,8 +1360,8 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	/* Check NFS protocol revision and initialize RPC op vector */
 	clp->rpc_ops = &nfs_v4_clientops;
 
-	error = nfs_create_rpc_client(clp, timeparms, authflavour,
-				      1, noresvport);
+	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
+	error = nfs_create_rpc_client(clp, timeparms, authflavour);
 	if (error < 0)
 		goto error;
 
@@ -1431,9 +1429,11 @@ static int nfs4_set_client(struct nfs_server *server,
 
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
@@ -1492,7 +1492,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 	 * (section 13.1 RFC 5661).
 	 */
 	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
-			     mds_clp->cl_rpcclient->cl_auth->au_flavor, 0);
+			     mds_clp->cl_rpcclient->cl_auth->au_flavor);
 
 	dprintk("<-- %s %p\n", __func__, clp);
 	return clp;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f1021c8..315dc86 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -157,13 +157,11 @@ nfs4_find_client_sessionid(struct net *, const struct sockaddr *,
 extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
 				const struct rpc_timeout *timeparms,
 				const char *ip_addr,
-				rpc_authflavor_t authflavour,
-				int noresvport);
+				rpc_authflavor_t authflavour);
 extern struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 				const struct rpc_timeout *timeparms,
 				const char *ip_addr,
-				rpc_authflavor_t authflavour,
-				int noresvport);
+				rpc_authflavor_t authflavour);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,
 					struct nfs_fh *);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 1c4c174..6f7a93c 100644
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
index 7437931..1fbca8b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1286,7 +1286,7 @@ struct nfs_rpc_ops {
 				struct iattr *iattr);
 	struct nfs_client *
 		(*init_client) (struct nfs_client *, const struct rpc_timeout *,
-				const char *, rpc_authflavor_t, int);
+				const char *, rpc_authflavor_t);
 	int	(*secinfo)(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
 };
 

