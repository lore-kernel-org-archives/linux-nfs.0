From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 09/25] SUNRPC: Teach the RPC portmapper to use the new
	rpc_peeraddr() API.
Date: Wed, 09 Aug 2006 10:59:11 -0400
Message-ID: <20060809145911.3914.93589.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcT-0000ol-5c
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:18 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcT-0003GK-7X
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

Hide the details of how the RPC client stores remote peer addresses from
the RPC portmapper.

Test plan:
Destructive testing (unplugging the network temporarily).  Connectathon
with UDP and TCP.  NFSv2/3 and NFSv4 mounting should be carefully checked.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/pmap_clnt.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/pmap_clnt.c b/net/sunrpc/pmap_clnt.c
index 66f18d0..ff0b92c 100644
--- a/net/sunrpc/pmap_clnt.c
+++ b/net/sunrpc/pmap_clnt.c
@@ -89,7 +89,7 @@ void rpc_getport(struct rpc_task *task)
 {
 	struct rpc_clnt *clnt = task->tk_client;
 	struct rpc_xprt *xprt = task->tk_xprt;
-	struct sockaddr_in *sap = &xprt->addr;
+	struct sockaddr_in addr;
 	struct portmap_args *map;
 	struct rpc_clnt	*pmap_clnt;
 	struct rpc_task *child;
@@ -124,7 +124,8 @@ void rpc_getport(struct rpc_task *task)
 	map->pm_port = 0;
 	map->pm_task = task;
 
-	pmap_clnt = pmap_create(clnt->cl_server, sap, map->pm_prot, 0);
+	rpc_peeraddr(clnt, (struct sockaddr *) &addr, sizeof(addr));
+	pmap_clnt = pmap_create(clnt->cl_server, &addr, map->pm_prot, 0);
 	if (IS_ERR(pmap_clnt)) {
 		task->tk_status = PTR_ERR(pmap_clnt);
 		goto bailout;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
