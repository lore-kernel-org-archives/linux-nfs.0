From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] SUNRPC: More useful debugging output for rpcb client
Date: Wed, 25 Jun 2008 17:24:23 -0400
Message-ID: <20080625212423.3171.3112.stgit@ellison.1015granger.net>
References: <20080625212101.3171.86703.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62310 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448AbYFYVZQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2008 17:25:16 -0400
In-Reply-To: <20080625212101.3171.86703.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up dprintk's in rpcb client's XDR decoder functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)


diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 0517967..2c27dd1 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -439,7 +439,7 @@ static int rpcb_decode_getport(struct rpc_rqst *req, __be32 *p,
 			       unsigned short *portp)
 {
 	*portp = (unsigned short) ntohl(*p++);
-	dprintk("RPC:      rpcb_decode_getport result %u\n",
+	dprintk("RPC:       rpcb_decode_getport result %u\n",
 			*portp);
 	return 0;
 }
@@ -448,8 +448,8 @@ static int rpcb_decode_set(struct rpc_rqst *req, __be32 *p,
 			   unsigned int *boolp)
 {
 	*boolp = (unsigned int) ntohl(*p++);
-	dprintk("RPC:      rpcb_decode_set result %u\n",
-			*boolp);
+	dprintk("RPC:       rpcb_decode_set: call %s\n",
+			(*boolp ? "succeeded" : "failed"));
 	return 0;
 }
 

