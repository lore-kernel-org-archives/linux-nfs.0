From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/4] SUNRPC: Defer the auth_gss upcall when the RPC call is asynchronous
Date: Tue, 15 Sep 2009 21:07:56 -0400
Message-ID: <1253063278-30137-2-git-send-email-bfields@citi.umich.edu>
References: <20090916010604.GA29397@fieldses.org>
 <1253063278-30137-1-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33108 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245AbZIPBHy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Sep 2009 21:07:54 -0400
In-Reply-To: <1253063278-30137-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Otherwise, the upcall is going to be synchronous, which may not be what the
caller wants...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/auth.h |    4 ++--
 net/sunrpc/auth.c           |   20 ++++++++++++--------
 net/sunrpc/auth_generic.c   |    4 ++--
 3 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 3f63218..996df4d 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -111,7 +111,7 @@ struct rpc_credops {
 	void			(*crdestroy)(struct rpc_cred *);
 
 	int			(*crmatch)(struct auth_cred *, struct rpc_cred *, int);
-	void			(*crbind)(struct rpc_task *, struct rpc_cred *);
+	void			(*crbind)(struct rpc_task *, struct rpc_cred *, int);
 	__be32 *		(*crmarshal)(struct rpc_task *, __be32 *);
 	int			(*crrefresh)(struct rpc_task *);
 	__be32 *		(*crvalidate)(struct rpc_task *, __be32 *);
@@ -140,7 +140,7 @@ struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *
 void			rpcauth_init_cred(struct rpc_cred *, const struct auth_cred *, struct rpc_auth *, const struct rpc_credops *);
 struct rpc_cred *	rpcauth_lookupcred(struct rpc_auth *, int);
 void			rpcauth_bindcred(struct rpc_task *, struct rpc_cred *, int);
-void			rpcauth_generic_bind_cred(struct rpc_task *, struct rpc_cred *);
+void			rpcauth_generic_bind_cred(struct rpc_task *, struct rpc_cred *, int);
 void			put_rpccred(struct rpc_cred *);
 void			rpcauth_unbindcred(struct rpc_task *);
 __be32 *		rpcauth_marshcred(struct rpc_task *, __be32 *);
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 0c431c2..54a4e04 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -385,7 +385,7 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
 EXPORT_SYMBOL_GPL(rpcauth_init_cred);
 
 void
-rpcauth_generic_bind_cred(struct rpc_task *task, struct rpc_cred *cred)
+rpcauth_generic_bind_cred(struct rpc_task *task, struct rpc_cred *cred, int lookupflags)
 {
 	task->tk_msg.rpc_cred = get_rpccred(cred);
 	dprintk("RPC: %5u holding %s cred %p\n", task->tk_pid,
@@ -394,7 +394,7 @@ rpcauth_generic_bind_cred(struct rpc_task *task, struct rpc_cred *cred)
 EXPORT_SYMBOL_GPL(rpcauth_generic_bind_cred);
 
 static void
-rpcauth_bind_root_cred(struct rpc_task *task)
+rpcauth_bind_root_cred(struct rpc_task *task, int lookupflags)
 {
 	struct rpc_auth *auth = task->tk_client->cl_auth;
 	struct auth_cred acred = {
@@ -405,7 +405,7 @@ rpcauth_bind_root_cred(struct rpc_task *task)
 
 	dprintk("RPC: %5u looking up %s cred\n",
 		task->tk_pid, task->tk_client->cl_auth->au_ops->au_name);
-	ret = auth->au_ops->lookup_cred(auth, &acred, 0);
+	ret = auth->au_ops->lookup_cred(auth, &acred, lookupflags);
 	if (!IS_ERR(ret))
 		task->tk_msg.rpc_cred = ret;
 	else
@@ -413,14 +413,14 @@ rpcauth_bind_root_cred(struct rpc_task *task)
 }
 
 static void
-rpcauth_bind_new_cred(struct rpc_task *task)
+rpcauth_bind_new_cred(struct rpc_task *task, int lookupflags)
 {
 	struct rpc_auth *auth = task->tk_client->cl_auth;
 	struct rpc_cred *ret;
 
 	dprintk("RPC: %5u looking up %s cred\n",
 		task->tk_pid, auth->au_ops->au_name);
-	ret = rpcauth_lookupcred(auth, 0);
+	ret = rpcauth_lookupcred(auth, lookupflags);
 	if (!IS_ERR(ret))
 		task->tk_msg.rpc_cred = ret;
 	else
@@ -430,12 +430,16 @@ rpcauth_bind_new_cred(struct rpc_task *task)
 void
 rpcauth_bindcred(struct rpc_task *task, struct rpc_cred *cred, int flags)
 {
+	int lookupflags = 0;
+
+	if (flags & RPC_TASK_ASYNC)
+		lookupflags |= RPCAUTH_LOOKUP_NEW;
 	if (cred != NULL)
-		cred->cr_ops->crbind(task, cred);
+		cred->cr_ops->crbind(task, cred, lookupflags);
 	else if (flags & RPC_TASK_ROOTCREDS)
-		rpcauth_bind_root_cred(task);
+		rpcauth_bind_root_cred(task, lookupflags);
 	else
-		rpcauth_bind_new_cred(task);
+		rpcauth_bind_new_cred(task, lookupflags);
 }
 
 void
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 4028502..bf88bf8 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -55,13 +55,13 @@ struct rpc_cred *rpc_lookup_machine_cred(void)
 EXPORT_SYMBOL_GPL(rpc_lookup_machine_cred);
 
 static void
-generic_bind_cred(struct rpc_task *task, struct rpc_cred *cred)
+generic_bind_cred(struct rpc_task *task, struct rpc_cred *cred, int lookupflags)
 {
 	struct rpc_auth *auth = task->tk_client->cl_auth;
 	struct auth_cred *acred = &container_of(cred, struct generic_cred, gc_base)->acred;
 	struct rpc_cred *ret;
 
-	ret = auth->au_ops->lookup_cred(auth, acred, 0);
+	ret = auth->au_ops->lookup_cred(auth, acred, lookupflags);
 	if (!IS_ERR(ret))
 		task->tk_msg.rpc_cred = ret;
 	else
-- 
1.6.0.4

