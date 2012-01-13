Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10299 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932766Ab2AMULl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:41 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 41/44] NFS: Move v4 client.c code to nfs4/client.c
Date: Fri, 13 Jan 2012 15:10:50 -0500
Message-Id: <1326485453-1350-42-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This code is all nfs v4-only, so it shouldn't need to exist in the
generic nfs client.  I move it to the v4 subdirectory so it can
eventually compile as part of the v4 module.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c      |  632 --------------------------------------------------
 fs/nfs/nfs4/client.c |  617 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 617 insertions(+), 632 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8e053a4..2c3f50e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -60,36 +60,6 @@ static LIST_HEAD(nfs_versions);
 static LIST_HEAD(nfs_client_list);
 static LIST_HEAD(nfs_volume_list);
 static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
-#ifdef CONFIG_NFS_V4
-static DEFINE_SPINLOCK(nfs_idr_lock);
-static DEFINE_IDR(cb_ident_idr); /* Protected by nfs_idr_lock */
-
-/*
- * Get a unique NFSv4.0 callback identifier which will be used
- * by the V4.0 callback service to lookup the nfs_client struct
- */
-static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
-{
-	int ret = 0;
-
-	if (clp->rpc_ops->version != 4 || minorversion != 0)
-		return ret;
-retry:
-	if (!idr_pre_get(&cb_ident_idr, GFP_KERNEL))
-		return -ENOMEM;
-	spin_lock(&nfs_idr_lock);
-	ret = idr_get_new(&cb_ident_idr, clp, &clp->cl_cb_ident);
-	spin_unlock(&nfs_idr_lock);
-	if (ret == -EAGAIN)
-		goto retry;
-	return ret;
-}
-#endif /* CONFIG_NFS_V4 */
-
-/*
- * Turn off NFSv4 uid/gid mapping when using AUTH_SYS
- */
-static int nfs4_disable_idmapping = 0;
 
 /*
  * RPC cruft for NFS
@@ -167,25 +137,6 @@ void unregister_nfs_version(struct nfs_subversion *nfs)
 }
 EXPORT_SYMBOL_GPL(unregister_nfs_version);
 
-#ifdef CONFIG_NFS_V4
-int nfs4_alloc_client(struct nfs_client *clp, const struct nfs_client_initdata *cl_init)
-{
-	int err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
-	if (err)
-		return err;
-
-	spin_lock_init(&clp->cl_lock);
-	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
-	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
-	clp->cl_boot_time = CURRENT_TIME;
-	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
-	clp->cl_minorversion = cl_init->minorversion;
-	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
-
-	return 0;
-}
-#endif
-
 /*
  * Allocate a shared client record
  *
@@ -240,43 +191,6 @@ error_0:
 	return ERR_PTR(err);
 }
 
-#ifdef CONFIG_NFS_V4
-/* idr_remove_all is not needed as all id's are removed by nfs_put_client */
-void nfs_cleanup_cb_ident_idr(void)
-{
-	idr_destroy(&cb_ident_idr);
-}
-
-static void nfs_cb_idr_remove(struct nfs_client *clp)
-{
-	spin_lock(&nfs_idr_lock);
-	if (clp->cl_cb_ident)
-		idr_remove(&cb_ident_idr, clp->cl_cb_ident);
-	spin_unlock(&nfs_idr_lock);
-}
-
-static void nfs4_destroy_server(struct nfs_server *server)
-{
-	nfs4_purge_state_owners(server);
-}
-
-void nfs4_put_client(struct nfs_client *clp)
-{
-	nfs_cb_idr_remove(clp);
-}
-
-#else
-
-void nfs_cleanup_cb_ident_idr(void)
-{
-}
-
-static void nfs_cb_idr_remove(struct nfs_client *clp)
-{
-}
-
-#endif /* CONFIG_NFS_V4 */
-
 /*
  * Destroy a shared client record
  */
@@ -437,30 +351,6 @@ static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
 	return 0;
 }
 
