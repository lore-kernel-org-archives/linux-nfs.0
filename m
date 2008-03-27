From: Olga Kornievskaia <aglo@umich.edu>
Subject: [PATCH 1/1] bring-back-chatty
Date: Thu, 27 Mar 2008 17:56:24 -0400
Message-ID: <1206654984-3097-1-git-send-email-aglo@umich.edu>
Cc: Olga Kornievskaia <aglo-f4j/GOoueJu+0zDwvd8n29KIQNXEaThN@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from skydive.citi.umich.edu ([141.211.133.216]:44334 "EHLO
	skydive.citi.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760083AbYC0V50 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Mar 2008 17:57:26 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo-f4j/GOoueJu+0zDwvd8n29KIQNXEaThN@public.gmane.org>

Another attempt to silence call_timeout() prints by bringing back "chatty".

When the client's callback server goes away, the server's callback client
tries to contact the server and times out. For nfsd, it is beneficial to
printout a message when the client is unable to contact the server. For
the callback server, the same message is printed yet it is really not
an error. Thus we need a way to silence the message for the callback
and yet print it for other cases.

---
 fs/nfsd/nfs4callback.c      |    2 +-
 include/linux/sunrpc/clnt.h |    4 +++-
 net/sunrpc/clnt.c           |    5 ++++-
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index aae2b29..00d3448 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -367,7 +367,7 @@ static int do_probe_callback(void *data)
 		.program	= program,
 		.version	= nfs_cb_version[1]->number,
 		.authflavor	= RPC_AUTH_UNIX, /* XXX: need AUTH_GSS... */
-		.flags		= (RPC_CLNT_CREATE_NOPING),
+		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
 	};
 	struct rpc_message msg = {
 		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 129a86e..249f7a2 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -42,7 +42,8 @@ struct rpc_clnt {
 
 	unsigned int		cl_softrtry : 1,/* soft timeouts */
 				cl_discrtry : 1,/* disconnect before retry */
-				cl_autobind : 1;/* use getport() */
+				cl_autobind : 1,/* use getport() */
+				cl_chatty   : 1;/* be verbose */
 
 	struct rpc_rtt *	cl_rtt;		/* RTO estimator data */
 	const struct rpc_timeout *cl_timeout;	/* Timeout strategy */
@@ -114,6 +115,7 @@ struct rpc_create_args {
 #define RPC_CLNT_CREATE_NONPRIVPORT	(1UL << 3)
 #define RPC_CLNT_CREATE_NOPING		(1UL << 4)
 #define RPC_CLNT_CREATE_DISCRTRY	(1UL << 5)
+#define RPC_CLNT_CREATE_QUIET		(1UL << 6)
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8c6a7f1..3aa3348 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -328,6 +328,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		clnt->cl_autobind = 1;
 	if (args->flags & RPC_CLNT_CREATE_DISCRTRY)
 		clnt->cl_discrtry = 1;
+	if (args->flags & RPC_CLNT_CREATE_QUIET)
+		clnt->cl_chatty = 0;
 
 	return clnt;
 }
@@ -1160,7 +1162,8 @@ call_timeout(struct rpc_task *task)
 	task->tk_timeouts++;
 
 	if (RPC_IS_SOFT(task)) {
-		printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
+		if (clnt->cl_chatty)
+			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
 				clnt->cl_protname, clnt->cl_server);
 		rpc_exit(task, -EIO);
 		return;
-- 
1.5.3.3

