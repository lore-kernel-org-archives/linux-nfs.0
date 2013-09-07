Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:11907 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819Ab3IGXSS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Sep 2013 19:18:18 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/6] NFS: Clean up the auth flavour array mess
Date: Sat, 7 Sep 2013 19:18:08 -0400
Message-ID: <1378595893-60395-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378595893-60395-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1378595893-60395-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

What is the point of having a 'auth_flavor_len' field, if it is
always set to 1, and can't be used to determine if the user has
selected an auth flavour?
This cleanup goes back to using auth_flavor_len for its original
intended purpose, and gets rid of the ad-hoc replacements.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4super.c |  4 +++-
 fs/nfs/super.c     | 37 +++++++++++++++++++++++++------------
 2 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 5dbe2d2..4ad837c 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -253,8 +253,10 @@ struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 
 	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
 
-	if (data->auth_flavors[0] == RPC_AUTH_MAXFLAVOR)
+	if (data->auth_flavor_len < 1) {
 		data->auth_flavors[0] = RPC_AUTH_UNIX;
+		data->auth_flavor_len = 1;
+	}
 	export_path = data->nfs_server.export_path;
 	data->nfs_server.export_path = "/";
 	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, mount_info,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6ad9053..5d16ee3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -923,7 +923,7 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
 		data->nfs_server.port	= NFS_UNSPEC_PORT;
 		data->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 		data->auth_flavors[0]	= RPC_AUTH_MAXFLAVOR;
-		data->auth_flavor_len	= 1;
+		data->auth_flavor_len	= 0;
 		data->minorversion	= 0;
 		data->need_mount	= true;
 		data->net		= current->nsproxy->net_ns;
@@ -1018,6 +1018,13 @@ static void nfs_set_mount_transport_protocol(struct nfs_parsed_mount_data *mnt)
 	}
 }
 
+static void nfs_set_auth_parsed_mount_data(struct nfs_parsed_mount_data *data,
+		rpc_authflavor_t pseudoflavor)
+{
+	data->auth_flavors[0] = pseudoflavor;
+	data->auth_flavor_len = 1;
+}
+
 /*
  * Parse the value of the 'sec=' option.
  */
@@ -1729,7 +1736,7 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 	 * Was a sec= authflavor specified in the options? First, verify
 	 * whether the server supports it, and then just try to use it if so.
 	 */
-	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR) {
+	if (args->auth_flavor_len > 0) {
 		status = nfs_verify_authflavor(args, authlist, authlist_len);
 		dfprintk(MOUNT, "NFS: using auth flavor %u\n", args->auth_flavors[0]);
 		if (status)
@@ -1760,7 +1767,7 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 			/* Fallthrough */
 		}
 		dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", flavor);
-		args->auth_flavors[0] = flavor;
+		nfs_set_auth_parsed_mount_data(args, flavor);
 		server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
 		if (!IS_ERR(server))
 			return server;
@@ -1776,7 +1783,7 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 
 	/* Last chance! Try AUTH_UNIX */
 	dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", RPC_AUTH_UNIX);
-	args->auth_flavors[0] = RPC_AUTH_UNIX;
+	nfs_set_auth_parsed_mount_data(args, RPC_AUTH_UNIX);
 	return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
 }
 
@@ -1893,6 +1900,7 @@ static int nfs23_validate_mount_data(void *options,
 {
 	struct nfs_mount_data *data = (struct nfs_mount_data *)options;
 	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
+	int extra_flags = NFS_MOUNT_LEGACY_INTERFACE;
 
 	if (data == NULL)
 		goto out_no_data;
@@ -1908,6 +1916,8 @@ static int nfs23_validate_mount_data(void *options,
 			goto out_no_v3;
 		data->root.size = NFS2_FHSIZE;
 		memcpy(data->root.data, data->old_root.data, NFS2_FHSIZE);
+		/* Turn off security negotiation */
+		extra_flags |= NFS_MOUNT_SECFLAVOUR;
 	case 4:
 		if (data->flags & NFS_MOUNT_SECFLAVOUR)
 			goto out_no_sec;
@@ -1935,7 +1945,7 @@ static int nfs23_validate_mount_data(void *options,
 		 * can deal with.
 		 */
 		args->flags		= data->flags & NFS_MOUNT_FLAGMASK;
-		args->flags		|= NFS_MOUNT_LEGACY_INTERFACE;
+		args->flags		|= extra_flags;
 		args->rsize		= data->rsize;
 		args->wsize		= data->wsize;
 		args->timeo		= data->timeo;
@@ -1959,9 +1969,10 @@ static int nfs23_validate_mount_data(void *options,
 		args->namlen		= data->namlen;
 		args->bsize		= data->bsize;
 
-		args->auth_flavors[0] = RPC_AUTH_UNIX;
 		if (data->flags & NFS_MOUNT_SECFLAVOUR)
-			args->auth_flavors[0] = data->pseudoflavor;
+			nfs_set_auth_parsed_mount_data(args, data->pseudoflavor);
+		else
+			nfs_set_auth_parsed_mount_data(args, RPC_AUTH_UNIX);
 		if (!args->nfs_server.hostname)
 			goto out_nomem;
 
@@ -2176,7 +2187,7 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	data->rsize = nfss->rsize;
 	data->wsize = nfss->wsize;
 	data->retrans = nfss->client->cl_timeout->to_retries;
-	data->auth_flavors[0] = nfss->client->cl_auth->au_flavor;
+	nfs_set_auth_parsed_mount_data(data, nfss->client->cl_auth->au_flavor);
 	data->acregmin = nfss->acregmin / HZ;
 	data->acregmax = nfss->acregmax / HZ;
 	data->acdirmin = nfss->acdirmin / HZ;
@@ -2675,15 +2686,17 @@ static int nfs4_validate_mount_data(void *options,
 			goto out_no_address;
 		args->nfs_server.port = ntohs(((struct sockaddr_in *)sap)->sin_port);
 
-		args->auth_flavors[0] = RPC_AUTH_UNIX;
 		if (data->auth_flavourlen) {
+			rpc_authflavor_t pseudoflavor;
 			if (data->auth_flavourlen > 1)
 				goto out_inval_auth;
-			if (copy_from_user(&args->auth_flavors[0],
+			if (copy_from_user(&pseudoflavor,
 					   data->auth_flavours,
-					   sizeof(args->auth_flavors[0])))
+					   sizeof(pseudoflavor)))
 				return -EFAULT;
-		}
+			nfs_set_auth_parsed_mount_data(args, pseudoflavor);
+		} else
+			nfs_set_auth_parsed_mount_data(args, RPC_AUTH_UNIX);
 
 		c = strndup_user(data->hostname.data, NFS4_MAXNAMLEN);
 		if (IS_ERR(c))
-- 
1.8.3.1

