From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] rpc: bring back cl_chatty
Date: Tue, 8 Apr 2008 16:48:56 -0400
Message-ID: <20080408204856.GA21966@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, aglo@citi.umich.edu
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56955 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755848AbYDHUs6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 16:48:58 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

The cl_chatty flag alows us to control whether a given rpc client leaves

	"server X not responding, timed out"

messages in the syslog.  Such messages make sense for ordinary nfs
clients (where an unresponsive server means applications on the
mountpoint are probably hanging), but not for the callback client (which
can fail more commonly, with the only result just of disabling some
optimizations).

Previously cl_chatty was removed, do to lack of users; reinstate it, and
use it for the nfsd's callback client.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c      |    2 +-
 include/linux/sunrpc/clnt.h |    4 +++-
 net/sunrpc/clnt.c           |   16 +++++++++++-----
 3 files changed, 15 insertions(+), 7 deletions(-)

Default cl_chatty value fixed since the last version you saw.

Also I added cl_chatty checks before all printk's that used to have them
previously.  (Olga's version just did one.)

--b.

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index de75a71..92d692e 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -382,7 +382,7 @@ static int do_probe_callback(void *data)
 		.program	= &cb_program,
 		.version	= nfs_cb_version[1]->number,
 		.authflavor	= RPC_AUTH_UNIX, /* XXX: need AUTH_GSS... */
-		.flags		= (RPC_CLNT_CREATE_NOPING),
+		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
 	};
 	struct rpc_message msg = {
 		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 6fff7f8..764fd4c 100644
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
index ea14314..033e0c0 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -328,6 +328,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		clnt->cl_autobind = 1;
 	if (args->flags & RPC_CLNT_CREATE_DISCRTRY)
 		clnt->cl_discrtry = 1;
+	if (!(args->flags & RPC_CLNT_CREATE_QUIET))
+		clnt->cl_chatty = 1;
 
 	return clnt;
 }
@@ -1135,7 +1137,8 @@ call_status(struct rpc_task *task)
 		rpc_exit(task, status);
 		break;
 	default:
-		printk("%s: RPC call returned error %d\n",
+		if (clnt->cl_chatty)
+			printk("%s: RPC call returned error %d\n",
 			       clnt->cl_protname, -status);
 		rpc_exit(task, status);
 	}
@@ -1160,7 +1163,8 @@ call_timeout(struct rpc_task *task)
 	task->tk_timeouts++;
 
 	if (RPC_IS_SOFT(task)) {
-		printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
+		if (clnt->cl_chatty)
+			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
 				clnt->cl_protname, clnt->cl_server);
 		rpc_exit(task, -EIO);
 		return;
@@ -1168,7 +1172,8 @@ call_timeout(struct rpc_task *task)
 
 	if (!(task->tk_flags & RPC_CALL_MAJORSEEN)) {
 		task->tk_flags |= RPC_CALL_MAJORSEEN;
-		printk(KERN_NOTICE "%s: server %s not responding, still trying\n",
+		if (clnt->cl_chatty)
+			printk(KERN_NOTICE "%s: server %s not responding, still trying\n",
 			clnt->cl_protname, clnt->cl_server);
 	}
 	rpc_force_rebind(clnt);
@@ -1194,8 +1199,9 @@ call_decode(struct rpc_task *task)
 			task->tk_pid, task->tk_status);
 
 	if (task->tk_flags & RPC_CALL_MAJORSEEN) {
-		printk(KERN_NOTICE "%s: server %s OK\n",
-			clnt->cl_protname, clnt->cl_server);
+		if (clnt->cl_chatty)
+			printk(KERN_NOTICE "%s: server %s OK\n",
+				clnt->cl_protname, clnt->cl_server);
 		task->tk_flags &= ~RPC_CALL_MAJORSEEN;
 	}
 
-- 
1.5.5.rc1

