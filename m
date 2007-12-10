From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 26/27] NFS: Support non-IPv4 addresses in nfs_parsed_mount_data
Date: Mon, 10 Dec 2007 14:59:28 -0500
Message-ID: <20071210195928.2823.99007.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:10599 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbXLJUUb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:20:31 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the nfs_server and mount_server address fields in the
nfs_parsed_mount_data structure with a "struct sockaddr_storage"
instead of a "struct sockaddr_in".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/client.c   |    4 ++--
 fs/nfs/internal.h |    6 ++++--
 fs/nfs/super.c    |   54 +++++++++++++++++++++++++++++++++--------------------
 3 files changed, 40 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5406410..8652e5e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -585,7 +585,7 @@ static int nfs_init_server(struct nfs_server *server,
 	/* Allocate or find a client reference we can use */
 	clp = nfs_get_client(data->nfs_server.hostname,
 			     (struct sockaddr *)&data->nfs_server.address,
-			     sizeof(data->nfs_server.address),
+			     data->nfs_server.addrlen,
 			     nfsvers);
 	if (IS_ERR(clp)) {
 		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
@@ -997,7 +997,7 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	error = nfs4_set_client(server,
 			data->nfs_server.hostname,
 			(struct sockaddr *)&data->nfs_server.address,
-			sizeof(data->nfs_server.address),
+			data->nfs_server.addrlen,
 			data->client_address,
 			data->auth_flavors[0],
 			data->nfs_server.protocol,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b54ed13..2e226d2 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -42,7 +42,8 @@ struct nfs_parsed_mount_data {
 	char			*client_address;
 
 	struct {
-		struct sockaddr_in	address;
+		struct sockaddr_storage	address;
+		size_t			addrlen;
 		char			*hostname;
 		unsigned int		version;
 		unsigned short		port;
@@ -50,7 +51,8 @@ struct nfs_parsed_mount_data {
 	} mount_server;
 
 	struct {
-		struct sockaddr_in	address;
+		struct sockaddr_storage	address;
+		size_t			addrlen;
 		char			*hostname;
 		char			*export_path;
 		int			protocol;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index bf98b8f..379841e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -625,15 +625,18 @@ static int nfs_verify_server_address(struct sockaddr *addr)
  * to punt the mount.
  */
 static void nfs_parse_server_address(char *value,
-				     struct sockaddr *sap)
+				     struct sockaddr *sap,
+				     size_t *len)
 {
 	struct sockaddr_in *ap = (void *)sap;
 
 	ap->sin_family = AF_INET;
+	*len = sizeof(*ap);
 	if (in4_pton(value, -1, (u8 *)&ap->sin_addr.s_addr, '\0', NULL))
 		return;
 
 	sap->sa_family = AF_UNSPEC;
+	*len = 0;
 }
 
 /*
@@ -960,7 +963,8 @@ static int nfs_parse_mount_options(char *raw,
 			if (string == NULL)
 				goto out_nomem;
 			nfs_parse_server_address(string, (struct sockaddr *)
-						 &mnt->nfs_server.address);
+						 &mnt->nfs_server.address,
+						 &mnt->nfs_server.addrlen);
 			kfree(string);
 			break;
 		case Opt_clientaddr:
@@ -980,7 +984,8 @@ static int nfs_parse_mount_options(char *raw,
 			if (string == NULL)
 				goto out_nomem;
 			nfs_parse_server_address(string, (struct sockaddr *)
-						 &mnt->mount_server.address);
+						 &mnt->mount_server.address,
+						 &mnt->mount_server.addrlen);
 			kfree(string);
 			break;
 
@@ -1025,9 +1030,9 @@ out_unknown:
 static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 			 struct nfs_fh *root_fh)
 {
-	struct sockaddr_in sin;
-	int status;
+	struct sockaddr *sap = (struct sockaddr *)&args->mount_server.address;
 	char *hostname;
+	int status;
 
 	if (args->mount_server.version == 0) {
 		if (args->flags & NFS_MOUNT_VER3)
@@ -1044,21 +1049,23 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	/*
 	 * Construct the mount server's address.
 	 */
-	if (args->mount_server.address.sin_addr.s_addr != INADDR_ANY)
-		sin = args->mount_server.address;
-	else
-		sin = args->nfs_server.address;
+	if (args->mount_server.address.ss_family == AF_UNSPEC) {
+		memcpy(sap, &args->nfs_server.address,
+		       args->nfs_server.addrlen);
+		args->mount_server.addrlen = args->nfs_server.addrlen;
+	}
+
 	/*
 	 * autobind will be used if mount_server.port == 0
 	 */
-	nfs_set_port((struct sockaddr *)&sin, args->mount_server.port);
+	nfs_set_port(sap, args->mount_server.port);
 
 	/*
 	 * Now ask the mount server to map our export path
 	 * to a file handle.
 	 */
-	status = nfs_mount((struct sockaddr *) &sin,
-			   sizeof(sin),
+	status = nfs_mount(sap,
+			   args->mount_server.addrlen,
 			   hostname,
 			   args->nfs_server.export_path,
 			   args->mount_server.version,
@@ -1141,9 +1148,6 @@ static int nfs_validate_mount_data(void *options,
 			memset(mntfh->data + mntfh->size, 0,
 			       sizeof(mntfh->data) - mntfh->size);
 
-		if (!nfs_verify_server_address((struct sockaddr *) &data->addr))
-			goto out_no_address;
-
 		/*
 		 * Translate to nfs_parsed_mount_data, which nfs_fill_super
 		 * can deal with.
@@ -1158,7 +1162,14 @@ static int nfs_validate_mount_data(void *options,
 		args->acregmax		= data->acregmax;
 		args->acdirmin		= data->acdirmin;
 		args->acdirmax		= data->acdirmax;
-		args->nfs_server.address = data->addr;
+
+		memcpy(&args->nfs_server.address, &data->addr,
+		       sizeof(data->addr));
+		args->nfs_server.addrlen = sizeof(data->addr);
+		if (!nfs_verify_server_address((struct sockaddr *)
+						&args->nfs_server.address))
+			goto out_no_address;
+
 		if (!(data->flags & NFS_MOUNT_TCP))
 			args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 		/* N.B. caller will free nfs_server.hostname in all cases */
@@ -1631,6 +1642,7 @@ static int nfs4_validate_mount_data(void *options,
 				    struct nfs_parsed_mount_data *args,
 				    const char *dev_name)
 {
+	struct sockaddr_in *ap;
 	struct nfs4_mount_data *data = (struct nfs4_mount_data *)options;
 	char *c;
 
@@ -1651,11 +1663,13 @@ static int nfs4_validate_mount_data(void *options,
 
 	switch (data->version) {
 	case 1:
-		if (data->host_addrlen != sizeof(args->nfs_server.address))
+		ap = (struct sockaddr_in *)&args->nfs_server.address;
+		if (data->host_addrlen > sizeof(args->nfs_server.address))
+			goto out_no_address;
+		if (data->host_addrlen == 0)
 			goto out_no_address;
-		if (copy_from_user(&args->nfs_server.address,
-				   data->host_addr,
-				   sizeof(args->nfs_server.address)))
+		args->nfs_server.addrlen = data->host_addrlen;
+		if (copy_from_user(ap, data->host_addr, data->host_addrlen))
 			return -EFAULT;
 		if (!nfs_verify_server_address((struct sockaddr *)
 						&args->nfs_server.address))

