From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 25/37] rpc: bring back cl_chatty
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.48848.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14765 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759435AbYFLTew (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:52 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfsd/nfs4callback.c      |    2 +-
 include/linux/sunrpc/clnt.h |    4 +++-
 net/sunrpc/clnt.c           |   16 +++++++++++-----
 3 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 4d4760e..702fa57 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -381,7 +381,7 @@ static int do_probe_callback(void *data)
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
index 0530eea..09631f6 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -324,6 +324,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		clnt->cl_autobind = 1;
 	if (args->flags & RPC_CLNT_CREATE_DISCRTRY)
 		clnt->cl_discrtry = 1;
+	if (!(args->flags & RPC_CLNT_CREATE_QUIET))
+		clnt->cl_chatty = 1;
 
 	return clnt;
 }
@@ -1149,7 +1151,8 @@ call_status(struct rpc_task *task)
 		rpc_exit(task, status);
 		break;
 	default:
-		printk("%s: RPC call returned error %d\n",
+		if (clnt->cl_chatty)
+			printk("%s: RPC call returned error %d\n",
 			       clnt->cl_protname, -status);
 		rpc_exit(task, status);
 	}
@@ -1174,7 +1177,8 @@ call_timeout(struct rpc_task *task)
 	task->tk_timeouts++;
 
 	if (RPC_IS_SOFT(task)) {
-		printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
+		if (clnt->cl_chatty)
+			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
 				clnt->cl_protname, clnt->cl_server);
 		rpc_exit(task, -EIO);
 		return;
@@ -1182,7 +1186,8 @@ call_timeout(struct rpc_task *task)
 
 	if (!(task->tk_flags & RPC_CALL_MAJORSEEN)) {
 		task->tk_flags |= RPC_CALL_MAJORSEEN;
-		printk(KERN_NOTICE "%s: server %s not responding, still trying\n",
+		if (clnt->cl_chatty)
+			printk(KERN_NOTICE "%s: server %s not responding, still trying\n",
 			clnt->cl_protname, clnt->cl_server);
 	}
 	rpc_force_rebind(clnt);
@@ -1213,8 +1218,9 @@ call_decode(struct rpc_task *task)
 			task->tk_pid, task->tk_status);
 
 	if (task->tk_flags & RPC_CALL_MAJORSEEN) {
-		printk(KERN_NOTICE "%s: server %s OK\n",
-			clnt->cl_protname, clnt->cl_server);
+		if (clnt->cl_chatty)
+			printk(KERN_NOTICE "%s: server %s OK\n",
+				clnt->cl_protname, clnt->cl_server);
 		task->tk_flags &= ~RPC_CALL_MAJORSEEN;
 	}
 

