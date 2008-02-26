From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/10] Cleanups of the RPC waitqueue locking
Date: Tue, 26 Feb 2008 15:41:35 -0800
Message-ID: <1204069295.10615.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35598 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763721AbYBZXlh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2008 18:41:37 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m1QNfa6H028013
	for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2008 15:41:37 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One of the main reasons for the complicated locking in the RPC waitqueue
wakeup code is the fact that the timeout code can kick in at any time
between the call to rpc_wake_up_*(), and the call to rpc_delete_timer()
inside __rpc_execute().
By moving the timers from the rpc_task onto the waitqueue itself, we can
greatly simplify the locking on the rpc_wakeup_task() stuff, since we
can then guarantee that the timer will not touch the task once it has
been removed from the wait queue (and the wake-queue loses track of
where the task is).

Another simplification that results is that we can get rid of the
rcu-safe releases of the RPC tasks.

Finally, we simplify the RPC timer callbacks themselves by moving the
complexity into the process context (using task->tk_callback()), and
simplify the RPC timer callbacks themselves to simply waking up the
tasks and setting task->tk_status to ETIMEDOUT. 

Cheers
  Trond
