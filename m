From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/10] SUNRPC: Use more consistent variable typing
	in	xs_send_pagedata
Date: Fri, 25 May 2007 17:41:31 -0400
Message-ID: <20070525214131.28668.48936.stgit@schiele.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HrhXZ-0003zM-H5
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:41 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HrhXb-0002Vx-DO
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:44 -0700
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

The 3rd argument of ->sendpage is an "int" and the 4th is a "size_t".
Make sure that comparison between the "int" return value and a "size_t"
variable is explicitly cast.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index cc33c58..dd2a9db 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -319,7 +319,8 @@ static int xs_send_kvec(struct socket *sock, struct sockaddr *addr, int addrlen,
 	return kernel_sendmsg(sock, &msg, NULL, 0, 0);
 }
 
-static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned int base, int more)
+static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr,
+			    unsigned int base, int more)
 {
 	struct page **ppage;
 	unsigned int remainder;
@@ -330,14 +331,17 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
 	ppage = xdr->pages + (base >> PAGE_SHIFT);
 	base &= ~PAGE_MASK;
 	for(;;) {
-		unsigned int len = min_t(unsigned int, PAGE_SIZE - base, remainder);
+		size_t len = min_t(size_t, PAGE_SIZE - base, remainder);
 		int flags = XS_SENDMSG_FLAGS;
 
 		remainder -= len;
 		if (remainder != 0 || more)
 			flags |= MSG_MORE;
-		err = sock->ops->sendpage(sock, *ppage, base, len, flags);
-		if (remainder == 0 || err != len)
+		err = sock->ops->sendpage(sock, *ppage, (int)base, len, flags);
+		if (err < 0 || (size_t)err != len)
+			break;
+
+		if (remainder == 0)
 			break;
 		sent += err;
 		ppage++;


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
