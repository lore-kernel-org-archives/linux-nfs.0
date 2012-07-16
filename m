Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4387 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752928Ab2GPUjb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jul 2012 16:39:31 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 09/12] NFS: Split out NFS v4 server creating code
Date: Mon, 16 Jul 2012 16:39:18 -0400
Message-Id: <1342471161-22452-10-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
References: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

These functions are specific to NFS v4 and can be moved to nfs4client.c
to keep them out of the generic client.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c     | 457 ++--------------------------------------------------
 fs/nfs/internal.h   |  25 +++
 fs/nfs/nfs4client.c | 428 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 462 insertions(+), 448 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5664c7b..0d50629 100644
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
 static const struct rpc_version *nfs_version[5] = {
@@ -130,17 +125,6 @@ const struct rpc_program nfsacl_program = {
 };
 #endif  /* CONFIG_NFS_V3_ACL */
 
-struct nfs_client_initdata {
-	unsigned long init_flags;
-	const char *hostname;
-	const struct sockaddr *addr;
-	size_t addrlen;
-	const struct nfs_rpc_ops *rpc_ops;
-	int proto;
-	u32 minorversion;
-	struct net *net;
-};
-
 /*
  * Allocate a shared client record
  *
@@ -282,13 +266,6 @@ static void pnfs_init_server(struct nfs_server *server)
 	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
 }
 
-static void nfs4_destroy_server(struct nfs_server *server)
-{
-	nfs_server_return_all_delegations(server);
-	unset_pnfs_layoutdriver(server);
-	nfs4_purge_state_owners(server);
-}
-
 #else
 void nfs_cleanup_cb_ident_idr(struct net *net)
 {
@@ -426,8 +403,8 @@ static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
  * Test if two socket addresses represent the same actual socket,
  * by comparing (only) relevant fields, excluding the port number.
  */
-static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
-				     const struct sockaddr *sa2)
+int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
+			      const struct sockaddr *sa2)
 {
 	if (sa1->sa_family != sa2->sa_family)
 		return 0;
@@ -461,33 +438,6 @@ static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
 	return 0;
 }
 
-#if defined(CONFIG_NFS_V4_1)
-/* Common match routine for v4.0 and v4.1 callback services */
-static bool nfs4_cb_match_client(const struct sockaddr *addr,
-		struct nfs_client *clp, u32 minorversion)
-{
-	struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
-
-	/* Don't match clients that failed to initialise */
-	if (!(clp->cl_cons_state == NFS_CS_READY ||
-	    clp->cl_cons_state == NFS_CS_SESSION_INITING))
-		return false;
-
-	smp_rmb();
-
-	/* Match the version and minorversion */
-	if (clp->rpc_ops->version != 4 ||
-	    clp->cl_minorversion != minorversion)
-		return false;
-
-	/* Match only the IP address, not the port number */
-	if (!nfs_sockaddr_match_ipaddr(addr, clap))
-		return false;
-
-	return true;
-}
-#endif /* CONFIG_NFS_V4_1 */
-
 /*
  * Find an nfs_client on the list that matches the initialisation data
  * that is supplied.
@@ -566,7 +516,7 @@ nfs_found_client(const struct nfs_client_initdata *cl_init,
  * Look up a client by IP address and protocol version
  * - creates a new record if one doesn't yet exist
  */
