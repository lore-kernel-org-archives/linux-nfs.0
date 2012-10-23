Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14548 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755355Ab2JWOxc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:32 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 22/25] SUNRPC: remove BUG_ON from __rpc_sleep_on_priority
Date: Tue, 23 Oct 2012 10:43:46 -0400
Message-Id: <1351003429-18887-23-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with WARN_ON_ONCE().

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/sched.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index f494b35..e6db496 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -334,7 +334,7 @@ static void __rpc_sleep_on_priority(struct rpc_wait_queue *q,
 
 	__rpc_add_wait_queue(q, task, queue_priority);
 
-	BUG_ON(task->tk_callback != NULL);
+	WARN_ON_ONCE(task->tk_callback != NULL);
 	task->tk_callback = action;
 	__rpc_add_timer(q, task);
 }
-- 
1.7.9.6 (Apple Git-31.1)

