From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/69] NFS: introduce nfs_mount_info struct for calling
 nfs_mount()
Date: Tue, 23 Dec 2008 18:02:08 -0500
Message-ID: <20081223230207.13743.7598.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29099 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752209AbYLWXXj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:39 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNbsQ006182
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:38 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: convert nfs_mount() to take a single data structure argument to make
it simpler to add more arguments.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/internal.h   |   13 +++++++++++--
 fs/nfs/mount_clnt.c |   30 ++++++++++++------------------
 fs/nfs/nfsroot.c    |   17 +++++++++++------
 fs/nfs/super.c      |   29 +++++++++++++++--------------
 4 files changed, 49 insertions(+), 40 deletions(-)


diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7a38cc7..4e98396 100644
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
index f48db67..2b0c8e1 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1329,8 +1329,13 @@ out_security_failure:
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
@@ -1339,42 +1344,38 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
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
 

