Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36089 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbcGXVhX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:37:23 -0400
Received: by mail-io0-f194.google.com with SMTP id y34so10765641ioi.3
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:37:23 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix a compiler warning in fs/nfs/clnt.c
Date: Sun, 24 Jul 2016 17:36:58 -0400
Message-Id: <1469396218-85598-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469396218-85598-2-git-send-email-trond.myklebust@primarydata.com>
References: <1469396218-85598-1-git-send-email-trond.myklebust@primarydata.com>
 <1469396218-85598-2-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix the report:

net/sunrpc/clnt.c:2580:1: warning: ‘static’ is not at beginning of declaration [-Wold-style-declaration]

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/clnt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 06b4df9faaa1..d6e75872454d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2558,7 +2558,7 @@ static void rpc_cb_add_xprt_release(void *calldata)
 	kfree(data);
 }
 
-const static struct rpc_call_ops rpc_cb_add_xprt_call_ops = {
+static const struct rpc_call_ops rpc_cb_add_xprt_call_ops = {
 	.rpc_call_done = rpc_cb_add_xprt_done,
 	.rpc_release = rpc_cb_add_xprt_release,
 };
-- 
2.7.4

