Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f173.google.com ([209.85.214.173]:63040 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467Ab3FZOgK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jun 2013 10:36:10 -0400
Received: by mail-ob0-f173.google.com with SMTP id wc20so13578822obb.18
        for <linux-nfs@vger.kernel.org>; Wed, 26 Jun 2013 07:36:10 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfs: allow NFSv3 to fall back to using AUTH_UNIX automatically if available
Date: Wed, 26 Jun 2013 10:36:03 -0400
Message-Id: <1372257363-28148-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1372257363-28148-1-git-send-email-jlayton@redhat.com>
References: <1372257363-28148-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, when using NFSv3 the mount will fail if the server happens to
have AUTH_GSS flavors in the returned authlist before AUTH_UNIX. This
seems to have been a deliberate change in commit 4580a92 (NFS: Use
server-recommended security flavor by default (NFSv3)).

While the workarounds are fine, I think we can do better here and allow
this to keep "just working". Allow the client to fall back to
automatically trying AUTH_UNIX under if the following are all true:

    - the server return -EACCES from ->create_server call
    - the client had to do a MNT request (i.e. no binary options)
    - we didn't just try to use AUTH_UNIX
    - the admin did not explcitly specify a sec= option

At that point, try to use AUTH_UNIX, if the server listed it.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c | 39 +++++++++++++++++++++++++++++++--------
 1 file changed, 31 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5538bcc..6df327e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1701,10 +1701,10 @@ out_err:
  * corresponding to the provided path.
  */
 static int nfs_request_mount(struct nfs_parsed_mount_data *args,
-			     struct nfs_fh *root_fh)
+			     struct nfs_fh *root_fh,
+			     unsigned int *server_authlist_len,
+			     rpc_authflavor_t *server_authlist)
 {
-	rpc_authflavor_t server_authlist[NFS_MAX_SECFLAVORS];
-	unsigned int server_authlist_len = ARRAY_SIZE(server_authlist);
 	struct nfs_mount_request request = {
 		.sap		= (struct sockaddr *)
 						&args->mount_server.address,
@@ -1712,7 +1712,7 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
 		.protocol	= args->mount_server.protocol,
 		.fh		= root_fh,
 		.noresvport	= args->flags & NFS_MOUNT_NORESVPORT,
-		.auth_flav_len	= &server_authlist_len,
+		.auth_flav_len	= server_authlist_len,
 		.auth_flavs	= server_authlist,
 		.net		= args->net,
 	};
@@ -1756,7 +1756,7 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
 		return status;
 	}
 
-	return nfs_select_flavor(args, server_authlist_len, server_authlist);
+	return 0;
 }
 
 struct dentry *nfs_try_mount(int flags, const char *dev_name,
@@ -1765,17 +1765,40 @@ struct dentry *nfs_try_mount(int flags, const char *dev_name,
 {
 	int status;
 	struct nfs_server *server;
+	struct nfs_parsed_mount_data *args = mount_info->parsed;
+	rpc_authflavor_t requested_authflavor = args->auth_flavors[0];
+	rpc_authflavor_t server_authlist[NFS_MAX_SECFLAVORS];
+	unsigned int server_authlist_len = ARRAY_SIZE(server_authlist);
 
-	if (mount_info->parsed->need_mount) {
-		status = nfs_request_mount(mount_info->parsed, mount_info->mntfh);
+	if (args->need_mount) {
+		status = nfs_request_mount(args, mount_info->mntfh,
+					&server_authlist_len, server_authlist);
+		if (status)
+			return ERR_PTR(status);
+retry:
+		status = nfs_select_flavor(args, server_authlist_len,
+						server_authlist);
 		if (status)
 			return ERR_PTR(status);
 	}
 
 	/* Get a volume representation */
 	server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
-	if (IS_ERR(server))
+	if (IS_ERR(server)) {
+		/*
+		 * If the initial attempt fails with -EACCES, then that likely
+		 * means that we couldn't get proper credentials to talk to the
+		 * server. If an authflavor wasn't specified in the options,
+		 * and we didn't try to use it already, then try AUTH_UNIX.
+		 */
+		if (PTR_ERR(server) == -EACCES && args->need_mount &&
+		    args->auth_flavors[0] != RPC_AUTH_UNIX &&
+		    requested_authflavor == RPC_AUTH_MAXFLAVOR) {
+			args->auth_flavors[0] = RPC_AUTH_UNIX;
+			goto retry;
+		}
 		return ERR_CAST(server);
+	}
 
 	return nfs_fs_mount_common(server, flags, dev_name, mount_info, nfs_mod);
 }
-- 
1.8.1.4

