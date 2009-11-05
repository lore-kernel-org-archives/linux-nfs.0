From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/11] SUNRPC: Use soft connect semantics when performing RPC
	ping
Date: Thu, 05 Nov 2009 13:23:42 -0500
Message-ID: <20091105182342.2796.77879.stgit@matisse.1015granger.net>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:43341
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758181AbZKESXo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2009 13:23:44 -0500
In-Reply-To: <20091105181924.2796.9313.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, if a remote RPC service is unreachable, an RPC ping will
hang until the underlying transport connect attempt times out.  A more
desirable behavior might be to have the ping fail immediately so upper
layers can recover appropriately.

In the case of an NFS mount, for instance, this would mean the
mount(2) system call could fail immediately if the server isn't
listening, rather than hanging uninterruptibly for more than 3
minutes.

Change rpc_ping() so that it fails immediately for connection-oriented
transports.  rpc_create() will then fail immediately for such
transports if an RPC ping was requested.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4b76ef9..97931d9 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -79,7 +79,7 @@ static void	call_connect_status(struct rpc_task *task);
 
 static __be32	*rpc_encode_header(struct rpc_task *task);
 static __be32	*rpc_verify_header(struct rpc_task *task);
-static int	rpc_ping(struct rpc_clnt *clnt, int flags);
+static int	rpc_ping(struct rpc_clnt *clnt);
 
 static void rpc_register_client(struct rpc_clnt *clnt)
 {
@@ -340,7 +340,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		return clnt;
 
 	if (!(args->flags & RPC_CLNT_CREATE_NOPING)) {
-		int err = rpc_ping(clnt, RPC_TASK_SOFT);
+		int err = rpc_ping(clnt);
 		if (err != 0) {
 			rpc_shutdown_client(clnt);
 			return ERR_PTR(err);
@@ -528,7 +528,7 @@ struct rpc_clnt *rpc_bind_new_program(struct rpc_clnt *old,
 	clnt->cl_prog     = program->number;
 	clnt->cl_vers     = version->number;
 	clnt->cl_stats    = program->stats;
-	err = rpc_ping(clnt, RPC_TASK_SOFT);
+	err = rpc_ping(clnt);
 	if (err != 0) {
 		rpc_shutdown_client(clnt);
 		clnt = ERR_PTR(err);
@@ -1709,14 +1709,14 @@ static struct rpc_procinfo rpcproc_null = {
 	.p_decode = rpcproc_decode_null,
 };
 
-static int rpc_ping(struct rpc_clnt *clnt, int flags)
+static int rpc_ping(struct rpc_clnt *clnt)
 {
 	struct rpc_message msg = {
 		.rpc_proc = &rpcproc_null,
 	};
 	int err;
 	msg.rpc_cred = authnull_ops.lookup_cred(NULL, NULL, 0);
-	err = rpc_call_sync(clnt, &msg, flags);
+	err = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN);
 	put_rpccred(msg.rpc_cred);
 	return err;
 }

