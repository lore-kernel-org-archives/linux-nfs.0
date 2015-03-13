Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:53610 "EHLO www.osadl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230AbbCMIaL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Mar 2015 04:30:11 -0400
From: Nicholas Mc Guire <hofrat@osadl.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        kbuild test robot <fengguang.wu@intel.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] SUNRPC: fix build-warning due to format missmatch
Date: Fri, 13 Mar 2015 04:25:34 -0400
Message-Id: <1426235134-14349-1-git-send-email-hofrat@osadl.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fix build-warning introduced by commit: f0eede10fd4 ("SUNRPC: use
jiffies_to_msecs for converting jiffies") which did not fixup
the format properly (my bad).

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

This fixes the build warning reported by kbuild test robot
<fengguang.wu@intel.com> - thanks !
>    net/sunrpc/sched.c: In function '__rpc_add_timer':
> >> net/sunrpc/sched.c:92:2: warning: format '%lu' expects argument of type 'long unsigned int', but argument 3 has type 'unsigned int' [-Wformat=]
>      dprintk("RPC: %5u setting alarm for %lu ms\n",
>      ^

While at it this also fixes the checkpatch alignment warning.

Patch was compile tested with x86_64_defconfig and xtensa_defconfig
(implies CONFIG_SUNRPC=y/m)

Patch is against 4.0-rc3 (localversion-next is -next-20150312)
with commit: f0eede10fd4 ("SUNRPC: use jiffies_to_msecs for converting
jiffies") applied.

 net/sunrpc/sched.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index c234e7f..337ca85 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -89,8 +89,8 @@ __rpc_add_timer(struct rpc_wait_queue *queue, struct rpc_task *task)
 	if (!task->tk_timeout)
 		return;
 
-	dprintk("RPC: %5u setting alarm for %lu ms\n",
-			task->tk_pid, jiffies_to_msecs(task->tk_timeout));
+	dprintk("RPC: %5u setting alarm for %u ms\n",
+		task->tk_pid, jiffies_to_msecs(task->tk_timeout));
 
 	task->u.tk_wait.expires = jiffies + task->tk_timeout;
 	if (list_empty(&queue->timer_list.list) || time_before(task->u.tk_wait.expires, queue->timer_list.expires))
-- 
1.7.10.4

