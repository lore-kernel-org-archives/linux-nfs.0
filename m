Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50349 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491Ab0IGFC1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 01:02:27 -0400
Date: Tue, 7 Sep 2010 01:01:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] Fix null dereference in call_allocate
Message-ID: <20100907050142.GA14584@fieldses.org>
References: <20100828170953.GB5104@fieldses.org>
 <20100830175728.GA18764@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100830175728.GA18764@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

In call_allocate we need to reach the auth in order to factor au_cslack
into the allocation.

As of a17c2153d2e271b0cbacae9bed83b0eaa41db7e1 "SUNRPC: Move the bound
cred to struct rpc_rqst", call_allocate attempts to do this by
dereferencing tk_client->cl_auth, however this is not guaranteed to be
defined--cl_auth can be zero in the case of gss context destruction (see
rpc_free_auth).

Reorder the client state machine to bind credentials before allocating,
so that we can instead reach the auth through the cred.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>

---

On Mon, Aug 30, 2010 at 01:57:28PM -0400, J. Bruce Fields wrote:
> On Sat, Aug 28, 2010 at 01:09:53PM -0400, J. Bruce Fields wrote:
> > As of a17c2153d2e271b0cbacae9bed83b0eaa41db7e1 "SUNRPC: Move the bound
> > cred to struct rpc_rqst" the NFS server crashes when using krb5.
> > 
> > I don't have good errors--I'll get some--but what I've seen suggests
> > maybe a use-after-free of an rpc client on rpc_pipefs operations by
> > gssd?

As it turns out, there were two problems causing the crashes I saw.
This one was the regression identified by the above commit.

If this is actually the right approach, then we should probably also
reorder these functions and fix the comments to reflect the new
state-machine order.

--b.

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2388d83..657aac6 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -931,7 +931,7 @@ call_reserveresult(struct rpc_task *task)
 	task->tk_status = 0;
 	if (status >= 0) {
 		if (task->tk_rqstp) {
-			task->tk_action = call_allocate;
+			task->tk_action = call_refresh;
 			return;
 		}
 
@@ -972,7 +972,7 @@ call_reserveresult(struct rpc_task *task)
 static void
 call_allocate(struct rpc_task *task)
 {
-	unsigned int slack = task->tk_client->cl_auth->au_cslack;
+	unsigned int slack = task->tk_rqstp->rq_cred->cr_auth->au_cslack;
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = task->tk_xprt;
 	struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
@@ -980,7 +980,7 @@ call_allocate(struct rpc_task *task)
 	dprint_status(task);
 
 	task->tk_status = 0;
-	task->tk_action = call_refresh;
+	task->tk_action = call_bind;
 
 	if (req->rq_buffer)
 		return;
@@ -1042,7 +1042,7 @@ call_refreshresult(struct rpc_task *task)
 	dprint_status(task);
 
 	task->tk_status = 0;
-	task->tk_action = call_bind;
+	task->tk_action = call_allocate;
 	if (status >= 0 && rpcauth_uptodatecred(task))
 		return;
 	switch (status) {