-/* Common match routine for v4.0 and v4.1 callback services */
-bool
-nfs4_cb_match_client(const struct sockaddr *addr, struct nfs_client *clp,
-		     u32 minorversion)
-{
-	struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
-
-	/* Don't match clients that failed to initialise */
-	if (!(clp->cl_cons_state == NFS_CS_READY ||
-	    clp->cl_cons_state == NFS_CS_SESSION_INITING))
-		return false;
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
-
 /*
  * Find an nfs_client on the list that matches the initialisation data
  * that is supplied.
@@ -1170,524 +1060,6 @@ error:
 	return ERR_PTR(error);
 }
 
-#ifdef CONFIG_NFS_V4
-/*
- * NFSv4.0 callback thread helper
- *
- * Find a client by IP address, protocol version, and minorversion
- *
- * Called from the pg_authenticate method. The callback identifier
- * is not used as it has not been decoded.
- *
- * Returns NULL if no such client
- */
-struct nfs_client *
-nfs4_find_client_no_ident(const struct sockaddr *addr)
-{
-	struct nfs_client *clp;
-	struct list_head *cl_list = nfs_client_list_start();
-
-	list_for_each_entry(clp, cl_list, cl_share_link) {
-		if (nfs4_cb_match_client(addr, clp, 0) == false)
-			continue;
-		atomic_inc(&clp->cl_count);
-		goto out;
-	}
-	clp = NULL;
-out:
-	nfs_client_list_end();
-	return clp;
-}
-
-/*
- * NFSv4.0 callback thread helper
- *
- * Find a client by callback identifier
- */
-struct nfs_client *
-nfs4_find_client_ident(int cb_ident)
-{
-	struct nfs_client *clp;
-
-	spin_lock(&nfs_idr_lock);
-	clp = idr_find(&cb_ident_idr, cb_ident);
-	if (clp) {
-		if (!atomic_inc_not_zero(&clp->cl_count))
-			clp = NULL;
-	}
-	spin_unlock(&nfs_idr_lock);
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
-nfs4_find_client_sessionid(const struct sockaddr *addr,
-			   struct nfs4_sessionid *sid)
-{
-	struct nfs_client *clp;
-
-	spin_lock(&nfs_client_lock);
-	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
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
-		spin_unlock(&nfs_client_lock);
-		return clp;
-	}
-	spin_unlock(&nfs_client_lock);
-	return NULL;
-}
-
-#else /* CONFIG_NFS_V4_1 */
-
-struct nfs_client *
-nfs4_find_client_sessionid(const struct sockaddr *addr,
-			   struct nfs4_sessionid *sid)
-{
-	return NULL;
-}
-#endif /* CONFIG_NFS_V4_1 */
-
-/*
- * Initialize the NFS4 callback service
- */
-static int nfs4_init_callback(struct nfs_client *clp)
-{
-	int error;
-
-	if (clp->rpc_ops->version == 4) {
-		if (nfs4_has_session(clp)) {
-			error = xprt_setup_backchannel(
-						clp->cl_rpcclient->cl_xprt,
-						NFS41_BC_MIN_CALLBACKS);
-			if (error < 0)
-				return error;
-		}
-
-		error = nfs_callback_up(clp->cl_mvops->minor_version,
-					clp->cl_rpcclient->cl_xprt);
-		if (error < 0) {
-			dprintk("%s: failed to start callback. Error = %d\n",
-				__func__, error);
-			return error;
-		}
-		__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
-	}
-	return 0;
-}
-
-/*
- * Initialize the minor version specific parts of an NFS4 client record
- */
-static int nfs4_init_client_minor_version(struct nfs_client *clp)
-{
-#if defined(CONFIG_NFS_V4_1)
-	if (clp->cl_mvops->minor_version) {
-		struct nfs4_session *session = NULL;
-		/*
-		 * Create the session and mark it expired.
-		 * When a SEQUENCE operation encounters the expired session
-		 * it will do session recovery to initialize it.
-		 */
-		session = nfs4_alloc_session(clp);
-		if (!session)
-			return -ENOMEM;
-
-		clp->cl_session = session;
-		/*
-		 * The create session reply races with the server back
-		 * channel probe. Mark the client NFS_CS_SESSION_INITING
-		 * so that the client back channel can find the
-		 * nfs_client struct
-		 */
-		clp->cl_cons_state = NFS_CS_SESSION_INITING;
-	}
-#endif /* CONFIG_NFS_V4_1 */
-
-	return nfs4_init_callback(clp);
-}
-
-/*
- * Initialise an NFS4 client record
- */
-int nfs4_init_client(struct nfs_client *clp,
-		     const struct rpc_timeout *timeparms,
-		     const char *ip_addr,
-		     rpc_authflavor_t authflavour,
-		     int noresvport)
-{
-	int error;
-
-	if (clp->cl_cons_state == NFS_CS_READY) {
-		/* the client is initialised already */
-		dprintk("<-- nfs4_init_client() = 0 [already %p]\n", clp);
-		return 0;
-	}
-
-	/* Check NFS protocol revision and initialize RPC op vector */
-	clp->rpc_ops = &nfs_v4_clientops;
-
-	error = nfs_create_rpc_client(clp, timeparms, authflavour,
-				      1, noresvport);
-	if (error < 0)
-		goto error;
-	strlcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
-
-	error = nfs_idmap_new(clp);
-	if (error < 0) {
-		dprintk("%s: failed to create idmapper. Error = %d\n",
-			__func__, error);
-		goto error;
-	}
-	__set_bit(NFS_CS_IDMAP, &clp->cl_res_state);
-
-	error = nfs4_init_client_minor_version(clp);
-	if (error < 0)
-		goto error;
-
-	if (!nfs4_has_session(clp))
-		nfs_mark_client_ready(clp, NFS_CS_READY);
-	return 0;
-
-error:
-	nfs_mark_client_ready(clp, error);
-	dprintk("<-- nfs4_init_client() = xerror %d\n", error);
-	return error;
-}
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
-		u32 minorversion)
-{
-	struct nfs_client_initdata cl_init = {
-		.hostname = hostname,
-		.addr = addr,
-		.addrlen = addrlen,
-		.rpc_ops = &nfs_v4_clientops,
-		.proto = proto,
-		.minorversion = minorversion,
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
-			data->minorversion);
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
-	server = nfs4_alloc_server();
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
-	server = nfs4_alloc_server();
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
-				parent_server->client->cl_xprt->prot,
-				parent_server->client->cl_timeout,
-				parent_client->cl_mvops->minor_version);
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
 struct nfs_server *do_nfs_clone_server(struct nfs_server *source,
 				       struct nfs_server *server,
 				       struct nfs_fh *fh,
@@ -2092,7 +1464,3 @@ int nfs_stat_to_errno(enum nfs_stat status)
 	return nfs_errtbl[i].errno;
 }
 EXPORT_SYMBOL_GPL(nfs_stat_to_errno);