-static struct nfs_client *
+struct nfs_client *
 nfs_get_client(const struct nfs_client_initdata *cl_init,
 	       const struct rpc_timeout *timeparms,
 	       const char *ip_addr,
@@ -621,7 +571,7 @@ void nfs_mark_client_ready(struct nfs_client *clp, int state)
 /*
  * Initialise the timeout values for a connection
  */
-static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
+void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 				    unsigned int timeo, unsigned int retrans)
 {
 	to->to_initval = timeo * HZ / 10;
@@ -781,7 +731,7 @@ static inline void nfs_init_server_aclclient(struct nfs_server *server)
 /*
  * Create a general RPC client
  */
-static int nfs_init_server_rpcclient(struct nfs_server *server,
+int nfs_init_server_rpcclient(struct nfs_server *server,
 		const struct rpc_timeout *timeo,
 		rpc_authflavor_t pseudoflavour)
 {
@@ -1014,7 +964,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 /*
  * Probe filesystem information, including the FSID on v2/v3
  */
-static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs_fattr *fattr)
+int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs_fattr *fattr)
 {
 	struct nfs_fsinfo fsinfo;
 	struct nfs_client *clp = server->nfs_client;
@@ -1058,7 +1008,7 @@ out_error:
 /*
  * Copy useful information when duplicating a server record
  */
-static void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *source)
+void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *source)
 {
 	target->flags = source->flags;
 	target->rsize = source->rsize;
@@ -1071,7 +1021,7 @@ static void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_serve
 	target->options = source->options;
 }
 
-static void nfs_server_insert_lists(struct nfs_server *server)
+void nfs_server_insert_lists(struct nfs_server *server)
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
@@ -1105,7 +1055,7 @@ static void nfs_server_remove_lists(struct nfs_server *server)
 /*
  * Allocate and initialise a server record
  */
-static struct nfs_server *nfs_alloc_server(void)
+struct nfs_server *nfs_alloc_server(void)
 {
 	struct nfs_server *server;
 
@@ -1238,391 +1188,6 @@ error:
 	return ERR_PTR(error);
 }
 
-#ifdef CONFIG_NFS_V4
-/*
- * NFSv4.0 callback thread helper
- *
- * Find a client by callback identifier
- */
-struct nfs_client *
-nfs4_find_client_ident(struct net *net, int cb_ident)
-{
-	struct nfs_client *clp;
-	struct nfs_net *nn = net_generic(net, nfs_net_id);
-
-	spin_lock(&nn->nfs_client_lock);
-	clp = idr_find(&nn->cb_ident_idr, cb_ident);
-	if (clp)
-		atomic_inc(&clp->cl_count);
-	spin_unlock(&nn->nfs_client_lock);
-	return clp;
-}
-
-#if defined(CONFIG_NFS_V4_1)
-/*
- * NFSv4.1 callback thread helper
- * For CB_COMPOUND calls, find a client by IP address, protocol version,
- * minorversion, and sessionID
- *
- * Returns NULL if no such client
- */
-struct nfs_client *
-nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
-			   struct nfs4_sessionid *sid)
-{
-	struct nfs_client *clp;
-	struct nfs_net *nn = net_generic(net, nfs_net_id);
-
-	spin_lock(&nn->nfs_client_lock);
-	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
-		if (nfs4_cb_match_client(addr, clp, 1) == false)
-			continue;
-
-		if (!nfs4_has_session(clp))
-			continue;
-
-		/* Match sessionid*/
-		if (memcmp(clp->cl_session->sess_id.data,
-		    sid->data, NFS4_MAX_SESSIONID_LEN) != 0)
-			continue;
-
-		atomic_inc(&clp->cl_count);
-		spin_unlock(&nn->nfs_client_lock);
-		return clp;
-	}
-	spin_unlock(&nn->nfs_client_lock);
-	return NULL;
-}
-
-#else /* CONFIG_NFS_V4_1 */
-
-struct nfs_client *
-nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
-			   struct nfs4_sessionid *sid)
-{
-	return NULL;
-}
-#endif /* CONFIG_NFS_V4_1 */
-
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
-	if (server->flags & NFS_MOUNT_NORESVPORT)
-		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
-
-	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(&cl_init, timeparms, ip_addr, authflavour);
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
-		const struct sockaddr *ds_addr, int ds_addrlen,
-		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans)
-{
-	struct nfs_client_initdata cl_init = {
-		.addr = ds_addr,
-		.addrlen = ds_addrlen,
-		.rpc_ops = &nfs_v4_clientops,
-		.proto = ds_proto,
-		.minorversion = mds_clp->cl_minorversion,
-		.net = mds_clp->cl_net,
-	};
-	struct rpc_timeout ds_timeout;
-	struct nfs_client *clp;
-
-	/*
-	 * Set an authflavor equual to the MDS value. Use the MDS nfs_client
-	 * cl_ipaddr so as to use the same EXCHANGE_ID co_ownerid as the MDS
-	 * (section 13.1 RFC 5661).
-	 */
-	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
-	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
-			     mds_clp->cl_rpcclient->cl_auth->au_flavor);
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
-				parent_client->cl_net);
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
-#endif /* CONFIG_NFS_V4 */
-
 /*
  * Clone an NFS2, NFS3 or NFS4 server record
  */
