From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/10] SUNRPC: Fix a signage nit
Date: Fri, 25 May 2007 17:41:41 -0400
Message-ID: <20070525214141.28668.75351.stgit@schiele.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HrhXe-0003zW-MT
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:46 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HrhXh-000431-K8
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:49 -0700
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

Avoids a compiler warning.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d08a151..f44c04d 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -536,7 +536,8 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	struct rpc_xprt *xprt = req->rq_xprt;
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	struct xdr_buf *xdr = &req->rq_snd_buf;
-	int status, retry = 0;
+	int status;
+	unsigned int retry = 0;
 
 	xs_encode_tcp_record_marker(&req->rq_snd_buf);
 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
