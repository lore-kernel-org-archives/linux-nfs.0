Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31911 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759006Ab2CUPVU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:20 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 14/23] NFS: Move nfs4_set_client() and support code to nfs4client.c
Date: Wed, 21 Mar 2012 11:20:44 -0400
Message-Id: <1332343253-24970-15-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This chunk of code is only used by NFS v4, so it can safely move to a
v4-only file that won't even be compiled if v4 isn't selected.  This
also helps to avoid future modpost errors when v4 is turned into a
module.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c     |  349 ++-------------------------------------------------
 fs/nfs/nfs.h        |   12 +-
 fs/nfs/nfs4client.c |  337 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 356 insertions(+), 342 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 41c687e..38efcf4 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -82,11 +82,6 @@ retry:
 #endif /* CONFIG_NFS_V4 */
 
 /*
- * Turn off NFSv4 uid/gid mapping when using AUTH_SYS
- */
-static bool nfs4_disable_idmapping = true;
-
-/*
  * RPC cruft for NFS
  */
 static struct rpc_version *nfs_version[5] = {
@@ -227,11 +222,6 @@ static void pnfs_init_server(struct nfs_server *server)
 	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
 }
 
-static void nfs4_destroy_server(struct nfs_server *server)
-{
-	nfs4_purge_state_owners(server);
-}
-
 /* idr_remove_all is not needed as all id's are removed by nfs_put_client */
 void nfs_cleanup_cb_ident_idr(struct net *net)
 {
@@ -494,7 +484,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
  * Look up a client by IP address and protocol version
  * - creates a new record if one doesn't yet exist
  */
-static struct nfs_client *
+struct nfs_client *
 nfs_get_client(const struct nfs_client_initdata *cl_init,
 	       const struct rpc_timeout *timeparms,
 	       const char *ip_addr,
@@ -597,8 +587,8 @@ int nfs4_check_client_ready(struct nfs_client *clp)
 /*
  * Initialise the timeout values for a connection
  */
-static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
-				    unsigned int timeo, unsigned int retrans)
+void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
+			     unsigned int timeo, unsigned int retrans)
 {
 	to->to_initval = timeo * HZ / 10;
 	to->to_retries = retrans;
@@ -728,7 +718,7 @@ static int nfs_start_lockd(struct nfs_server *server)
 /*
  * Create a general RPC client
  */
-static int nfs_init_server_rpcclient(struct nfs_server *server,
+int nfs_init_server_rpcclient(struct nfs_server *server,
 		const struct rpc_timeout *timeo,
 		rpc_authflavor_t pseudoflavour)
 {
@@ -944,7 +934,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 /*
  * Probe filesystem information, including the FSID on v2/v3
  */
-static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs_fattr *fattr)
+int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs_fattr *fattr)
 {
 	struct nfs_fsinfo fsinfo;
 	struct nfs_client *clp = server->nfs_client;
@@ -988,7 +978,7 @@ out_error:
 /*
  * Copy useful information when duplicating a server record
  */
-static void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *source)
+void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *source)
 {
 	target->flags = source->flags;
 	target->rsize = source->rsize;
@@ -1001,7 +991,7 @@ static void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_serve
 	target->options = source->options;
 }
 
-static void nfs_server_insert_lists(struct nfs_server *server)
+void nfs_server_insert_lists(struct nfs_server *server)
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs_net *nn = net_generic(clp->net, nfs_net_id);
@@ -1035,7 +1025,7 @@ static void nfs_server_remove_lists(struct nfs_server *server)
 /*
  * Allocate and initialise a server record
  */
-static struct nfs_server *nfs_alloc_server(void)
+struct nfs_server *nfs_alloc_server(void)
 {
 	struct nfs_server *server;
 
@@ -1360,325 +1350,6 @@ error:
 	return error;
 }
 
