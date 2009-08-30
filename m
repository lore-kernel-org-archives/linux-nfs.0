From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] NFS: Mount option parser should detect unset port values
Date: Sun, 30 Aug 2009 12:34:40 -0400
Message-ID: <20090830163440.3652.26254.stgit@matisse.1015granger.net>
References: <20090830162211.3652.14638.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:49881
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753882AbZH3Qeo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Aug 2009 12:34:44 -0400
In-Reply-To: <20090830162211.3652.14638.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS mount option parser needs to distinguish between a user set
port value of zero, and the absence of a port setting (currently,
also zero).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h |   22 ++++++++++++++++++++--
 fs/nfs/super.c    |   51 ++++++++++++++++++++++++++++-----------------------
 2 files changed, 48 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index dabf345..d30b4fb 100644
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
 
@@ -80,13 +85,26 @@ struct nfs_parsed_mount_data {
 		size_t			addrlen;
 		char			*hostname;
 		char			*export_path;
-		unsigned short		port;
+		int			port;
 		unsigned short		protocol;
 	} nfs_server;
 
 	struct security_mnt_opts lsm_opts;
 };
 
+static inline struct sockaddr *
+nfs_server_address(struct nfs_parsed_mount_data *mnt)
+{
+	return (struct sockaddr *)&mnt->nfs_server.address;
+}
+
+static inline struct sockaddr *
+mnt_server_address(struct nfs_parsed_mount_data *mnt)
+{
+	return (struct sockaddr *)&mnt->mount_server.address;
+}
+
+
 /* mount_clnt.c */
 struct nfs_mount_request {
 	struct sockaddr		*sap;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d215707..ea7aedc 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -746,6 +746,21 @@ static int nfs_verify_server_address(struct sockaddr *addr)
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
@@ -1226,8 +1241,7 @@ static int nfs_parse_mount_options(char *raw,
 				goto out_nomem;
 			mnt->nfs_server.addrlen =
 				rpc_pton(string, strlen(string),
-					(struct sockaddr *)
-					&mnt->nfs_server.address,
+					nfs_server_address(mnt),
 					sizeof(mnt->nfs_server.address));
 			kfree(string);
 			if (mnt->nfs_server.addrlen == 0)
@@ -1414,11 +1428,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
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
@@ -1607,8 +1617,8 @@ static int nfs_validate_mount_data(void *options,
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
@@ -1659,8 +1669,7 @@ static int nfs_validate_mount_data(void *options,
 		memcpy(&args->nfs_server.address, &data->addr,
 		       sizeof(data->addr));
 		args->nfs_server.addrlen = sizeof(data->addr);
-		if (!nfs_verify_server_address((struct sockaddr *)
-						&args->nfs_server.address))
+		if (!nfs_verify_server_address(nfs_server_address(args)))
 			goto out_no_address;
 
 		if (!(data->flags & NFS_MOUNT_TCP))
@@ -1708,12 +1717,11 @@ static int nfs_validate_mount_data(void *options,
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
-		if (!nfs_verify_server_address((struct sockaddr *)
-						&args->nfs_server.address))
+		if (!nfs_verify_server_address(nfs_server_address(args)))
 			goto out_no_address;
 
-		rpc_set_port((struct sockaddr *)&args->nfs_server.address,
-				args->nfs_server.port);
+		nfs_set_default_port(nfs_server_address(args),
+					args->nfs_server.port, 0);
 
 		nfs_set_mount_transport_protocol(args);
 
@@ -2284,7 +2292,7 @@ static int nfs4_validate_mount_data(void *options,
 	args->acregmax		= NFS_DEF_ACREGMAX;
 	args->acdirmin		= NFS_DEF_ACDIRMIN;
 	args->acdirmax		= NFS_DEF_ACDIRMAX;
-	args->nfs_server.port	= NFS_PORT; /* 2049 unless user set port= */
+	args->nfs_server.port	= NFS_UNSPEC_PORT;
 	args->auth_flavors[0]	= RPC_AUTH_UNIX;
 	args->auth_flavor_len	= 1;
 	args->minorversion	= 0;
@@ -2299,8 +2307,7 @@ static int nfs4_validate_mount_data(void *options,
 		args->nfs_server.addrlen = data->host_addrlen;
 		if (copy_from_user(ap, data->host_addr, data->host_addrlen))
 			return -EFAULT;
-		if (!nfs_verify_server_address((struct sockaddr *)
-						&args->nfs_server.address))
+		if (!nfs_verify_server_address(nfs_server_address(args)))
 			goto out_no_address;
 
 		if (data->auth_flavourlen) {
@@ -2352,12 +2359,10 @@ static int nfs4_validate_mount_data(void *options,
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
-		if (!nfs_verify_server_address((struct sockaddr *)
-						&args->nfs_server.address))
+		if (!nfs_verify_server_address(nfs_server_address(args)))
 			return -EINVAL;
-
-		rpc_set_port((struct sockaddr *)&args->nfs_server.address,
-				args->nfs_server.port);
+		nfs_set_default_port(nfs_server_address(args),
+					args->nfs_server.port, NFS_PORT);
 
 		nfs_validate_transport_protocol(args);
 

