From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/24] SUNRPC: More useful debugging output for rpcb client
Date: Mon, 14 Apr 2008 12:28:07 -0400
Message-ID: <20080414162807.12741.96605.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:40409 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760301AbYDNRBH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 13:01:07 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up dprintk's in rpcb client's XDR decoder functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 3164a08..904b1f5 100644
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
 

