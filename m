From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH] RPC: return task->tk_status from
	rpc_wait_for_completion_task() in case of successfull task completion
Date: Tue, 15 Mar 2011 17:20:36 +0300
Message-ID: <20110315141951.16564.72417.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	linux-kernel@vger.kernel.org, bfields@fieldses.org,
	skinsbursky@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:18710 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836Ab1COOVN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2011 10:21:13 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some NFS and NLM routines doesn't check RPC task tk_status if
rpc_wait_for_completion_task() returned 0 but have to.
The best way to handle such RPC task error, from my pow, is to return RPC task
tk_status from rpc_wait_for_completion_task() instead of 0 value.
This approach will cover RPC tasks error status since NFS and NLM routines
checks rpc_wait_for_completion_task() result.

Kernel version affected: 2.6.38

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/sched.h |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index d81db80..f733036 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -245,7 +245,12 @@ void		rpc_prepare_task(struct rpc_task *task);
 
 static inline int rpc_wait_for_completion_task(struct rpc_task *task)
 {
-	return __rpc_wait_for_completion_task(task, NULL);
+	int res;
+
+	res = __rpc_wait_for_completion_task(task, NULL);
+	if (res == 0)
+		res = task->tk_status;
+	return res;
 }
 
 static inline void rpc_task_set_priority(struct rpc_task *task, unsigned char prio)

