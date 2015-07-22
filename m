Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:34887 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752321AbbGVVM5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 17:12:57 -0400
Received: by igr7 with SMTP id 7so78274075igr.0
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2015 14:12:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/2] SUNRPC: Fix a backchannel deadlock
Date: Wed, 22 Jul 2015 17:12:54 -0400
Message-Id: <1437599575-25281-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xprt_alloc_bc_request() cannot call xprt_free_bc_request() without
deadlocking, since it already holds the xprt->bc_pa_lock.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Fixes: 0d2a970d0ae55 ("SUNRPC: Fix a backchannel race")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/backchannel_rqst.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 9825ff0f91d6..5a3b50aec397 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -240,8 +240,8 @@ static struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt, __be32 xid)
 		req = xprt_alloc_bc_req(xprt, GFP_ATOMIC);
 		if (!req)
 			goto not_found;
-		/* Note: this 'free' request adds it to xprt->bc_pa_list */
-		xprt_free_bc_request(req);
+		list_add_tail(&req->rq_bc_pa_list, &xprt->bc_pa_list);
+		xprt->bc_alloc_count++;
 	}
 	req = list_first_entry(&xprt->bc_pa_list, struct rpc_rqst,
 				rq_bc_pa_list);
-- 
2.4.3

