From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3] nfsd: use nfs client rpc callback program
Date: Mon, 22 Sep 2008 16:07:45 +0300
Message-ID: <1222088865-19162-1-git-send-email-bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:40942 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbYIVNbF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2008 09:31:05 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

since commit ff7d9756b501744540be65e172d27ee321d86103
"nfsd: use static memory for callback program and stats"
do_probe_callback uses a static callback program
(NFS4_CALLBACK) rather than the one set in clp->cl_callback.cb_prog
as passed in by the client in setclientid (4.0)
or create_session (4.1).

This patches allows allocating cb_program (and cb_stats) dynamically
and setting a free_rpc_program function pointer to be
called when the rpc_clnt structure is destroyed.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---

v3 fixes review comments by J. Bruce Fields and Pete Staubach
Applies against 2.6.27-rc6 and 2.6.26

Benny

 fs/nfsd/nfs4callback.c      |   49 ++++++++++++++++++++++++++++++------------
 include/linux/sunrpc/clnt.h |    1 +
 net/sunrpc/clnt.c           |    2 +
 3 files changed, 38 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 30d3130..0f13d75 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -342,20 +342,20 @@ static struct rpc_version *	nfs_cb_version[] = {
 	&nfs_cb_version4,
 };
 
-static struct rpc_program cb_program;
-
-static struct rpc_stat cb_stats = {
-		.program	= &cb_program
+/* used internally for dynamically allocating the callback rpc_program
+ * and rpc_stat */
+struct __rpc_prog_stats {
+	struct rpc_program	program;
+	struct rpc_stat		stats;
 };
 
-#define NFS4_CALLBACK 0x40000000
-static struct rpc_program cb_program = {
-		.name 		= "nfs4_cb",
-		.number		= NFS4_CALLBACK,
-		.nrvers		= ARRAY_SIZE(nfs_cb_version),
-		.version	= nfs_cb_version,
-		.stats		= &cb_stats,
-};
+static void free_rpc_program(struct rpc_program *p)
+{
+	struct __rpc_prog_stats *ps = container_of(p, struct __rpc_prog_stats,
+						   program);
+	dprintk("%s: freeing callback prog_stats 0x%p\n", __func__, ps);
+	kfree(ps);
+}
 
 /* Reference counting, callback cleanup, etc., all look racy as heck.
  * And why is cb_set an atomic? */
@@ -371,12 +371,12 @@ static int do_probe_callback(void *data)
 		.to_maxval	= (NFSD_LEASE_TIME/2) * HZ,
 		.to_exponential	= 1,
 	};
+	struct __rpc_prog_stats	*cb_prog_stats;
 	struct rpc_create_args args = {
 		.protocol	= IPPROTO_TCP,
 		.address	= (struct sockaddr *)&addr,
 		.addrsize	= sizeof(addr),
 		.timeout	= &timeparms,
-		.program	= &cb_program,
 		.version	= nfs_cb_version[1]->number,
 		.authflavor	= RPC_AUTH_UNIX, /* XXX: need AUTH_GSS... */
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
@@ -394,8 +394,29 @@ static int do_probe_callback(void *data)
 	addr.sin_port = htons(cb->cb_port);
 	addr.sin_addr.s_addr = htonl(cb->cb_addr);
 
+	/* Initialize rpc_program */
+	cb_prog_stats = kzalloc(sizeof(*cb_prog_stats), GFP_KERNEL);
+	if (!cb_prog_stats) {
+		dprintk("NFSD: %s: couldn't allocate callback program\n",
+			__func__);
+		status = -ENOMEM;
+		goto out_err;
+	}
+
+	args.program = &cb_prog_stats->program;
+	args.program->name = "nfs4_cb";
+	args.program->number = clp->cl_callback.cb_prog;
+	args.program->nrvers = ARRAY_SIZE(nfs_cb_version);
+	args.program->version = nfs_cb_version;
+	args.program->free_rpc_program = free_rpc_program;
+
+	dprintk("%s: program %s 0x%x nrvers %u version %u\n",
+		__func__, args.program->name, args.program->number,
+		args.program->nrvers, args.version);
+
 	/* Initialize rpc_stat */
-	memset(args.program->stats, 0, sizeof(struct rpc_stat));
+	args.program->stats = &cb_prog_stats->stats;
+	args.program->stats->program = args.program;
 
 	/* Create RPC client */
 	client = rpc_create(&args);
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index e5bfe01..d342374 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -71,6 +71,7 @@ struct rpc_program {
 	struct rpc_version **	version;	/* version array */
 	struct rpc_stat *	stats;		/* statistics */
 	char *			pipe_dir_name;	/* path to rpc_pipefs dir */
+	void			(*free_rpc_program)(struct rpc_program *);
 };
 
 struct rpc_version {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 76739e9..cfb21c0 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -415,6 +415,8 @@ rpc_free_client(struct kref *kref)
 	if (clnt->cl_server != clnt->cl_inline_name)
 		kfree(clnt->cl_server);
 out_free:
+	if (clnt->cl_program && clnt->cl_program->free_rpc_program)
+		clnt->cl_program->free_rpc_program(clnt->cl_program);
 	rpc_unregister_client(clnt);
 	rpc_free_iostats(clnt->cl_metrics);
 	clnt->cl_metrics = NULL;
-- 
1.6.0

