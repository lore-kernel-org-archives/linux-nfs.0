Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:35358 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbdHNTxn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Aug 2017 15:53:43 -0400
Received: by mail-io0-f182.google.com with SMTP id m88so41728871iod.2
        for <linux-nfs@vger.kernel.org>; Mon, 14 Aug 2017 12:53:43 -0700 (PDT)
Subject: [PATCH v1] NLM: GRANTED_MSG fails after client remount
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org, manjunath.b.patil@oracle.com,
        trond.myklebust@primarydata.com, jlayton@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Aug 2017 15:53:41 -0400
Message-ID: <20170814195255.9419.84211.stgit@klimt.1015granger.net>
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

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=311
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Changes from RFC:
- Use nlmsvc_timeout instead of hard-coding 10 * HZ

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
index 3507c80..b65b093 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -830,7 +830,7 @@ static void nlmsvc_grant_callback(struct rpc_task *task, void *data)
 	 * can be done, though. */
 	if (task->tk_status < 0) {
 		/* RPC error: Re-insert for retransmission */
-		timeout = 10 * HZ;
+		timeout = nlmsvc_timeout;
 	} else {
 		/* Call was successful, now wait for client callback */
 		timeout = 60 * HZ;

