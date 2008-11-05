From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] NFS: introduce nfs_mount_info struct for calling
	nfs_mount()
Date: Wed, 05 Nov 2008 15:25:06 -0500
Message-ID: <20081105202506.14469.54605.stgit@ingres.1015granger.net>
References: <20081105202040.14469.32458.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:43091 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756714AbYKEUZ1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 15:25:27 -0500
In-Reply-To: <20081105202040.14469.32458.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: convert nfs_mount() to take a single data structure argument to make
it simpler to add more arguments.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h   |   13 +++++++++++--
 fs/nfs/mount_clnt.c |   30 ++++++++++++------------------
 fs/nfs/nfsroot.c    |   17 +++++++++++------
 fs/nfs/super.c      |   29 +++++++++++++++--------------
 4 files changed, 49 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0134e59..fa8174c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -64,8 +64,17 @@ struct nfs_parsed_mount_data {
 };
 
 /* mount_clnt.c */
-extern int nfs_mount(struct sockaddr *, size_t, char *, char *,
-					int, int, struct nfs_fh *);
+struct nfs_mount_request {
+	struct sockaddr		*sap;
+	size_t			salen;
+	char			*hostname;
+	char			*dirpath;
+	u32			version;
+	unsigned short		protocol;
+	struct nfs_fh		*fh;
+};
+
+extern int nfs_mount(struct nfs_mount_request *info);
 
 /* client.c */
 extern struct rpc_program nfs_program;
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 086a683..7e37113 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -29,33 +29,26 @@ struct mnt_fhstatus {
 
 /**
  * nfs_mount - Obtain an NFS file handle for the given host and path
- * @addr: pointer to server's address
- * @len: size of server's address
- * @hostname: name of server host, or NULL
- * @path: pointer to string containing export path to mount
- * @version: mount version to use for this request
- * @protocol: transport protocol to use for thie request
- * @fh: pointer to location to place returned file handle
+ * @info: pointer to mount request arguments
  *
  * Uses default timeout parameters specified by underlying transport.
  */
-int nfs_mount(struct sockaddr *addr, size_t len, char *hostname, char *path,
-	      int version, int protocol, struct nfs_fh *fh)
+int nfs_mount(struct nfs_mount_request *info)
 {
 	struct mnt_fhstatus	result = {
-		.fh		= fh
+		.fh		= info->fh
 	};
 	struct rpc_message msg	= {
-		.rpc_argp	= path,
+		.rpc_argp	= info->dirpath,
 		.rpc_resp	= &result,
 	};
 	struct rpc_create_args args = {
-		.protocol	= protocol,
-		.address	= addr,
-		.addrsize	= len,
-		.servername	= hostname,
+		.protocol	= info->protocol,
+		.address	= info->sap,
+		.addrsize	= info->salen,
+		.servername	= info->hostname,
 		.program	= &mnt_program,
-		.version	= version,
+		.version	= info->version,
 		.authflavor	= RPC_AUTH_UNIX,
 		.flags		= 0,
 	};
@@ -63,13 +56,14 @@ int nfs_mount(struct sockaddr *addr, size_t len, char *hostname, char *path,
 	int			status;
 
 	dprintk("NFS: sending MNT request for %s:%s\n",
-		(hostname ? hostname : "server"), path);
+		(info->hostname ? info->hostname : "server"),
+			info->dirpath);
 
 	mnt_clnt = rpc_create(&args);
 	if (IS_ERR(mnt_clnt))
 		goto out_clnt_err;
 
-	if (version == NFS_MNT3_VERSION)
+	if (info->version == NFS_MNT3_VERSION)
 		msg.rpc_proc = &mnt_clnt->cl_procinfo[MOUNTPROC3_MNT];
 	else
 		msg.rpc_proc = &mnt_clnt->cl_procinfo[MNTPROC_MNT];
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index a96e5fd..f015e0d 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -487,15 +487,20 @@ static int __init root_nfs_get_handle(void)
 {
 	struct nfs_fh fh;
 	struct sockaddr_in sin;
+	struct nfs_mount_request request = {
+		.sap		= (struct sockaddr *)&sin,
+		.salen		= sizeof(sin),
+		.dirpath	= nfs_export_path,
+		.version	= (nfs_data.flags & NFS_MOUNT_VER3) ?
+					NFS_MNT3_VERSION : NFS_MNT_VERSION,
+		.protocol	= (nfs_data.flags & NFS_MOUNT_TCP) ?
+					XPRT_TRANSPORT_TCP : XPRT_TRANSPORT_UDP,
+		.fh		= &fh,
+	};
 	int status;
-	int protocol = (nfs_data.flags & NFS_MOUNT_TCP) ?
-					XPRT_TRANSPORT_TCP : XPRT_TRANSPORT_UDP;
-	int version = (nfs_data.flags & NFS_MOUNT_VER3) ?
-					NFS_MNT3_VERSION : NFS_MNT_VERSION;
 
 	set_sockaddr(&sin, servaddr, htons(mount_port));
-	status = nfs_mount((struct sockaddr *) &sin, sizeof(sin), NULL,
-			   nfs_export_path, version, protocol, &fh);
+	status = nfs_mount(&request);
 	if (status < 0)
 		printk(KERN_ERR "Root-NFS: Server returned error %d "
 				"while mounting %s\n", status, nfs_export_path);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6900734..735ff2b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1210,8 +1210,13 @@ out_security_failure:
 static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 			 struct nfs_fh *root_fh)
 {
-	struct sockaddr *sap = (struct sockaddr *)&args->mount_server.address;
-	char *hostname;
+	struct nfs_mount_request request = {
+		.sap		= (struct sockaddr *)
+						&args->mount_server.address,
+		.dirpath	= args->nfs_server.export_path,
+		.protocol	= args->mount_server.protocol,
+		.fh		= root_fh,
+	};
 	int status;
 
 	if (args->mount_server.version == 0) {
@@ -1220,42 +1225,38 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 		else
 			args->mount_server.version = NFS_MNT_VERSION;
 	}
+	request.version = args->mount_server.version;
 
 	if (args->mount_server.hostname)
-		hostname = args->mount_server.hostname;
+		request.hostname = args->mount_server.hostname;
 	else
-		hostname = args->nfs_server.hostname;
+		request.hostname = args->nfs_server.hostname;
 
 	/*
 	 * Construct the mount server's address.
 	 */
 	if (args->mount_server.address.ss_family == AF_UNSPEC) {
-		memcpy(sap, &args->nfs_server.address,
+		memcpy(request.sap, &args->nfs_server.address,
 		       args->nfs_server.addrlen);
 		args->mount_server.addrlen = args->nfs_server.addrlen;
 	}
+	request.salen = args->mount_server.addrlen;
 
 	/*
 	 * autobind will be used if mount_server.port == 0
 	 */
-	nfs_set_port(sap, args->mount_server.port);
+	nfs_set_port(request.sap, args->mount_server.port);
 
 	/*
 	 * Now ask the mount server to map our export path
 	 * to a file handle.
 	 */
-	status = nfs_mount(sap,
-			   args->mount_server.addrlen,
-			   hostname,
-			   args->nfs_server.export_path,
-			   args->mount_server.version,
-			   args->mount_server.protocol,
-			   root_fh);
+	status = nfs_mount(&request);
 	if (status == 0)
 		return 0;
 
 	dfprintk(MOUNT, "NFS: unable to mount server %s, error %d\n",
-			hostname, status);
+			request.hostname, status);
 	return status;
 }
 

