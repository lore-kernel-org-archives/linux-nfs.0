From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] SUNRPC: Fix generation of universal addresses
	for	GETVERSADDR requests
Date: Thu, 16 Aug 2007 16:03:31 -0400
Message-ID: <20070816200331.3831.17252.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILlZJ-0005iC-Kn
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 13:03:45 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ILlZM-0003Yi-HU
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 13:03:49 -0700
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

Fix some problems with rpcbind v3 and v4 queries from the in-kernel rpcbind
client:

1.  The r_addr argument must be a full universal address, not just an IP
address, and

2.  The universal address in r_addr is the address of the remote rpcbind
server, not the RPC service being requested

This addresses bugzilla.kernel.org report 8891 for 2.6.23-rc and greater.

In addition, if the rpcbind client is unable to start the rpcbind request,
make sure not to leak the xprt.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 4d6ed4e..0f5ccf1 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -387,6 +387,15 @@ void rpcb_getport_async(struct rpc_task *task)
 	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
 		task->tk_pid, __FUNCTION__, bind_version);
 
+	rpcb_clnt = rpcb_create(clnt->cl_server, &addr, xprt->prot,
+				bind_version, 0);
+	if (IS_ERR(rpcb_clnt)) {
+		status = PTR_ERR(rpcb_clnt);
+		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",
+			task->tk_pid, __FUNCTION__, PTR_ERR(rpcb_clnt));
+		goto bailout_nofree;
+	}
+
 	map = kzalloc(sizeof(struct rpcbind_args), GFP_ATOMIC);
 	if (!map) {
 		status = -ENOMEM;
@@ -401,25 +410,18 @@ void rpcb_getport_async(struct rpc_task *task)
 	map->r_xprt = xprt_get(xprt);
 	map->r_netid = (xprt->prot == IPPROTO_TCP) ? RPCB_NETID_TCP :
 						   RPCB_NETID_UDP;
-	memcpy(&map->r_addr, rpc_peeraddr2str(clnt, RPC_DISPLAY_ADDR),
-			sizeof(map->r_addr));
+	memcpy(&map->r_addr,
+	       rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR),
+	       sizeof(map->r_addr));
 	map->r_owner = RPCB_OWNER_STRING;	/* ignored for GETADDR */
 
-	rpcb_clnt = rpcb_create(clnt->cl_server, &addr, xprt->prot, bind_version, 0);
-	if (IS_ERR(rpcb_clnt)) {
-		status = PTR_ERR(rpcb_clnt);
-		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",
-			task->tk_pid, __FUNCTION__, PTR_ERR(rpcb_clnt));
-		goto bailout;
-	}
-
 	child = rpc_run_task(rpcb_clnt, RPC_TASK_ASYNC, &rpcb_getport_ops, map);
 	rpc_release_client(rpcb_clnt);
 	if (IS_ERR(child)) {
 		status = -EIO;
 		dprintk("RPC: %5u %s: rpc_run_task failed\n",
 			task->tk_pid, __FUNCTION__);
-		goto bailout_nofree;
+		goto bailout;
 	}
 	rpc_put_task(child);
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
