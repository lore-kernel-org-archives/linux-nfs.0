Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f47.google.com ([209.85.210.47]:36979 "EHLO
	mail-da0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757214Ab3BXWXj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Feb 2013 17:23:39 -0500
From: Syam Sidhardhan <syamsidhardh@gmail.com>
To: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc: davem@davemloft.net, Trond.Myklebust@netapp.com, syamsidhardh@gmail.com
Subject: [PATCH] SUNRPC: Fix possible NULL pointer dereference
Date: Mon, 25 Feb 2013 03:53:25 +0530
Message-Id: <1361744605-28235-1-git-send-email-s.syam@samsung.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Check for cred == NULL has to be done before accessing cred.

Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
---
 net/sunrpc/auth.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index f529404..18678a6 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -695,10 +695,13 @@ rpcauth_invalcred(struct rpc_task *task)
 {
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
 
+	if (cred == NULL)
+		return;
+
 	dprintk("RPC: %5u invalidating %s cred %p\n",
 		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
-	if (cred)
-		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
+
+	clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 }
 
 int
-- 
1.7.9.5

