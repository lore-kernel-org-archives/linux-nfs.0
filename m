Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51769 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754629Ab2BFU2b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Feb 2012 15:28:31 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: Fix up sunrpc trace events
Date: Mon,  6 Feb 2012 15:28:25 -0500
Message-Id: <1328560106-24066-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The reporting of the RPC queue name needs to use the __string()
event interface.

Reported-by: Neil Horman <nhorman@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/trace/events/sunrpc.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 51cc949..ec8668d 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -75,21 +75,21 @@ DECLARE_EVENT_CLASS(rpc_task_queued,
 	TP_STRUCT__entry(
 		__field(const struct rpc_clnt *, clnt)
 		__field(const struct rpc_task *, task)
-		__field(const struct rpc_wait_queue *, queue)
 		__field(unsigned long, timeout)
 		__field(unsigned long, runstate)
 		__field(int, status)
 		__field(unsigned short, flags)
+		__string(q_name, rpc_qname(q))
 		),
 
 	TP_fast_assign(
 		__entry->clnt = clnt;
 		__entry->task = task;
-		__entry->queue = q;
 		__entry->timeout = task->tk_timeout;
 		__entry->runstate = task->tk_runstate;
 		__entry->status = task->tk_status;
 		__entry->flags = task->tk_flags;
+		__assign_str(q_name, rpc_qname(q));
 		),
 
 	TP_printk("task:%p@%p flags=%4.4x state=%4.4lx status=%d timeout=%lu queue=%s",
@@ -99,7 +99,7 @@ DECLARE_EVENT_CLASS(rpc_task_queued,
 		__entry->runstate,
 		__entry->status,
 		__entry->timeout,
-		rpc_qname(__entry->queue)
+		__get_str(q_name)
 		)
 );
 
-- 
1.7.7.6

