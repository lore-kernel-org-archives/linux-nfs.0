Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53950 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238AbbFOFzj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2015 01:55:39 -0400
Date: Mon, 15 Jun 2015 15:55:30 +1000
From: Neil Brown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] SUNRPC: never enqueue a ->rq_cong request on ->sending
Message-ID: <20150615155530.3e0e40f4@home.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



If the sending queue has a task without ->rq_cong set at the front,
and then a number of tasks with ->rq_cong set such that they use
the entire congestion window, then the queue deadlocks.  The first
entry cannot be processed until later entries complete.

This scenario has been seen with a client using UDP to access a server,
and the network connection breaking for a period of time - it doesn't
recover.

It never really makes sense for an ->rq_cong request to be on the ->sending
queue, but it can happen when a request is being retried, and finds
the transport if locked (XPRT_LOCKED).  In this case we simple call
__xprt_put_cong() and the deadlock goes away.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 1d4fe24..826fecf 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -68,6 +68,7 @@ static void	 xprt_init(struct rpc_xprt *xprt, struct net *net);
 static void	xprt_request_init(struct rpc_task *, struct rpc_xprt *);
 static void	xprt_connect_status(struct rpc_task *task);
 static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
+static void     __xprt_put_cong(struct rpc_xprt *, struct rpc_rqst *);
 static void	 xprt_destroy(struct rpc_xprt *xprt);
 
 static DEFINE_SPINLOCK(xprt_list_lock);
@@ -250,6 +251,8 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 	}
 	xprt_clear_locked(xprt);
 out_sleep:
+	if (req)
+		__xprt_put_cong(xprt, req);
 	dprintk("RPC: %5u failed to lock transport %p\n", task->tk_pid, xprt);
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
