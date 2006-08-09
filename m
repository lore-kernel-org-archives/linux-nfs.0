From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 18/25] NFS: Convert NFS client to use new rpc_create()
	API
Date: Wed, 09 Aug 2006 10:59:34 -0400
Message-ID: <20060809145933.3914.19856.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcb-0000qe-Mk
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:25 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcS-0005lo-7a
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:26 -0700
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

Convert NFS client mount logic to use rpc_create() instead of the old
xprt_create_proto/rpc_create_client API.

Test plan:
Mount stress tests.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/mount_clnt.c |   29 +++++++++-----------
 fs/nfs/super.c      |   74 +++++++++++++++++++++++----------------------------
 2 files changed, 46 insertions(+), 57 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 4127487..ef8a3a0 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -76,22 +76,19 @@ static struct rpc_clnt *
 mnt_create(char *hostname, struct sockaddr_in *srvaddr, int version,
 		int protocol)
 {
-	struct rpc_xprt	*xprt;
-	struct rpc_clnt	*clnt;
-
-	xprt = xprt_create_proto(protocol, srvaddr, NULL);
-	if (IS_ERR(xprt))
-		return (struct rpc_clnt *)xprt;
-
-	clnt = rpc_create_client(xprt, hostname,
-				&mnt_program, version,
-				RPC_AUTH_UNIX);
-	if (!IS_ERR(clnt)) {
-		clnt->cl_softrtry = 1;
-		clnt->cl_oneshot  = 1;
-		clnt->cl_intr = 1;
-	}
-	return clnt;
+	struct rpc_create_args args = {
+		.protocol	= protocol,
+		.address	= (struct sockaddr *)srvaddr,
+		.addrsize	= sizeof(*srvaddr),
+		.servername	= hostname,
+		.program	= &mnt_program,
+		.version	= version,
+		.authflavor	= RPC_AUTH_UNIX,
+		.flags		= (RPC_CLNT_CREATE_ONESHOT |
+				   RPC_CLNT_INTR),
+	};
+
+	return rpc_create(&args);
 }
 
 /*
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e8a9bee..8daccf6 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -685,37 +685,29 @@ static void nfs_init_timeout_values(stru
 static struct rpc_clnt *
 nfs_create_client(struct nfs_server *server, const struct nfs_mount_data *data)
 {
+	struct rpc_clnt		*clnt;
 	struct rpc_timeout	timeparms;
-	struct rpc_xprt		*xprt = NULL;
-	struct rpc_clnt		*clnt = NULL;
-	int			proto = (data->flags & NFS_MOUNT_TCP) ? IPPROTO_TCP : IPPROTO_UDP;
-
-	nfs_init_timeout_values(&timeparms, proto, data->timeo, data->retrans);
+	struct rpc_create_args args = {
+		.protocol	= ((data->flags & NFS_MOUNT_TCP) ?
+						IPPROTO_TCP : IPPROTO_UDP),
+		.address	= (struct sockaddr *)&server->addr,
+		.addrsize	= sizeof(server->addr),
+		.timeout	= &timeparms,
+		.servername	= server->hostname,
+		.program	= &nfs_program,
+		.version	= server->rpc_ops->version,
+		.authflavor	= data->pseudoflavor,
+	};
 
+	nfs_init_timeout_values(&timeparms, args.protocol,
+					data->timeo, data->retrans);
 	server->retrans_timeo = timeparms.to_initval;
 	server->retrans_count = timeparms.to_retries;
 
-	/* create transport and client */
-	xprt = xprt_create_proto(proto, &server->addr, &timeparms);
-	if (IS_ERR(xprt)) {
-		dprintk("%s: cannot create RPC transport. Error = %ld\n",
-				__FUNCTION__, PTR_ERR(xprt));
-		return (struct rpc_clnt *)xprt;
-	}
-	clnt = rpc_create_client(xprt, server->hostname, &nfs_program,
-				 server->rpc_ops->version, data->pseudoflavor);
-	if (IS_ERR(clnt)) {
+	clnt = rpc_create(&args);
+	if (IS_ERR(clnt))
 		dprintk("%s: cannot create RPC client. Error = %ld\n",
-				__FUNCTION__, PTR_ERR(xprt));
-		goto out_fail;
-	}
-
-	clnt->cl_intr     = 1;
-	clnt->cl_softrtry = 1;
-
-	return clnt;
-
-out_fail:
+				__FUNCTION__, PTR_ERR(clnt));
 	return clnt;
 }
 
@@ -1122,11 +1114,14 @@ static int nfs_clone_nfs_sb(struct file_
 }
 
 #ifdef CONFIG_NFS_V4
+/*
+ * NB: nfs4_kill_super takes care of reaping the rpc_clnt if something
+ *     here fails.
+ */
 static struct rpc_clnt *nfs4_create_client(struct nfs_server *server,
 	struct rpc_timeout *timeparms, int proto, rpc_authflavor_t flavor)
 {
 	struct nfs4_client *clp;
-	struct rpc_xprt *xprt = NULL;
 	struct rpc_clnt *clnt = NULL;
 	int err = -EIO;
 
@@ -1136,21 +1131,20 @@ static struct rpc_clnt *nfs4_create_clie
 		return ERR_PTR(err);
 	}
 
-	/* Now create transport and client */
 	down_write(&clp->cl_sem);
 	if (IS_ERR(clp->cl_rpcclient)) {
-		xprt = xprt_create_proto(proto, &server->addr, timeparms);
-		if (IS_ERR(xprt)) {
-			up_write(&clp->cl_sem);
-			err = PTR_ERR(xprt);
-			dprintk("%s: cannot create RPC transport. Error = %d\n",
-					__FUNCTION__, err);
-			goto out_fail;
-		}
-		/* Bind to a reserved port! */
-		xprt->resvport = 1;
-		clnt = rpc_create_client(xprt, server->hostname, &nfs_program,
-				server->rpc_ops->version, flavor);
+		struct rpc_create_args args = {
+			.protocol	= proto,
+			.address	= (struct sockaddr *)&server->addr,
+			.addrsize	= sizeof(server->addr),
+			.timeout	= timeparms,
+			.servername	= server->hostname,
+			.program	= &nfs_program,
+			.version	= server->rpc_ops->version,
+			.authflavor	= flavor,
+		};
+
+		clnt = rpc_create(&args);
 		if (IS_ERR(clnt)) {
 			up_write(&clp->cl_sem);
 			err = PTR_ERR(clnt);
@@ -1158,8 +1152,6 @@ static struct rpc_clnt *nfs4_create_clie
 					__FUNCTION__, err);
 			goto out_fail;
 		}
-		clnt->cl_intr     = 1;
-		clnt->cl_softrtry = 1;
 		clp->cl_rpcclient = clnt;
 		memcpy(clp->cl_ipaddr, server->ip_addr, sizeof(clp->cl_ipaddr));
 		nfs_idmap_new(clp);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
