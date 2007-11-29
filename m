From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 03/29] SUNRPC: Fix socket address handling in rpcb_clnt
Date: Thu, 29 Nov 2007 14:40:07 -0500
Message-ID: <20071129194007.4170.2959.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpGm-0001Wd-0i
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:56 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpGr-00026U-Oy
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:42:02 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Make sure rpcb_clnt passes the correct address length to rpc_create().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   30 +++++++++++++++++-------------
 1 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index a05493a..e69c0d2 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -161,13 +161,14 @@ static void rpcb_wake_rpcbind_waiters(struct rpc_xprt *xprt, int status)
 	rpc_wake_up_status(&xprt->binding, status);
 }
 
-static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
-					int proto, int version, int privileged)
+static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *sap,
+				    size_t salen, unsigned int proto,
+				    unsigned int version, int privileged)
 {
 	struct rpc_create_args args = {
 		.protocol	= proto,
-		.address	= srvaddr,
-		.addrsize	= sizeof(struct sockaddr_in),
+		.address	= sap,
+		.addrsize	= salen,
 		.servername	= hostname,
 		.program	= &rpcb_program,
 		.version	= version,
@@ -176,12 +177,12 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 				   RPC_CLNT_CREATE_INTR),
 	};
 
-	switch (srvaddr->sa_family) {
+	switch (sap->sa_family) {
 	case AF_INET:
-		((struct sockaddr_in *)srvaddr)->sin_port = htons(RPCBIND_PORT);
+		((struct sockaddr_in *)sap)->sin_port = htons(RPCBIND_PORT);
 		break;
 	case AF_INET6:
-		((struct sockaddr_in6 *)srvaddr)->sin6_port = htons(RPCBIND_PORT);
+		((struct sockaddr_in6 *)sap)->sin6_port = htons(RPCBIND_PORT);
 		break;
 	default:
 		return NULL;
@@ -230,7 +231,7 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 			prog, vers, prot, port);
 
 	rpcb_clnt = rpcb_create("localhost", (struct sockaddr *) &sin,
-					XPRT_TRANSPORT_UDP, 2, 1);
+				sizeof(sin), XPRT_TRANSPORT_UDP, 2, 1);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 
@@ -279,7 +280,8 @@ int rpcb_getport_sync(struct sockaddr_in *sin, __u32 prog,
 		__FUNCTION__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
 	sprintf(hostname, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
-	rpcb_clnt = rpcb_create(hostname, (struct sockaddr *)sin, prot, 2, 0);
+	rpcb_clnt = rpcb_create(hostname, (struct sockaddr *)sin,
+				sizeof(sin), prot, 2, 0);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 
@@ -310,7 +312,9 @@ void rpcb_getport_async(struct rpc_task *task)
 	struct rpc_clnt	*rpcb_clnt;
 	static struct rpcbind_args *map;
 	struct rpc_task	*child;
-	struct sockaddr addr;
+	struct sockaddr_storage addr;
+	struct sockaddr *sap = (struct sockaddr *)&addr;
+	size_t salen;
 	int status;
 	struct rpcb_info *info;
 
@@ -340,10 +344,10 @@ void rpcb_getport_async(struct rpc_task *task)
 		goto bailout_nofree;
 	}
 
-	rpc_peeraddr(clnt, (void *)&addr, sizeof(addr));
+	salen = rpc_peeraddr(clnt, sap, sizeof(addr));
 
 	/* Don't ever use rpcbind v2 for AF_INET6 requests */
-	switch (addr.sa_family) {
+	switch (sap->sa_family) {
 	case AF_INET:
 		info = rpcb_next_version;
 		break;
@@ -368,7 +372,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
 		task->tk_pid, __FUNCTION__, bind_version);
 
-	rpcb_clnt = rpcb_create(clnt->cl_server, &addr, xprt->prot,
+	rpcb_clnt = rpcb_create(clnt->cl_server, sap, salen, xprt->prot,
 				bind_version, 0);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

