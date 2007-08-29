From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/8] SUNRPC: Add a new rpcbind error code for version
	retry	exhaustion
Date: Wed, 29 Aug 2007 15:49:28 -0400
Message-ID: <20070829194928.14142.79042.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQTXu-0007D3-Ed
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:49:46 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQTXx-0000T3-SL
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:49:51 -0700
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

Replace processing in call_bind_status() for the unused error code
-EPFNOSUPPORT with processing for -ENOPROTOOPT (which more closely matches
the semantics we want).  Change rpcb_clnt to use the new error code when it
recognizes that it has tried all rpcbind versions it supports, and the
server claims not to support any of them.  Treat this as a temporary server
misconfiguration.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c      |    8 +++++---
 net/sunrpc/rpcb_clnt.c |    2 +-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e5ccf64..5590bb7 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -961,10 +961,12 @@ call_bind_status(struct rpc_task *task)
 		dprintk("RPC: %5u rpcbind request timed out\n",
 				task->tk_pid);
 		goto retry_timeout;
-	case -EPFNOSUPPORT:
-		dprintk("RPC: %5u remote rpcbind service unavailable\n",
+	case -ENOPROTOOPT:
+		dprintk("RPC: %5u no remote rpcbind versions available\n",
 				task->tk_pid);
-		break;
+		/* treat as a temporary server configuration error */
+		rpc_delay(task, 5*HZ);
+		goto retry_timeout;
 	case -EPROTONOSUPPORT:
 		dprintk("RPC: %5u remote rpcbind version unavailable, retrying\n",
 				task->tk_pid);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 01f4b3f..f44dda4 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -345,7 +345,7 @@ void rpcb_getport_async(struct rpc_task *task)
 
 	if (rpcb_next_version[xprt->bind_index].rpc_proc == NULL) {
 		xprt->bind_index = 0;
-		status = -EACCES;	/* tell caller to try again later */
+		status = -ENOPROTOOPT;
 		dprintk("RPC: %5u %s: no more getport versions available\n",
 			task->tk_pid, __FUNCTION__);
 		goto bailout_nofree;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
