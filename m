Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33111 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdLCSuS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Dec 2017 13:50:18 -0500
Received: by mail-it0-f67.google.com with SMTP id o130so8920649itg.0
        for <linux-nfs@vger.kernel.org>; Sun, 03 Dec 2017 10:50:18 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chucklever@gmail.com>
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix a race in the receive code path
Date: Sun,  3 Dec 2017 13:50:12 -0500
Message-Id: <20171203185012.24473-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must ensure that the call to rpc_sleep_on() in xprt_transmit() cannot
race with the call to xprt_complete_rqst().

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Link: https://bugzilla.linux-nfs.org/show_bug.cgi?id=317
Fixes: ce7c252a8c74 ("SUNRPC: Add a separate spinlock to protect..")
Cc: stable@vger.kernel.org # 4.14+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 333b9d697ae5..9d9092805696 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1035,6 +1035,7 @@ void xprt_transmit(struct rpc_task *task)
 
 	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
 	task->tk_flags |= RPC_TASK_SENT;
+	spin_lock(&xprt->recv_lock);
 	spin_lock_bh(&xprt->transport_lock);
 
 	xprt->ops->set_retrans_timeout(task);
@@ -1061,6 +1062,7 @@ void xprt_transmit(struct rpc_task *task)
 		req->rq_connect_cookie = xprt->connect_cookie;
 	}
 	spin_unlock_bh(&xprt->transport_lock);
+	spin_unlock(&xprt->recv_lock);
 }
 
 static void xprt_add_backlog(struct rpc_xprt *xprt, struct rpc_task *task)
-- 
2.14.3

