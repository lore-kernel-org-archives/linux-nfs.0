Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:38247 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754683AbbHNPF5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2015 11:05:57 -0400
Received: by igfj19 with SMTP id j19so13849338igf.1
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2015 08:05:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix a thinko in xs_connect()
Date: Fri, 14 Aug 2015 11:05:55 -0400
Message-Id: <1439564755-4240-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is rather pointless to test the value of transport->inet after
calling xs_reset_transport(), since it will always be zero, and
so we will never see any exponential back off behaviour.
Also don't force early connections for SOFTCONN tasks. If the server
disconnects us, we should respect the exponential backoff.

Cc: stable@vger.kernel.org # 4.0+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0030376327b7..86ed778bb18b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2279,13 +2279,14 @@ static void xs_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 
 	WARN_ON_ONCE(!xprt_lock_connect(xprt, task, transport));
 
-	/* Start by resetting any existing state */
-	xs_reset_transport(transport);
-
-	if (transport->sock != NULL && !RPC_IS_SOFTCONN(task)) {
+	if (transport->sock != NULL) {
 		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
 				"seconds\n",
 				xprt, xprt->reestablish_timeout / HZ);
+
+		/* Start by resetting any existing state */
+		xs_reset_transport(transport);
+
 		queue_delayed_work(rpciod_workqueue,
 				   &transport->connect_worker,
 				   xprt->reestablish_timeout);
-- 
2.4.3

