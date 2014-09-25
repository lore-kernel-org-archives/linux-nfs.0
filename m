Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:42808 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987AbaIYCvX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 22:51:23 -0400
Received: by mail-qa0-f49.google.com with SMTP id n8so4032488qaq.22
        for <linux-nfs@vger.kernel.org>; Wed, 24 Sep 2014 19:51:22 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Add missing support for RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT
Date: Wed, 24 Sep 2014 22:51:19 -0400
Message-Id: <1411613479-8803-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The flag RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT was intended introduced in
order to allow NFSv4 clients to disable resend timeouts. Since those
cause the RPC layer to break the connection, they mess up the duplicate
reply caches that remain indexed on the port number in NFSv4..

This patch includes the code that was missing in the original to
set the appropriate flag in struct rpc_clnt, when the caller of
rpc_create() sets RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT.

Fixes: 8a19a0b6cb2e (SUNRPC: Add RPC task and client level options to...)
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/clnt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 488ddeed9363..841565450354 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -461,6 +461,8 @@ struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
 
 	if (args->flags & RPC_CLNT_CREATE_AUTOBIND)
 		clnt->cl_autobind = 1;
+	if (args->flags & RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT)
+		clnt->cl_noretranstimeo = 1;
 	if (args->flags & RPC_CLNT_CREATE_DISCRTRY)
 		clnt->cl_discrtry = 1;
 	if (!(args->flags & RPC_CLNT_CREATE_QUIET))
-- 
1.9.3

