Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33273 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751514AbdAaSio (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jan 2017 13:38:44 -0500
Subject: [PATCH v2 4/7] sunrpc: Allow xprt->ops->timer method to sleep
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 31 Jan 2017 13:38:41 -0500
Message-ID: <20170131183841.5325.33330.stgit@manet.1015granger.net>
In-Reply-To: <20170131183345.5325.47072.stgit@manet.1015granger.net>
References: <20170131183345.5325.47072.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The transport lock is needed to protect the xprt_adjust_cwnd() call
in xs_udp_timer, but it is not necessary for accessing the
rq_reply_bytes_recvd or tk_status fields. It is correct to sublimate
the lock into UDP's xs_udp_timer method, where it is required.

The ->timer method has to take the transport lock if needed, but it
can now sleep safely, or even call back into the RPC scheduler.

This is more a clean-up than a fix, but the "issue" was introduced
by my transport switch patches back in 2005.

Fixes: 46c0ee8bc4ad ("RPC: separate xprt_timer implementations")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprt.c     |    2 --
 net/sunrpc/xprtsock.c |    2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 9a6be03..b530a28 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -897,13 +897,11 @@ static void xprt_timer(struct rpc_task *task)
 		return;
 	dprintk("RPC: %5u xprt_timer\n", task->tk_pid);
 
-	spin_lock_bh(&xprt->transport_lock);
 	if (!req->rq_reply_bytes_recvd) {
 		if (xprt->ops->timer)
 			xprt->ops->timer(xprt, task);
 	} else
 		task->tk_status = 0;
-	spin_unlock_bh(&xprt->transport_lock);
 }
 
 /**
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index af392d9..d9bb644 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1734,7 +1734,9 @@ static void xs_udp_set_buffer_size(struct rpc_xprt *xprt, size_t sndsize, size_t
  */
 static void xs_udp_timer(struct rpc_xprt *xprt, struct rpc_task *task)
 {
+	spin_lock_bh(&xprt->transport_lock);
 	xprt_adjust_cwnd(xprt, task, -ETIMEDOUT);
+	spin_unlock_bh(&xprt->transport_lock);
 }
 
 static unsigned short xs_get_random_port(void)

