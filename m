From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/7] SUNRPC: Fix bytes-per-op accounting for RPC over
	UDP
Date: Mon, 24 Sep 2007 15:40:00 -0400
Message-ID: <20070924194000.3568.12518.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZtnB-0001Oa-3w
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 12:40:29 -0700
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZtn9-0007W6-Ro
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 12:40:29 -0700
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

NFS performance metrics reported zero bytes sent per op when mounting with
UDP.  The UDP socket transport wasn't properly counting the number of bytes
sent.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b81494a..e97e4ca 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -587,6 +587,7 @@ static int xs_udp_send_request(struct rpc_task *task)
 	dprintk("RPC:       xs_udp_send_request(%u) = %d\n",
 			xdr->len - req->rq_bytes_sent, status);
 
+	task->tk_bytes_sent += status;
 	if (likely(status >= (int) req->rq_slen))
 		return 0;
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
