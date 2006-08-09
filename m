From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 17/25] LOCKD: Convert to use new rpc_create() API
Date: Wed, 09 Aug 2006 10:59:31 -0400
Message-ID: <20060809145931.3914.70914.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcT-0000or-JH
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:18 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcS-0003Gg-Vz
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:18 -0700
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

Replace xprt_create_proto/rpc_create_client with new rpc_create()
interface in the Network Lock Manager.

Note that the semantics of NLM transports is now "hard" instead of "soft"
to provide a better guarantee that lock requests will get to the server.

Test plan:
Repeated runs of Connectathon locking suite.  Check network trace to ensure
NLM requests are working correctly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   50 +++++++++++++++++++++++++++-----------------------
 fs/lockd/mon.c  |   41 +++++++++++++++++------------------------
 2 files changed, 44 insertions(+), 47 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index a516a01..703fb03 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -166,7 +166,6 @@ struct rpc_clnt *
 nlm_bind_host(struct nlm_host *host)
 {
 	struct rpc_clnt	*clnt;
-	struct rpc_xprt	*xprt;
 
 	dprintk("lockd: nlm_bind_host(%08x)\n",
 			(unsigned)ntohl(host->h_addr.sin_addr.s_addr));
@@ -178,7 +177,6 @@ nlm_bind_host(struct nlm_host *host)
 	 * RPC rebind is required
 	 */
 	if ((clnt = host->h_rpcclnt) != NULL) {
-		xprt = clnt->cl_xprt;
 		if (time_after_eq(jiffies, host->h_nextrebind)) {
 			rpc_force_rebind(clnt);
 			host->h_nextrebind = jiffies + NLM_HOST_REBIND;
@@ -186,31 +184,37 @@ nlm_bind_host(struct nlm_host *host)
 					host->h_nextrebind - jiffies);
 		}
 	} else {
-		xprt = xprt_create_proto(host->h_proto, &host->h_addr, NULL);
-		if (IS_ERR(xprt))
-			goto forgetit;
-
-		xprt_set_timeout(&xprt->timeout, 5, nlmsvc_timeout);
-		xprt->resvport = 1;	/* NLM requires a reserved port */
-
-		/* Existing NLM servers accept AUTH_UNIX only */
-		clnt = rpc_new_client(xprt, host->h_name, &nlm_program,
-					host->h_version, RPC_AUTH_UNIX);
-		if (IS_ERR(clnt))
-			goto forgetit;
-		clnt->cl_autobind = 1;	/* turn on pmap queries */
-		clnt->cl_softrtry = 1; /* All queries are soft */
-
-		host->h_rpcclnt = clnt;
+		unsigned long increment = nlmsvc_timeout * HZ;
+		struct rpc_timeout timeparms = {
+			.to_initval	= increment,
+			.to_increment	= increment,
+			.to_maxval	= increment * 6UL,
+			.to_retries	= 5U,
+		};
+		struct rpc_create_args args = {
+			.protocol	= host->h_proto,
+			.address	= (struct sockaddr *)&host->h_addr,
+			.addrsize	= sizeof(host->h_addr),
+			.timeout	= &timeparms,
+			.servername	= host->h_name,
+			.program	= &nlm_program,
+			.version	= host->h_version,
+			.authflavor	= RPC_AUTH_UNIX,
+			.flags		= (RPC_CLNT_CREATE_HARDRTRY |
+					   RPC_CLNT_CREATE_AUTOBIND),
+		};
+
+		clnt = rpc_create(&args);
+		if (!IS_ERR(clnt))
+			host->h_rpcclnt = clnt;
+		else {
+			printk("lockd: couldn't create RPC handle for %s\n", host->h_name);
+			clnt = NULL;
+		}
 	}
 
 	mutex_unlock(&host->h_mutex);
 	return clnt;
-
-forgetit:
-	printk("lockd: couldn't create RPC handle for %s\n", host->h_name);
-	mutex_unlock(&host->h_mutex);
-	return NULL;
 }
 
 /*
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 3fc683f..5954dcb 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -109,30 +109,23 @@ nsm_unmonitor(struct nlm_host *host)
 static struct rpc_clnt *
 nsm_create(void)
 {
-	struct rpc_xprt		*xprt;
-	struct rpc_clnt		*clnt;
-	struct sockaddr_in	sin;
-
-	sin.sin_family = AF_INET;
-	sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
-	sin.sin_port = 0;
-
-	xprt = xprt_create_proto(IPPROTO_UDP, &sin, NULL);
-	if (IS_ERR(xprt))
-		return (struct rpc_clnt *)xprt;
-	xprt->resvport = 1;	/* NSM requires a reserved port */
-
-	clnt = rpc_create_client(xprt, "localhost",
-				&nsm_program, SM_VERSION,
-				RPC_AUTH_NULL);
-	if (IS_ERR(clnt))
-		goto out_err;
-	clnt->cl_softrtry = 1;
-	clnt->cl_oneshot  = 1;
-	return clnt;
-
-out_err:
-	return clnt;
+	struct sockaddr_in	sin = {
+		.sin_family	= AF_INET,
+		.sin_addr.s_addr = htonl(INADDR_LOOPBACK),
+		.sin_port	= 0,
+	};
+	struct rpc_create_args args = {
+		.protocol	= IPPROTO_UDP,
+		.address	= (struct sockaddr *)&sin,
+		.addrsize	= sizeof(sin),
+		.servername	= "localhost",
+		.program	= &nsm_program,
+		.version	= SM_VERSION,
+		.authflavor	= RPC_AUTH_NULL,
+		.flags		= (RPC_CLNT_CREATE_ONESHOT),
+	};
+
+	return rpc_create(&args);
 }
 
 /*

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
