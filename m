From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/15] SUNRPC: Add a new error code for retry waiting
	for	another binder
Date: Tue, 11 Sep 2007 18:00:41 -0400
Message-ID: <20070911220041.26136.31895.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDnL-0006xz-F1
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:19 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDnQ-0005Ul-2w
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:24 -0700
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

Add new error code processing to the kernel's rpcbind client and to
call_bind_status() to distinguish two cases:

Case 1: the remote has replied that the program/version tuple is not
registered (returns -EACCES)

Case 2: another process is already in the middle of binding on this
transport (now returns -EAGAIN)

This change allows more specific retry processing for each of these two
cases.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c      |    6 ++++++
 net/sunrpc/rpcb_clnt.c |    2 +-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7a7cd3b..e53d718 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -950,6 +950,12 @@ call_bind_status(struct rpc_task *task)
 	}
 
 	switch (task->tk_status) {
+	case -EAGAIN:
+		dprintk("RPC: %5u rpcbind waiting for another request "
+				"to finish\n", task->tk_pid);
+		/* avoid busy-waiting here -- could be a network outage. */
+		rpc_delay(task, 5*HZ);
+		goto retry_timeout;
 	case -EACCES:
 		dprintk("RPC: %5u remote rpcbind: RPC program/version "
 				"unavailable\n", task->tk_pid);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index a0c9f69..9b06a21 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -341,7 +341,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	BUG_ON(clnt->cl_parent != clnt);
 
 	if (xprt_test_and_set_binding(xprt)) {
-		status = -EACCES;		/* tell caller to check again */
+		status = -EAGAIN;	/* tell caller to check again */
 		dprintk("RPC: %5u %s: waiting for another binder\n",
 			task->tk_pid, __FUNCTION__);
 		goto bailout_nowake;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
