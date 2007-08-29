From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] SUNRPC: Clean up rpcbind error handling
Date: Wed, 29 Aug 2007 15:49:30 -0400
Message-ID: <20070829194930.14142.30785.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQTYM-0007Jp-AB
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:50:14 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQTYP-0000mK-Ll
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:50:18 -0700
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

Add a comment and clarify an error message or two.  Also clean up the
default error code returned by call_bind_status() for non-specific errors.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 5590bb7..9a220af 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -937,7 +937,7 @@ call_bind(struct rpc_task *task)
 static void
 call_bind_status(struct rpc_task *task)
 {
-	int status = -EACCES;
+	int status = -EIO;
 
 	if (task->tk_status >= 0) {
 		dprint_status(task);
@@ -960,6 +960,7 @@ call_bind_status(struct rpc_task *task)
 	case -ETIMEDOUT:
 		dprintk("RPC: %5u rpcbind request timed out\n",
 				task->tk_pid);
+		/* no need to delay before retrying */
 		goto retry_timeout;
 	case -ENOPROTOOPT:
 		dprintk("RPC: %5u no remote rpcbind versions available\n",
@@ -968,15 +969,14 @@ call_bind_status(struct rpc_task *task)
 		rpc_delay(task, 5*HZ);
 		goto retry_timeout;
 	case -EPROTONOSUPPORT:
-		dprintk("RPC: %5u remote rpcbind version unavailable, retrying\n",
+		dprintk("RPC: %5u retrying with different rpcbind version\n",
 				task->tk_pid);
 		task->tk_status = 0;
 		task->tk_action = call_bind;
 		return;
 	default:
-		dprintk("RPC: %5u unrecognized rpcbind error (%d)\n",
+		dprintk("RPC: %5u rpcbind error (%d)\n",
 				task->tk_pid, -task->tk_status);
-		status = -EIO;
 	}
 
 	rpc_exit(task, status);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
