From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/8] SUNRPC: Add a new error code for retry waiting
	for	another binder
Date: Wed, 29 Aug 2007 15:49:26 -0400
Message-ID: <20070829194926.14142.65866.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQTXo-0007Cp-QU
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:49:40 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQTXt-0003NY-6Y
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:49:45 -0700
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

We want to make rpcbind error recovery processing more specific in the next
few patches in order to handle RPC pings slightly differently.  The -EACCES
return code is overloaded, so the following patches change rpcb_clnt to use
unique error codes in some cases where -EACCES is now returned.

Add processing in call_bind_status() for an -EAGAIN return code to simply
retry the same bind request a little later.  Change rpcb_clnt to use it
appropriately.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c      |    5 +++++
 net/sunrpc/rpcb_clnt.c |    2 +-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 52429b1..e5ccf64 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -952,6 +952,11 @@ call_bind_status(struct rpc_task *task)
 				"unavailable\n", task->tk_pid);
 		rpc_delay(task, 3*HZ);
 		goto retry_timeout;
+	case -EAGAIN:
+		dprintk("RPC: %5u rpcb requested a retry", task->tk_pid);
+		/* avoid busy-waiting here -- could be a network outage. */
+		rpc_delay(task, 5*HZ);
+		goto retry_timeout;
 	case -ETIMEDOUT:
 		dprintk("RPC: %5u rpcbind request timed out\n",
 				task->tk_pid);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index d1740db..01f4b3f 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -325,7 +325,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	BUG_ON(clnt->cl_parent != clnt);
 
 	if (xprt_test_and_set_binding(xprt)) {
-		status = -EACCES;		/* tell caller to check again */
+		status = -EAGAIN;	/* tell caller to check again later */
 		dprintk("RPC: %5u %s: waiting for another binder\n",
 			task->tk_pid, __FUNCTION__);
 		goto bailout_nowake;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
