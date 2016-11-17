Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:25474 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751020AbcKQUQP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Nov 2016 15:16:15 -0500
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@Netapp.com>
Subject: [PATCH] NFS: Remove unused authflavour parameter from nfs_get_client()
Date: Thu, 17 Nov 2016 15:15:55 -0500
Message-ID: <20161117201555.10357-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This parameter hasn't been used since f8407299 (Linux 3.11-rc2), so
let's remove it from this function and callers.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/client.c                           |  6 ++----
 fs/nfs/filelayout/filelayoutdev.c         |  3 +--
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  3 +--
 fs/nfs/internal.h                         |  8 +++-----
 fs/nfs/nfs3client.c                       |  5 ++---
 fs/nfs/nfs4client.c                       | 10 +++-------
 fs/nfs/pnfs.h                             |  3 +--
 fs/nfs/pnfs_nfs.c                         | 28 ++++++++++------------------
 8 files changed, 23 insertions(+), 43 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5ac3e1d..e431b77 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -361,9 +361,7 @@ nfs_found_client(const struct nfs_client_initdata *cl_init,
  * Look up a client by IP address and protocol version
  * - creates a new record if one doesn't yet exist
  */
-struct nfs_client *
-nfs_get_client(const struct nfs_client_initdata *cl_init,
-	       rpc_authflavor_t authflavour)
+struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_init)
 {
 	struct nfs_client *clp, *new = NULL;
 	struct nfs_net *nn = net_generic(cl_init->net, nfs_net_id);
@@ -642,7 +640,7 @@ static int nfs_init_server(struct nfs_server *server,
 		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(&cl_init, RPC_AUTH_UNIX);
+	clp = nfs_get_client(&cl_init);
 	if (IS_ERR(clp)) {
 		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
 		return PTR_ERR(clp);
diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 4946ef4..a5589b7 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -279,8 +279,7 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 
 	nfs4_pnfs_ds_connect(s, ds, devid, dataserver_timeo,
 			     dataserver_retrans, 4,
-			     s->nfs_client->cl_minorversion,
-			     s->nfs_client->cl_rpcclient->cl_auth->au_flavor);
+			     s->nfs_client->cl_minorversion);
 
 out_test_devid:
 	if (filelayout_test_devid_unavailable(devid))
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index f7a3f6b..b220b44 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -393,8 +393,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 	nfs4_pnfs_ds_connect(s, ds, devid, dataserver_timeo,
 			     dataserver_retrans,
 			     mirror->mirror_ds->ds_versions[0].version,
-			     mirror->mirror_ds->ds_versions[0].minor_version,
-			     RPC_AUTH_UNIX);
+			     mirror->mirror_ds->ds_versions[0].minor_version);
 
 	/* connect success, check rsize/wsize limit */
 	if (ds->ds_clp) {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 80bcc0b..4622d5f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -154,8 +154,7 @@ extern const struct rpc_program nfs_program;
 extern void nfs_clients_init(struct net *net);
 extern struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *);
 int nfs_create_rpc_client(struct nfs_client *, const struct nfs_client_initdata *, rpc_authflavor_t);
-struct nfs_client *nfs_get_client(const struct nfs_client_initdata *,
-				  rpc_authflavor_t);
+struct nfs_client *nfs_get_client(const struct nfs_client_initdata *);
 int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *, struct nfs_fattr *);
 void nfs_server_insert_lists(struct nfs_server *);
 void nfs_server_remove_lists(struct nfs_server *);
@@ -194,14 +193,13 @@ extern struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 					     int ds_addrlen, int ds_proto,
 					     unsigned int ds_timeo,
 					     unsigned int ds_retrans,
