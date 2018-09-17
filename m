Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:45120 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728299AbeIQSbp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:45 -0400
Received: by mail-qt0-f194.google.com with SMTP id g44-v6so15094867qtb.12
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:30 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.29
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:29 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 28/44] SUNRPC: Enqueue swapper tagged RPCs at the head of the transmit queue
Date: Mon, 17 Sep 2018 09:03:19 -0400
Message-Id: <20180917130335.112832-29-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-28-trond.myklebust@hammerspace.com>
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
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
 <20180917130335.112832-25-trond.myklebust@hammerspace.com>
 <20180917130335.112832-26-trond.myklebust@hammerspace.com>
 <20180917130335.112832-27-trond.myklebust@hammerspace.com>
 <20180917130335.112832-28-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid memory starvation by giving RPCs that are tagged with the
RPC_TASK_SWAPPER flag the highest priority.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index e07a54fbe1e7..68974966b2e4 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1111,6 +1111,17 @@ xprt_request_enqueue_transmit(struct rpc_task *task)
 				INIT_LIST_HEAD(&req->rq_xmit2);
 				goto out;
 			}
+		} else if (RPC_IS_SWAPPER(task)) {
+			list_for_each_entry(pos, &xprt->xmit_queue, rq_xmit) {
+				if (pos->rq_cong || pos->rq_bytes_sent)
+					continue;
+				if (RPC_IS_SWAPPER(pos->rq_task))
+					continue;
+				/* Note: req is added _before_ pos */
+				list_add_tail(&req->rq_xmit, &pos->rq_xmit);
+				INIT_LIST_HEAD(&req->rq_xmit2);
+				goto out;
+			}
 		} else {
 			list_for_each_entry(pos, &xprt->xmit_queue, rq_xmit) {
 				if (pos->rq_task->tk_owner != task->tk_owner)
-- 
2.17.1
