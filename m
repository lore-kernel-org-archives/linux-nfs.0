From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/8] SUNRPC: RPC bind failures should be permanent for
	NULL	requests
Date: Wed, 29 Aug 2007 15:49:33 -0400
Message-ID: <20070829194932.14142.78680.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQTYM-0007Jo-8M
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:50:14 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQTYP-0003fE-Le
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

The purpose of an RPC ping (a NULL request) is to determine whether the
remote end is operating and supports the program and version of the
request.

If we do an RPC bind and the remote's rpcbind service says "this program or
service isn't supported" then we have our answer already, and we should
give up immediately.

This is good for the kernel mount client, as it will cause the request to
fail quickly, and then allow an immediate retry with different options.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 9a220af..8fc05a1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -949,7 +949,12 @@ call_bind_status(struct rpc_task *task)
 	switch (task->tk_status) {
 	case -EACCES:
 		dprintk("RPC: %5u remote rpcbind: RPC program/version "
-				"unavailable\n", task->tk_pid);
+				"not available\n", task->tk_pid);
+		/* fail immediately if this is an RPC ping */
+		if (task->tk_msg.rpc_proc->p_proc == 0) {
+			status = -ENOPROTOOPT;
+			break;
+		}
 		rpc_delay(task, 3*HZ);
 		goto retry_timeout;
 	case -EAGAIN:


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