@@ -1972,7 +1537,3 @@ void nfs_fs_proc_exit(void)
 }
 
 #endif /* CONFIG_PROC_FS */
-
-module_param(nfs4_disable_idmapping, bool, 0644);
-MODULE_PARM_DESC(nfs4_disable_idmapping,
-		"Turn off NFSv4 idmapping when using 'sec=sys'");
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 10df28d..b4a3570 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -85,6 +85,17 @@ struct nfs_clone_mount {
  */
 #define NFS_MAX_READDIR_PAGES 8
 
+struct nfs_client_initdata {
+	unsigned long init_flags;
+	const char *hostname;
+	const struct sockaddr *addr;
+	size_t addrlen;
+	const struct nfs_rpc_ops *rpc_ops;
+	int proto;
+	u32 minorversion;
+	struct net *net;
+};
+
 /*
  * In-kernel mount arguments
  */
@@ -150,6 +161,16 @@ extern const struct rpc_program nfs_program;
 extern void nfs_clients_init(struct net *net);
 extern struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *);
 int nfs_create_rpc_client(struct nfs_client *, const struct rpc_timeout *, rpc_authflavor_t);
+struct nfs_client *nfs_get_client(const struct nfs_client_initdata *,
+				  const struct rpc_timeout *, const char *,
+				  rpc_authflavor_t);
+int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *, struct nfs_fattr *);
+void nfs_server_insert_lists(struct nfs_server *);
+void nfs_init_timeout_values(struct rpc_timeout *, int, unsigned int, unsigned int);
+int nfs_init_server_rpcclient(struct nfs_server *, const struct rpc_timeout *t,
+		rpc_authflavor_t);
+struct nfs_server *nfs_alloc_server(void);
+void nfs_server_copy_userdata(struct nfs_server *, struct nfs_server *);
 
 extern void nfs_cleanup_cb_ident_idr(struct net *);
 extern void nfs_put_client(struct nfs_client *);
@@ -191,6 +212,10 @@ static inline void nfs_fs_proc_exit(void)
 }
 #endif
 
+#ifdef CONFIG_NFS_V4_1
+int nfs_sockaddr_match_ipaddr(const struct sockaddr *, const struct sockaddr *);
+#endif
+
 /* callback_xdr.c */
 extern struct svc_version nfs4_callback_version1;
 extern struct svc_version nfs4_callback_version4;
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index c5234b5..a71d95e 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -2,17 +2,27 @@
  * Copyright (C) 2006 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  */
+#include <linux/module.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_idmap.h>
+#include <linux/nfs_mount.h>
 #include <linux/sunrpc/auth.h>
 #include <linux/sunrpc/xprt.h>
 #include <linux/sunrpc/bc_xprt.h>
 #include "internal.h"
 #include "callback.h"
+#include "delegation.h"
+#include "pnfs.h"
+#include "netns.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
 /*
+ * Turn off NFSv4 uid/gid mapping when using AUTH_SYS
+ */
+static bool nfs4_disable_idmapping = true;
+
+/*
  * Initialize the NFS4 callback service
  */
 static int nfs4_init_callback(struct nfs_client *clp)
@@ -142,3 +152,421 @@ error:
 	dprintk("<-- nfs4_init_client() = xerror %d\n", error);
 	return ERR_PTR(error);
 }
