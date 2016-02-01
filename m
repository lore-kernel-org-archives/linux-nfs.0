Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33347 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932896AbcBAPXL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2016 10:23:11 -0500
Received: by mail-io0-f171.google.com with SMTP id f81so159986674iof.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Feb 2016 07:23:10 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH v2 01/13] SUNRPC: Remove unused function rpc_task_reset_client
Date: Mon,  1 Feb 2016 10:22:23 -0500
Message-Id: <1454340155-7670-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454340155-7670-1-git-send-email-trond.myklebust@primarydata.com>
References: <1454340155-7670-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/clnt.h | 1 -
 net/sunrpc/clnt.c           | 8 --------
 2 files changed, 9 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 131032f15cc1..0c5c2cbe96c9 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -139,7 +139,6 @@ struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
 					struct rpc_xprt *xprt);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
 				const struct rpc_program *, u32);
-void rpc_task_reset_client(struct rpc_task *task, struct rpc_clnt *clnt);
 struct rpc_clnt *rpc_clone_client(struct rpc_clnt *);
 struct rpc_clnt *rpc_clone_client_set_auth(struct rpc_clnt *,
 				rpc_authflavor_t);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b7f21044f4d8..2b4ad7aa40c6 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -900,14 +900,6 @@ void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
 	}
 }
 
-void rpc_task_reset_client(struct rpc_task *task, struct rpc_clnt *clnt)
-{
-	rpc_task_release_client(task);
-	rpc_task_set_client(task, clnt);
-}
-EXPORT_SYMBOL_GPL(rpc_task_reset_client);
-
-
 static void
 rpc_task_set_rpc_message(struct rpc_task *task, const struct rpc_message *msg)
 {
-- 
2.5.0

