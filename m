Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:33601 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753258Ab3F0PuS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jun 2013 11:50:18 -0400
Received: by mail-yh0-f46.google.com with SMTP id i57so486949yha.33
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jun 2013 08:50:18 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
        Weston.Adamson@netapp.com
Subject: [PATCH v3 3/3] nfs: have NFSv3 try server-specified auth flavors in turn
Date: Thu, 27 Jun 2013 11:50:07 -0400
Message-Id: <1372348207-26388-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1372348207-26388-1-git-send-email-jlayton@redhat.com>
References: <1372348207-26388-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current scheme is to try and pick the auth flavor that the server
prefers. In some cases though, we may find that we're not actually
able to use that auth flavor later. For instance, the server may
prefer an AUTH_GSS flavor, but we may not be able to get GSSAPI creds.

The current code just gives up at that point. Change it instead to
try the ->create_server call using each of the different authflavors
in the server's list if one was not specified at mount time. Once
we have a successful ->create_server call, return the result. Only
give up and return error if all attempts fail.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c | 150 ++++++++++++++++++++++++++++++---------------------------
 1 file changed, 80 insertions(+), 70 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a0949f5..12ffd7d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1608,29 +1608,13 @@ out_security_failure:
 }
 
 /*
- * Select a security flavor for this mount.  The selected flavor
- * is planted in args->auth_flavors[0].
- *
- * Returns 0 on success, -EACCES on failure.
+ * Ensure that the specified authtype in args->auth_flavors[0] is supported by
+ * the server. Returns 0 if it's ok, and -EACCES if not.
  */
-static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
-			      struct nfs_mount_request *request)
+static int nfs_verify_authflavor(struct nfs_parsed_mount_data *args,
+			rpc_authflavor_t *server_authlist, unsigned int count)
 {
-	unsigned int i, count = *(request->auth_flav_len);
-	rpc_authflavor_t flavor;
-
-	/*
-	 * The NFSv2 MNT operation does not return a flavor list.
-	 */
-	if (args->mount_server.version != NFS_MNT3_VERSION)
-		goto out_default;
-
-	/*
-	 * Certain releases of Linux's mountd return an empty
-	 * flavor list in some cases.
-	 */
-	if (count == 0)
-		goto out_default;
+	unsigned int i;
 
 	/*
 	 * If the sec= mount option is used, the specified flavor or AUTH_NULL
@@ -1640,60 +1624,19 @@ static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
 	 * means that the server will ignore the rpc creds, so any flavor
 	 * can be used.
 	 */
-	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR) {
-		for (i = 0; i < count; i++) {
-			if (args->auth_flavors[0] == request->auth_flavs[i] ||
-			    request->auth_flavs[i] == RPC_AUTH_NULL)
-				goto out;
-		}
-		dfprintk(MOUNT, "NFS: auth flavor %d not supported by server\n",
-			args->auth_flavors[0]);
-		goto out_err;
-	}
-
-	/*
-	 * RFC 2623, section 2.7 suggests we SHOULD prefer the
-	 * flavor listed first.  However, some servers list
-	 * AUTH_NULL first.  Avoid ever choosing AUTH_NULL.
-	 */
 	for (i = 0; i < count; i++) {
-		struct rpcsec_gss_info info;
-
-		flavor = request->auth_flavs[i];
-		switch (flavor) {
-		case RPC_AUTH_UNIX:
-			goto out_set;
-		case RPC_AUTH_NULL:
-			continue;
-		default:
-			if (rpcauth_get_gssinfo(flavor, &info) == 0)
-				goto out_set;
-		}
+		if (args->auth_flavors[0] == server_authlist[i] ||
+		    server_authlist[i] == RPC_AUTH_NULL)
+			goto out;
 	}
 
