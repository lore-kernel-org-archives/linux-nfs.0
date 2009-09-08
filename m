From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] NFS: Change default behavior when "sec=" is not specified
	by user
Date: Tue, 08 Sep 2009 18:36:31 -0400
Message-ID: <20090908223631.23375.202.stgit@matisse.1015granger.net>
References: <20090908223433.23375.40342.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:53243
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752175AbZIHWgg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2009 18:36:36 -0400
In-Reply-To: <20090908223433.23375.40342.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the kernel's MNT client always uses AUTH_UNIX if no "sec="
mount option was specified.  In the interest of conforming more
closely to RFC 2623, use the first flavor on the server's returned
authflavor list instead of AUTH_UNIX, if "sec=" was not specified.

When the user does _not_ specify "sec=" :

 o  For NFSv2 and NFSv4: the default is always AUTH_UNIX (unchanged).

 o  For NFSv3: if the server does not return an auth flavor list, use
    AUTH_UNIX by default; if the server does return a list, use the
    first entry on the list supported by the client.

See http://marc.info/?t=125075305400001&r=1&w=2

 and

http://marc.info/?l=linux-nfs&m=125089022306281&w=2 .

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c                  |  100 ++++++++++++++++++++++++++++-----------
 include/linux/sunrpc/msg_prot.h |    2 +
 2 files changed, 74 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index bde444b..2cd7b22 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1363,48 +1363,72 @@ out_security_failure:
 }
 
 /*
- * Match the requested auth flavors with the list returned by
- * the server.  Returns zero and sets the mount's authentication
- * flavor on success; returns -EACCES if server does not support
- * the requested flavor.
+ * User did not request a security flavor: pick one we support
  */
-static int nfs_walk_authlist(struct nfs_parsed_mount_data *args,
-			     struct nfs_mount_request *request)
+static int nfs_walk_authlist_unspec(struct nfs_parsed_mount_data *args,
+				    struct nfs_mount_request *request)
 {
-	unsigned int i, j, server_authlist_len = *(request->auth_flav_len);
+	unsigned int i, server_authlist_len = *(request->auth_flav_len);
 
 	/*
 	 * Certain releases of Linux's mountd return an empty
 	 * flavor list.  To prevent behavioral regression with
 	 * these servers (ie. rejecting mounts that used to
-	 * succeed), revert to pre-2.6.32 behavior (no checking)
-	 * if the returned flavor list is empty.
+	 * succeed), revert to pre-2.6.32 behavior (select
+	 * AUTH_UNIX).
 	 */
-	if (server_authlist_len == 0)
+	if (server_authlist_len == 0) {
+		args->auth_flavors[0] = RPC_AUTH_UNIX;
 		return 0;
+	}
 
 	/*
-	 * We avoid sophisticated negotiating here, as there are
-	 * plenty of cases where we can get it wrong, providing
-	 * either too little or too much security.
+	 * See RFC 2623, section 2.7.
 	 *
-	 * RFC 2623, section 2.7 suggests we SHOULD prefer the
-	 * flavor listed first.  However, some servers list
-	 * AUTH_NULL first.  Our caller plants AUTH_SYS, the
-	 * preferred default, in args->auth_flavors[0] if user
-	 * didn't specify sec= mount option.
+	 * Exception: some older servers don't properly sort their
+	 * flavor list, and return AUTH_NULL first.  To prevent a
+	 * client upgrade suddenly causing unexpected permission
+	 * and file ownership problems with these servers, avoid
+	 * selecting AUTH_NULL by default.
 	 */
+	for (i = 0; i < server_authlist_len; i++) {
+		if (args->auth_flavors[i] == RPC_AUTH_NULL &&
+		    server_authlist_len > 1)
+			continue;
+		if (rpcauth_is_supported(args->auth_flavors[i])) {
+			args->auth_flavors[0] = request->auth_flavs[i];
+			return 0;
+		}
+	}
+
+	return -EACCES;
+}
+
+/*
+ * User requested a specific security flavor: check it against the
+ * returned list.
+ */
+static int nfs_walk_authlist_spec(struct nfs_parsed_mount_data *args,
+				  struct nfs_mount_request *request)
+{
+	unsigned int i, j, server_authlist_len = *(request->auth_flav_len);
+
+	/*
+	 * Certain releases of Linux's mountd return an empty
+	 * flavor list.  To prevent behavioral regression with
+	 * these servers (ie. rejecting mounts that used to
+	 * succeed), revert to pre-2.6.32 behavior (no checking).
+	 */
+	if (server_authlist_len == 0)
+		return 0;
+
 	for (i = 0; i < args->auth_flavor_len; i++)
 		for (j = 0; j < server_authlist_len; j++)
 			if (args->auth_flavors[i] == request->auth_flavs[j]) {
-				dfprintk(MOUNT, "NFS: using auth flavor %d\n",
-					request->auth_flavs[j]);
 				args->auth_flavors[0] = request->auth_flavs[j];
 				return 0;
 			}
 
-	dfprintk(MOUNT, "NFS: server does not support requested auth flavor\n");
-	nfs_umount(request);
 	return -EACCES;
 }
 
