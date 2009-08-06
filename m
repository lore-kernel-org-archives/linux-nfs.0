From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/10] SUNRPC: Clean up: Remove unused XDR decoder functions
	from rpcb_clnt.c
Date: Thu, 06 Aug 2009 14:55:08 -0400
Message-ID: <20090806185507.3458.60802.stgit@matisse.1015granger.net>
References: <20090806184944.3458.44739.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45904
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751902AbZHFSzJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2009 14:55:09 -0400
In-Reply-To: <20090806184944.3458.44739.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   81 ------------------------------------------------
 1 files changed, 0 insertions(+), 81 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 88de754..c4b716c 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -718,15 +718,6 @@ static int rpcb_enc_mapping(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
-static int rpcb_decode_getport(struct rpc_rqst *req, __be32 *p,
-			       unsigned short *portp)
-{
-	*portp = (unsigned short) ntohl(*p++);
-	dprintk("RPC:       rpcb getport result: %u\n",
-			*portp);
-	return 0;
-}
-
 static int rpcb_dec_getport(struct rpc_rqst *req, __be32 *p,
 			    struct rpcbind_args *rpcb)
 {
@@ -752,15 +743,6 @@ static int rpcb_dec_getport(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
-static int rpcb_decode_set(struct rpc_rqst *req, __be32 *p,
-			   unsigned int *boolp)
-{
-	*boolp = (unsigned int) ntohl(*p++);
-	dprintk("RPC:       rpcb set/unset call %s\n",
-			(*boolp ? "succeeded" : "failed"));
-	return 0;
-}
-
 static int rpcb_dec_set(struct rpc_rqst *req, __be32 *p,
 			unsigned int *boolp)
 {
@@ -833,69 +815,6 @@ static int rpcb_enc_getaddr(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
-static int rpcb_decode_getaddr(struct rpc_rqst *req, __be32 *p,
-			       unsigned short *portp)
-{
-	char *addr;
-	u32 addr_len;
-	int c, i, f, first, val;
-
-	*portp = 0;
-	addr_len = ntohl(*p++);
-
-	if (addr_len == 0) {
-		dprintk("RPC:       rpcb_decode_getaddr: "
-					"service is not registered\n");
-		return 0;
-	}
-
-	/*
-	 * Simple sanity check.
-	 */
-	if (addr_len > RPCBIND_MAXUADDRLEN)
-		goto out_err;
-
-	/*
-	 * Start at the end and walk backwards until the first dot
-	 * is encountered.  When the second dot is found, we have
-	 * both parts of the port number.
-	 */
-	addr = (char *)p;
-	val = 0;
-	first = 1;
-	f = 1;
-	for (i = addr_len - 1; i > 0; i--) {
-		c = addr[i];
-		if (c >= '0' && c <= '9') {
-			val += (c - '0') * f;
-			f *= 10;
-		} else if (c == '.') {
-			if (first) {
-				*portp = val;
-				val = first = 0;
-				f = 1;
-			} else {
-				*portp |= (val << 8);
-				break;
-			}
-		}
-	}
-
-	/*
-	 * Simple sanity check.  If we never saw a dot in the reply,
-	 * then this was probably just garbage.
-	 */
-	if (first)
-		goto out_err;
-
-	dprintk("RPC:       rpcb_decode_getaddr port=%u\n", *portp);
-	return 0;
-
-out_err:
-	dprintk("RPC:       rpcbind server returned malformed reply\n");
-	return -EIO;
-}
-
 static int rpcb_dec_getaddr(struct rpc_rqst *req, __be32 *p,
 			    struct rpcbind_args *rpcb)
 {