-
-module_param(nfs4_disable_idmapping, bool, 0644);
-MODULE_PARM_DESC(nfs4_disable_idmapping,
-		"Turn off NFSv4 idmapping when using 'sec=sys'");
diff --git a/fs/nfs/nfs4/client.c b/fs/nfs/nfs4/client.c
index 130c6a6..dd40936 100644
--- a/fs/nfs/nfs4/client.c
+++ b/fs/nfs/nfs4/client.c
@@ -1,7 +1,9 @@
 /*
  * Copyright (c) 2012 Netapp, Inc. All rights reserved.
  */
+#include <linux/module.h>
 #include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/bc_xprt.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_fs_sb.h>
 #include <linux/nfs_idmap.h>
@@ -10,10 +12,19 @@
 #include "nfs4_fs.h"
 #include "delegation.h"
 #include "callback.h"
+#include "../internal.h"
 #include "../nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
+static DEFINE_SPINLOCK(nfs_idr_lock);
+static DEFINE_IDR(cb_ident_idr); /* Protected by nfs_idr_lock */
+
+/*
+ * Turn off NFSv4 uid/gid mapping when using AUTH_SYS
+ */
+static int nfs4_disable_idmapping = 0;
+
 void nfs4_init_aclclient(struct nfs_server *server)
 {
 	server->flags &= ~NFS_MOUNT_NOACL;
@@ -33,6 +44,44 @@ static void nfs4_shutdown_session(struct nfs_client *clp)
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
+ * Get a unique NFSv4.0 callback identifier which will be used
+ * by the V4.0 callback service to lookup the nfs_client struct
+ */
+static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
+{
+	int ret = 0;
+
+	if (clp->rpc_ops->version != 4 || minorversion != 0)
+		return ret;
+retry:
+	if (!idr_pre_get(&cb_ident_idr, GFP_KERNEL))
+		return -ENOMEM;
+	spin_lock(&nfs_idr_lock);
+	ret = idr_get_new(&cb_ident_idr, clp, &clp->cl_cb_ident);
+	spin_unlock(&nfs_idr_lock);
+	if (ret == -EAGAIN)
+		goto retry;
+	return ret;
+}
+
+int nfs4_alloc_client(struct nfs_client *clp, const struct nfs_client_initdata *cl_init)
+{
+	int err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
+	if (err)
+		return err;
+
+	spin_lock_init(&clp->cl_lock);
+	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
+	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
+	clp->cl_boot_time = CURRENT_TIME;
+	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
+	clp->cl_minorversion = cl_init->minorversion;
+	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
+
+	return 0;
+}
+
+/*
  * Destroy the NFS4 callback service
  */
 static void nfs4_destroy_callback(struct nfs_client *clp)
@@ -53,11 +102,36 @@ void nfs4_shutdown_client(struct nfs_client *clp)
 	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
 }
 
