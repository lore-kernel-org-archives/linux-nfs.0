Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:42303 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757527Ab3J1W4D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 18:56:03 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>, Chuck Lever <Chuck.Lever@oracle.com>
Subject: [PATCH] SUNRPC: Add correct rcu_dereference annotation in rpc_clnt_set_transport
Date: Mon, 28 Oct 2013 18:55:55 -0400
Message-ID: <1383000955-62175-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc_clnt_set_transport should use rcu_derefence_protected(), as it is
only safe to be called with the rpc_clnt::cl_lock held.

Cc: Chuck Lever <Chuck.Lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/clnt.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f167d9c8d7dd..759b78b056a7 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -272,7 +272,8 @@ static struct rpc_xprt *rpc_clnt_set_transport(struct rpc_clnt *clnt,
 	struct rpc_xprt *old;
 
 	spin_lock(&clnt->cl_lock);
-	old = clnt->cl_xprt;
+	old = rcu_dereference_protected(clnt->cl_xprt,
+			lockdep_is_held(&clnt->cl_lock));
 
 	if (!xprt_bound(xprt))
 		clnt->cl_autobind = 1;
-- 
1.8.3.1

