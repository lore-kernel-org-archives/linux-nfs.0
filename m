From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 021/112] SUNRPC: Add a helper rpc_call_start() that
	initialises task->tk_action
Date: Fri, 25 Jan 2008 11:37:28 -0500
Message-ID: <20080125163728.31887.78529.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33369 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753874AbYAYQ7m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:42 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxdsk010119
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:40 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/clnt.h |    2 +-
 net/sunrpc/clnt.c           |    7 +++++++
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index ec97041..c79f2ed 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -127,7 +127,7 @@ int		rpcb_getport_sync(struct sockaddr_in *, __u32, __u32, int);
 void		rpcb_getport_async(struct rpc_task *);
 
 void		rpc_call_setup(struct rpc_task *, const struct rpc_message *, int);
-
+void		rpc_call_start(struct rpc_task *);
 int		rpc_call_async(struct rpc_clnt *clnt, struct rpc_message *msg,
 			       int flags, const struct rpc_call_ops *tk_ops,
 			       void *calldata);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index aefe3ae..7aeffee 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -634,6 +634,13 @@ rpc_call_setup(struct rpc_task *task, const struct rpc_message *msg, int flags)
 }
 EXPORT_SYMBOL_GPL(rpc_call_setup);
 
+void
+rpc_call_start(struct rpc_task *task)
+{
+	task->tk_action = call_start;
+}
+EXPORT_SYMBOL_GPL(rpc_call_start);
+
 /**
  * rpc_peeraddr - extract remote peer address from clnt's xprt
  * @clnt: RPC client structure
