From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/10] SUNRPC: Replace a signed v. unsigned comparison
	in	rpcbind client
Date: Fri, 25 May 2007 17:41:26 -0400
Message-ID: <20070525214125.28668.69844.stgit@schiele.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HrhXR-0003yk-Ar
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:33 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HrhXU-00040o-7E
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:36 -0700
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 6c7aa8a..d9eb93f 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -485,7 +485,8 @@ static int rpcb_decode_getaddr(struct rpc_rqst *req, __be32 *p,
 			       unsigned short *portp)
 {
 	char *addr;
-	int addr_len, c, i, f, first, val;
+	u32 addr_len;
+	int c, i, f, first, val;
 
 	*portp = 0;
 	addr_len = (unsigned int) ntohl(*p++);


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
