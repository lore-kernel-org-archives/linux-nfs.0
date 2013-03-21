Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:33214 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918Ab3CUATv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2013 20:19:51 -0400
Received: by mail-ie0-f171.google.com with SMTP id e14so1053452iej.16
        for <linux-nfs@vger.kernel.org>; Wed, 20 Mar 2013 17:19:50 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 3/3] NFS: Use server-recommended security flavor by default
 (NFSv3)
To: linux-nfs@vger.kernel.org
Date: Wed, 20 Mar 2013 20:19:49 -0400
Message-ID: <20130321001949.12106.16804.stgit@seurat.1015granger.net>
In-Reply-To: <20130321001753.12106.50688.stgit@seurat.1015granger.net>
References: <20130321001753.12106.50688.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit ec88f28d in 2009, checking if the user-specified flavor
is in the server's flavor list has been the source of a few
noticeable regressions (now fixed), but there is one that is still
vexing.

An NFS server can list AUTH_NULL in its flavor list, which suggests
a client should try to mount the server with the flavor of the
client's choice, but the server will squash all accesses.  In some
cases, our client fails to mount a server because of this check,
when the mount could have proceeded successfully.

Skip this check if the user has specified "sec=" on the mount
command line.  But do consult the server-provided flavor list to
choose a security flavor if no sec= option is specified on the mount
command.

If a server lists Kerberos pseudoflavors before "sys" in its export
options, our client now chooses Kerberos over AUTH_UNIX for mount
points, when no security flavor is specified by the mount command.
This could be surprising to some administrators or users, who would
then need to have Kerberos credentials to access the export.

Or, a client administrator may not have enabled rpc.gssd.  In this
case, auth_rpcgss.ko might still be loadable, which is enough for
the new logic to choose Kerberos over AUTH_UNIX.  But the mount
would fail since no GSS context can be created without rpc.gssd
running.

To retain the use of AUTH_UNIX by default:

  o  The server administrator can ensure that "sys" is listed before
     Kerberos flavors in its export security options (see
     exports(5)),

  o  The client administrator can explicitly specify "sec=sys" on
     its mount command line (see nfs(5)),

  o  The client administrator can use "Sec=sys" in an appropriate
     section of /etc/nfsmount.conf (see nfsmount.conf(5)), or

  o  The client administrator can blacklist auth_rpcgss.ko.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4super.c |    2 +
 fs/nfs/super.c     |   80 +++++++++++++++++++++++++++-------------------------
 2 files changed, 44 insertions(+), 38 deletions(-)

diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 569b166..a175dad 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -252,6 +252,8 @@ struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 
 	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
 
+	if (data->arg_flavors[0] == RPC_AUTH_MAXFLAVOR)
+		data->arg_flavors[0] = RPC_AUTH_UNIX;
 	export_path = data->nfs_server.export_path;
 	data->nfs_server.export_path = "/";
 	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, mount_info,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 95cdcb2..cc858f6 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -919,7 +919,7 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
 		data->mount_server.port	= NFS_UNSPEC_PORT;
 		data->nfs_server.port	= NFS_UNSPEC_PORT;
 		data->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-		data->auth_flavors[0]	= RPC_AUTH_UNIX;
+		data->auth_flavors[0]	= RPC_AUTH_MAXFLAVOR;
 		data->auth_flavor_len	= 1;
 		data->minorversion	= 0;
 		data->need_mount	= true;
@@ -1607,49 +1607,57 @@ out_security_failure:
 }
 
 /*
- * Match the requested auth flavors with the list returned by
- * the server.  Returns zero and sets the mount's authentication
- * flavor on success; returns -EACCES if server does not support
- * the requested flavor.
+ * Select a security flavor for this mount.  The selected flavor
+ * is planted in args->auth_flavors[0].
  */
-static int nfs_walk_authlist(struct nfs_parsed_mount_data *args,
-			     struct nfs_mount_request *request)
+static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
+			      struct nfs_mount_request *request)
 {
-	unsigned int i, j, server_authlist_len = *(request->auth_flav_len);
+	unsigned int i, count = *(request->auth_flav_len);
+	rpc_authflavor_t flavor;
+
+	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR)
+		goto out;
+
+	/*
+	 * The NFSv2 MNT operation does not return a flavor list.
+	 */
+	if (args->mount_server.version != NFS_MNT3_VERSION)
+		goto out_default;
 
 	/*
 	 * Certain releases of Linux's mountd return an empty
-	 * flavor list.  To prevent behavioral regression with
-	 * these servers (ie. rejecting mounts that used to
-	 * succeed), revert to pre-2.6.32 behavior (no checking)
-	 * if the returned flavor list is empty.
+	 * flavor list in some cases.
 	 */
-	if (server_authlist_len == 0)
-		return 0;
+	if (count == 0)
+		goto out_default;
 
 	/*
-	 * We avoid sophisticated negotiating here, as there are
-	 * plenty of cases where we can get it wrong, providing
-	 * either too little or too much security.
-	 *
 	 * RFC 2623, section 2.7 suggests we SHOULD prefer the
 	 * flavor listed first.  However, some servers list
-	 * AUTH_NULL first.  Our caller plants AUTH_SYS, the
-	 * preferred default, in args->auth_flavors[0] if user
-	 * didn't specify sec= mount option.
+	 * AUTH_NULL first.  Avoid ever choosing AUTH_NULL.
 	 */
-	for (i = 0; i < args->auth_flavor_len; i++)
-		for (j = 0; j < server_authlist_len; j++)
-			if (args->auth_flavors[i] == request->auth_flavs[j]) {
-				dfprintk(MOUNT, "NFS: using auth flavor %d\n",
-					request->auth_flavs[j]);
-				args->auth_flavors[0] = request->auth_flavs[j];
-				return 0;
-			}
+	for (i = 0; i < count; i++) {
+		struct rpcsec_gss_info info;
+
+		flavor = request->auth_flavs[i];
+		switch (flavor) {
+		case RPC_AUTH_UNIX:
+			goto out_set;
+		case RPC_AUTH_NULL:
+			continue;
+		default:
+			if (rpcauth_get_gssinfo(flavor, &info) == 0)
+				goto out_set;
+		}
+	}
 
-	dfprintk(MOUNT, "NFS: server does not support requested auth flavor\n");
-	nfs_umount(request);
-	return -EACCES;
+out_default:
+	flavor = RPC_AUTH_UNIX;
+out_set:
+	args->auth_flavors[0] = flavor;
+out:
+	dfprintk(MOUNT, "NFS: using auth flavor %d\n", args->auth_flavors[0]);
 }
 
 /*
@@ -1712,12 +1720,8 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
 		return status;
 	}
 
-	/*
-	 * MNTv1 (NFSv2) does not support auth flavor negotiation.
-	 */
-	if (args->mount_server.version != NFS_MNT3_VERSION)
-		return 0;
-	return nfs_walk_authlist(args, &request);
+	nfs_select_flavor(args, &request);
+	return 0;
 }
 
 struct dentry *nfs_try_mount(int flags, const char *dev_name,