-	/*
-	 * As a last chance, see if the server list contains AUTH_NULL -
-	 * if it does, use the default flavor.
-	 */
-	for (i = 0; i < count; i++) {
-		if (request->auth_flavs[i] == RPC_AUTH_NULL)
-			goto out_default;
-	}
-
-	dfprintk(MOUNT, "NFS: no auth flavors in common with server\n");
-	goto out_err;
+	dfprintk(MOUNT, "NFS: auth flavor %u not supported by server\n",
+		args->auth_flavors[0]);
+	return -EACCES;
 
-out_default:
-	/* use default if flavor not already set */
-	flavor = (args->auth_flavors[0] == RPC_AUTH_MAXFLAVOR) ?
-		RPC_AUTH_UNIX : args->auth_flavors[0];
-out_set:
-	args->auth_flavors[0] = flavor;
 out:
-	dfprintk(MOUNT, "NFS: using auth flavor %d\n", args->auth_flavors[0]);
+	dfprintk(MOUNT, "NFS: using auth flavor %u\n", args->auth_flavors[0]);
 	return 0;
-out_err:
-	return -EACCES;
 }
 
 /*
@@ -1756,13 +1699,17 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
 		return status;
 	}
 
-	return nfs_select_flavor(args, &request);
+	return 0;
 }
 
 static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_info,
 					struct nfs_subversion *nfs_mod)
 {
 	int status;
+	unsigned int i;
+	bool tried_auth_unix = false;
+	bool auth_null_in_list = false;
+	struct nfs_server *server = ERR_PTR(-EACCES);
 	struct nfs_parsed_mount_data *args = mount_info->parsed;
 	rpc_authflavor_t authlist[NFS_MAX_SECFLAVORS];
 	unsigned int authlist_len = ARRAY_SIZE(authlist);
@@ -1772,6 +1719,69 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 	if (status)
 		return ERR_PTR(status);
 
+	/*
+	 * The NFSv2 MNT operation does not return a flavor list. Also, some
+	 * NFS servers (older Linux servers in particular) return an empty list.
+	 *
+	 * In that event fake up a list that just has RPC_AUTH_NULL in it since
+	 * we have no way to know what the server actually supports.
+	 */
+	if (args->mount_server.version != NFS_MNT3_VERSION ||
+	    authlist_len == 0) {
+		authlist[0] = RPC_AUTH_NULL;
+		authlist_len = 1;
+	}
+
+	/*
+	 * Was a sec= authflavor specified in the options? First, verify
+	 * whether the server supports it, and then just try to use it if so.
+	 */
+	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR) {
+		status = nfs_verify_authflavor(args, authlist, authlist_len);
+		dfprintk(MOUNT, "NFS: using auth flavor %u\n", args->auth_flavors[0]);
+		if (status)
+			return ERR_PTR(status);
+		return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
+	}
+
+	/*
+	 * No sec= option was provided. RFC 2623, section 2.7 suggests we
+	 * SHOULD prefer the flavor listed first. However, some servers list
+	 * AUTH_NULL first. Avoid ever choosing AUTH_NULL.
+	 */
+	for (i = 0; i < authlist_len; ++i) {
+		rpc_authflavor_t flavor;
+		struct rpcsec_gss_info info;
+
+		flavor = authlist[i];
+		switch (flavor) {
+		case RPC_AUTH_UNIX:
+			tried_auth_unix = true;
+			break;
+		case RPC_AUTH_NULL:
+			auth_null_in_list = true;
+			continue;
+		default:
+			if (rpcauth_get_gssinfo(flavor, &info) != 0)
+				continue;
+			/* Fallthrough */
+		}
+		dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", flavor);
+		args->auth_flavors[0] = flavor;
+		server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
+		if (!IS_ERR(server))
+			return server;
+	}
+
+	/*
+	 * Nothing we tried so far worked. As a last ditch effort, try to use
+	 * AUTH_UNIX if we haven't already, and AUTH_NULL was in server's list.
+	 */
+	if (tried_auth_unix || !auth_null_in_list)
+		return server;
+
+	dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", RPC_AUTH_UNIX);
+	args->auth_flavors[0] = RPC_AUTH_UNIX;
 	return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
 }
 
-- 
1.8.1.4

