From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/15] SUNRPC: RPC bind failures should be permanent
	for NULL	requests
Date: Tue, 11 Sep 2007 18:00:52 -0400
Message-ID: <20070911220052.26136.90336.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDn9-0006ww-QU
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:07 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDnD-0005Qw-4o
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:12 -0700
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
remote end is operating and supports the RPC program and version of the
request.

If we do an RPC bind and the remote's rpcbind service says "this
program or service isn't supported" then we have our answer already,
and we should give up immediately.

This is good for the kernel mount client, as it will cause the request
to fail, and then allow an immediate retry with different options.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 04f6e15..b19bacf 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -959,6 +959,11 @@ call_bind_status(struct rpc_task *task)
 	case -EACCES:
 		dprintk("RPC: %5u remote rpcbind: RPC program/version "
 				"unavailable\n", task->tk_pid);
+		/* fail immediately if this is an RPC ping */
+		if (task->tk_msg.rpc_proc->p_proc == 0) {
+			status = -EOPNOTSUPP;
+			break;
+		}
 		rpc_delay(task, 3*HZ);
 		goto retry_timeout;
 	case -ETIMEDOUT:


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
