Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:45083 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728095AbeIQSb2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:28 -0400
Received: by mail-qt0-f196.google.com with SMTP id g44-v6so15093842qtb.12
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:13 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.11
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:11 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 13/44] SUNRPC: Don't wake queued RPC calls multiple times in xprt_transmit
Date: Mon, 17 Sep 2018 09:03:04 -0400
Message-Id: <20180917130335.112832-14-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-13-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather than waking up the entire queue of RPC messages a second time,
just wake up the task that was put to sleep.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 649a40cfae6d..3a3b3445a7c0 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1079,13 +1079,10 @@ void xprt_transmit(struct rpc_task *task)
 		spin_lock(&xprt->recv_lock);
 		if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate)) {
 			rpc_sleep_on(&xprt->pending, task, xprt_timer);
-			/*
-			 * Send an extra queue wakeup call if the
-			 * connection was dropped in case the call to
-			 * rpc_sleep_on() raced.
-			 */
+			/* Wake up immediately if the connection was dropped */
 			if (!xprt_connected(xprt))
-				xprt_wake_pending_tasks(xprt, -ENOTCONN);
+				rpc_wake_up_queued_task_set_status(&xprt->pending,
+						task, -ENOTCONN);
 		}
 		spin_unlock(&xprt->recv_lock);
 	}
-- 
2.17.1