+/* idr_remove_all is not needed as all id's are removed by nfs_put_client */
+void nfs_cleanup_cb_ident_idr(void)
+{
+	idr_destroy(&cb_ident_idr);
+}
+
+static void nfs_cb_idr_remove(struct nfs_client *clp)
+{
+	spin_lock(&nfs_idr_lock);
+	if (clp->cl_cb_ident)
+		idr_remove(&cb_ident_idr, clp->cl_cb_ident);
+	spin_unlock(&nfs_idr_lock);
+}
+
 static void pnfs_init_server(struct nfs_server *server)
 {
 	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
 }
 
+static void nfs4_destroy_server(struct nfs_server *server)
+{
+	nfs4_purge_state_owners(server);
+}
+
+void nfs4_put_client(struct nfs_client *clp)
+{
+	nfs_cb_idr_remove(clp);
+}
+
+
 struct nfs_server *nfs4_alloc_server(void)
 {
 	struct nfs_server *server = nfs_alloc_server();
@@ -81,3 +155,546 @@ struct nfs_server *nfs4_clone_server(struct nfs_server *source,
 		return ERR_PTR(-ENOMEM);
 	return do_nfs_clone_server(source, server, fh, fattr);
 }
+
+/* Common match routine for v4.0 and v4.1 callback services */
+bool
+nfs4_cb_match_client(const struct sockaddr *addr, struct nfs_client *clp,
+		     u32 minorversion)
+{
+	struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
+
+	/* Don't match clients that failed to initialise */
+	if (!(clp->cl_cons_state == NFS_CS_READY ||
+	    clp->cl_cons_state == NFS_CS_SESSION_INITING))
+		return false;
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
+ * NFSv4.0 callback thread helper
+ *
+ * Find a client by IP address, protocol version, and minorversion
+ *
+ * Called from the pg_authenticate method. The callback identifier
+ * is not used as it has not been decoded.
+ *
+ * Returns NULL if no such client
+ */
+struct nfs_client *
+nfs4_find_client_no_ident(const struct sockaddr *addr)
+{
+	struct nfs_client *clp;
+	struct list_head *cl_list = nfs_client_list_start();
+
+	list_for_each_entry(clp, cl_list, cl_share_link) {
+		if (nfs4_cb_match_client(addr, clp, 0) == false)
+			continue;
+		atomic_inc(&clp->cl_count);
+		goto out;
+	}
+	clp = NULL;
+out:
+	nfs_client_list_end();
+	return clp;
+}
+
+/*
+ * NFSv4.0 callback thread helper
+ *
+ * Find a client by callback identifier
+ */
+struct nfs_client *
+nfs4_find_client_ident(int cb_ident)
+{
+	struct nfs_client *clp;
+
+	spin_lock(&nfs_idr_lock);
+	clp = idr_find(&cb_ident_idr, cb_ident);
+	if (clp) {
+		if (!atomic_inc_not_zero(&clp->cl_count))
+			clp = NULL;
+	}
+	spin_unlock(&nfs_idr_lock);
+	return clp;
+}
+
+#if defined(CONFIG_NFS_V4_1)
+/*
+ * NFSv4.1 callback thread helper
+ * For CB_COMPOUND calls, find a client by IP address, protocol version,
+ * minorversion, and sessionID
+ *
+ * Returns NULL if no such client
+ */
+struct nfs_client *
+nfs4_find_client_sessionid(const struct sockaddr *addr,
+			   struct nfs4_sessionid *sid)
+{
+	struct nfs_client *clp;
+
+	spin_lock(&nfs_client_lock);
+	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
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
+		spin_unlock(&nfs_client_lock);
+		return clp;
+	}
+	spin_unlock(&nfs_client_lock);
+	return NULL;
+}
+
+#else /* CONFIG_NFS_V4_1 */
+
+struct nfs_client *
+nfs4_find_client_sessionid(const struct sockaddr *addr,
+			   struct nfs4_sessionid *sid)
+{
+	return NULL;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
+/*
+ * Initialize the NFS4 callback service
+ */
+static int nfs4_init_callback(struct nfs_client *clp)
+{
+	int error;
+
+	if (clp->rpc_ops->version == 4) {
+		if (nfs4_has_session(clp)) {
+			error = xprt_setup_backchannel(
+						clp->cl_rpcclient->cl_xprt,
+						NFS41_BC_MIN_CALLBACKS);
+			if (error < 0)
+				return error;
+		}
+
+		error = nfs_callback_up(clp->cl_mvops->minor_version,
+					clp->cl_rpcclient->cl_xprt);
+		if (error < 0) {
+			dprintk("%s: failed to start callback. Error = %d\n",
+				__func__, error);
+			return error;
+		}
+		__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
+	}
+	return 0;
+}
+
+/*
+ * Initialize the minor version specific parts of an NFS4 client record
+ */
+static int nfs4_init_client_minor_version(struct nfs_client *clp)
+{
+#if defined(CONFIG_NFS_V4_1)
+	if (clp->cl_mvops->minor_version) {
+		struct nfs4_session *session = NULL;
+		/*
+		 * Create the session and mark it expired.
+		 * When a SEQUENCE operation encounters the expired session
+		 * it will do session recovery to initialize it.
+		 */
+		session = nfs4_alloc_session(clp);
+		if (!session)
+			return -ENOMEM;
+
+		clp->cl_session = session;
+		/*
+		 * The create session reply races with the server back
+		 * channel probe. Mark the client NFS_CS_SESSION_INITING
+		 * so that the client back channel can find the
+		 * nfs_client struct
+		 */
+		clp->cl_cons_state = NFS_CS_SESSION_INITING;
+	}
+#endif /* CONFIG_NFS_V4_1 */
+
+	return nfs4_init_callback(clp);
+}
+
+/*
+ * Initialise an NFS4 client record
+ */
+int nfs4_init_client(struct nfs_client *clp,
+		     const struct rpc_timeout *timeparms,
+		     const char *ip_addr,
+		     rpc_authflavor_t authflavour,
+		     int noresvport)
+{
+	int error;
+
+	if (clp->cl_cons_state == NFS_CS_READY) {
+		/* the client is initialised already */
+		dprintk("<-- nfs4_init_client() = 0 [already %p]\n", clp);
+		return 0;
+	}
+
+	/* Check NFS protocol revision and initialize RPC op vector */
+	clp->rpc_ops = &nfs_v4_clientops;
+
+	error = nfs_create_rpc_client(clp, timeparms, authflavour,
+				      1, noresvport);
+	if (error < 0)
+		goto error;
+	strlcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
+
+	error = nfs_idmap_new(clp);
+	if (error < 0) {
+		dprintk("%s: failed to create idmapper. Error = %d\n",
+			__func__, error);
+		goto error;
+	}
+	__set_bit(NFS_CS_IDMAP, &clp->cl_res_state);
+
+	error = nfs4_init_client_minor_version(clp);
+	if (error < 0)
+		goto error;
+
+	if (!nfs4_has_session(clp))
+		nfs_mark_client_ready(clp, NFS_CS_READY);
+	return 0;
+
+error:
+	nfs_mark_client_ready(clp, error);
+	dprintk("<-- nfs4_init_client() = xerror %d\n", error);
+	return error;
+}
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
+		u32 minorversion)
+{
+	struct nfs_client_initdata cl_init = {
+		.hostname = hostname,
+		.addr = addr,
+		.addrlen = addrlen,
+		.rpc_ops = &nfs_v4_clientops,
+		.proto = proto,
+		.minorversion = minorversion,
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
+			data->minorversion);
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
+	server = nfs4_alloc_server();
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
+	server = nfs4_alloc_server();
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
+				parent_server->client->cl_xprt->prot,
+				parent_server->client->cl_timeout,
+				parent_client->cl_mvops->minor_version);
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
1.7.8.3

