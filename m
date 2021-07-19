Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BFA7C07E9D
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Jul 2021 14:54:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 52E3A61019
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Jul 2021 14:54:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232597AbhGSONp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Jul 2021 10:13:45 -0400
Received: from mail.kernel.org ([198.145.29.99]:45462 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S232059AbhGSONp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Jul 2021 10:13:45 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id B3688610D2;
        Mon, 19 Jul 2021 14:48:04 +0000 (UTC)
Subject: [PATCH v2 1/6] SUNRPC: Refactor rpc_ping()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     trondmy@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Date:   Mon, 19 Jul 2021 10:48:04 -0400
Message-ID: <162670608397.468132.13660340202537302059.stgit@manet.1015granger.net>
In-Reply-To: <162670594361.468132.16222376053830760696.stgit@manet.1015granger.net>
References: <162670594361.468132.16222376053830760696.stgit@manet.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Make it use the rpc_null_call_helper() so that it can share the
new rpc_call_ops structure to be introduced in the next patch.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/clnt.c |   24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8b4de70e8ead..ca2000d8cf64 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2694,17 +2694,6 @@ static const struct rpc_procinfo rpcproc_null = {
 	.p_decode = rpcproc_decode_null,
 };
 
-static int rpc_ping(struct rpc_clnt *clnt)
-{
-	struct rpc_message msg = {
-		.rpc_proc = &rpcproc_null,
-	};
-	int err;
-	err = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN |
-			    RPC_TASK_NULLCREDS);
-	return err;
-}
-
 static
 struct rpc_task *rpc_call_null_helper(struct rpc_clnt *clnt,
 		struct rpc_xprt *xprt, struct rpc_cred *cred, int flags,
@@ -2733,6 +2722,19 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int
 }
 EXPORT_SYMBOL_GPL(rpc_call_null);
 
+static int rpc_ping(struct rpc_clnt *clnt)
+{
+	struct rpc_task	*task;
+	int status;
+
+	task = rpc_call_null_helper(clnt, NULL, NULL, 0, NULL, NULL);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	status = task->tk_status;
+	rpc_put_task(task);
+	return status;
+}
+
 struct rpc_cb_add_xprt_calldata {
 	struct rpc_xprt_switch *xps;
 	struct rpc_xprt *xprt;


