Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:42369 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726749AbeIEBdZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:25 -0400
Received: by mail-io0-f196.google.com with SMTP id n18-v6so4217875ioa.9
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:34 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.32
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:32 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 30/34] SUNRPC: Allow soft RPC calls to time out when waiting for the XPRT_LOCK
Date: Tue,  4 Sep 2018 17:05:45 -0400
Message-Id: <20180904210549.81673-31-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-30-trond.myklebust@hammerspace.com>
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
 <20180904210549.81673-13-trond.myklebust@hammerspace.com>
 <20180904210549.81673-14-trond.myklebust@hammerspace.com>
 <20180904210549.81673-15-trond.myklebust@hammerspace.com>
 <20180904210549.81673-16-trond.myklebust@hammerspace.com>
 <20180904210549.81673-17-trond.myklebust@hammerspace.com>
 <20180904210549.81673-18-trond.myklebust@hammerspace.com>
 <20180904210549.81673-19-trond.myklebust@hammerspace.com>
 <20180904210549.81673-20-trond.myklebust@hammerspace.com>
 <20180904210549.81673-21-trond.myklebust@hammerspace.com>
 <20180904210549.81673-22-trond.myklebust@hammerspace.com>
 <20180904210549.81673-23-trond.myklebust@hammerspace.com>
 <20180904210549.81673-24-trond.myklebust@hammerspace.com>
 <20180904210549.81673-25-trond.myklebust@hammerspace.com>
 <20180904210549.81673-26-trond.myklebust@hammerspace.com>
 <20180904210549.81673-27-trond.myklebust@hammerspace.com>
 <20180904210549.81673-28-trond.myklebust@hammerspace.com>
 <20180904210549.81673-29-trond.myklebust@hammerspace.com>
 <20180904210549.81673-30-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This no longer causes them to lose their place in the transmission queue.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ebe5235c484b..bd818b97cb09 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -194,7 +194,7 @@ int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 out_sleep:
 	dprintk("RPC: %5u failed to lock transport %p\n",
 			task->tk_pid, xprt);
-	task->tk_timeout = 0;
+	task->tk_timeout = RPC_IS_SOFT(task) ? req->rq_timeout : 0;
 	task->tk_status = -EAGAIN;
 	rpc_sleep_on(&xprt->sending, task, NULL);
 	return 0;
@@ -241,7 +241,7 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 	xprt_clear_locked(xprt);
 out_sleep:
 	dprintk("RPC: %5u failed to lock transport %p\n", task->tk_pid, xprt);
-	task->tk_timeout = 0;
+	task->tk_timeout = RPC_IS_SOFT(task) ? req->rq_timeout : 0;
 	task->tk_status = -EAGAIN;
 	rpc_sleep_on(&xprt->sending, task, NULL);
 	return 0;
-- 
2.17.1
