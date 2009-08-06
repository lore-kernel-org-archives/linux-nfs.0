From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/10] SUNRPC: Clean up: Remove unused XDR encoder functions
	from rpcb_clnt.c
Date: Thu, 06 Aug 2009 14:54:45 -0400
Message-ID: <20090806185444.3458.90734.stgit@matisse.1015granger.net>
References: <20090806184944.3458.44739.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45895
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753113AbZHFSyr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2009 14:54:47 -0400
In-Reply-To: <20090806184944.3458.44739.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   34 ----------------------------------
 1 files changed, 0 insertions(+), 34 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 823d20d..e0d7b31 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -694,20 +694,6 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
  * XDR functions for rpcbind
  */
 
-static int rpcb_encode_mapping(struct rpc_rqst *req, __be32 *p,
-			       struct rpcbind_args *rpcb)
-{
-	dprintk("RPC:       encoding rpcb request (%u, %u, %d, %u)\n",
-			rpcb->r_prog, rpcb->r_vers, rpcb->r_prot, rpcb->r_port);
-	*p++ = htonl(rpcb->r_prog);
-	*p++ = htonl(rpcb->r_vers);
-	*p++ = htonl(rpcb->r_prot);
-	*p++ = htonl(rpcb->r_port);
-
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
 static int rpcb_enc_mapping(struct rpc_rqst *req, __be32 *p,
 			    const struct rpcbind_args *rpcb)
 {
@@ -750,26 +736,6 @@ static int rpcb_decode_set(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
-static int rpcb_encode_getaddr(struct rpc_rqst *req, __be32 *p,
-			       struct rpcbind_args *rpcb)
-{
-	if (rpcb->r_addr == NULL)
-		return -EIO;
-
-	dprintk("RPC:       encoding rpcb request (%u, %u, %s)\n",
-			rpcb->r_prog, rpcb->r_vers, rpcb->r_addr);
-	*p++ = htonl(rpcb->r_prog);
-	*p++ = htonl(rpcb->r_vers);
-
-	p = xdr_encode_string(p, rpcb->r_netid);
-	p = xdr_encode_string(p, rpcb->r_addr);
-	p = xdr_encode_string(p, rpcb->r_owner);
-
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-
-	return 0;
-}
-
 static int encode_rpcb_string(struct xdr_stream *xdr, const char *string,
 				const u32 maxstrlen)
 {