+
+static void nfs4_destroy_server(struct nfs_server *server)
+{
+	nfs_server_return_all_delegations(server);
+	unset_pnfs_layoutdriver(server);
+	nfs4_purge_state_owners(server);
+}
+
+/*
+ * NFSv4.0 callback thread helper
+ *
+ * Find a client by callback identifier
+ */
+struct nfs_client *
+nfs4_find_client_ident(struct net *net, int cb_ident)
+{
+	struct nfs_client *clp;
+	struct nfs_net *nn = net_generic(net, nfs_net_id);
+
+	spin_lock(&nn->nfs_client_lock);
+	clp = idr_find(&nn->cb_ident_idr, cb_ident);
+	if (clp)
+		atomic_inc(&clp->cl_count);
+	spin_unlock(&nn->nfs_client_lock);
+	return clp;
+}
+
+#if defined(CONFIG_NFS_V4_1)
+/* Common match routine for v4.0 and v4.1 callback services */
+static bool nfs4_cb_match_client(const struct sockaddr *addr,
+		struct nfs_client *clp, u32 minorversion)
+{
+	struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
+
+	/* Don't match clients that failed to initialise */
+	if (!(clp->cl_cons_state == NFS_CS_READY ||
+	    clp->cl_cons_state == NFS_CS_SESSION_INITING))
+		return false;
+
+	smp_rmb();
+
+	/* Match the version and minorversion */
+	if (clp->rpc_ops->version != 4 ||
+	    clp->cl_minorversion != minorversion)
+		return false;
+
+	/* Match only the IP address, not the port number */
+	if (!nfs_sockaddr_match_ipaddr(addr, clap))
+		return false;
+
+	return true;
+}
+
+/*
+ * NFSv4.1 callback thread helper
+ * For CB_COMPOUND calls, find a client by IP address, protocol version,
+ * minorversion, and sessionID
+ *
+ * Returns NULL if no such client
+ */
+struct nfs_client *
+nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
+			   struct nfs4_sessionid *sid)
+{
+	struct nfs_client *clp;
+	struct nfs_net *nn = net_generic(net, nfs_net_id);
+
+	spin_lock(&nn->nfs_client_lock);
+	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
+		if (nfs4_cb_match_client(addr, clp, 1) == false)
+			continue;
+
+		if (!nfs4_has_session(clp))
+			continue;
+
+		/* Match sessionid*/
+		if (memcmp(clp->cl_session->sess_id.data,
+		    sid->data, NFS4_MAX_SESSIONID_LEN) != 0)
+			continue;
+
+		atomic_inc(&clp->cl_count);
+		spin_unlock(&nn->nfs_client_lock);
+		return clp;
+	}
+	spin_unlock(&nn->nfs_client_lock);
+	return NULL;
+}
+
+#else /* CONFIG_NFS_V4_1 */
+
+struct nfs_client *
+nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
+			   struct nfs4_sessionid *sid)
+{
+	return NULL;
+}
+#endif /* CONFIG_NFS_V4_1 */
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
+	if (server->flags & NFS_MOUNT_NORESVPORT)
+		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
+
+	/* Allocate or find a client reference we can use */
+	clp = nfs_get_client(&cl_init, timeparms, ip_addr, authflavour);
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
+		const struct sockaddr *ds_addr, int ds_addrlen,
+		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans)
+{
+	struct nfs_client_initdata cl_init = {
+		.addr = ds_addr,
+		.addrlen = ds_addrlen,
+		.rpc_ops = &nfs_v4_clientops,
+		.proto = ds_proto,
+		.minorversion = mds_clp->cl_minorversion,
+		.net = mds_clp->cl_net,
+	};
+	struct rpc_timeout ds_timeout;
+	struct nfs_client *clp;
+
+	/*
+	 * Set an authflavor equual to the MDS value. Use the MDS nfs_client
+	 * cl_ipaddr so as to use the same EXCHANGE_ID co_ownerid as the MDS
+	 * (section 13.1 RFC 5661).
+	 */
+	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
+	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
+			     mds_clp->cl_rpcclient->cl_auth->au_flavor);
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
+				parent_client->cl_net);
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
1.7.11.2