-/*
- * Set up an NFS4 client
- */
-static int nfs4_set_client(struct nfs_server *server,
-		const char *hostname,
-		const struct sockaddr *addr,
-		const size_t addrlen,
-		const char *ip_addr,
-		rpc_authflavor_t authflavour,
-		int proto, const struct rpc_timeout *timeparms,
-		u32 minorversion, struct net *net)
-{
-	struct nfs_client_initdata cl_init = {
-		.hostname = hostname,
-		.addr = addr,
-		.addrlen = addrlen,
-		.rpc_ops = &nfs_v4_clientops,
-		.proto = proto,
-		.minorversion = minorversion,
-		.net = net,
-	};
-	struct nfs_client *clp;
-	int error;
-
-	dprintk("--> nfs4_set_client()\n");
-
-	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(&cl_init, timeparms, ip_addr, authflavour,
-			     server->flags & NFS_MOUNT_NORESVPORT);
-	if (IS_ERR(clp)) {
-		error = PTR_ERR(clp);
-		goto error;
-	}
-
-	/*
-	 * Query for the lease time on clientid setup or renewal
-	 *
-	 * Note that this will be set on nfs_clients that were created
-	 * only for the DS role and did not set this bit, but now will
-	 * serve a dual role.
-	 */
-	set_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state);
-
-	server->nfs_client = clp;
-	dprintk("<-- nfs4_set_client() = 0 [new %p]\n", clp);
-	return 0;
-error:
-	dprintk("<-- nfs4_set_client() = xerror %d\n", error);
-	return error;
-}
-
-/*
- * Set up a pNFS Data Server client.
- *
- * Return any existing nfs_client that matches server address,port,version
- * and minorversion.
- *
- * For a new nfs_client, use a soft mount (default), a low retrans and a
- * low timeout interval so that if a connection is lost, we retry through
- * the MDS.
- */
-struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
-		const struct sockaddr *ds_addr,
-		int ds_addrlen, int ds_proto)
-{
-	struct nfs_client_initdata cl_init = {
-		.addr = ds_addr,
-		.addrlen = ds_addrlen,
-		.rpc_ops = &nfs_v4_clientops,
-		.proto = ds_proto,
-		.minorversion = mds_clp->cl_minorversion,
-		.net = mds_clp->net,
-	};
-	struct rpc_timeout ds_timeout = {
-		.to_initval = 15 * HZ,
-		.to_maxval = 15 * HZ,
-		.to_retries = 1,
-		.to_exponential = 1,
-	};
-	struct nfs_client *clp;
-
-	/*
-	 * Set an authflavor equual to the MDS value. Use the MDS nfs_client
-	 * cl_ipaddr so as to use the same EXCHANGE_ID co_ownerid as the MDS
-	 * (section 13.1 RFC 5661).
-	 */
-	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
-			     mds_clp->cl_rpcclient->cl_auth->au_flavor, 0);
-
-	dprintk("<-- %s %p\n", __func__, clp);
-	return clp;
-}
-EXPORT_SYMBOL_GPL(nfs4_set_ds_client);
-
-/*
- * Session has been established, and the client marked ready.
- * Set the mount rsize and wsize with negotiated fore channel
- * attributes which will be bound checked in nfs_server_set_fsinfo.
- */
-static void nfs4_session_set_rwsize(struct nfs_server *server)
-{
-#ifdef CONFIG_NFS_V4_1
-	struct nfs4_session *sess;
-	u32 server_resp_sz;
-	u32 server_rqst_sz;
-
-	if (!nfs4_has_session(server->nfs_client))
-		return;
-	sess = server->nfs_client->cl_session;
-	server_resp_sz = sess->fc_attrs.max_resp_sz - nfs41_maxread_overhead;
-	server_rqst_sz = sess->fc_attrs.max_rqst_sz - nfs41_maxwrite_overhead;
-
-	if (server->rsize > server_resp_sz)
-		server->rsize = server_resp_sz;
-	if (server->wsize > server_rqst_sz)
-		server->wsize = server_rqst_sz;
-#endif /* CONFIG_NFS_V4_1 */
-}
-
-static int nfs4_server_common_setup(struct nfs_server *server,
-		struct nfs_fh *mntfh)
-{
-	struct nfs_fattr *fattr;
-	int error;
-
-	BUG_ON(!server->nfs_client);
-	BUG_ON(!server->nfs_client->rpc_ops);
-	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
-
-	/* data servers support only a subset of NFSv4.1 */
-	if (is_ds_only_client(server->nfs_client))
-		return -EPROTONOSUPPORT;
-
-	fattr = nfs_alloc_fattr();
-	if (fattr == NULL)
-		return -ENOMEM;
-
-	/* We must ensure the session is initialised first */
-	error = nfs4_init_session(server);
-	if (error < 0)
-		goto out;
-
-	/* Probe the root fh to retrieve its FSID and filehandle */
-	error = nfs4_get_rootfh(server, mntfh);
-	if (error < 0)
-		goto out;
-
-	dprintk("Server FSID: %llx:%llx\n",
-			(unsigned long long) server->fsid.major,
-			(unsigned long long) server->fsid.minor);
-	dprintk("Mount FH: %d\n", mntfh->size);
-
-	nfs4_session_set_rwsize(server);
-
-	error = nfs_probe_fsinfo(server, mntfh, fattr);
-	if (error < 0)
-		goto out;
-
-	if (server->namelen == 0 || server->namelen > NFS4_MAXNAMLEN)
-		server->namelen = NFS4_MAXNAMLEN;
-
-	nfs_server_insert_lists(server);
-	server->mount_time = jiffies;
-	server->destroy = nfs4_destroy_server;
-out:
-	nfs_free_fattr(fattr);
-	return error;
-}
-
-/*
- * Create a version 4 volume record
- */
-static int nfs4_init_server(struct nfs_server *server,
-		const struct nfs_parsed_mount_data *data)
-{
-	struct rpc_timeout timeparms;
-	int error;
-
-	dprintk("--> nfs4_init_server()\n");
-
-	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
-			data->timeo, data->retrans);
-
-	/* Initialise the client representation from the mount data */
-	server->flags = data->flags;
-	server->caps |= NFS_CAP_ATOMIC_OPEN|NFS_CAP_CHANGE_ATTR|NFS_CAP_POSIX_LOCK;
-	if (!(data->flags & NFS_MOUNT_NORDIRPLUS))
-			server->caps |= NFS_CAP_READDIRPLUS;
-	server->options = data->options;
-
-	/* Get a client record */
-	error = nfs4_set_client(server,
-			data->nfs_server.hostname,
-			(const struct sockaddr *)&data->nfs_server.address,
-			data->nfs_server.addrlen,
-			data->client_address,
-			data->auth_flavors[0],
-			data->nfs_server.protocol,
-			&timeparms,
-			data->minorversion,
-			data->net);
-	if (error < 0)
-		goto error;
-
-	/*
-	 * Don't use NFS uid/gid mapping if we're using AUTH_SYS or lower
-	 * authentication.
-	 */
-	if (nfs4_disable_idmapping && data->auth_flavors[0] == RPC_AUTH_UNIX)
-		server->caps |= NFS_CAP_UIDGID_NOMAP;
-
-	if (data->rsize)
-		server->rsize = nfs_block_size(data->rsize, NULL);
-	if (data->wsize)
-		server->wsize = nfs_block_size(data->wsize, NULL);
-
-	server->acregmin = data->acregmin * HZ;
-	server->acregmax = data->acregmax * HZ;
-	server->acdirmin = data->acdirmin * HZ;
-	server->acdirmax = data->acdirmax * HZ;
-
-	server->port = data->nfs_server.port;
-
-	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
-
-error:
-	/* Done */
-	dprintk("<-- nfs4_init_server() = %d\n", error);
-	return error;
-}
-
-/*
- * Create a version 4 volume record
- * - keyed on server and FSID
- */
-struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
-				      struct nfs_fh *mntfh)
-{
-	struct nfs_server *server;
-	int error;
-
-	dprintk("--> nfs4_create_server()\n");
-
-	server = nfs_alloc_server();
-	if (!server)
-		return ERR_PTR(-ENOMEM);
-
-	/* set up the general RPC client */
-	error = nfs4_init_server(server, data);
-	if (error < 0)
-		goto error;
-
-	error = nfs4_server_common_setup(server, mntfh);
-	if (error < 0)
-		goto error;
-
-	dprintk("<-- nfs4_create_server() = %p\n", server);
-	return server;
-
-error:
-	nfs_free_server(server);
-	dprintk("<-- nfs4_create_server() = error %d\n", error);
-	return ERR_PTR(error);
-}
-
-/*
- * Create an NFS4 referral server record
- */
-struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
-					       struct nfs_fh *mntfh)
-{
-	struct nfs_client *parent_client;
-	struct nfs_server *server, *parent_server;
-	int error;
-
-	dprintk("--> nfs4_create_referral_server()\n");
-
-	server = nfs_alloc_server();
-	if (!server)
-		return ERR_PTR(-ENOMEM);
-
-	parent_server = NFS_SB(data->sb);
-	parent_client = parent_server->nfs_client;
-
-	/* Initialise the client representation from the parent server */
-	nfs_server_copy_userdata(server, parent_server);
-	server->caps |= NFS_CAP_ATOMIC_OPEN|NFS_CAP_CHANGE_ATTR;
-
-	/* Get a client representation.
-	 * Note: NFSv4 always uses TCP, */
-	error = nfs4_set_client(server, data->hostname,
-				data->addr,
-				data->addrlen,
-				parent_client->cl_ipaddr,
-				data->authflavor,
-				rpc_protocol(parent_server->client),
-				parent_server->client->cl_timeout,
-				parent_client->cl_mvops->minor_version,
-				parent_client->net);
-	if (error < 0)
-		goto error;
-
-	error = nfs_init_server_rpcclient(server, parent_server->client->cl_timeout, data->authflavor);
-	if (error < 0)
-		goto error;
-
-	error = nfs4_server_common_setup(server, mntfh);
-	if (error < 0)
-		goto error;
-
-	dprintk("<-- nfs_create_referral_server() = %p\n", server);
-	return server;
-
-error:
-	nfs_free_server(server);
-	dprintk("<-- nfs4_create_referral_server() = error %d\n", error);
-	return ERR_PTR(error);
-}
-
 #endif /* CONFIG_NFS_V4 */
 
 /*
@@ -2094,7 +1765,3 @@ int nfs_stat_to_errno(enum nfs_stat status)
 	return nfs_errtbl[i].errno;
 }
 EXPORT_SYMBOL_GPL(nfs_stat_to_errno);
-
-module_param(nfs4_disable_idmapping, bool, 0644);
-MODULE_PARM_DESC(nfs4_disable_idmapping,
-		"Turn off NFSv4 idmapping when using 'sec=sys'");
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 6036141..3ed4b32 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -56,9 +56,19 @@ void unregister_nfs_version(struct nfs_subversion *);
 
 /* Exported in client.c */
 int nfs_get_cb_ident_idr(struct nfs_client *, int);
-struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *, struct nfs_fh *);
 struct nfs_client *_nfs_alloc_client(const struct nfs_client_initdata *);
 void _nfs_free_client(struct nfs_client *);
+struct nfs_client *nfs_get_client(const struct nfs_client_initdata *,
+				  const struct rpc_timeout *, const char *,
+				  rpc_authflavor_t, int);
+void nfs_init_timeout_values(struct rpc_timeout *, int, unsigned int, unsigned int);
+int nfs_init_server_rpcclient(struct nfs_server *, const struct rpc_timeout *,
+			      rpc_authflavor_t);
+int nfs_probe_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *);
+void nfs_server_copy_userdata(struct nfs_server *, struct nfs_server *);
+void nfs_server_insert_lists(struct nfs_server *);
+struct nfs_server *nfs_alloc_server(void);
+struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *, struct nfs_fh *);
 
 /* Exported in dir.c */
 struct dentry *nfs_lookup(struct inode *, struct dentry *, struct nameidata *);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index c555748..230d25e 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -3,6 +3,8 @@
  * Written by David Howells (dhowells@redhat.com)
  */
 
+#include <linux/module.h>
+#include <linux/nfs_mount.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_fs_sb.h>
@@ -11,6 +13,13 @@
 #include "callback.h"
 #include "pnfs.h"
 
