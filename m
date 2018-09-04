Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:37962 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725879AbeIEBdN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:13 -0400
Received: by mail-it0-f65.google.com with SMTP id p129-v6so6701602ite.3
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:21 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.19
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:19 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 12/34] SUNRPC: Don't wake queued RPC calls multiple times in xprt_transmit
Date: Tue,  4 Sep 2018 17:05:27 -0400
Message-Id: <20180904210549.81673-13-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-12-trond.myklebust@hammerspace.com>
References: <20180904210549.81673-1-trond.myklebust@hammerspace.com>
 <20180904210549.81673-2-trond.myklebust@hammerspace.com>
 <20180904210549.81673-3-trond.myklebust@hammerspace.com>
 <20180904210549.81673-4-trond.myklebust@hammerspace.com>
 <20180904210549.81673-5-trond.myklebust@hammerspace.com>
 <20180904210549.81673-6-trond.myklebust@hammerspace.com>
 <20180904210549.81673-7-trond.myklebust@hammerspace.com>
 <20180904210549.81673-8-trond.myklebust@hammerspace.com>
 <20180904210549.81673-9-trond.myklebust@hammerspace.com>
 <20180904210549.81673-10-trond.myklebust@hammerspace.com>
 <20180904210549.81673-11-trond.myklebust@hammerspace.com>
 <20180904210549.81673-12-trond.myklebust@hammerspace.com>
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
index bf8fc1a5dbd1..0441e6c8153d 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1075,13 +1075,10 @@ void xprt_transmit(struct rpc_task *task)
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
