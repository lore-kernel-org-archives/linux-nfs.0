From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] NFS: Mount option parser should detect unset port values
Date: Tue, 01 Sep 2009 10:21:09 -0400
Message-ID: <20090901142109.3700.29070.stgit@matisse.1015granger.net>
References: <20090901141615.3700.41738.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:51784
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754923AbZIAOVO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2009 10:21:14 -0400
In-Reply-To: <20090901141615.3700.41738.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel's NFS mount option parser needs to distinguish between
the "port=0" mount option and the absense of the "port=" option
(currently also zero).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h |    9 +++++++--
 fs/nfs/super.c    |   55 ++++++++++++++++++++++++++++-------------------------
 2 files changed, 36 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index dabf345..ffadffa 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -49,6 +49,11 @@ struct nfs_clone_mount {
 #define NFS_MAX_SECFLAVORS	(12)
 
 /*
+ * Value used if the user did not specify a port value.
+ */
+#define NFS_UNSPEC_PORT		(-1)
+
+/*
  * In-kernel mount arguments
  */
 struct nfs_parsed_mount_data {
@@ -71,7 +76,7 @@ struct nfs_parsed_mount_data {
 		size_t			addrlen;
 		char			*hostname;
 		u32			version;
-		unsigned short		port;
+		int			port;
 		unsigned short		protocol;
 	} mount_server;
 
@@ -80,7 +85,7 @@ struct nfs_parsed_mount_data {
 		size_t			addrlen;
 		char			*hostname;
 		char			*export_path;
-		unsigned short		port;
+		int			port;
 		unsigned short		protocol;
 	} nfs_server;
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f3a95df..0554433 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -747,6 +747,21 @@ static int nfs_verify_server_address(struct sockaddr *addr)
 }
 
 /*
+ * Select between a default port value and a user-specified port value.
+ * If a zero value is set, then autobind will be used.
+ */
+static void nfs_set_default_port(struct sockaddr *sap, const int parsed_port,
+				 const unsigned short default_port)
+{
+	unsigned short port = default_port;
+
+	if (parsed_port != NFS_UNSPEC_PORT)
+		port = parsed_port;
+
+	rpc_set_port(sap, port);
+}
+
+/*
  * Sanity check the NFS transport protocol.
  *
  */
@@ -1415,11 +1430,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 		args->mount_server.addrlen = args->nfs_server.addrlen;
 	}
 	request.salen = args->mount_server.addrlen;
-
-	/*
-	 * autobind will be used if mount_server.port == 0
-	 */
-	rpc_set_port(request.sap, args->mount_server.port);
+	nfs_set_default_port(request.sap, args->mount_server.port, 0);
 
 	/*
 	 * Now ask the mount server to map our export path
@@ -1597,6 +1608,7 @@ static int nfs_validate_mount_data(void *options,
 				   const char *dev_name)
 {
 	struct nfs_mount_data *data = (struct nfs_mount_data *)options;
+	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
 
 	if (data == NULL)
 		goto out_no_data;
@@ -1608,8 +1620,8 @@ static int nfs_validate_mount_data(void *options,
 	args->acregmax		= NFS_DEF_ACREGMAX;
 	args->acdirmin		= NFS_DEF_ACDIRMIN;
 	args->acdirmax		= NFS_DEF_ACDIRMAX;
-	args->mount_server.port	= 0;	/* autobind unless user sets port */
-	args->nfs_server.port	= 0;	/* autobind unless user sets port */
+	args->mount_server.port	= NFS_UNSPEC_PORT;
+	args->nfs_server.port	= NFS_UNSPEC_PORT;
 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 	args->auth_flavors[0]	= RPC_AUTH_UNIX;
 	args->auth_flavor_len	= 1;
@@ -1657,11 +1669,9 @@ static int nfs_validate_mount_data(void *options,
 		args->acdirmin		= data->acdirmin;
 		args->acdirmax		= data->acdirmax;
 
-		memcpy(&args->nfs_server.address, &data->addr,
-		       sizeof(data->addr));
+		memcpy(sap, &data->addr, sizeof(data->addr));
 		args->nfs_server.addrlen = sizeof(data->addr);
-		if (!nfs_verify_server_address((struct sockaddr *)
-						&args->nfs_server.address))
+		if (!nfs_verify_server_address(sap))
 			goto out_no_address;
 
 		if (!(data->flags & NFS_MOUNT_TCP))
@@ -1709,12 +1719,10 @@ static int nfs_validate_mount_data(void *options,
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
-		if (!nfs_verify_server_address((struct sockaddr *)
-						&args->nfs_server.address))
+		if (!nfs_verify_server_address(sap))
 			goto out_no_address;
 
-		rpc_set_port((struct sockaddr *)&args->nfs_server.address,
-				args->nfs_server.port);
+		nfs_set_default_port(sap, args->nfs_server.port, 0);
 
 		nfs_set_mount_transport_protocol(args);
 
@@ -2261,7 +2269,7 @@ static int nfs4_validate_mount_data(void *options,
 				    struct nfs_parsed_mount_data *args,
 				    const char *dev_name)
 {
-	struct sockaddr_in *ap;
+	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
 	struct nfs4_mount_data *data = (struct nfs4_mount_data *)options;
 	char *c;
 
@@ -2274,23 +2282,21 @@ static int nfs4_validate_mount_data(void *options,
 	args->acregmax		= NFS_DEF_ACREGMAX;
 	args->acdirmin		= NFS_DEF_ACDIRMIN;
 	args->acdirmax		= NFS_DEF_ACDIRMAX;
-	args->nfs_server.port	= NFS_PORT; /* 2049 unless user set port= */
+	args->nfs_server.port	= NFS_UNSPEC_PORT;
 	args->auth_flavors[0]	= RPC_AUTH_UNIX;
 	args->auth_flavor_len	= 1;
 	args->minorversion	= 0;
 
 	switch (data->version) {
 	case 1:
-		ap = (struct sockaddr_in *)&args->nfs_server.address;
 		if (data->host_addrlen > sizeof(args->nfs_server.address))
 			goto out_no_address;
 		if (data->host_addrlen == 0)
 			goto out_no_address;
 		args->nfs_server.addrlen = data->host_addrlen;
-		if (copy_from_user(ap, data->host_addr, data->host_addrlen))
+		if (copy_from_user(sap, data->host_addr, data->host_addrlen))
 			return -EFAULT;
-		if (!nfs_verify_server_address((struct sockaddr *)
-						&args->nfs_server.address))
+		if (!nfs_verify_server_address(sap))
 			goto out_no_address;
 
 		if (data->auth_flavourlen) {
@@ -2342,12 +2348,9 @@ static int nfs4_validate_mount_data(void *options,
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
-		if (!nfs_verify_server_address((struct sockaddr *)
-						&args->nfs_server.address))
+		if (!nfs_verify_server_address(sap))
 			return -EINVAL;
-
-		rpc_set_port((struct sockaddr *)&args->nfs_server.address,
-				args->nfs_server.port);
+		nfs_set_default_port(sap, args->nfs_server.port, NFS_PORT);
 
 		nfs_validate_transport_protocol(args);
 

