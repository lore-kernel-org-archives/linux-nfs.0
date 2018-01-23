Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53340 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752016AbeAWOcg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Jan 2018 09:32:36 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix null rpc_clnt dereference in rpc_task_queued tracepoint
Date: Tue, 23 Jan 2018 09:32:35 -0500
Message-Id: <18838b4cfbc27c32ebcfdca516ab5fe27db70237.1516717887.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Backchannel tasks will not have a reference to the rpc_clnt.  Return -1 for
cl_clid in that case.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 include/trace/events/sunrpc.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 25a7739514cd..f51d2a4ff2b2 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -145,7 +145,7 @@ DECLARE_EVENT_CLASS(rpc_task_queued,
 		),
 
 	TP_fast_assign(
-		__entry->client_id = clnt->cl_clid;
+		__entry->client_id = clnt ? clnt->cl_clid : -1;
 		__entry->task_id = task->tk_pid;
 		__entry->timeout = task->tk_timeout;
 		__entry->runstate = task->tk_runstate;
@@ -154,7 +154,7 @@ DECLARE_EVENT_CLASS(rpc_task_queued,
 		__assign_str(q_name, rpc_qname(q));
 		),
 
-	TP_printk("task:%u@%u flags=%4.4x state=%4.4lx status=%d timeout=%lu queue=%s",
+	TP_printk("task:%u@%d flags=%4.4x state=%4.4lx status=%d timeout=%lu queue=%s",
 		__entry->task_id, __entry->client_id,
 		__entry->flags,
 		__entry->runstate,
-- 
2.9.3

