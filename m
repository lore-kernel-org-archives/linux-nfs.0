From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/15] SUNRPC: Retry bad rpcbind replies
Date: Tue, 11 Sep 2007 18:00:36 -0400
Message-ID: <20070911220036.26136.50947.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDnH-0006xN-BJ
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:15 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDnM-00020T-0n
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:20 -0700
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

When a server returns a bad rpcbind reply, make rpcbind client recovery logic
retry with an older protocol version.  Older versions are more likely to work
correctly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 34738c5..a0c9f69 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -446,6 +446,10 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
 	struct rpc_xprt *xprt = map->r_xprt;
 	int status = child->tk_status;
 
+	/* Garbage reply: retry with a lesser rpcbind version */
+	if (status == -EIO)
+		status = -EPROTONOSUPPORT;
+
 	/* rpcbind server doesn't support this rpcbind protocol version */
 	if (status == -EPROTONOSUPPORT)
 		xprt->bind_index++;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
