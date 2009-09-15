From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH v2 05/12] nfsd41: Backchannel: callback infrastructure
Date: Tue, 15 Sep 2009 13:32:13 -0400
Message-ID: <1253035933.4456.43.camel@heimdal.trondhjem.org>
References: <20090914163535.GE30806@fieldses.org>
	 <20090914164951.GA32757@fieldses.org> <4AAE7C19.7070600@panasas.com>
	 <20090914200423.GE1658@fieldses.org>
	 <1252959452.6866.92.camel@heimdal.trondhjem.org>
	 <20090914203910.GF1658@fieldses.org>
	 <1252961253.6866.98.camel@heimdal.trondhjem.org>
	 <20090914205648.GG1658@fieldses.org>
	 <1252962546.6866.102.camel@heimdal.trondhjem.org>
	 <1252962982.6866.104.camel@heimdal.trondhjem.org>
	 <20090915151048.GA19339@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:42051 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754494AbZIORcS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Sep 2009 13:32:18 -0400
In-Reply-To: <20090915151048.GA19339@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-09-15 at 11:10 -0400, J. Bruce Fields wrote:
> On Mon, Sep 14, 2009 at 05:16:22PM -0400, Trond Myklebust wrote:
> > On Mon, 2009-09-14 at 17:09 -0400, Trond Myklebust wrote:
> > 
> > > I suppose we could. Alternatively, why not just call it once and for all
> > > when you start the NFSv4 server? The one cred will work on all
> > > rpc_clients.
> > 
> > (This is correct...)
> > 
> > > You just have to remember to bump the reference count
> > > before using it in an RPC call...
> > 
> > Oops! Sorry, this is incorrect. The RPC engine will take care of bumping
> > the ref count for you if necessary...
> 
> OK, on another look: I create a generic cred with
> rpc_lookup_machine_cred().  The gss cred then gets created by something
> like:
> 
> 	rpc_call_async
> 	  rpc_run_task
> 	    rpc_new_task
> 	      rpc_init_task
> 	        rpcauth_bindcred
> 		  cred->cr_ops->crbind == generic_bind_cred
> 		    gss_auth->au_ops->lookup_cred(auth, acred, 0)
> 		      rpcauth_lookup_credcache(gss_auth, acred, 0)
> 
> But rpcauth_lookup_credcache ends up calling cr_init (gss_cred_init) and
> waiting synchronously for the gss upcall.  I want to avoid that.  Should
> I be setting up the cred differently, or could the rpc task
> initialization process be tweaked somehow?  (Or am I just
> misunderstanding the code?)

How about something like the following?

------------------------------------------------------------------------
SUNRPC: Defer the auth_gss upcall when the RPC call is asynchronous

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Otherwise, the upcall is going to be synchronous, which may not be what the
caller wants...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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


