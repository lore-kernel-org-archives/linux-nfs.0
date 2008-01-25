From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 030/112] SUNRPC: Remove the obsolete RPC_WAITQ macro
Date: Fri, 25 Jan 2008 11:37:31 -0500
Message-ID: <20080125163731.31887.56329.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755727AbYAYRAz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:55 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxloB019995
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:18 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we've killed off all the users.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/sched.h |   23 -----------------------
 1 files changed, 0 insertions(+), 23 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 23481a5..ce3d1b1 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -217,29 +217,6 @@ struct rpc_wait_queue {
  * performance of NFS operations such as read/write.
  */
 #define RPC_BATCH_COUNT			16
-
-#ifndef RPC_DEBUG
-# define RPC_WAITQ_INIT(var,qname) { \
-		.lock = __SPIN_LOCK_UNLOCKED(var.lock), \
-		.tasks = { \
-			[0] = LIST_HEAD_INIT(var.tasks[0]), \
-			[1] = LIST_HEAD_INIT(var.tasks[1]), \
-			[2] = LIST_HEAD_INIT(var.tasks[2]), \
-		}, \
-	}
-#else
-# define RPC_WAITQ_INIT(var,qname) { \
-		.lock = __SPIN_LOCK_UNLOCKED(var.lock), \
-		.tasks = { \
-			[0] = LIST_HEAD_INIT(var.tasks[0]), \
-			[1] = LIST_HEAD_INIT(var.tasks[1]), \
-			[2] = LIST_HEAD_INIT(var.tasks[2]), \
-		}, \
-		.name = qname, \
-	}
-#endif
-# define RPC_WAITQ(var,qname)      struct rpc_wait_queue var = RPC_WAITQ_INIT(var,qname)
-
 #define RPC_IS_PRIORITY(q)		((q)->maxpriority > 0)
 
 /*
