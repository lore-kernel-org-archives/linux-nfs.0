Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:57522 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756482Ab3CSTBo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 15:01:44 -0400
Received: by mail-ie0-f173.google.com with SMTP id 9so1097574iec.4
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 12:01:44 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] SUNRPC: Remove extra xprt_put()
To: linux-nfs@vger.kernel.org
Date: Tue, 19 Mar 2013 15:01:28 -0400
Message-ID: <20130319190128.1203.29390.stgit@seurat.1015granger.net>
In-Reply-To: <20130319185944.1203.38377.stgit@seurat.1015granger.net>
References: <20130319185944.1203.38377.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While testing error cases where rpc_new_client() fails, I saw
some oopses.

If rpc_new_client() fails, it already invokes xprt_put().  Thus
__rpc_clone_client() does not need to invoke it again.

Introduced by commit 1b63a751 "SUNRPC: Refactor rpc_clone_client()"
Fri Sep 14, 2012.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@kernel.org
---

 net/sunrpc/clnt.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index dcc446e..9df26b7 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -512,7 +512,7 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
 	new = rpc_new_client(args, xprt);
 	if (IS_ERR(new)) {
 		err = PTR_ERR(new);
-		goto out_put;
+		goto out_err;
 	}
 
 	atomic_inc(&clnt->cl_count);
@@ -525,8 +525,6 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
 	new->cl_chatty = clnt->cl_chatty;
 	return new;
 
-out_put:
-	xprt_put(xprt);
 out_err:
 	dprintk("RPC:       %s: returned error %d\n", __func__, err);
 	return ERR_PTR(err);

