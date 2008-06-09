From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 5/6] rpc: minor cleanup of scheduler callback code
Date: Mon,  9 Jun 2008 16:51:35 -0400
Message-ID: <1213044696-32741-6-git-send-email-bfields@citi.umich.edu>
References: <1213044696-32741-1-git-send-email-bfields@citi.umich.edu>
 <1213044696-32741-2-git-send-email-bfields@citi.umich.edu>
 <1213044696-32741-3-git-send-email-bfields@citi.umich.edu>
 <1213044696-32741-4-git-send-email-bfields@citi.umich.edu>
 <1213044696-32741-5-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48636 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752114AbYFIUvi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 16:51:38 -0400
In-Reply-To: <1213044696-32741-5-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Try to make the comment here a little more clear and concise.

Also, this macro definition seems unnecessary.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/sched.h |    1 -
 net/sunrpc/sched.c           |   14 +++++---------
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index d1a5c8c..64981a2 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -135,7 +135,6 @@ struct rpc_task_setup {
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
 #define RPC_DO_ROOTOVERRIDE(t)	((t)->tk_flags & RPC_TASK_ROOTCREDS)
 #define RPC_ASSASSINATED(t)	((t)->tk_flags & RPC_TASK_KILLED)
-#define RPC_DO_CALLBACK(t)	((t)->tk_callback != NULL)
 #define RPC_IS_SOFT(t)		((t)->tk_flags & RPC_TASK_SOFT)
 
 #define RPC_TASK_RUNNING	0
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 6eab9bf..6288af0 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -626,19 +626,15 @@ static void __rpc_execute(struct rpc_task *task)
 		/*
 		 * Execute any pending callback.
 		 */
-		if (RPC_DO_CALLBACK(task)) {
-			/* Define a callback save pointer */
+		if (task->tk_callback) {
 			void (*save_callback)(struct rpc_task *);
 
 			/*
-			 * If a callback exists, save it, reset it,
-			 * call it.
-			 * The save is needed to stop from resetting
-			 * another callback set within the callback handler
-			 * - Dave
+			 * We set tk_callback to NULL before calling it,
+			 * in case it sets the tk_callback field itself:
 			 */
-			save_callback=task->tk_callback;
-			task->tk_callback=NULL;
+			save_callback = task->tk_callback;
+			task->tk_callback = NULL;
 			save_callback(task);
 		}
 
-- 
1.5.5.rc1

