From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] SUNRPC: Clean up debug messages in rpcb_clnt.c
Date: Thu, 25 Sep 2008 11:57:05 -0400
Message-ID: <20080925155704.8353.38944.stgit@manray.1015granger.net>
References: <20080925154814.8353.64762.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:29327 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156AbYIYP6k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2008 11:58:40 -0400
In-Reply-To: <20080925154814.8353.64762.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPCB XDR functions are used for multiple procedures.  For instance,
rpcb_encode_getaddr() is used for RPCB_GETADDR, RPCB_SET, and
RPCB_UNSET.  Make the XDR debug messages more generic so they are less
confusing.

And, unlike in other RPC consumers in the kernel, a single debug flag
enables all levels of debug messages in the RPC bind client, including
XDR debug messages.  Since the XDR decoders already report success or
failure in this case, remove redundant debug messages in the mid-level
rpcb_register_call() function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 02164d4..0b93205 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -197,12 +197,8 @@ static int rpcb_register_call(struct sockaddr *addr, size_t addrlen,
 		return error;
 	}
 
-	if (!result) {
-		dprintk("RPC:       registration failed\n");
+	if (!result)
 		return -EACCES;
-	}
-
-	dprintk("RPC:       registration succeeded\n");
 	return 0;
 }
 
@@ -628,7 +624,7 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
 static int rpcb_encode_mapping(struct rpc_rqst *req, __be32 *p,
 			       struct rpcbind_args *rpcb)
 {
-	dprintk("RPC:       rpcb_encode_mapping(%u, %u, %d, %u)\n",
+	dprintk("RPC:       encoding rpcb request (%u, %u, %d, %u)\n",
 			rpcb->r_prog, rpcb->r_vers, rpcb->r_prot, rpcb->r_port);
 	*p++ = htonl(rpcb->r_prog);
 	*p++ = htonl(rpcb->r_vers);
@@ -643,7 +639,7 @@ static int rpcb_decode_getport(struct rpc_rqst *req, __be32 *p,
 			       unsigned short *portp)
 {
 	*portp = (unsigned short) ntohl(*p++);
-	dprintk("RPC:       rpcb_decode_getport result %u\n",
+	dprintk("RPC:       rpcb getport result: %u\n",
 			*portp);
 	return 0;
 }
@@ -652,7 +648,7 @@ static int rpcb_decode_set(struct rpc_rqst *req, __be32 *p,
 			   unsigned int *boolp)
 {
 	*boolp = (unsigned int) ntohl(*p++);
-	dprintk("RPC:       rpcb_decode_set: call %s\n",
+	dprintk("RPC:       rpcb set/unset call %s\n",
 			(*boolp ? "succeeded" : "failed"));
 	return 0;
 }
@@ -660,7 +656,7 @@ static int rpcb_decode_set(struct rpc_rqst *req, __be32 *p,
 static int rpcb_encode_getaddr(struct rpc_rqst *req, __be32 *p,
 			       struct rpcbind_args *rpcb)
 {
-	dprintk("RPC:       rpcb_encode_getaddr(%u, %u, %s)\n",
+	dprintk("RPC:       encoding rpcb request (%u, %u, %s)\n",
 			rpcb->r_prog, rpcb->r_vers, rpcb->r_addr);
 	*p++ = htonl(rpcb->r_prog);
 	*p++ = htonl(rpcb->r_vers);

