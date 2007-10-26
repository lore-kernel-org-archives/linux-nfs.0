From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/27] SUNRPC: Fix an unnecessary implicit type cast
	in	rpcrdma_count_chunks()
Date: Fri, 26 Oct 2007 13:30:49 -0400
Message-ID: <20071026173049.31475.68976.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT1a-0007Aj-6R
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:14 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT1a-0007w0-9B
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:10 -0700
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

Nit: rl_nchunks is an unsigned integer, so pass it into
rpcrdma_count_chunks() via an unsigned integer argument.  This eliminates
a harmless mixed sign comparison in rpcrdma_count_chunks()

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 65e211e..7024ac8 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -559,7 +559,8 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
  * RDMA'd by server. See map at rpcrdma_create_chunks()! :-)
  */
 static int
-rpcrdma_count_chunks(struct rpcrdma_rep *rep, int max, int wrchunk, u32 **iptrp)
+rpcrdma_count_chunks(struct rpcrdma_rep *rep, unsigned int max, int wrchunk,
+		     u32 **iptrp)
 {
 	unsigned int i, total_len;
 	struct rpcrdma_write_chunk *cur_wchunk;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