@@ -1465,11 +1489,27 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	}
 
 	/*
-	 * MNTv1 (NFSv2) does not support auth flavor negotiation.
+	 * Verify the authentication flavor for this mount.
 	 */
-	if (args->mount_server.version != NFS_MNT3_VERSION)
-		return 0;
-	return nfs_walk_authlist(args, &request);
+	if (args->mount_server.version == NFS_MNT_VERSION) {
+		status = 0;
+		if (args->auth_flavors[0] == RPC_AUTH_UNSPEC)
+			args->auth_flavors[0] = RPC_AUTH_UNIX;
+	} else {
+		if (args->auth_flavors[0] == RPC_AUTH_UNSPEC)
+			status = nfs_walk_authlist_unspec(args, &request);
+		else
+			status = nfs_walk_authlist_spec(args, &request);
+	}
+
+	if (status) {
+		dfprintk(MOUNT,
+			"NFS: server does not support requested auth flavor\n");
+		nfs_umount(&request);
+	} else
+		dfprintk(MOUNT, "NFS: MNT succeeded, using flavor %u\n",
+				args->auth_flavors[0]);
+	return status;
 }
 
 static int nfs_parse_simple_hostname(const char *dev_name,
@@ -1644,7 +1684,7 @@ static int nfs_validate_mount_data(void *options,
 	args->mount_server.port	= NFS_UNSPEC_PORT;
 	args->nfs_server.port	= NFS_UNSPEC_PORT;
 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-	args->auth_flavors[0]	= RPC_AUTH_UNIX;
+	args->auth_flavors[0]	= RPC_AUTH_UNSPEC;
 	args->auth_flavor_len	= 1;
 	args->minorversion	= 0;
 
@@ -1703,6 +1743,7 @@ static int nfs_validate_mount_data(void *options,
 		args->namlen		= data->namlen;
 		args->bsize		= data->bsize;
 
+		args->auth_flavors[0] = RPC_AUTH_UNIX;
 		if (data->flags & NFS_MOUNT_SECFLAVOUR)
 			args->auth_flavors[0] = data->pseudoflavor;
 		if (!args->nfs_server.hostname)
@@ -2323,6 +2364,8 @@ static int nfs4_validate_text_mount_data(void *options,
 			 "NFS4: Too many RPC auth flavours specified\n");
 		return -EINVAL;
 	}
+	if (args->auth_flavors[0] == RPC_AUTH_UNSPEC)
+		args->auth_flavors[0] = RPC_AUTH_UNIX;
 
 	if (args->client_address == NULL) {
 		dfprintk(MOUNT,
@@ -2358,7 +2401,7 @@ static int nfs4_validate_mount_data(void *options,
 	args->acdirmin		= NFS_DEF_ACDIRMIN;
 	args->acdirmax		= NFS_DEF_ACDIRMAX;
 	args->nfs_server.port	= NFS_UNSPEC_PORT;
-	args->auth_flavors[0]	= RPC_AUTH_UNIX;
+	args->auth_flavors[0]	= RPC_AUTH_UNSPEC;
 	args->auth_flavor_len	= 1;
 	args->minorversion	= 0;
 
@@ -2374,6 +2417,7 @@ static int nfs4_validate_mount_data(void *options,
 		if (!nfs_verify_server_address(sap))
 			goto out_no_address;
 
+		args->auth_flavors[0] = RPC_AUTH_UNIX;
 		if (data->auth_flavourlen) {
 			if (data->auth_flavourlen > 1)
 				goto out_inval_auth;
diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index 77e6248..7d6d3ed 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -35,6 +35,8 @@ enum rpc_auth_flavors {
 	RPC_AUTH_GSS_SPKM  = 390009,
 	RPC_AUTH_GSS_SPKMI = 390010,
 	RPC_AUTH_GSS_SPKMP = 390011,
+	/* flavor was unspecified: */
+	RPC_AUTH_UNSPEC = 0xffffffff,
 };
 
 /* Maximum size (in bytes) of an rpc credential or verifier */