+#define NFSDBG_FACILITY		NFSDBG_CLIENT
+
+/*
+ * Turn off NFSv4 uid/gid mapping when using AUTH_SYS
+ */
+static bool nfs4_disable_idmapping = true;
+
 #ifdef CONFIG_NFS_V4_1
 static void nfs4_shutdown_session(struct nfs_client *clp)
 {
@@ -25,6 +34,11 @@ static void nfs4_shutdown_session(struct nfs_client *clp)
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+static void nfs4_destroy_server(struct nfs_server *server)
+{
+	nfs4_purge_state_owners(server);
+}
+
 /*
  * Destroy the NFS4 callback service
  */
@@ -78,3 +92,326 @@ error_cleanup:
 	kfree(clp);
 	return ERR_PTR(err);
 }
+
+/*
+ * Set up an NFS4 client
+ */
+static int nfs4_set_client(struct nfs_server *server,
+		const char *hostname,
+		const struct sockaddr *addr,
+		const size_t addrlen,
+		const char *ip_addr,
+		rpc_authflavor_t authflavour,
+		int proto, const struct rpc_timeout *timeparms,
+		u32 minorversion, struct net *net)
+{
+	struct nfs_client_initdata cl_init = {
+		.hostname = hostname,
+		.addr = addr,
+		.addrlen = addrlen,
+		.rpc_ops = &nfs_v4_clientops,
+		.proto = proto,
+		.minorversion = minorversion,
+		.net = net,
+	};
+	struct nfs_client *clp;
+	int error;
+
+	dprintk("--> nfs4_set_client()\n");
+
+	/* Allocate or find a client reference we can use */
+	clp = nfs_get_client(&cl_init, timeparms, ip_addr, authflavour,
+			     server->flags & NFS_MOUNT_NORESVPORT);
+	if (IS_ERR(clp)) {
+		error = PTR_ERR(clp);
+		goto error;
+	}
+
+	/*
+	 * Query for the lease time on clientid setup or renewal
+	 *
+	 * Note that this will be set on nfs_clients that were created
+	 * only for the DS role and did not set this bit, but now will
+	 * serve a dual role.
+	 */
+	set_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state);
+
+	server->nfs_client = clp;
+	dprintk("<-- nfs4_set_client() = 0 [new %p]\n", clp);
+	return 0;
+error:
+	dprintk("<-- nfs4_set_client() = xerror %d\n", error);
+	return error;
+}
+
+/*
+ * Set up a pNFS Data Server client.
+ *
+ * Return any existing nfs_client that matches server address,port,version
+ * and minorversion.
+ *
+ * For a new nfs_client, use a soft mount (default), a low retrans and a
+ * low timeout interval so that if a connection is lost, we retry through
+ * the MDS.
+ */
+struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
+		const struct sockaddr *ds_addr,
+		int ds_addrlen, int ds_proto)
+{
+	struct nfs_client_initdata cl_init = {
+		.addr = ds_addr,
+		.addrlen = ds_addrlen,
+		.rpc_ops = &nfs_v4_clientops,
+		.proto = ds_proto,
+		.minorversion = mds_clp->cl_minorversion,
+		.net = mds_clp->net,
+	};
+	struct rpc_timeout ds_timeout = {
+		.to_initval = 15 * HZ,
+		.to_maxval = 15 * HZ,
+		.to_retries = 1,
+		.to_exponential = 1,
+	};
+	struct nfs_client *clp;
+
+	/*
+	 * Set an authflavor equual to the MDS value. Use the MDS nfs_client
+	 * cl_ipaddr so as to use the same EXCHANGE_ID co_ownerid as the MDS
+	 * (section 13.1 RFC 5661).
+	 */
+	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
+			     mds_clp->cl_rpcclient->cl_auth->au_flavor, 0);
+
+	dprintk("<-- %s %p\n", __func__, clp);
+	return clp;
+}
+EXPORT_SYMBOL_GPL(nfs4_set_ds_client);
+
+/*
+ * Session has been established, and the client marked ready.
+ * Set the mount rsize and wsize with negotiated fore channel
+ * attributes which will be bound checked in nfs_server_set_fsinfo.
+ */
+static void nfs4_session_set_rwsize(struct nfs_server *server)
+{
+#ifdef CONFIG_NFS_V4_1
+	struct nfs4_session *sess;
+	u32 server_resp_sz;
+	u32 server_rqst_sz;
+
+	if (!nfs4_has_session(server->nfs_client))
+		return;
+	sess = server->nfs_client->cl_session;
+	server_resp_sz = sess->fc_attrs.max_resp_sz - nfs41_maxread_overhead;
+	server_rqst_sz = sess->fc_attrs.max_rqst_sz - nfs41_maxwrite_overhead;
+
+	if (server->rsize > server_resp_sz)
+		server->rsize = server_resp_sz;
+	if (server->wsize > server_rqst_sz)
+		server->wsize = server_rqst_sz;
+#endif /* CONFIG_NFS_V4_1 */
+}
+
+static int nfs4_server_common_setup(struct nfs_server *server,
+		struct nfs_fh *mntfh)
+{
+	struct nfs_fattr *fattr;
+	int error;
+
+	BUG_ON(!server->nfs_client);
+	BUG_ON(!server->nfs_client->rpc_ops);
+	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
+
+	/* data servers support only a subset of NFSv4.1 */
+	if (is_ds_only_client(server->nfs_client))
+		return -EPROTONOSUPPORT;
+
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL)
+		return -ENOMEM;
+
+	/* We must ensure the session is initialised first */
+	error = nfs4_init_session(server);
+	if (error < 0)
+		goto out;
+
+	/* Probe the root fh to retrieve its FSID and filehandle */
+	error = nfs4_get_rootfh(server, mntfh);
+	if (error < 0)
+		goto out;
+
+	dprintk("Server FSID: %llx:%llx\n",
+			(unsigned long long) server->fsid.major,
+			(unsigned long long) server->fsid.minor);
+	dprintk("Mount FH: %d\n", mntfh->size);
+
+	nfs4_session_set_rwsize(server);
+
+	error = nfs_probe_fsinfo(server, mntfh, fattr);
+	if (error < 0)
+		goto out;
+
+	if (server->namelen == 0 || server->namelen > NFS4_MAXNAMLEN)
+		server->namelen = NFS4_MAXNAMLEN;
+
+	nfs_server_insert_lists(server);
+	server->mount_time = jiffies;
+	server->destroy = nfs4_destroy_server;
+out:
+	nfs_free_fattr(fattr);
+	return error;
+}
+
+/*
+ * Create a version 4 volume record
+ */
+static int nfs4_init_server(struct nfs_server *server,
+		const struct nfs_parsed_mount_data *data)
+{
+	struct rpc_timeout timeparms;
+	int error;
+
+	dprintk("--> nfs4_init_server()\n");
+
+	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
+			data->timeo, data->retrans);
+
+	/* Initialise the client representation from the mount data */
+	server->flags = data->flags;
+	server->caps |= NFS_CAP_ATOMIC_OPEN|NFS_CAP_CHANGE_ATTR|NFS_CAP_POSIX_LOCK;
+	if (!(data->flags & NFS_MOUNT_NORDIRPLUS))
+			server->caps |= NFS_CAP_READDIRPLUS;
+	server->options = data->options;
+
+	/* Get a client record */
+	error = nfs4_set_client(server,
+			data->nfs_server.hostname,
+			(const struct sockaddr *)&data->nfs_server.address,
+			data->nfs_server.addrlen,
+			data->client_address,
+			data->auth_flavors[0],
+			data->nfs_server.protocol,
+			&timeparms,
+			data->minorversion,
+			data->net);
+	if (error < 0)
+		goto error;
+
+	/*
+	 * Don't use NFS uid/gid mapping if we're using AUTH_SYS or lower
+	 * authentication.
+	 */
+	if (nfs4_disable_idmapping && data->auth_flavors[0] == RPC_AUTH_UNIX)
+		server->caps |= NFS_CAP_UIDGID_NOMAP;
+
+	if (data->rsize)
+		server->rsize = nfs_block_size(data->rsize, NULL);
+	if (data->wsize)
+		server->wsize = nfs_block_size(data->wsize, NULL);
+
+	server->acregmin = data->acregmin * HZ;
+	server->acregmax = data->acregmax * HZ;
+	server->acdirmin = data->acdirmin * HZ;
+	server->acdirmax = data->acdirmax * HZ;
+
+	server->port = data->nfs_server.port;
+
+	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
+
+error:
+	/* Done */
+	dprintk("<-- nfs4_init_server() = %d\n", error);
+	return error;
+}
+
+/*
+ * Create a version 4 volume record
+ * - keyed on server and FSID
+ */
+struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
+				      struct nfs_fh *mntfh)
+{
+	struct nfs_server *server;
+	int error;
+
+	dprintk("--> nfs4_create_server()\n");
+
+	server = nfs_alloc_server();
+	if (!server)
+		return ERR_PTR(-ENOMEM);
+
+	/* set up the general RPC client */
+	error = nfs4_init_server(server, data);
+	if (error < 0)
+		goto error;
+
+	error = nfs4_server_common_setup(server, mntfh);
+	if (error < 0)
+		goto error;
+
+	dprintk("<-- nfs4_create_server() = %p\n", server);
+	return server;
+
+error:
+	nfs_free_server(server);
+	dprintk("<-- nfs4_create_server() = error %d\n", error);
+	return ERR_PTR(error);
+}
+
+/*
+ * Create an NFS4 referral server record
+ */
+struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
+					       struct nfs_fh *mntfh)
+{
+	struct nfs_client *parent_client;
+	struct nfs_server *server, *parent_server;
+	int error;
+
+	dprintk("--> nfs4_create_referral_server()\n");
+
+	server = nfs_alloc_server();
+	if (!server)
+		return ERR_PTR(-ENOMEM);
+
+	parent_server = NFS_SB(data->sb);
+	parent_client = parent_server->nfs_client;
+
+	/* Initialise the client representation from the parent server */
+	nfs_server_copy_userdata(server, parent_server);
+	server->caps |= NFS_CAP_ATOMIC_OPEN|NFS_CAP_CHANGE_ATTR;
+
+	/* Get a client representation.
+	 * Note: NFSv4 always uses TCP, */
+	error = nfs4_set_client(server, data->hostname,
+				data->addr,
+				data->addrlen,
+				parent_client->cl_ipaddr,
+				data->authflavor,
+				rpc_protocol(parent_server->client),
+				parent_server->client->cl_timeout,
+				parent_client->cl_mvops->minor_version,
+				parent_client->net);
+	if (error < 0)
+		goto error;
+
+	error = nfs_init_server_rpcclient(server, parent_server->client->cl_timeout, data->authflavor);
+	if (error < 0)
+		goto error;
+
+	error = nfs4_server_common_setup(server, mntfh);
+	if (error < 0)
+		goto error;
+
+	dprintk("<-- nfs_create_referral_server() = %p\n", server);
+	return server;
+
+error:
+	nfs_free_server(server);
+	dprintk("<-- nfs4_create_referral_server() = error %d\n", error);
+	return ERR_PTR(error);
+}
+
+module_param(nfs4_disable_idmapping, bool, 0644);
+MODULE_PARM_DESC(nfs4_disable_idmapping,
+		"Turn off NFSv4 idmapping when using 'sec=sys'");
-- 
1.7.9.4

