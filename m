From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 105/112] SUNRPC: Don't bother changing the sigmask for
	asynchronous RPC calls
Date: Fri, 25 Jan 2008 11:38:01 -0500
Message-ID: <20080125163801.31887.38903.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14327 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754745AbYAYQ7o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:44 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxfem019943
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:43 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The caller will never sleep in rpc_execute, so don't bother setting the
sigmask.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e775ca7..924916c 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -579,9 +579,12 @@ struct rpc_task *rpc_run_task(const struct rpc_task_setup *task_setup_data)
 	}
 	atomic_inc(&task->tk_count);
 	/* Mask signals on synchronous RPC calls and RPCSEC_GSS upcalls */
-	rpc_task_sigmask(task, &oldset);
-	rpc_execute(task);
-	rpc_restore_sigmask(&oldset);
+	if (!RPC_IS_ASYNC(task)) {
+		rpc_task_sigmask(task, &oldset);
+		rpc_execute(task);
+		rpc_restore_sigmask(&oldset);
+	} else
+		rpc_execute(task);
 	ret = task;
 out:
 	return ret;
