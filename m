From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 14/85] nfs41: sunrpc: support minorversion for rpc_clnt version table.
Date: Mon, 10 Nov 2008 22:20:16 +0200
Message-ID: <1226348416-7651-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60741 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbYKJUUX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:20:23 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Validate minorversion only if not zero as legacy code declares
nrminorvers==0 and that should work just fine with minorversion==0 argument.

Pass minorversion down to rpc_create in nfs_create_rpc_client

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c             |   17 ++++++++++++++---
 include/linux/nfs_xdr.h     |    3 +++
 include/linux/sunrpc/clnt.h |   10 +++++++++-
 net/sunrpc/clnt.c           |   13 ++++++++-----
 4 files changed, 34 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 7bc150b..4e8c641 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -56,7 +56,10 @@ static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
 /*
  * RPC cruft for NFS
  */
-static struct rpc_version *nfs_version[5] = {
+#define NFS_MAXVERSION	4
+
+static struct rpc_version *nfs_version[(NFS_MAXVERSION + 1) *
+				       (NFS4_MAX_MINOR_VERSION + 1)] = {
 	[2]			= &nfs_version2,
 #ifdef CONFIG_NFS_V3
 	[3]			= &nfs_version3,
@@ -64,12 +67,16 @@ static struct rpc_version *nfs_version[5] = {
 #ifdef CONFIG_NFS_V4
 	[4]			= &nfs_version4,
 #endif
+#ifdef CONFIG_NFS_V4_1
+	[(NFS_MAXVERSION + 1) + 4] = &nfs_version41,
+#endif /* CONFIG_NFS_V4_1 */
 };
 
 struct rpc_program nfs_program = {
 	.name			= "nfs",
 	.number			= NFS_PROGRAM,
-	.nrvers			= ARRAY_SIZE(nfs_version),
+	.nrvers			= NFS_MAXVERSION + 1,
+	.nrminorvers		= NFS4_MAX_MINOR_VERSION + 1,
 	.version		= nfs_version,
 	.stats			= &nfs_rpcstat,
 	.pipe_dir_name		= "/nfs",
@@ -482,6 +489,9 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 		.servername	= clp->cl_hostname,
 		.program	= &nfs_program,
 		.version	= clp->rpc_ops->version,
+#ifdef CONFIG_NFS_V4
+		.minorversion	= clp->cl_minorversion,
+#endif /* CONFIG_NFS_V4 */
 		.authflavor	= flavor,
 		.flags		= flags,
 	};
@@ -550,7 +560,7 @@ static void nfs_init_server_aclclient(struct nfs_server *server)
 	if (server->flags & NFS_MOUNT_NOACL)
 		goto out_noacl;
 
-	server->client_acl = rpc_bind_new_program(server->client, &nfsacl_program, 3);
+	server->client_acl = rpc_bind_new_program(server->client, &nfsacl_program, 3, 0);
 	if (IS_ERR(server->client_acl))
 		goto out_noacl;
 
@@ -970,6 +980,7 @@ static int nfs4_init_client(struct nfs_client *clp,
 {
 	int error;
 
+	dprintk("--> nfs4_init_client minorversion %u\n", clp->cl_minorversion);
 	if (clp->cl_cons_state == NFS_CS_READY) {
 		/* the client is initialised already */
 		dprintk("<-- nfs4_init_client() = 0 [already %p]\n", clp);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 743b5ac..b401477 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -975,6 +975,9 @@ extern struct rpc_procinfo *nfs4_minorversion_procedures[];
 extern struct rpc_version	nfs_version2;
 extern struct rpc_version	nfs_version3;
 extern struct rpc_version	nfs_version4;
+#if defined(CONFIG_NFS_V4_1)
+extern struct rpc_version	nfs_version41;
+#endif /* CONFIG_NFS_V4_1 */
 
 extern struct rpc_version	nfsacl_version3;
 extern struct rpc_program	nfsacl_program;
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 6f0ee1b..99d4f9e 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -68,11 +68,18 @@ struct rpc_program {
 	char *			name;		/* protocol name */
 	u32			number;		/* program number */
 	unsigned int		nrvers;		/* number of versions */
+	unsigned int		nrminorvers;	/* number of minor versions */
 	struct rpc_version **	version;	/* version array */
 	struct rpc_stat *	stats;		/* statistics */
 	char *			pipe_dir_name;	/* path to rpc_pipefs dir */
 };
 
+static inline struct rpc_version *
+get_rpc_version(struct rpc_program *prog, u32 vers, int minorvers)
+{
+	return prog->version[minorvers * prog->nrvers + vers];
+}
+
 struct rpc_version {
 	u32			number;		/* version number */
 	unsigned int		nrprocs;	/* number of procs */
@@ -106,6 +113,7 @@ struct rpc_create_args {
 	struct rpc_program	*program;
 	u32			prognumber;	/* overrides program->number */
 	u32			version;
+	unsigned char		minorversion;
 	rpc_authflavor_t	authflavor;
 	unsigned long		flags;
 };
@@ -120,7 +128,7 @@ struct rpc_create_args {
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
-				struct rpc_program *, u32);
+				struct rpc_program *, u32, int minorversion);
 struct rpc_clnt *rpc_clone_client(struct rpc_clnt *);
 void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4895c34..44f251d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -148,9 +148,10 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	if (!xprt)
 		goto out_no_xprt;
 
-	if (args->version >= program->nrvers)
+	if (args->version >= program->nrvers ||
+	    (args->minorversion && args->minorversion >= program->nrminorvers))
 		goto out_err;
-	version = program->version[args->version];
+	version = get_rpc_version(program, args->version, args->minorversion);
 	if (version == NULL)
 		goto out_err;
 
@@ -472,14 +473,16 @@ rpc_release_client(struct rpc_clnt *clnt)
  */
 struct rpc_clnt *rpc_bind_new_program(struct rpc_clnt *old,
 				      struct rpc_program *program,
-				      u32 vers)
+				      u32 vers, int minorversion)
 {
 	struct rpc_clnt *clnt;
 	struct rpc_version *version;
 	int err;
 
-	BUG_ON(vers >= program->nrvers || !program->version[vers]);
-	version = program->version[vers];
+	BUG_ON(vers >= program->nrvers ||
+	       (minorversion && minorversion >= program->nrminorvers) ||
+	       !get_rpc_version(program, vers, minorversion));
+	version = get_rpc_version(program, vers, minorversion);
 	clnt = rpc_clone_client(old);
 	if (IS_ERR(clnt))
 		goto out;
-- 
1.6.0.2

