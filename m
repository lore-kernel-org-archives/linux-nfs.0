From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/15] SUNRPC: Split another new rpcbind retry error
	code from	EACCES
Date: Tue, 11 Sep 2007 18:00:47 -0400
Message-ID: <20070911220047.26136.60928.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDn2-0006rZ-Lm
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:00 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDn7-0001sK-5l
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:05 -0700
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

Add more new error code processing to the kernel's rpcbind client
and to call_bind_status() to distinguish two cases:

Case 1: the remote has replied that the program/version tuple is not
registered (returns EACCES)

Case 2: retry with a lesser rpcbind version (rpcb now returns EPFNOSUPPORT)

This change allows more specific error processing for each of these two
cases.  We now fail case 2 instead of retrying... it's a server
configuration error not to support even rpcbind version 2.  And don't
expose this new error code to user land -- convert it to EIO before
failing the RPC.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c      |    4 ++--
 net/sunrpc/rpcb_clnt.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e53d718..04f6e15 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -940,7 +940,7 @@ call_bind(struct rpc_task *task)
 static void
 call_bind_status(struct rpc_task *task)
 {
-	int status = -EACCES;
+	int status = -EIO;
 
 	if (task->tk_status >= 0) {
 		dprint_status(task);
@@ -966,6 +966,7 @@ call_bind_status(struct rpc_task *task)
 				task->tk_pid);
 		goto retry_timeout;
 	case -EPFNOSUPPORT:
+		/* server doesn't support any rpcbind version we know of */
 		dprintk("RPC: %5u remote rpcbind service unavailable\n",
 				task->tk_pid);
 		break;
@@ -978,7 +979,6 @@ call_bind_status(struct rpc_task *task)
 	default:
 		dprintk("RPC: %5u unrecognized rpcbind error (%d)\n",
 				task->tk_pid, -task->tk_status);
-		status = -EIO;
 	}
 
 	rpc_exit(task, status);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 9b06a21..d7b9f02 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -377,7 +377,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	}
 	if (info[xprt->bind_index].rpc_proc == NULL) {
 		xprt->bind_index = 0;
-		status = -EACCES;	/* tell caller to try again later */
+		status = -EPFNOSUPPORT;
 		dprintk("RPC: %5u %s: no more getport versions available\n",
 			task->tk_pid, __FUNCTION__);
 		goto bailout_nofree;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
