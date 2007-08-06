From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/20] SUNRPC: add support for IPv6 to the kernel's
	rpcbind	client
Date: Mon, 06 Aug 2007 11:57:18 -0400
Message-ID: <20070806155717.31233.17792.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4xR-00011R-H6
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:25 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4xV-00064s-BN
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:29 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Prepare for adding IPv6 support to the RPC client by adding IPv6
capabilities to rpcbind.  Note that this is support on the query side
only; registering IPv6 addresses with the local portmapper will come
later.

Note we have to take care not to fall back to using version 2 of the
rpcbind protocol if we're dealing with IPv6 address.  Version 2 doesn't
support IPv6 at all.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 net/sunrpc/rpcb_clnt.c |   48 +++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 43 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index eae711f..73c0381 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -16,6 +16,8 @@
 
 #include <linux/types.h>
 #include <linux/socket.h>
+#include <linux/in.h>
+#include <linux/in6.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
 
@@ -137,10 +139,13 @@ struct rpcbind_args {
 static struct rpc_procinfo rpcb_procedures2[];
 static struct rpc_procinfo rpcb_procedures3[];
 
-static struct rpcb_info {
+struct rpcb_info {
 	int			rpc_vers;
 	struct rpc_procinfo *	rpc_proc;
-} rpcb_next_version[];
+};
+
+static struct rpcb_info rpcb_next_version[];
+static struct rpcb_info rpcb_next_version6[];
 
 static void rpcb_getport_prepare(struct rpc_task *task, void *calldata)
 {
@@ -190,7 +195,17 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 				   RPC_CLNT_CREATE_INTR),
 	};
 
-	((struct sockaddr_in *)srvaddr)->sin_port = htons(RPCBIND_PORT);
+	switch (srvaddr->sa_family) {
+	case AF_INET:
+		((struct sockaddr_in *)srvaddr)->sin_port = htons(RPCBIND_PORT);
+		break;
+	case AF_INET6:
+		((struct sockaddr_in6 *)srvaddr)->sin6_port = htons(RPCBIND_PORT);
+		break;
+	default:
+		return NULL;
+	}
+
 	if (!privileged)
 		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 	return rpc_create(&args);
@@ -316,6 +331,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	struct rpc_task	*child;
 	struct sockaddr addr;
 	int status;
+	struct rpcb_info *info;
 
 	dprintk("RPC: %5u %s(%s, %u, %u, %d)\n",
 		task->tk_pid, __FUNCTION__,
@@ -343,14 +359,28 @@ void rpcb_getport_async(struct rpc_task *task)
 		goto bailout_nofree;
 	}
 
-	if (rpcb_next_version[xprt->bind_index].rpc_proc == NULL) {
+	/* Don't ever use rpcbind v2 for AF_INET6 requests */
+	switch (addr.sa_family) {
+	case AF_INET:
+		info = rpcb_next_version;
+		break;
+	case AF_INET6:
+		info = rpcb_next_version6;
+		break;
+	default:
+		status = -EAFNOSUPPORT;
+		dprintk("RPC: %5u %s: bad address family\n",
+				task->tk_pid, __FUNCTION__);
+		goto bailout_nofree;
+	}
+	if (info[xprt->bind_index].rpc_proc == NULL) {
 		xprt->bind_index = 0;
 		status = -EACCES;	/* tell caller to try again later */
 		dprintk("RPC: %5u %s: no more getport versions available\n",
 			task->tk_pid, __FUNCTION__);
 		goto bailout_nofree;
 	}
-	bind_version = rpcb_next_version[xprt->bind_index].rpc_vers;
+	bind_version = info[xprt->bind_index].rpc_vers;
 
 	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
 		task->tk_pid, __FUNCTION__, bind_version);
@@ -594,6 +624,14 @@ static struct rpcb_info rpcb_next_version[] = {
 	{ 0, NULL },
 };
 
+static struct rpcb_info rpcb_next_version6[] = {
+#ifdef CONFIG_SUNRPC_BIND34
+	{ 4, &rpcb_procedures4[RPCBPROC_GETVERSADDR] },
+	{ 3, &rpcb_procedures3[RPCBPROC_GETADDR] },
+#endif
+	{ 0, NULL },
+};
+
 static struct rpc_version rpcb_version2 = {
 	.number		= 2,
 	.nrprocs	= RPCB_HIGHPROC_2,


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
