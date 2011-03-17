Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:43277 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753846Ab1CQMRN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2011 08:17:13 -0400
Subject: [PATCH] RPC: killing RPC tasks races fixed
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net, skinsbursky@openvz.org
Date: Thu, 17 Mar 2011 15:16:55 +0300
Message-ID: <20110317121638.15035.39410.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

task->tk_waitqueue must be checked for NULL before trying to wake up task in
rpc_killall_tasks() because it can be NULL.

Here is an example:

CPU 0               	CPU 1				CPU 2
--------------------	---------------------	--------------------------
nfs4_run_open_task
rpc_run_task
rpc_execute
rpc_set_active
rpc_make_runnable
(waiting)
			rpc_async_schedule
			nfs4_open_prepare
			nfs_wait_on_sequence
						nfs_umount_begin
						rpc_killall_tasks
						rpc_wake_up_task
						rpc_wake_up_queued_task
						spin_lock(tk_waitqueue == NULL)
						BUG()
			rpc_sleep_on
			spin_lock(&q->lock)
			__rpc_sleep_on
			task->tk_waitqueue = q

Signed-off-by: Stanislav Kinsbursky <skinsbursky@openvz.org>

---
 net/sunrpc/clnt.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 57d344c..24039fe 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -436,7 +436,9 @@ void rpc_killall_tasks(struct rpc_clnt *clnt)
 		if (!(rovr->tk_flags & RPC_TASK_KILLED)) {
 			rovr->tk_flags |= RPC_TASK_KILLED;
 			rpc_exit(rovr, -EIO);
-			rpc_wake_up_queued_task(rovr->tk_waitqueue, rovr);
+			if (rovr->tk_waitqueue)
+				rpc_wake_up_queued_task(rovr->tk_waitqueue, 
+							rovr);
 		}
 	}
 	spin_unlock(&clnt->cl_lock);

