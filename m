From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/11] SUNRPC: Allow RPCs to fail quickly if the server is
	unreachable
Date: Thu, 05 Nov 2009 13:23:05 -0500
Message-ID: <20091105182304.2796.76586.stgit@matisse.1015granger.net>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:43326
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758158AbZKESXI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2009 13:23:08 -0500
In-Reply-To: <20091105181924.2796.9313.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel sometimes makes RPC calls to services that aren't running.
Because the kernel's RPC client always assumes the hard retry semantic
when reconnecting a connection-oriented RPC transport, the underlying
reconnect logic takes a long while to time out, even though the remote
may have responded immediately with ECONNREFUSED.

In certain cases, like upcalls to our local rpcbind daemon, or for NFS
mount requests, we'd like the kernel to fail immediately if the remote
service isn't reachable.  This allows another transport to be tried
immediately, or the pending request can be abandoned quickly.

Introduce a per-request flag which controls how call_transmit_status()
behaves when request transmission fails because the server cannot be
reached.

We don't want soft connection semantics to apply to other errors.  The
default case of the switch statement in call_transmit_status() no
longer falls through; the fall through code is copied to the default
case, and a "break;" is added.

The transport's connection re-establishment timeout is also ignored for
such requests.  We want the request to fail immediately, so the
reconnect delay is skipped.  Additionally, we don't want a connect
failure here to further increase the reconnect timeout value, since
this request will not be retried.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/sched.h |    2 ++
 net/sunrpc/clnt.c            |   11 +++++++++--
 net/sunrpc/xprtsock.c        |    2 +-
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 4010977..1906782 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -130,12 +130,14 @@ struct rpc_task_setup {
 #define RPC_TASK_DYNAMIC	0x0080		/* task was kmalloc'ed */
 #define RPC_TASK_KILLED		0x0100		/* task was killed */
 #define RPC_TASK_SOFT		0x0200		/* Use soft timeouts */
+#define RPC_TASK_SOFTCONN	0x0400		/* Fail if can't connect */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
 #define RPC_DO_ROOTOVERRIDE(t)	((t)->tk_flags & RPC_TASK_ROOTCREDS)
 #define RPC_ASSASSINATED(t)	((t)->tk_flags & RPC_TASK_KILLED)
 #define RPC_IS_SOFT(t)		((t)->tk_flags & RPC_TASK_SOFT)
+#define RPC_IS_SOFTCONN(t)	((t)->tk_flags & RPC_TASK_SOFTCONN)
 
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7bcd931..68a2358 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1197,6 +1197,8 @@ call_transmit_status(struct rpc_task *task)
 	default:
 		dprint_status(task);
 		xprt_end_transmit(task);
+		rpc_task_force_reencode(task);
+		break;
 		/*
 		 * Special cases: if we've been waiting on the
 		 * socket's write_space() callback, or if the
@@ -1204,11 +1206,16 @@ call_transmit_status(struct rpc_task *task)
 		 * then hold onto the transport lock.
 		 */
 	case -ECONNREFUSED:
-	case -ECONNRESET:
-	case -ENOTCONN:
 	case -EHOSTDOWN:
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
+		if (RPC_IS_SOFTCONN(task)) {
+			xprt_end_transmit(task);
+			rpc_exit(task, task->tk_status);
+			break;
+		}
+	case -ECONNRESET:
+	case -ENOTCONN:
 	case -EPIPE:
 		rpc_task_force_reencode(task);
 	}
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 37c5475..ff312f8 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2033,7 +2033,7 @@ static void xs_connect(struct rpc_task *task)
 	if (xprt_test_and_set_connecting(xprt))
 		return;
 
-	if (transport->sock != NULL) {
+	if (transport->sock != NULL && !RPC_IS_SOFTCONN(task)) {
 		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
 				"seconds\n",
 				xprt, xprt->reestablish_timeout / HZ);

