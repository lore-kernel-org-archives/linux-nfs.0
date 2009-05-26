From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH] nfs41: sunrpc: xs_tcp_read_callback() should use xprt_force_disconnect()
Date: Tue, 26 May 2009 10:32:52 -0700
Message-ID: <1243359172-32250-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37385 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755153AbZEZRd6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 May 2009 13:33:58 -0400
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xs_tcp_read_callback() drops the connection when the number of expected
callbacks is exceeded.  Use xprt_force_disconnect(), ensuring tasks on
the pending queue are awaken on disconnect.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 net/sunrpc/xprtsock.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1a268bf..7445d4b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1147,13 +1147,8 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
 
 	req = xprt_alloc_bc_request(xprt);
 	if (req == NULL) {
-		/*
-		 * Schedule an autoclose RPC call
-		 */
 		printk(KERN_WARNING "Callback slot table overflowed\n");
-		set_bit(XPRT_CLOSE_WAIT, &xprt->state);
-		if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
-			queue_work(rpciod_workqueue, &xprt->task_cleanup);
+		xprt_force_disconnect(xprt);
 		return -1;
 	}
 
-- 
1.5.4.3

