From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 025/112] SUNRPC: Remove the now unused function
	rpc_call_setup()
Date: Fri, 25 Jan 2008 11:37:30 -0500
Message-ID: <20080125163729.31887.71727.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63573 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756996AbYAYRAg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:36 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Ln8010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:33 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/clnt.h |    1 -
 net/sunrpc/clnt.c           |   18 ------------------
 2 files changed, 0 insertions(+), 19 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index c79f2ed..4fc268a 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -126,7 +126,6 @@ int		rpcb_register(u32, u32, int, unsigned short, int *);
 int		rpcb_getport_sync(struct sockaddr_in *, __u32, __u32, int);
 void		rpcb_getport_async(struct rpc_task *);
 
-void		rpc_call_setup(struct rpc_task *, const struct rpc_message *, int);
 void		rpc_call_start(struct rpc_task *);
 int		rpc_call_async(struct rpc_clnt *clnt, struct rpc_message *msg,
 			       int flags, const struct rpc_call_ops *tk_ops,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6eb79c4..e0a5e47 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -614,24 +614,6 @@ rpc_call_async(struct rpc_clnt *clnt, struct rpc_message *msg, int flags,
 EXPORT_SYMBOL_GPL(rpc_call_async);
 
 void
-rpc_call_setup(struct rpc_task *task, const struct rpc_message *msg, int flags)
-{
-	task->tk_msg   = *msg;
-	task->tk_flags |= flags;
-	/* Bind the user cred */
-	if (task->tk_msg.rpc_cred != NULL)
-		rpcauth_holdcred(task);
-	else
-		rpcauth_bindcred(task);
-
-	if (task->tk_status == 0)
-		task->tk_action = call_start;
-	else
-		task->tk_action = rpc_exit_task;
-}
-EXPORT_SYMBOL_GPL(rpc_call_setup);
-
-void
 rpc_call_start(struct rpc_task *task)
 {
 	task->tk_action = call_start;
