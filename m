From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 19/25] NFSD: Convert NFS server callback logic to use
	new rpc_create API
Date: Wed, 09 Aug 2006 10:59:36 -0400
Message-ID: <20060809145936.3914.8829.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcS-0000og-EF
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:16 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcS-0005lO-7V
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:16 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Replace xprt_create_proto/rpc_create_client call in NFS server callback
functions to use new rpc_create() API.

Test plan:
NFSv4 delegation functionality tests.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfs4callback.c |   66 ++++++++++++++++++++----------------------------
 1 files changed, 27 insertions(+), 39 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 54b37b1..8583d99 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -375,16 +375,28 @@ nfsd4_probe_callback(struct nfs4_client 
 {
 	struct sockaddr_in	addr;
 	struct nfs4_callback    *cb = &clp->cl_callback;
-	struct rpc_timeout	timeparms;
-	struct rpc_xprt *	xprt;
+	struct rpc_timeout	timeparms = {
+		.to_initval	= (NFSD_LEASE_TIME/4) * HZ,
+		.to_retries	= 5,
+		.to_maxval	= (NFSD_LEASE_TIME/2) * HZ,
+		.to_exponential	= 1,
+	};
 	struct rpc_program *	program = &cb->cb_program;
-	struct rpc_stat *	stat = &cb->cb_stat;
-	struct rpc_clnt *	clnt;
+	struct rpc_create_args args = {
+		.protocol	= IPPROTO_TCP,
+		.address	= (struct sockaddr *)&addr,
+		.addrsize	= sizeof(addr),
+		.timeout	= &timeparms,
+		.servername	= clp->cl_name.data,
+		.program	= program,
+		.version	= nfs_cb_version[1]->number,
+		.authflavor	= RPC_AUTH_UNIX,	/* XXX: need AUTH_GSS... */
+		.flags		= (RPC_CLNT_CREATE_NOPING),
+	};
 	struct rpc_message msg = {
 		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
 		.rpc_argp       = clp,
 	};
-	char                    hostname[32];
 	int status;
 
 	if (atomic_read(&cb->cb_set))
@@ -396,51 +408,27 @@ nfsd4_probe_callback(struct nfs4_client 
 	addr.sin_port = htons(cb->cb_port);
 	addr.sin_addr.s_addr = htonl(cb->cb_addr);
 
-	/* Initialize timeout */
-	timeparms.to_initval = (NFSD_LEASE_TIME/4) * HZ;
-	timeparms.to_retries = 0;
-	timeparms.to_maxval = (NFSD_LEASE_TIME/2) * HZ;
-	timeparms.to_exponential = 1;
-
-	/* Create RPC transport */
-	xprt = xprt_create_proto(IPPROTO_TCP, &addr, &timeparms);
-	if (IS_ERR(xprt)) {
-		dprintk("NFSD: couldn't create callback transport!\n");
-		goto out_err;
-	}
-
 	/* Initialize rpc_program */
 	program->name = "nfs4_cb";
 	program->number = cb->cb_prog;
 	program->nrvers = ARRAY_SIZE(nfs_cb_version);
 	program->version = nfs_cb_version;
-	program->stats = stat;
+	program->stats = &cb->cb_stat;
 
 	/* Initialize rpc_stat */
-	memset(stat, 0, sizeof(struct rpc_stat));
-	stat->program = program;
-
-	/* Create RPC client
- 	 *
-	 * XXX AUTH_UNIX only - need AUTH_GSS....
-	 */
-	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(addr.sin_addr.s_addr));
-	clnt = rpc_new_client(xprt, hostname, program, 1, RPC_AUTH_UNIX);
-	if (IS_ERR(clnt)) {
+	memset(program->stats, 0, sizeof(cb->cb_stat));
+	program->stats->program = program;
+
+	/* Create RPC client */
+	cb->cb_client = rpc_create(&args);
+	if (!cb->cb_client) {
 		dprintk("NFSD: couldn't create callback client\n");
 		goto out_err;
 	}
-	clnt->cl_intr = 0;
-	clnt->cl_softrtry = 1;
 
 	/* Kick rpciod, put the call on the wire. */
-
-	if (rpciod_up() != 0) {
-		dprintk("nfsd: couldn't start rpciod for callbacks!\n");
+	if (rpciod_up() != 0)
 		goto out_clnt;
-	}
-
-	cb->cb_client = clnt;
 
 	/* the task holds a reference to the nfs4_client struct */
 	atomic_inc(&clp->cl_count);
@@ -448,7 +436,7 @@ nfsd4_probe_callback(struct nfs4_client 
 	msg.rpc_cred = nfsd4_lookupcred(clp,0);
 	if (IS_ERR(msg.rpc_cred))
 		goto out_rpciod;
-	status = rpc_call_async(clnt, &msg, RPC_TASK_ASYNC, &nfs4_cb_null_ops, NULL);
+	status = rpc_call_async(cb->cb_client, &msg, RPC_TASK_ASYNC, &nfs4_cb_null_ops, NULL);
 	put_rpccred(msg.rpc_cred);
 
 	if (status != 0) {
@@ -462,7 +450,7 @@ out_rpciod:
 	rpciod_down();
 	cb->cb_client = NULL;
 out_clnt:
-	rpc_shutdown_client(clnt);
+	rpc_shutdown_client(cb->cb_client);
 out_err:
 	dprintk("NFSD: warning: no callback path to client %.*s\n",
 		(int)clp->cl_name.len, clp->cl_name.data);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
