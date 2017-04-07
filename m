Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:19461 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932731AbdDGSQB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:16:01 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 24/34] NFS: Remove extra dprintk()s from nfs4client.c
Date: Fri, 7 Apr 2017 14:15:18 -0400
Message-ID: <20170407181528.2832-25-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4client.c | 62 +++++++++--------------------------------------------
 1 file changed, 10 insertions(+), 52 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 2e7fc76cbd4b..692a7a8bfc7a 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -359,11 +359,9 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	struct nfs_client *old;
 	int error;
 
-	if (clp->cl_cons_state == NFS_CS_READY) {
+	if (clp->cl_cons_state == NFS_CS_READY)
 		/* the client is initialised already */
-		dprintk("<-- nfs4_init_client() = 0 [already %p]\n", clp);
 		return clp;
-	}
 
 	/* Check NFS protocol revision and initialize RPC op vector */
 	clp->rpc_ops = &nfs_v4_clientops;
@@ -421,7 +419,6 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 error:
 	nfs_mark_client_ready(clp, error);
 	nfs_put_client(clp);
-	dprintk("<-- nfs4_init_client() = xerror %d\n", error);
 	return ERR_PTR(error);
 }
 
@@ -577,8 +574,6 @@ int nfs40_walk_client_list(struct nfs_client *new,
 
 			prev = NULL;
 			*result = pos;
-			dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
-				__func__, pos, atomic_read(&pos->cl_count));
 			goto out;
 		case -ERESTARTSYS:
 		case -ETIMEDOUT:
@@ -599,7 +594,6 @@ int nfs40_walk_client_list(struct nfs_client *new,
 	/* No match found. The server lost our clientid */
 out:
 	nfs_put_client(prev);
-	dprintk("NFS: <-- %s status = %d\n", __func__, status);
 	return status;
 }
 
@@ -909,7 +903,6 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 		.net = mds_clp->cl_net,
 		.timeparms = &ds_timeout,
 	};
-	struct nfs_client *clp;
 	char buf[INET6_ADDRSTRLEN + 1];
 
 	if (rpc_ntop(ds_addr, buf, sizeof(buf)) <= 0)
@@ -925,10 +918,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 	 * (section 13.1 RFC 5661).
 	 */
 	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
-	clp = nfs_get_client(&cl_init);
-
-	dprintk("<-- %s %p\n", __func__, clp);
-	return clp;
+	return nfs_get_client(&cl_init);
 }
 EXPORT_SYMBOL_GPL(nfs4_set_ds_client);
 
@@ -1082,8 +1072,6 @@ struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
 	bool auth_probe;
 	int error;
 
-	dprintk("--> nfs4_create_server()\n");
-
 	server = nfs_alloc_server();
 	if (!server)
 		return ERR_PTR(-ENOMEM);
@@ -1099,12 +1087,10 @@ struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
 	if (error < 0)
 		goto error;
 
-	dprintk("<-- nfs4_create_server() = %p\n", server);
 	return server;
 
 error:
 	nfs_free_server(server);
-	dprintk("<-- nfs4_create_server() = error %d\n", error);
 	return ERR_PTR(error);
 }
 
@@ -1119,8 +1105,6 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	bool auth_probe;
 	int error;
 
-	dprintk("--> nfs4_create_referral_server()\n");
-
 	server = nfs_alloc_server();
 	if (!server)
 		return ERR_PTR(-ENOMEM);
@@ -1154,12 +1138,10 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	if (error < 0)
 		goto error;
 
-	dprintk("<-- nfs_create_referral_server() = %p\n", server);
 	return server;
 
 error:
 	nfs_free_server(server);
-	dprintk("<-- nfs4_create_referral_server() = error %d\n", error);
 	return ERR_PTR(error);
 }
 
@@ -1219,31 +1201,16 @@ int nfs4_update_server(struct nfs_server *server, const char *hostname,
 	struct sockaddr *localaddr = (struct sockaddr *)&address;
 	int error;
 
-	dprintk("--> %s: move FSID %llx:%llx to \"%s\")\n", __func__,
-			(unsigned long long)server->fsid.major,
-			(unsigned long long)server->fsid.minor,
-			hostname);
-
 	error = rpc_switch_client_transport(clnt, &xargs, clnt->cl_timeout);
-	if (error != 0) {
-		dprintk("<-- %s(): rpc_switch_client_transport returned %d\n",
-			__func__, error);
-		goto out;
-	}
+	if (error != 0)
+		return error;
 
 	error = rpc_localaddr(clnt, localaddr, sizeof(address));
-	if (error != 0) {
-		dprintk("<-- %s(): rpc_localaddr returned %d\n",
-			__func__, error);
-		goto out;
-	}
+	if (error != 0)
+		return error;
 
-	error = -EAFNOSUPPORT;
-	if (rpc_ntop(localaddr, buf, sizeof(buf)) == 0) {
-		dprintk("<-- %s(): rpc_ntop returned %d\n",
-			__func__, error);
-		goto out;
-	}
+	if (rpc_ntop(localaddr, buf, sizeof(buf)) == 0)
+		return -EAFNOSUPPORT;
 
 	nfs_server_remove_lists(server);
 	error = nfs4_set_client(server, hostname, sap, salen, buf,
@@ -1252,21 +1219,12 @@ int nfs4_update_server(struct nfs_server *server, const char *hostname,
 	nfs_put_client(clp);
 	if (error != 0) {
 		nfs_server_insert_lists(server);
-		dprintk("<-- %s(): nfs4_set_client returned %d\n",
-			__func__, error);
-		goto out;
+		return error;
 	}
 
 	if (server->nfs_client->cl_hostname == NULL)
 		server->nfs_client->cl_hostname = kstrdup(hostname, GFP_KERNEL);
 	nfs_server_insert_lists(server);
 
-	error = nfs_probe_destination(server);
-	if (error < 0)
-		goto out;
-
-	dprintk("<-- %s() succeeded\n", __func__);
-
-out:
-	return error;
+	return nfs_probe_destination(server);
 }
-- 
2.12.2

