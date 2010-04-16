From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] SUNRPC: Fail over more quickly on connect errors
Date: Fri, 16 Apr 2010 16:47:49 -0400
Message-ID: <1271450871-10777-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1271450871-10777-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271450871-10777-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271450871-10777-3-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54877 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932522Ab0DPUry (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:47:54 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKlp90008034
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:47:53 -0700 (PDT)
In-Reply-To: <1271450871-10777-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should not allow soft tasks to wait for longer than the major timeout
period when waiting for a reconnect to occur.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xprt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index c71d835..01449a3 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -710,7 +710,7 @@ void xprt_connect(struct rpc_task *task)
 		if (task->tk_rqstp)
 			task->tk_rqstp->rq_bytes_sent = 0;
 
-		task->tk_timeout = xprt->connect_timeout;
+		task->tk_timeout = min(req->rq_timeout, xprt->connect_timeout);
 		rpc_sleep_on(&xprt->pending, task, xprt_connect_status);
 
 		if (test_bit(XPRT_CLOSING, &xprt->state))
-- 
1.6.6.1