-					     u32 minor_version,
-					     rpc_authflavor_t au_flavor);
+					     u32 minor_version);
 extern struct rpc_clnt *nfs4_find_or_create_ds_client(struct nfs_client *,
 						struct inode *);
 extern struct nfs_client *nfs3_set_ds_client(struct nfs_server *mds_srv,
 			const struct sockaddr *ds_addr, int ds_addrlen,
 			int ds_proto, unsigned int ds_timeo,
-			unsigned int ds_retrans, rpc_authflavor_t au_flavor);
+			unsigned int ds_retrans);
 #ifdef CONFIG_PROC_FS
 extern int __init nfs_fs_proc_init(void);
 extern void nfs_fs_proc_exit(void);
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index ee75354..7879f2a 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -78,8 +78,7 @@ struct nfs_server *nfs3_clone_server(struct nfs_server *source,
  */
 struct nfs_client *nfs3_set_ds_client(struct nfs_server *mds_srv,
 		const struct sockaddr *ds_addr, int ds_addrlen,
-		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
-		rpc_authflavor_t au_flavor)
+		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans)
 {
 	struct rpc_timeout ds_timeout;
 	struct nfs_client *mds_clp = mds_srv->nfs_client;
@@ -106,7 +105,7 @@ struct nfs_client *nfs3_set_ds_client(struct nfs_server *mds_srv,
 
 	/* Use the MDS nfs_client cl_ipaddr. */
 	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
-	clp = nfs_get_client(&cl_init, au_flavor);
+	clp = nfs_get_client(&cl_init);
 
 	return clp;
 }
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 074ac71..c5b7d5c 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -881,7 +881,6 @@ static int nfs4_set_client(struct nfs_server *server,
 		const struct sockaddr *addr,
 		const size_t addrlen,
 		const char *ip_addr,
-		rpc_authflavor_t authflavour,
 		int proto, const struct rpc_timeout *timeparms,
 		u32 minorversion, struct net *net)
 {
@@ -907,7 +906,7 @@ static int nfs4_set_client(struct nfs_server *server,
 		set_bit(NFS_CS_MIGRATION, &cl_init.init_flags);
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(&cl_init, authflavour);
+	clp = nfs_get_client(&cl_init);
 	if (IS_ERR(clp)) {
 		error = PTR_ERR(clp);
 		goto error;
@@ -948,7 +947,7 @@ static int nfs4_set_client(struct nfs_server *server,
 struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 		const struct sockaddr *ds_addr, int ds_addrlen,
 		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
-		u32 minor_version, rpc_authflavor_t au_flavor)
+		u32 minor_version)
 {
 	struct rpc_timeout ds_timeout;
 	struct nfs_client *mds_clp = mds_srv->nfs_client;
@@ -979,7 +978,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 	 * (section 13.1 RFC 5661).
 	 */
 	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
-	clp = nfs_get_client(&cl_init, au_flavor);
+	clp = nfs_get_client(&cl_init);
 
 	dprintk("<-- %s %p\n", __func__, clp);
 	return clp;
@@ -1103,7 +1102,6 @@ static int nfs4_init_server(struct nfs_server *server,
 			(const struct sockaddr *)&data->nfs_server.address,
 			data->nfs_server.addrlen,
 			data->client_address,
-			data->selected_flavor,
 			data->nfs_server.protocol,
 			&timeparms,
 			data->minorversion,
@@ -1200,7 +1198,6 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				data->addr,
 				data->addrlen,
 				parent_client->cl_ipaddr,
-				data->authflavor,
 				rpc_protocol(parent_server->client),
 				parent_server->client->cl_timeout,
 				parent_client->cl_mvops->minor_version,
@@ -1311,7 +1308,6 @@ int nfs4_update_server(struct nfs_server *server, const char *hostname,
 
 	nfs_server_remove_lists(server);
 	error = nfs4_set_client(server, hostname, sap, salen, buf,
-				clp->cl_rpcclient->cl_auth->au_flavor,
 				clp->cl_proto, clnt->cl_timeout,
 				clp->cl_minorversion, net);
 	nfs_put_client(clp);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5c29551..f6d456b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -362,8 +362,7 @@ struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(struct list_head *dsaddrs,
 void nfs4_pnfs_v3_ds_connect_unload(void);
 void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
-			  unsigned int retrans, u32 version, u32 minor_version,
-			  rpc_authflavor_t au_flavor);
+			  unsigned int retrans, u32 version, u32 minor_version);
 struct nfs4_pnfs_ds_addr *nfs4_decode_mp_ds_addr(struct net *net,
 						 struct xdr_stream *xdr,
 						 gfp_t gfp_flags);
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 53b4705..9414b49 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -600,8 +600,7 @@ static struct nfs_client *(*get_v3_ds_connect)(
 			int ds_addrlen,
 			int ds_proto,
 			unsigned int ds_timeo,
-			unsigned int ds_retrans,
-			rpc_authflavor_t au_flavor);
+			unsigned int ds_retrans);
 
 static bool load_v3_ds_connect(void)
 {
@@ -625,15 +624,13 @@ EXPORT_SYMBOL_GPL(nfs4_pnfs_v3_ds_connect_unload);
 static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 				 struct nfs4_pnfs_ds *ds,
 				 unsigned int timeo,
-				 unsigned int retrans,
-				 rpc_authflavor_t au_flavor)
+				 unsigned int retrans)
 {
 	struct nfs_client *clp = ERR_PTR(-EIO);
 	struct nfs4_pnfs_ds_addr *da;
 	int status = 0;
 
-	dprintk("--> %s DS %s au_flavor %d\n", __func__,
-		ds->ds_remotestr, au_flavor);
+	dprintk("--> %s DS %s\n", __func__, ds->ds_remotestr);
 
 	if (!load_v3_ds_connect())
 		goto out;
@@ -657,7 +654,7 @@ static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 			clp = get_v3_ds_connect(mds_srv,
 					(struct sockaddr *)&da->da_addr,
 					da->da_addrlen, IPPROTO_TCP,
-					timeo, retrans, au_flavor);
+					timeo, retrans);
 	}
 
 	if (IS_ERR(clp)) {
@@ -676,15 +673,13 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 				 struct nfs4_pnfs_ds *ds,
 				 unsigned int timeo,
 				 unsigned int retrans,
-				 u32 minor_version,
-				 rpc_authflavor_t au_flavor)
+				 u32 minor_version)
 {
 	struct nfs_client *clp = ERR_PTR(-EIO);
 	struct nfs4_pnfs_ds_addr *da;
 	int status = 0;
 
-	dprintk("--> %s DS %s au_flavor %d\n", __func__, ds->ds_remotestr,
-		au_flavor);
+	dprintk("--> %s DS %s\n", __func__, ds->ds_remotestr);
 
 	list_for_each_entry(da, &ds->ds_addrs, da_node) {
 		dprintk("%s: DS %s: trying address %s\n",
@@ -720,8 +715,7 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 			clp = nfs4_set_ds_client(mds_srv,
 						(struct sockaddr *)&da->da_addr,
 						da->da_addrlen, IPPROTO_TCP,
-						timeo, retrans, minor_version,
-						au_flavor);
+						timeo, retrans, minor_version);
 			if (IS_ERR(clp))
 				continue;
 
@@ -755,19 +749,17 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
  */
 void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
-			  unsigned int retrans, u32 version,
-			  u32 minor_version, rpc_authflavor_t au_flavor)
+			  unsigned int retrans, u32 version, u32 minor_version)
 {
 	if (test_and_set_bit(NFS4DS_CONNECTING, &ds->ds_state) == 0) {
 		int err = 0;
 
 		if (version == 3) {
 			err = _nfs4_pnfs_v3_ds_connect(mds_srv, ds, timeo,
-						       retrans, au_flavor);
+						       retrans);
 		} else if (version == 4) {
 			err = _nfs4_pnfs_v4_ds_connect(mds_srv, ds, timeo,
-						       retrans, minor_version,
-						       au_flavor);
+						       retrans, minor_version);
 		} else {
 			dprintk("%s: unsupported DS version %d\n", __func__,
 				version);
-- 
2.10.2

