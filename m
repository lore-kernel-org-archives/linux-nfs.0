From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 076/112] NFS: Support non-IPv4 addresses in
	nfs_parsed_mount_data
Date: Fri, 25 Jan 2008 11:37:50 -0500
Message-ID: <20080125163750.31887.25763.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14348 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755077AbYAYQ7y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:54 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxrZs010219
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:54 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Replace the nfs_server and mount_server address fields in the
nfs_parsed_mount_data structure with a "struct sockaddr_storage"
instead of a "struct sockaddr_in".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c   |    4 ++--
 fs/nfs/internal.h |    6 ++++--
 fs/nfs/super.c    |   54 +++++++++++++++++++++++++++++++++--------------------
 3 files changed, 40 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ba114fa..9066133 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -581,7 +581,7 @@ static int nfs_init_server(struct nfs_server *server,
 	struct nfs_client_initdata cl_init = {
 		.hostname = data->nfs_server.hostname,
 		.addr = (const struct sockaddr *)&data->nfs_server.address,
-		.addrlen = sizeof(data->nfs_server.address),
+		.addrlen = data->nfs_server.addrlen,
 		.rpc_ops = &nfs_v2_clientops,
 	};
 	struct nfs_client *clp;
@@ -1018,7 +1018,7 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	error = nfs4_set_client(server,
 			data->nfs_server.hostname,
 			(struct sockaddr *)&data->nfs_server.address,
-			sizeof(data->nfs_server.address),
+			data->nfs_server.addrlen,
 			data->client_address,
 			data->auth_flavors[0],
 			data->nfs_server.protocol,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 75dd4e2..a806211 100644
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
index 041fe9e..7efc6a3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -649,15 +649,18 @@ static int nfs_verify_server_address(struct sockaddr *addr)
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
@@ -984,7 +987,8 @@ static int nfs_parse_mount_options(char *raw,
 			if (string == NULL)
 				goto out_nomem;
 			nfs_parse_server_address(string, (struct sockaddr *)
-						 &mnt->nfs_server.address);
+						 &mnt->nfs_server.address,
+						 &mnt->nfs_server.addrlen);
 			kfree(string);
 			break;
 		case Opt_clientaddr:
@@ -1004,7 +1008,8 @@ static int nfs_parse_mount_options(char *raw,
 			if (string == NULL)
 				goto out_nomem;
 			nfs_parse_server_address(string, (struct sockaddr *)
-						 &mnt->mount_server.address);
+						 &mnt->mount_server.address,
+						 &mnt->mount_server.addrlen);
 			kfree(string);
 			break;
 
@@ -1049,9 +1054,9 @@ out_unknown:
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
@@ -1068,21 +1073,23 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
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
@@ -1165,9 +1172,6 @@ static int nfs_validate_mount_data(void *options,
 			memset(mntfh->data + mntfh->size, 0,
 			       sizeof(mntfh->data) - mntfh->size);
 
-		if (!nfs_verify_server_address((struct sockaddr *) &data->addr))
-			goto out_no_address;
-
 		/*
 		 * Translate to nfs_parsed_mount_data, which nfs_fill_super
 		 * can deal with.
@@ -1182,7 +1186,14 @@ static int nfs_validate_mount_data(void *options,
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
@@ -1655,6 +1666,7 @@ static int nfs4_validate_mount_data(void *options,
 				    struct nfs_parsed_mount_data *args,
 				    const char *dev_name)
 {
+	struct sockaddr_in *ap;
 	struct nfs4_mount_data *data = (struct nfs4_mount_data *)options;
 	char *c;
 
@@ -1675,11 +1687,13 @@ static int nfs4_validate_mount_data(void *options,
 
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
