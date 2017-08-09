Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34026 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752219AbdHIWEv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Aug 2017 18:04:51 -0400
Received: by mail-it0-f67.google.com with SMTP id t78so592697ita.1
        for <linux-nfs@vger.kernel.org>; Wed, 09 Aug 2017 15:04:51 -0700 (PDT)
Subject: [PATCH RFC] NLM: GRANTED_MSG fails after client remount
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, jlayton@redhat.com,
        manjunath.patil@oracle.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 09 Aug 2017 18:04:49 -0400
Message-ID: <20170809220335.12343.40647.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If I repeatedly run the cthon04 lock test on NFSv3, at some point
the Linux NFS server reports "lockd: server not responding". The NFS
server is sending a GRANTED_MSG request via TCP, but the NFS client
lockd has restarted and changed ports. The correct recovery is for
the NFS server to rebind and reconnect to the new client port, but
the server never rebinds, and the request times out and fails.

The underlying problem is that the RPC client on the NFS server is
attempting to reconnect in a loop, and does not return control to
the NLM layer until the request times out. There is never a chance
for the NLM layer to force a rebind until the request has failed.

To address this, set the RPC_TASK_SOFTCONN flag when sending async
NLM requests. The request fails immediately if it cannot connect,
and the code can force a rebind and then retry the request.

Sidebar: Using SOFTCONN could be reasonable for the NFS client side
as well.

Sidebar: Is h_nextrebind appropriate for NLM on TCP?

Sidebar: If XPRT_BOUND is cleared while the RPC client is
connecting, the connect can fail in xs_tcp_finish_connecting:

2353         if (!xprt_bound(xprt))
2354                 goto out;

There's no recovery in xs_tcp_setup_socket for this case, so an
error message is logged, and connection set up fails. The error
is noise. Does the RPC client try to connect again in this case?

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=311
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/clntproc.c |    2 +-
 fs/lockd/host.c     |    7 ++++++-
 fs/lockd/svclock.c  |    2 +-
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 066ac31..5806e1a 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -342,7 +342,7 @@ static struct rpc_task *__nlm_async_call(struct nlm_rqst *req, u32 proc, struct
 		.rpc_message = msg,
 		.callback_ops = tk_ops,
 		.callback_data = req,
-		.flags = RPC_TASK_ASYNC,
+		.flags = RPC_TASK_ASYNC | RPC_TASK_SOFTCONN,
 	};
 
 	dprintk("lockd: call procedure %d on %s (async)\n",
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index d716c99..be0f847 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -490,7 +490,12 @@ struct rpc_clnt *
 nlm_rebind_host(struct nlm_host *host)
 {
 	dprintk("lockd: rebind host %s\n", host->h_name);
-	if (host->h_rpcclnt && time_after_eq(jiffies, host->h_nextrebind)) {
+
+	if (!host->h_rpcclnt)
+		return;
+
+	if (time_after_eq(jiffies, host->h_nextrebind) ||
+	    host->h_proto == IPPROTO_TCP) {
 		rpc_force_rebind(host->h_rpcclnt);
 		host->h_nextrebind = jiffies + NLM_HOST_REBIND;
 	}
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 3507c80..2f64a6b 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -830,7 +830,7 @@ static void nlmsvc_grant_callback(struct rpc_task *task, void *data)
 	 * can be done, though. */
 	if (task->tk_status < 0) {
 		/* RPC error: Re-insert for retransmission */
-		timeout = 10 * HZ;
+		timeout = 5 * HZ;
 	} else {
 		/* Call was successful, now wait for client callback */
 		timeout = 60 * HZ;

