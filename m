From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] NFS: Save the value of the "port=" mount option
Date: Thu, 31 Jan 2008 15:00:35 -0500
Message-ID: <20080131200035.17975.34577.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: miklos@szeredi.hu, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:53593 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759107AbYAaUAw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jan 2008 15:00:52 -0500
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
index 685c43f..2fed191 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -684,6 +684,8 @@ static int nfs_init_server(struct nfs_server *server,
 	if (error < 0)
 		goto error;
 
+	server->port = data->nfs_server.port;
+
 	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
 	if (error < 0)
 		goto error;
@@ -1066,6 +1068,8 @@ static int nfs4_init_server(struct nfs_server *server,
 	server->acdirmin = data->acdirmin * HZ;
 	server->acdirmax = data->acdirmax * HZ;
 
+	server->port = data->nfs_server.port;
+
 	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
 
 error:
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 4769ed6..fbe5ba4 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -55,6 +55,7 @@ struct nfs_parsed_mount_data {
 		size_t			addrlen;
 		char			*hostname;
 		char			*export_path;
+		unsigned short		port;
 		unsigned short		protocol;
 	} nfs_server;
 };
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 93ce01f..3fd04d2 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -682,7 +682,6 @@ static int nfs_parse_mount_options(char *raw,
 				   struct nfs_parsed_mount_data *mnt)
 {
 	char *p, *string;
-	unsigned short port = 0;
 
 	if (!raw) {
 		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
@@ -785,7 +784,7 @@ static int nfs_parse_mount_options(char *raw,
 				return 0;
 			if (option < 0 || option > 65535)
 				return 0;
-			port = option;
+			mnt->nfs_server.port = option;
 			break;
 		case Opt_rsize:
 			if (match_int(args, &mnt->rsize))
@@ -1035,7 +1034,8 @@ static int nfs_parse_mount_options(char *raw,
 		}
 	}
 
-	nfs_set_port((struct sockaddr *)&mnt->nfs_server.address, port);
+	nfs_set_port((struct sockaddr *)&mnt->nfs_server.address,
+				mnt->nfs_server.port);
 
 	return 1;
 
@@ -1153,7 +1153,9 @@ static int nfs_validate_mount_data(void *options,
 	args->acregmax		= 60;
 	args->acdirmin		= 30;
 	args->acdirmax		= 60;
+	args->mount_server.port	= 0;	/* autobind unless user sets port */
 	args->mount_server.protocol = XPRT_TRANSPORT_UDP;
+	args->nfs_server.port	= 0;	/* autobind unless user sets port */
 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 
 	switch (data->version) {
@@ -1651,28 +1653,6 @@ static void nfs4_fill_super(struct super_block *sb)
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
@@ -1696,6 +1676,7 @@ static int nfs4_validate_mount_data(void *options,
 	args->acregmax		= 60;
 	args->acdirmin		= 30;
 	args->acdirmax		= 60;
+	args->nfs_server.port	= NFS_PORT; /* 2049 unless user set port= */
 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 
 	switch (data->version) {
@@ -1712,9 +1693,6 @@ static int nfs4_validate_mount_data(void *options,
 						&args->nfs_server.address))
 			goto out_no_address;
 
-		nfs4_default_port((struct sockaddr *)
-				  &args->nfs_server.address);
-
 		switch (data->auth_flavourlen) {
 		case 0:
 			args->auth_flavors[0] = RPC_AUTH_UNIX;
@@ -1772,9 +1750,6 @@ static int nfs4_validate_mount_data(void *options,
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

