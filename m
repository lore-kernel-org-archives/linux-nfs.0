From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/27] SUNRPC: Prevent mixed sign comparisons
	in	rpcrdma_convert_iovs()
Date: Fri, 26 Oct 2007 13:30:43 -0400
Message-ID: <20071026173043.31475.35420.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT1S-00078J-M8
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:02 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT1Y-0007sP-3b
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:08 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Keep the type of the buffer position the same during iovec conversion to
reduce the likelihood of unexpected results from comparisons and length
computations.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 12db635..65e211e 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -83,7 +83,7 @@ static const char transfertypes[][12] = {
  */
 
 static int
-rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, int pos,
+rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 	enum rpcrdma_chunktype type, struct rpcrdma_mr_seg *seg, int nsegs)
 {
 	int len, n = 0, p;
@@ -130,7 +130,7 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, int pos,
 	}
 
 	if (pos < xdrbuf->len)
-		dprintk("RPC:       %s: marshaled only %d of %d\n",
+		dprintk("RPC:       %s: marshaled only %u of %u\n",
 				__func__, pos, xdrbuf->len);
 
 	return n;
@@ -176,7 +176,7 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_task->tk_xprt);
 	int nsegs, nchunks = 0;
-	int pos;
+	unsigned int pos;
 	struct rpcrdma_mr_seg *seg = req->rl_segments;
 	struct rpcrdma_read_chunk *cur_rchunk = NULL;
 	struct rpcrdma_write_array *warray = NULL;
@@ -220,7 +220,7 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 					(u32 *)&cur_rchunk->rc_target.rs_offset,
 					seg->mr_base);
 			dprintk("RPC:       %s: read chunk "
-				"elem %d@0x%llx:0x%x pos %d (%s)\n", __func__,
+				"elem %d@0x%llx:0x%x pos %u (%s)\n", __func__,
 				seg->mr_len, seg->mr_base, seg->mr_rkey, pos,
 				n < nsegs ? "more" : "last");
 			cur_rchunk++;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
