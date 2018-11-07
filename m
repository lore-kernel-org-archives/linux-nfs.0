Return-Path: <SRS0=4cvb=NS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 030BFC0044C
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:15:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C7AF22081D
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:15:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7AF22081D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727289AbeKGNni (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Nov 2018 08:43:38 -0500
Received: from mx2.suse.de ([195.135.220.15]:56832 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726516AbeKGNni (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Nov 2018 08:43:38 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 9AAD4B659;
        Wed,  7 Nov 2018 04:15:00 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Wed, 07 Nov 2018 15:12:31 +1100
Subject: [PATCH 14/23] SUNRPC: add side channel to use non-generic cred for
 rpc call.
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154156395125.24086.7558322763063813778.stgit@noble>
In-Reply-To: <154156285766.24086.14262073575778354276.stgit@noble>
References: <154156285766.24086.14262073575778354276.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The credential passed in rpc_message.rpc_cred is always a
generic credential except in one instance.
When gss_destroying_context() calls rpc_call_null(), it passes
a specific credential that it needs to destroy.
In this case the RPC acts *on* the credential rather than
being authorized by it.

This special case deserves explicit support and providing that will
mean that rpc_message.rpc_cred is *always* generic, allowing
some optimizations.

So add "tk_op_cred" to rpc_task and "rpc_op_cred" to the setup data.
Use this to pass the cred down from rpc_call_null(), and have
rpcauth_bindcred() notice it and bind it in place.

Credit to kernel test robot <fengguang.wu@intel.com> for finding
a bug in earlier version of this patch.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/sunrpc/sched.h |    2 ++
 net/sunrpc/auth.c            |    6 +++++-
 net/sunrpc/clnt.c            |    2 +-
 net/sunrpc/sched.c           |    3 +++
 4 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index bd722ebc70b7..4e2b893b83a8 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -71,6 +71,7 @@ struct rpc_task {
 
 	struct rpc_clnt *	tk_client;	/* RPC client */
 	struct rpc_xprt *	tk_xprt;	/* Transport */
+	struct rpc_cred *	tk_op_cred;	/* cred being operated on */
 
 	struct rpc_rqst *	tk_rqstp;	/* RPC request */
 
@@ -105,6 +106,7 @@ struct rpc_task_setup {
 	struct rpc_task *task;
 	struct rpc_clnt *rpc_client;
 	struct rpc_xprt *rpc_xprt;
+	struct rpc_cred *rpc_op_cred;	/* credential being operated on */
 	const struct rpc_message *rpc_message;
 	const struct rpc_call_ops *callback_ops;
 	void *callback_data;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index dcfcc590b34e..27d90578e7a0 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -751,7 +751,11 @@ rpcauth_bindcred(struct rpc_task *task, struct rpc_cred *cred, int flags)
 
 	if (flags & RPC_TASK_ASYNC)
 		lookupflags |= RPCAUTH_LOOKUP_NEW;
-	if (cred != NULL && cred != &machine_cred)
+	if (task->tk_op_cred)
+		/* Task must use exactly this rpc_cred */
+		new = task->tk_op_cred->cr_ops->crbind(task, task->tk_op_cred,
+						       lookupflags);
+	else if (cred != NULL && cred != &machine_cred)
 		new = cred->cr_ops->crbind(task, cred, lookupflags);
 	else if (cred == &machine_cred)
 		new = rpcauth_bind_machine_cred(task, lookupflags);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 1217d874202c..87a517d576c1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2525,12 +2525,12 @@ struct rpc_task *rpc_call_null_helper(struct rpc_clnt *clnt,
 {
 	struct rpc_message msg = {
 		.rpc_proc = &rpcproc_null,
-		.rpc_cred = cred,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = clnt,
 		.rpc_xprt = xprt,
 		.rpc_message = &msg,
+		.rpc_op_cred = cred,
 		.callback_ops = (ops != NULL) ? ops : &rpc_default_ops,
 		.callback_data = data,
 		.flags = flags,
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 57ca5bead1cb..c9f65037a6ad 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -997,6 +997,8 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 
 	task->tk_xprt = xprt_get(task_setup_data->rpc_xprt);
 
+	task->tk_op_cred = get_rpccred(task_setup_data->rpc_op_cred);
+
 	if (task->tk_ops->rpc_call_prepare != NULL)
 		task->tk_action = rpc_prepare_task;
 
@@ -1054,6 +1056,7 @@ static void rpc_free_task(struct rpc_task *task)
 {
 	unsigned short tk_flags = task->tk_flags;
 
+	put_rpccred(task->tk_op_cred);
 	rpc_release_calldata(task->tk_ops, task->tk_calldata);
 
 	if (tk_flags & RPC_TASK_DYNAMIC) {


