From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 20/25] SUNRPC: Convert RPC portmapper to use new
	rpc_create() API
Date: Wed, 09 Aug 2006 10:59:38 -0400
Message-ID: <20060809145938.3914.70044.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcS-0000oh-GX
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:16 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcS-0005kN-7e
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:17 -0700
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

Replace xprt_create_proto/rpc_create_client calls in pmap_clnt.c with new
rpc_create() API.

Test plan:
Repeated runs of Connectathon locking suite.  Check network trace for
proper PMAP calls and replies.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/pmap_clnt.c |   30 ++++++++++++++----------------
 1 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/pmap_clnt.c b/net/sunrpc/pmap_clnt.c
index 689333f..0fc45eb 100644
--- a/net/sunrpc/pmap_clnt.c
+++ b/net/sunrpc/pmap_clnt.c
@@ -279,24 +279,22 @@ int rpc_register(u32 prog, u32 vers, int
 
 static struct rpc_clnt *pmap_create(char *hostname, struct sockaddr_in *srvaddr, int proto, int privileged)
 {
-	struct rpc_xprt	*xprt;
-	struct rpc_clnt	*clnt;
+	struct rpc_create_args args = {
+		.protocol	= proto,
+		.address	= (struct sockaddr *)srvaddr,
+		.addrsize	= sizeof(*srvaddr),
+		.servername	= hostname,
+		.program	= &pmap_program,
+		.version	= RPC_PMAP_VERSION,
+		.authflavor	= RPC_AUTH_UNIX,
+		.flags		= (RPC_CLNT_CREATE_ONESHOT |
+				   RPC_CLNT_CREATE_NOPING),
+	};
 
-	xprt = xprt_create_proto(proto, srvaddr, NULL);
-	if (IS_ERR(xprt))
-		return (struct rpc_clnt *)xprt;
-	xprt->ops->set_port(xprt, RPC_PMAP_PORT);
+	srvaddr->sin_port = htons(RPC_PMAP_PORT);
 	if (!privileged)
-		xprt->resvport = 0;
-
-	clnt = rpc_new_client(xprt, hostname,
-				&pmap_program, RPC_PMAP_VERSION,
-				RPC_AUTH_UNIX);
-	if (!IS_ERR(clnt)) {
-		clnt->cl_softrtry = 1;
-		clnt->cl_oneshot  = 1;
-	}
-	return clnt;
+		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
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
