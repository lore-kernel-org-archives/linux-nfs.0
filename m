From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/20] SUNRPC: Fix some signed v. unsigned comparisons
	in	xprtsock.c
Date: Mon, 06 Aug 2007 11:56:36 -0400
Message-ID: <20070806155636.31233.33750.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4wr-0000uH-1S
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:56:49 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4wv-0001n7-3S
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:56:53 -0700
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

Currently these are not harmful because the range of "len" is less than the
size of a page.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4ae7eed..274f235 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -338,7 +338,10 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
 		if (remainder != 0 || more)
 			flags |= MSG_MORE;
 		err = sock->ops->sendpage(sock, *ppage, base, len, flags);
-		if (remainder == 0 || err != len)
+		if (err < 0 || (unsigned int)err != len)
+			break;
+
+		if (remainder == 0)
 			break;
 		sent += err;
 		ppage++;
@@ -377,8 +380,12 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
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
@@ -389,7 +396,10 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
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
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
