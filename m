Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fallback2.mail.ru ([94.100.176.87]:34371 "EHLO
	fallback2.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544Ab1CVO6H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 10:58:07 -0400
Received: from f70.mail.ru (f70.mail.ru [217.69.128.219])
	by fallback2.mail.ru (mPOP.Fallback_MX) with ESMTP id AEF824247BF0
	for <linux-nfs@vger.kernel.org>; Tue, 22 Mar 2011 17:53:01 +0300 (MSK)
From: Peter Lojkin <ia6432@inbox.ru>
To: linux-nfs@vger.kernel.org
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: =?utf-8?Q?Re=3A_[PATCH_v2]_RPC=3A_killing_RPC_tasks_races_fixed?=
Date: Tue, 22 Mar 2011 17:52:27 +0300
Reply-To: Peter Lojkin <ia6432@inbox.ru>
Content-Type: text/plain; charset=utf-8
Message-Id: <E1Q22wg-00080R-00.ia6432-inbox-ru@f70.mail.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-03-17 at 15:54:23 2011-03-17 at 18:43 +0300, Stanislav Kinsbursky wrote:

> RPC task RPC_TASK_QUEUED bit is set must be checked before trying to wake up
> task rpc_killall_tasks() because task->tk_waitqueue can not be set (equal to
> NULL).
> Also, as Trond Myklebust mentioned, such approach (instead of checking
> tk_waitqueue to NULL) allows us to "optimise away the call to
> rpc_wake_up_queued_task() altogether for those
> tasks that aren't queued".

you mentioned earlier that you have found this problem in .32 kernel but your patch only works for newer kernels.
does the following patch is correct and needed for pre .36 kernels?

--- a/net/sunrpc/sched.c	2011-03-22 16:55:36.802000287 +0300
+++ b/net/sunrpc/sched.c	2011-03-22 17:01:13.858000242 +0300
@@ -939,7 +939,8 @@
 		if (!(rovr->tk_flags & RPC_TASK_KILLED)) {
 			rovr->tk_flags |= RPC_TASK_KILLED;
 			rpc_exit(rovr, -EIO);
-			rpc_wake_up_task(rovr);
+			if (RPC_IS_QUEUED(rovr))
+				rpc_wake_up_task(rovr);
 		}
 	}
 	spin_unlock(&clnt->cl_lock);

