Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:39235 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751048AbeACUif (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jan 2018 15:38:35 -0500
Subject: [PATCH 4/6] sunrpc: Format RPC events consistently for display
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 03 Jan 2018 15:38:33 -0500
Message-ID: <20180103203833.29209.32335.stgit@manet.1015granger.net>
In-Reply-To: <20180103203540.29209.4620.stgit@manet.1015granger.net>
References: <20180103203540.29209.4620.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Make it easier to use text search when browsing a trace
report. Other events use "status=%d".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 7804d85..0594e66 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -32,7 +32,7 @@
 		__entry->status = task->tk_status;
 	),
 
-	TP_printk("task:%u@%u, status %d",
+	TP_printk("task:%u@%u status=%d",
 		__entry->task_id, __entry->client_id,
 		__entry->status)
 );
@@ -66,7 +66,7 @@
 		__entry->status = status;
 	),
 
-	TP_printk("task:%u@%u, status %d",
+	TP_printk("task:%u@%u status=%d",
 		__entry->task_id, __entry->client_id,
 		__entry->status)
 );

