Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:35177 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752078Ab2LOWcl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 15 Dec 2012 17:32:41 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: variable 'svsk' is unused in function bc_send_request
Date: Sat, 15 Dec 2012 17:32:35 -0500
Message-Id: <1355610755-27787-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1355610755-27787-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1355610755-27787-1-git-send-email-Trond.Myklebust@netapp.com>
 <1355610755-27787-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Silence a compile time warning.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xprtsock.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7163ef5..68b0a81 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2400,7 +2400,6 @@ static int bc_send_request(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct svc_xprt	*xprt;
-	struct svc_sock         *svsk;
 	u32                     len;
 
 	dprintk("sending request with xid: %08x\n", ntohl(req->rq_xid));
@@ -2408,7 +2407,6 @@ static int bc_send_request(struct rpc_task *task)
 	 * Get the server socket associated with this callback xprt
 	 */
 	xprt = req->rq_xprt->bc_xprt;
-	svsk = container_of(xprt, struct svc_sock, sk_xprt);
 
 	/*
 	 * Grab the mutex to serialize data as the connection is shared
-- 
1.7.11.7

