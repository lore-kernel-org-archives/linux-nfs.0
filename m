Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAC4AC04EB8
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:33:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B78F620659
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:33:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B78F620659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726068AbeLCAd1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:33:27 -0500
Received: from mx2.suse.de ([195.135.220.15]:41208 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCAd1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:33:27 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 30E87AD90;
        Mon,  3 Dec 2018 00:33:20 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Mon, 03 Dec 2018 11:30:30 +1100
Subject: [PATCH 13/23] SUNRPC: introduce RPC_TASK_NULLCREDS to request
 auth_none
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154379703063.28598.7939095418189753352.stgit@noble>
In-Reply-To: <154379689752.28598.6750646657534626618.stgit@noble>
References: <154379689752.28598.6750646657534626618.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In almost all cases the credential stored in rpc_message.rpc_cred
is a "generic" credential.  One of the two expections is when an
AUTH_NULL credential is used such as for RPC ping requests.

To improve consistency, don't pass an explicit credential in
these cases, but instead pass NULL and set a task flag,
similar to RPC_TASK_ROOTCREDS, which requests that NULL credentials
be used by default.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/auth.c            |    2 ++
 net/sunrpc/clnt.c            |   19 ++++++-------------
 3 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index f542dad8d4ab..bd722ebc70b7 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -118,6 +118,7 @@ struct rpc_task_setup {
  */
 #define RPC_TASK_ASYNC		0x0001		/* is an async task */
 #define RPC_TASK_SWAPPER	0x0002		/* is swapping in/out */
+#define RPC_TASK_NULLCREDS	0x0010		/* Use AUTH_NULL credential */
 #define RPC_CALL_MAJORSEEN	0x0020		/* major timeout seen */
 #define RPC_TASK_ROOTCREDS	0x0040		/* force root creds */
 #define RPC_TASK_DYNAMIC	0x0080		/* task was kmalloc'ed */
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 9e709dcc8c39..dcfcc590b34e 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -761,6 +761,8 @@ rpcauth_bindcred(struct rpc_task *task, struct rpc_cred *cred, int flags)
 		;
 	else if (cred == &machine_cred || (flags & RPC_TASK_ROOTCREDS))
 		new = rpcauth_bind_root_cred(task, lookupflags);
+	else if (flags & RPC_TASK_NULLCREDS)
+		new = authnull_ops.lookup_cred(NULL, NULL, 0);
 	else
 		new = rpcauth_bind_new_cred(task, lookupflags);
 	if (IS_ERR(new))
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7c720b60f482..1217d874202c 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2513,9 +2513,8 @@ static int rpc_ping(struct rpc_clnt *clnt)
 		.rpc_proc = &rpcproc_null,
 	};
 	int err;
-	msg.rpc_cred = authnull_ops.lookup_cred(NULL, NULL, 0);
-	err = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN);
-	put_rpccred(msg.rpc_cred);
+	err = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN |
+			    RPC_TASK_NULLCREDS);
 	return err;
 }
 
@@ -2585,7 +2584,6 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 		void *dummy)
 {
 	struct rpc_cb_add_xprt_calldata *data;
-	struct rpc_cred *cred;
 	struct rpc_task *task;
 
 	data = kmalloc(sizeof(*data), GFP_NOFS);
@@ -2594,11 +2592,9 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 	data->xps = xprt_switch_get(xps);
 	data->xprt = xprt_get(xprt);
 
-	cred = authnull_ops.lookup_cred(NULL, NULL, 0);
-	task = rpc_call_null_helper(clnt, xprt, cred,
-			RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC,
+	task = rpc_call_null_helper(clnt, xprt, NULL,
+			RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC|RPC_TASK_NULLCREDS,
 			&rpc_cb_add_xprt_call_ops, data);
-	put_rpccred(cred);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	rpc_put_task(task);
@@ -2629,7 +2625,6 @@ int rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *clnt,
 				     struct rpc_xprt *xprt,
 				     void *data)
 {
-	struct rpc_cred *cred;
 	struct rpc_task *task;
 	struct rpc_add_xprt_test *xtest = (struct rpc_add_xprt_test *)data;
 	int status = -EADDRINUSE;
@@ -2641,11 +2636,9 @@ int rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *clnt,
 		goto out_err;
 
 	/* Test the connection */
-	cred = authnull_ops.lookup_cred(NULL, NULL, 0);
-	task = rpc_call_null_helper(clnt, xprt, cred,
-				    RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
+	task = rpc_call_null_helper(clnt, xprt, NULL,
+				    RPC_TASK_SOFT | RPC_TASK_SOFTCONN | RPC_TASK_NULLCREDS,
 				    NULL, NULL);
-	put_rpccred(cred);
 	if (IS_ERR(task)) {
 		status = PTR_ERR(task);
 		goto out_err;


