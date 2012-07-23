Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:57691 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739Ab2GWTwB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jul 2012 15:52:01 -0400
Received: by yhmm54 with SMTP id m54so5887521yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jul 2012 12:52:00 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: clarify comments on rpc_make_runnable
Date: Mon, 23 Jul 2012 15:51:55 -0400
Message-Id: <1343073115-29944-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc_make_runnable is not generally called with the queue lock held, unless
it's waking up a task that has been sitting on a waitqueue. This is safe
when the task has not entered the FSM yet, but the comments don't really
spell this out.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/sched.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index eda32ae..1f19aa1 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -300,8 +300,9 @@ EXPORT_SYMBOL_GPL(__rpc_wait_for_completion_task);
 /*
  * Make an RPC task runnable.
  *
- * Note: If the task is ASYNC, this must be called with
- * the spinlock held to protect the wait queue operation.
+ * Note: If the task is ASYNC, and is being made runnable after sitting on an
+ * rpc_wait_queue, this must be called with the queue spinlock held to protect
+ * the wait queue operation.
  */
 static void rpc_make_runnable(struct rpc_task *task)
 {
-- 
1.7.10.4

