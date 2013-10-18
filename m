Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:25111 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753926Ab3JRTPj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Oct 2013 15:15:39 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/5] NFS: separate passed security flavs from selected
Date: Fri, 18 Oct 2013 15:15:16 -0400
Message-ID: <1382123719-25194-3-git-send-email-dros@netapp.com>
In-Reply-To: <1382123719-25194-1-git-send-email-dros@netapp.com>
References: <1382123719-25194-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When filling parsed_mount_data, store the parsed sec= mount option in
the new struct nfs_auth_info and the chosen flavor in selected_flavor.

This patch lays the groundwork for supporting multiple sec= options.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/client.c         |  3 ++-
 fs/nfs/internal.h       |  4 ++--
 fs/nfs/nfs4client.c     | 16 +++++++++-------
 fs/nfs/super.c          | 47 ++++++++++++++++++++++-------------------------
 include/linux/nfs_xdr.h |  6 ++++++
 5 files changed, 41 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index af03258..abc535f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -787,7 +787,8 @@ static int nfs_init_server(struct nfs_server *server,
 
 	server->port = data->nfs_server.port;
 
-	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
+	error = nfs_init_server_rpcclient(server, &timeparms,
+					  data->selected_flavor);
 	if (error < 0)
 		goto error;
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 38da8c2..5de1ef6c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -88,8 +88,8 @@ struct nfs_parsed_mount_data {
 	unsigned int		namlen;
 	unsigned int		options;
 	unsigned int		bsize;
-	unsigned int		auth_flavor_len;
-	rpc_authflavor_t	auth_flavors[1];
+	struct nfs_auth_info	auth_info;
+	rpc_authflavor_t	selected_flavor;
 	char			*client_address;
 	unsigned int		version;
 	unsigned int		minorversion;
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 511cdce..6a0661f 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -948,9 +948,8 @@ out:
  * Create a version 4 volume record
  */
 static int nfs4_init_server(struct nfs_server *server,
-		const struct nfs_parsed_mount_data *data)
+		struct nfs_parsed_mount_data *data)
 {
-	rpc_authflavor_t pseudoflavor = RPC_AUTH_UNIX;
 	struct rpc_timeout timeparms;
 	int error;
 
@@ -963,8 +962,10 @@ static int nfs4_init_server(struct nfs_server *server,
 	server->flags = data->flags;
 	server->options = data->options;
 
-	if (data->auth_flavor_len >= 1)
-		pseudoflavor = data->auth_flavors[0];
+	if (data->auth_info.flavor_len >= 1)
+		data->selected_flavor = data->auth_info.flavors[0];
+	else
+		data->selected_flavor = RPC_AUTH_UNIX;
 
 	/* Get a client record */
 	error = nfs4_set_client(server,
@@ -972,7 +973,7 @@ static int nfs4_init_server(struct nfs_server *server,
 			(const struct sockaddr *)&data->nfs_server.address,
 			data->nfs_server.addrlen,
 			data->client_address,
-			pseudoflavor,
+			data->selected_flavor,
 			data->nfs_server.protocol,
 			&timeparms,
 			data->minorversion,
@@ -992,7 +993,8 @@ static int nfs4_init_server(struct nfs_server *server,
 
 	server->port = data->nfs_server.port;
 
-	error = nfs_init_server_rpcclient(server, &timeparms, pseudoflavor);
+	error = nfs_init_server_rpcclient(server, &timeparms,
+					  data->selected_flavor);
 
 error:
 	/* Done */
@@ -1019,7 +1021,7 @@ struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
-	auth_probe = mount_info->parsed->auth_flavor_len < 1;
+	auth_probe = mount_info->parsed->auth_info.flavor_len < 1;
 
 	/* set up the general RPC client */
 	error = nfs4_init_server(server, mount_info->parsed);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a03b9c6..7cd2d57 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -923,8 +923,7 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
 		data->mount_server.port	= NFS_UNSPEC_PORT;
 		data->nfs_server.port	= NFS_UNSPEC_PORT;
 		data->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-		data->auth_flavors[0]	= RPC_AUTH_MAXFLAVOR;
-		data->auth_flavor_len	= 0;
+		data->selected_flavor	= RPC_AUTH_MAXFLAVOR;
 		data->minorversion	= 0;
 		data->need_mount	= true;
 		data->net		= current->nsproxy->net_ns;
@@ -1019,13 +1018,6 @@ static void nfs_set_mount_transport_protocol(struct nfs_parsed_mount_data *mnt)
 	}
 }
 
-static void nfs_set_auth_parsed_mount_data(struct nfs_parsed_mount_data *data,
-		rpc_authflavor_t pseudoflavor)
-{
-	data->auth_flavors[0] = pseudoflavor;
-	data->auth_flavor_len = 1;
-}
-
 /*
  * Parse the value of the 'sec=' option.
  */
@@ -1076,7 +1068,8 @@ static int nfs_parse_security_flavors(char *value,
 	}
 
 	mnt->flags |= NFS_MOUNT_SECFLAVOUR;
-	nfs_set_auth_parsed_mount_data(mnt, pseudoflavor);
+	mnt->auth_info.flavors[0] = pseudoflavor;
+	mnt->auth_info.flavor_len = 1;
 	return 1;
 }
 
@@ -1623,7 +1616,7 @@ out_security_failure:
 }
 
 /*
- * Ensure that the specified authtype in args->auth_flavors[0] is supported by
+ * Ensure that the specified authtype in args->auth_info is supported by
  * the server. Returns 0 if it's ok, and -EACCES if not.
  */
 static int nfs_verify_authflavor(struct nfs_parsed_mount_data *args,
@@ -1640,17 +1633,18 @@ static int nfs_verify_authflavor(struct nfs_parsed_mount_data *args,
 	 * can be used.
 	 */
 	for (i = 0; i < count; i++) {
-		if (args->auth_flavors[0] == server_authlist[i] ||
+		if (args->auth_info.flavors[0] == server_authlist[i] ||
 		    server_authlist[i] == RPC_AUTH_NULL)
 			goto out;
 	}
 
 	dfprintk(MOUNT, "NFS: auth flavor %u not supported by server\n",
-		args->auth_flavors[0]);
+		args->auth_info.flavors[0]);
 	return -EACCES;
 
 out:
-	dfprintk(MOUNT, "NFS: using auth flavor %u\n", args->auth_flavors[0]);
+	args->selected_flavor = args->auth_info.flavors[0];
+	dfprintk(MOUNT, "NFS: using auth flavor %u\n", args->selected_flavor);
 	return 0;
 }
 
@@ -1738,9 +1732,10 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 	 * Was a sec= authflavor specified in the options? First, verify
 	 * whether the server supports it, and then just try to use it if so.
 	 */
-	if (args->auth_flavor_len > 0) {
+	if (args->auth_info.flavor_len > 0) {
 		status = nfs_verify_authflavor(args, authlist, authlist_len);
-		dfprintk(MOUNT, "NFS: using auth flavor %u\n", args->auth_flavors[0]);
+		dfprintk(MOUNT, "NFS: using auth flavor %u\n",
+			 args->selected_flavor);
 		if (status)
 			return ERR_PTR(status);
 		return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
@@ -1769,7 +1764,7 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 			/* Fallthrough */
 		}
 		dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", flavor);
-		nfs_set_auth_parsed_mount_data(args, flavor);
+		args->selected_flavor = flavor;
 		server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
 		if (!IS_ERR(server))
 			return server;
@@ -1785,7 +1780,7 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 
 	/* Last chance! Try AUTH_UNIX */
 	dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", RPC_AUTH_UNIX);
-	nfs_set_auth_parsed_mount_data(args, RPC_AUTH_UNIX);
+	args->selected_flavor = RPC_AUTH_UNIX;
 	return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
 }
 
@@ -1972,9 +1967,9 @@ static int nfs23_validate_mount_data(void *options,
 		args->bsize		= data->bsize;
 
 		if (data->flags & NFS_MOUNT_SECFLAVOUR)
-			nfs_set_auth_parsed_mount_data(args, data->pseudoflavor);
+			args->selected_flavor = data->pseudoflavor;
 		else
-			nfs_set_auth_parsed_mount_data(args, RPC_AUTH_UNIX);
+			args->selected_flavor = RPC_AUTH_UNIX;
 		if (!args->nfs_server.hostname)
 			goto out_nomem;
 
@@ -2108,7 +2103,7 @@ static int nfs_validate_text_mount_data(void *options,
 
 	nfs_set_port(sap, &args->nfs_server.port, port);
 
-	if (args->auth_flavor_len > 1)
+	if (args->auth_info.flavor_len > 1)
 		goto out_bad_auth;
 
 	return nfs_parse_devname(dev_name,
@@ -2144,7 +2139,7 @@ nfs_compare_remount_data(struct nfs_server *nfss,
 	    data->rsize != nfss->rsize ||
 	    data->wsize != nfss->wsize ||
 	    data->retrans != nfss->client->cl_timeout->to_retries ||
-	    data->auth_flavors[0] != nfss->client->cl_auth->au_flavor ||
+	    data->selected_flavor != nfss->client->cl_auth->au_flavor ||
 	    data->acregmin != nfss->acregmin / HZ ||
 	    data->acregmax != nfss->acregmax / HZ ||
 	    data->acdirmin != nfss->acdirmin / HZ ||
@@ -2189,7 +2184,9 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	data->rsize = nfss->rsize;
 	data->wsize = nfss->wsize;
 	data->retrans = nfss->client->cl_timeout->to_retries;
-	nfs_set_auth_parsed_mount_data(data, nfss->client->cl_auth->au_flavor);
+	data->selected_flavor = nfss->client->cl_auth->au_flavor;
+	data->auth_info.flavors[0] = nfss->client->cl_auth->au_flavor;
+	data->auth_info.flavor_len = 1;
 	data->acregmin = nfss->acregmin / HZ;
 	data->acregmax = nfss->acregmax / HZ;
 	data->acdirmin = nfss->acdirmin / HZ;
@@ -2713,9 +2710,9 @@ static int nfs4_validate_mount_data(void *options,
 					   data->auth_flavours,
 					   sizeof(pseudoflavor)))
 				return -EFAULT;
-			nfs_set_auth_parsed_mount_data(args, pseudoflavor);
+			args->selected_flavor = pseudoflavor;
 		} else
-			nfs_set_auth_parsed_mount_data(args, RPC_AUTH_UNIX);
+			args->selected_flavor = RPC_AUTH_UNIX;
 
 		c = strndup_user(data->hostname.data, NFS4_MAXNAMLEN);
 		if (IS_ERR(c))
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 49f52c8..305263a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -591,6 +591,12 @@ struct nfs_renameres {
 	struct nfs_fattr		*new_fattr;
 };
 
+/* parsed sec= options */
+struct nfs_auth_info {
+	unsigned int            flavor_len;
+	rpc_authflavor_t        flavors[1];
+};
+
 /*
  * Argument struct for decode_entry function
  */
-- 
1.7.12.4 (Apple Git-37)

