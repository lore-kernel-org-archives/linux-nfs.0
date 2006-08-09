From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 04/25] SUNRPC: Clean-up after recent changes to
	sunrpc/pmap_clnt.c
Date: Wed, 09 Aug 2006 10:58:59 -0400
Message-ID: <20060809145859.3914.29665.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApWU-0008K1-7p
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 07:59:06 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApWU-0000vk-Ip
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 07:59:06 -0700
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

Add comments for external functions, use modern function definition style,
and fix up dprintk formatting.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/pmap_clnt.c |   70 +++++++++++++++++++++++++++++-------------------
 1 files changed, 42 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/pmap_clnt.c b/net/sunrpc/pmap_clnt.c
index 1dad361..1f80ad1 100644
--- a/net/sunrpc/pmap_clnt.c
+++ b/net/sunrpc/pmap_clnt.c
@@ -1,7 +1,9 @@
 /*
- * linux/net/sunrpc/pmap.c
+ * linux/net/sunrpc/pmap_clnt.c
  *
- * Portmapper client.
+ * In-kernel RPC portmapper client.
+ *
+ * Portmapper supports version 2 of the rpcbind protocol (RFC 1833).
  *
  * Copyright (C) 1996, Olaf Kirch <okir@monad.swb.de>
  */
@@ -76,12 +78,15 @@ static inline void pmap_wake_portmap_wai
 	rpc_wake_up(&xprt->binding);
 }
 
-/*
- * Obtain the port for a given RPC service on a given host. This one can
- * be called for an ongoing RPC request.
+/**
+ * rpc_getport - obtain the port for a given RPC service on a given host
+ * @task: task that is waiting for portmapper request
+ * @clnt: controlling rpc_clnt
+ *
+ * This one can be called for an ongoing RPC request, and can be used in
+ * an async (rpciod) context.
  */
-void
-rpc_getport(struct rpc_task *task, struct rpc_clnt *clnt)
+void rpc_getport(struct rpc_task *task, struct rpc_clnt *clnt)
 {
 	struct rpc_xprt *xprt = task->tk_xprt;
 	struct sockaddr_in *sap = &xprt->addr;
@@ -144,8 +149,16 @@ bailout_nofree:
 }
 
 #ifdef CONFIG_ROOT_NFS
-int
-rpc_getport_external(struct sockaddr_in *sin, __u32 prog, __u32 vers, int prot)
+/**
+ * rpc_getport_external - obtain the port for a given RPC service on a given host
+ * @sin: address of remote peer
+ * @prog: RPC program number to bind
+ * @vers: RPC version number to bind
+ * @prot: transport protocol to use to make this request
+ *
+ * This one is called from outside the RPC client in a synchronous task context.
+ */
+int rpc_getport_external(struct sockaddr_in *sin, __u32 prog, __u32 vers, int prot)
 {
 	struct portmap_args map = {
 		.pm_prog	= prog,
@@ -162,7 +175,7 @@ rpc_getport_external(struct sockaddr_in 
 	char		hostname[32];
 	int		status;
 
-	dprintk("RPC:      rpc_getport_external(%u.%u.%u.%u, %d, %d, %d)\n",
+	dprintk("RPC:      rpc_getport_external(%u.%u.%u.%u, %u, %u, %d)\n",
 			NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
 	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(sin->sin_addr.s_addr));
@@ -182,8 +195,10 @@ rpc_getport_external(struct sockaddr_in 
 }
 #endif
 
-static void
-pmap_getport_done(struct rpc_task *child, void *data)
+/*
+ * Portmapper child task invokes this callback via tk_exit.
+ */
+static void pmap_getport_done(struct rpc_task *child, void *data)
 {
 	struct portmap_args *map = data;
 	struct rpc_task *task = map->pm_task;
@@ -209,12 +224,17 @@ pmap_getport_done(struct rpc_task *child
 	pmap_wake_portmap_waiters(xprt);
 }
 
-/*
- * Set or unset a port registration with the local portmapper.
+/**
+ * rpc_register - set or unset a port registration with the local portmapper
+ * @prog: RPC program number to bind
+ * @vers: RPC version number to bind
+ * @prot: transport protocol to use to make this request
+ * @port: port value to register
+ * @okay: result code
+ *
  * port == 0 means unregister, port != 0 means register.
  */
-int
-rpc_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
+int rpc_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 {
 	struct sockaddr_in	sin = {
 		.sin_family	= AF_INET,
@@ -234,7 +254,7 @@ rpc_register(u32 prog, u32 vers, int pro
 	struct rpc_clnt		*pmap_clnt;
 	int error = 0;
 
-	dprintk("RPC: registering (%d, %d, %d, %d) with portmapper.\n",
+	dprintk("RPC: registering (%u, %u, %d, %u) with portmapper.\n",
 			prog, vers, prot, port);
 
 	pmap_clnt = pmap_create("localhost", &sin, IPPROTO_UDP, 1);
@@ -257,13 +277,11 @@ rpc_register(u32 prog, u32 vers, int pro
 	return error;
 }
 
-static struct rpc_clnt *
-pmap_create(char *hostname, struct sockaddr_in *srvaddr, int proto, int privileged)
+static struct rpc_clnt *pmap_create(char *hostname, struct sockaddr_in *srvaddr, int proto, int privileged)
 {
 	struct rpc_xprt	*xprt;
 	struct rpc_clnt	*clnt;
 
-	/* printk("pmap: create xprt\n"); */
 	xprt = xprt_create_proto(proto, srvaddr, NULL);
 	if (IS_ERR(xprt))
 		return (struct rpc_clnt *)xprt;
@@ -271,7 +289,6 @@ pmap_create(char *hostname, struct socka
 	if (!privileged)
 		xprt->resvport = 0;
 
-	/* printk("pmap: create clnt\n"); */
 	clnt = rpc_new_client(xprt, hostname,
 				&pmap_program, RPC_PMAP_VERSION,
 				RPC_AUTH_UNIX);
@@ -285,10 +302,9 @@ pmap_create(char *hostname, struct socka
 /*
  * XDR encode/decode functions for PMAP
  */
-static int
-xdr_encode_mapping(struct rpc_rqst *req, u32 *p, struct portmap_args *map)
+static int xdr_encode_mapping(struct rpc_rqst *req, u32 *p, struct portmap_args *map)
 {
-	dprintk("RPC: xdr_encode_mapping(%d, %d, %d, %d)\n",
+	dprintk("RPC: xdr_encode_mapping(%u, %u, %u, %u)\n",
 		map->pm_prog, map->pm_vers, map->pm_prot, map->pm_port);
 	*p++ = htonl(map->pm_prog);
 	*p++ = htonl(map->pm_vers);
@@ -299,15 +315,13 @@ xdr_encode_mapping(struct rpc_rqst *req,
 	return 0;
 }
 
-static int
-xdr_decode_port(struct rpc_rqst *req, u32 *p, unsigned short *portp)
+static int xdr_decode_port(struct rpc_rqst *req, u32 *p, unsigned short *portp)
 {
 	*portp = (unsigned short) ntohl(*p++);
 	return 0;
 }
 
-static int
-xdr_decode_bool(struct rpc_rqst *req, u32 *p, unsigned int *boolp)
+static int xdr_decode_bool(struct rpc_rqst *req, u32 *p, unsigned int *boolp)
 {
 	*boolp = (unsigned int) ntohl(*p++);
 	return 0;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
