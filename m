From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/21] SUNRPC: optimize socket send_request path
Date: Thu, 16 Nov 2006 15:04:47 -0500
Message-ID: <20061116200446.32549.12589.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko1j-0006ut-PU
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:03 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko1k-0004v5-9y
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:05 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061116200151.32549.88898.stgit@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Calling PageHighMem in the RPC client's socket send path is no longer
necessary because the device layer handles mapping high memory as
required (in fact by calling PageHighMem).

Clean up the socket send_request path by removing now invariant tests.

This will have a significant CPU benefit.  Kernel execution profiling
showed that the PageHighMem invocation here introduced a nasty AGI stall
in the middle of xs_sendpages; *page is never referenced again until we
get deep into the network layer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   30 +++++++++++++++++++++---------
 1 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f000595..9e6202a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -219,6 +219,7 @@ struct sock_xprt {
 	 */
 	struct socket *		sock;
 	struct sock *		inet;
+	unsigned char		sendpage   : 1;
 
 	/*
 	 * State of TCP reply receive
@@ -338,15 +339,18 @@ static int xs_send_tail(struct socket *s
 
 /**
  * xs_sendpages - write pages directly to a socket
- * @sock: socket to send on
+ * @priv: transport-specific info
  * @addr: UDP only -- address of destination
  * @addrlen: UDP only -- length of destination address
  * @xdr: buffer containing this request
  * @base: starting position in the buffer
  *
  */
-static inline int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen, struct xdr_buf *xdr, unsigned int base)
+static int xs_sendpages(struct sock_xprt *transport, struct sockaddr *addr,
+				int addrlen, struct xdr_buf *xdr,
+				unsigned int base)
 {
+	struct socket *sock = transport->sock;
 	struct page **ppage = xdr->pages;
 	unsigned int len, pglen = xdr->page_len;
 	int err, ret = 0;
@@ -394,7 +398,10 @@ static inline int xs_sendpages(struct so
 		if (pglen != len || xdr->tail[0].iov_len != 0)
 			flags |= MSG_MORE;
 
-		err = kernel_sendpage(sock, *ppage, base, len, flags);
+		if (likely(transport->sendpage))
+			err = kernel_sendpage(sock, *ppage, base, len, flags);
+		else
+			err = sock_no_sendpage(sock, *ppage, base, len, flags);
 		if (ret == 0)
 			ret = err;
 		else if (err > 0)
@@ -472,10 +479,8 @@ static int xs_udp_send_request(struct rp
 				req->rq_svec->iov_len);
 
 	req->rq_xtime = jiffies;
-	status = xs_sendpages(transport->sock,
-			      (struct sockaddr *) &xprt->addr,
-			      xprt->addrlen, xdr,
-			      req->rq_bytes_sent);
+	status = xs_sendpages(transport, (struct sockaddr *) &xprt->addr,
+				xprt->addrlen, xdr, req->rq_bytes_sent);
 
 	dprintk("RPC:      xs_udp_send_request(%u) = %d\n",
 			xdr->len - req->rq_bytes_sent, status);
@@ -546,8 +551,7 @@ static int xs_tcp_send_request(struct rp
 	 * called sendmsg(). */
 	while (1) {
 		req->rq_xtime = jiffies;
-		status = xs_sendpages(transport->sock,
-					NULL, 0, xdr, req->rq_bytes_sent);
+		status = xs_sendpages(transport, NULL, 0, xdr, req->rq_bytes_sent);
 
 		dprintk("RPC:      xs_tcp_send_request(%u) = %d\n",
 				xdr->len - req->rq_bytes_sent, status);
@@ -1235,6 +1239,10 @@ static void xs_udp_connect_worker(void *
 		transport->sock = sock;
 		transport->inet = sk;
 
+		transport->sendpage = 0;
+		if (sock->ops->sendpage != NULL)
+			transport->sendpage = 1;
+
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 	xs_udp_do_set_buffer_size(xprt);
@@ -1328,6 +1336,10 @@ static void xs_tcp_connect_worker(void *
 		transport->sock = sock;
 		transport->inet = sk;
 
+		transport->sendpage = 0;
+		if (sock->ops->sendpage != NULL)
+			transport->sendpage = 1;
+
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
