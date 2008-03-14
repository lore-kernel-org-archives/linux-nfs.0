From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] NFS: Save the value of the "port=" mount option
Date: Fri, 14 Mar 2008 14:10:22 -0400
Message-ID: <20080314181022.29830.42874.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:10180 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758586AbYCNSKn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:10:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

During a remount based on the mount options displayed in /proc/mounts, we
want to preserve the original behavior of the mount request.  Let's save
the original setting of the "port=" mount option in the mount's nfs_server
structure.

This allows us to simplify the default behavior of port setting for NFSv4
mounts: by default, NFSv2/3 mounts first try an RPC bind to determine the
NFS server's port, unless the user specified the "port=" mount option;
Users can force the client to skip the RPC bind by explicitly specifying
"port=<value>".

NFSv4, by contrast, assumes the NFS server port is 2049 and skips the RPC
bind, unless the user specifies "port=".  Users can force an RPC bind for
NFSv4 by explicitly specifying "port=0".

I added a couple of extra comments to clarify this behavior.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>
---

 fs/nfs/client.c           |    4 ++++
 fs/nfs/internal.h         |    1 +
 fs/nfs/super.c            |   37 ++++++-------------------------------
 include/linux/nfs_fs_sb.h |    1 +
 4 files changed, 12 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c5c0175..68bd04d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -680,6 +680,8 @@ static int nfs_init_server(struct nfs_server *server,
 	if (error < 0)
 		goto error;
 
+	server->port = data->nfs_server.port;
+
 	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
 	if (error < 0)
 		goto error;
@@ -1062,6 +1064,8 @@ static int nfs4_init_server(struct nfs_server *server,
 	server->acdirmin = data->acdirmin * HZ;
 	server->acdirmax = data->acdirmax * HZ;
 
+	server->port = data->nfs_server.port;
+
 	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
 
 error:
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 6e1b943..50cb5cb 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -56,6 +56,7 @@ struct nfs_parsed_mount_data {
 		size_t			addrlen;
 		char			*hostname;
 		char			*export_path;
+		unsigned short		port;
 		unsigned short		protocol;
 	} nfs_server;
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 53a67c6..3c6f53a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -685,7 +685,6 @@ static int nfs_parse_mount_options(char *raw,
 				   struct nfs_parsed_mount_data *mnt)
 {
 	char *p, *string, *secdata;
-	unsigned short port = 0;
 	int rc;
 
 	if (!raw) {
@@ -800,7 +799,7 @@ static int nfs_parse_mount_options(char *raw,
 				return 0;
 			if (option < 0 || option > 65535)
 				return 0;
-			port = option;
+			mnt->nfs_server.port = option;
 			break;
 		case Opt_rsize:
 			if (match_int(args, &mnt->rsize))
@@ -1050,7 +1049,8 @@ static int nfs_parse_mount_options(char *raw,
 		}
 	}
 
-	nfs_set_port((struct sockaddr *)&mnt->nfs_server.address, port);
+	nfs_set_port((struct sockaddr *)&mnt->nfs_server.address,
+				mnt->nfs_server.port);
 
 	return 1;
 
@@ -1171,7 +1171,9 @@ static int nfs_validate_mount_data(void *options,
 	args->acregmax		= 60;
 	args->acdirmin		= 30;
 	args->acdirmax		= 60;
+	args->mount_server.port	= 0;	/* autobind unless user sets port */
 	args->mount_server.protocol = XPRT_TRANSPORT_UDP;
+	args->nfs_server.port	= 0;	/* autobind unless user sets port */
 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 
 	switch (data->version) {
@@ -1708,28 +1710,6 @@ static void nfs4_fill_super(struct super_block *sb)
 }
 
 /*
- * If the user didn't specify a port, set the port number to
- * the NFS version 4 default port.
- */
-static void nfs4_default_port(struct sockaddr *sap)
-{
-	switch (sap->sa_family) {
-	case AF_INET: {
-		struct sockaddr_in *ap = (struct sockaddr_in *)sap;
-		if (ap->sin_port == 0)
-			ap->sin_port = htons(NFS_PORT);
-		break;
-	}
-	case AF_INET6: {
-		struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
-		if (ap->sin6_port == 0)
-			ap->sin6_port = htons(NFS_PORT);
-		break;
-	}
-	}
-}
-
-/*
  * Validate NFSv4 mount options
  */
 static int nfs4_validate_mount_data(void *options,
@@ -1753,6 +1733,7 @@ static int nfs4_validate_mount_data(void *options,
 	args->acregmax		= 60;
 	args->acdirmin		= 30;
 	args->acdirmax		= 60;
+	args->nfs_server.port	= NFS_PORT; /* 2049 unless user set port= */
 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 
 	switch (data->version) {
@@ -1769,9 +1750,6 @@ static int nfs4_validate_mount_data(void *options,
 						&args->nfs_server.address))
 			goto out_no_address;
 
-		nfs4_default_port((struct sockaddr *)
-				  &args->nfs_server.address);
-
 		switch (data->auth_flavourlen) {
 		case 0:
 			args->auth_flavors[0] = RPC_AUTH_UNIX;
@@ -1829,9 +1807,6 @@ static int nfs4_validate_mount_data(void *options,
 						&args->nfs_server.address))
 			return -EINVAL;
 
-		nfs4_default_port((struct sockaddr *)
-				  &args->nfs_server.address);
-
 		switch (args->auth_flavor_len) {
 		case 0:
 			args->auth_flavors[0] = RPC_AUTH_UNIX;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 3423c67..670e5c7 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -93,6 +93,7 @@ struct nfs_server {
 	unsigned int		wpages;		/* write size (in pages) */
 	unsigned int		wtmult;		/* server disk block size */
 	unsigned int		dtsize;		/* readdir size */
+	unsigned short		port;		/* "port=" setting */
 	unsigned int		bsize;		/* server block size */
 	unsigned int		acregmin;	/* attr cache timeouts */
 	unsigned int		acregmax;

