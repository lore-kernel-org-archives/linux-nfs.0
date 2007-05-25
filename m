From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/10] SUNRPC: Fix some compiler warnings in xprtsock.c
Date: Fri, 25 May 2007 17:41:36 -0400
Message-ID: <20070525214136.28668.89062.stgit@schiele.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HrhXb-0003zR-Rq
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:43 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HrhXe-0002Wj-Md
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:46 -0700
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

 net/sunrpc/xprtsock.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index dd2a9db..d08a151 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -302,7 +302,9 @@ static void xs_free_peer_addresses(struct rpc_xprt *xprt)
 
 #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
 
-static int xs_send_kvec(struct socket *sock, struct sockaddr *addr, int addrlen, struct kvec *vec, unsigned int base, int more)
+static int xs_send_kvec(struct socket *sock, struct sockaddr *addr,
+			int addrlen, struct kvec *vec, unsigned int base,
+			int more)
 {
 	struct msghdr msg = {
 		.msg_name	= addr,
@@ -363,7 +365,8 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr,
  * @base: starting position in the buffer
  *
  */
-static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen, struct xdr_buf *xdr, unsigned int base)
+static int xs_sendpages(struct socket *sock, struct sockaddr *addr,
+			int addrlen, struct xdr_buf *xdr, unsigned int base)
 {
 	unsigned int remainder = xdr->len - base;
 	int err, sent = 0;
@@ -380,8 +383,12 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 	if (base < xdr->head[0].iov_len || addr != NULL) {
 		unsigned int len = xdr->head[0].iov_len - base;
 		remainder -= len;
-		err = xs_send_kvec(sock, addr, addrlen, &xdr->head[0], base, remainder != 0);
-		if (remainder == 0 || err != len)
+		err = xs_send_kvec(sock, addr, addrlen, &xdr->head[0],
+				   base, remainder != 0);
+		if (err < 0 || (unsigned int)err != len)
+			goto out;
+
+		if (remainder == 0)
 			goto out;
 		sent += err;
 		base = 0;
@@ -392,7 +399,10 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 		unsigned int len = xdr->page_len - base;
 		remainder -= len;
 		err = xs_send_pagedata(sock, xdr, base, remainder != 0);
-		if (remainder == 0 || err != len)
+		if (err < 0 || (unsigned int)err != len)
+			goto out;
+
+		if (remainder == 0)
 			goto out;
 		sent += err;
 		base = 0;


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
