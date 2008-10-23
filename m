From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: RPC retransmission of write requests containing bogus data
Date: Thu, 23 Oct 2008 15:42:12 +0100
Message-ID: <1224772933.12607.2.camel@zakaz.uk.xensource.com>
References: <1224241273.9053.109.camel@zakaz.uk.xensource.com>
	 <1224247725.7722.4.camel@localhost>
	 <1224248469.9053.119.camel@zakaz.uk.xensource.com>
	 <1224249772.7722.9.camel@localhost>
	 <1224512708.15736.12.camel@zakaz.uk.xensource.com>
	 <1224520738.15736.22.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, Thomas Talpey <Thomas.Talpey@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:61096 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbYJWOmT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Oct 2008 10:42:19 -0400
In-Reply-To: <1224520738.15736.22.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(I've dropped Michael to bcc, since I think it's relatively clear this
isn't a NIC driver issue, apologies for the noise Michael)
(sorry to anyone who gets this twice, evolution had a bit of a fit and
I'm not sure if it went out properly)

On Mon, 2008-10-20 at 17:39 +0100, Ian Campbell wrote:
> 
> Actually, that was NFSv4 on 2.6.18, I guess I should test with
> something newer since it looks like the TCP connection reset stuff is
> newer (it's 43d78ef2ba5bec26d0315859e8324bfc0be23766 right?)

As expected 2.6.27 appears to be fine when using NFSv4. I used the patch
below with NFSv3 and the problem also went away, although I appreciate
you have concerns with this approach.

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5ee23e7..759589e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -623,7 +623,8 @@ static int nfs_init_client(struct nfs_client *clp,
 	 * Create a client RPC handle for doing FSSTAT with UNIX auth only
 	 * - RFC 2623, sec 2.3.2
 	 */
-	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX, 0);
+	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX,
+				      RPC_CLNT_CREATE_DISCRTRY);
 	if (error < 0)
 		goto error;
 	nfs_mark_client_ready(clp, NFS_CS_READY);

FYI I've also been experimenting with patches along the lines of the
below. I've not got it to actually work yet though :-/

Ian.

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 64981a2..5c57112 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -89,6 +89,7 @@ struct rpc_task {
 #ifdef RPC_DEBUG
 	unsigned short		tk_pid;		/* debugging aid */
 #endif
+	int			tk_nrtrans;	/* number of times this task has transmitted */
 };
 #define tk_xprt			tk_client->cl_xprt
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 99a52aa..72d1ceb 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -884,6 +884,8 @@ void xprt_transmit(struct rpc_task *task)
 		xprt->stat.req_u += xprt->stat.sends - xprt->stat.recvs;
 		xprt->stat.bklog_u += xprt->backlog.qlen;
 
+		task->tk_nrtrans++;
+
 		/* Don't race with disconnect */
 		if (!xprt_connected(xprt))
 			task->tk_status = -ENOTCONN;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4486c59..1fb5310 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -423,8 +423,9 @@ static int xs_send_kvec(struct socket *sock, struct sockaddr *addr, int addrlen,
 	return kernel_sendmsg(sock, &msg, NULL, 0, 0);
 }
 
-static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned int base, int more)
+static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned int base, int more, int copy)
 {
+	static int once = 0;
 	struct page **ppage;
 	unsigned int remainder;
 	int err, sent = 0;
@@ -440,7 +441,14 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
 		remainder -= len;
 		if (remainder != 0 || more)
 			flags |= MSG_MORE;
-		err = sock->ops->sendpage(sock, *ppage, base, len, flags);
+		if (!once && copy) {
+			once = 1;
+			printk("using sock_no_sendpage for retransmit\n");
+		}
+		if (copy)
+			err = sock_no_sendpage(sock, *ppage, base, len, flags);
+		else
+			err = sock->ops->sendpage(sock, *ppage, base, len, flags);
 		if (remainder == 0 || err != len)
 			break;
 		sent += err;
@@ -463,7 +471,7 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
  * @base: starting position in the buffer
  *
  */
-static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen, struct xdr_buf *xdr, unsigned int base)
+static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen, struct xdr_buf *xdr, unsigned int base, int copy)
 {
 	unsigned int remainder = xdr->len - base;
 	int err, sent = 0;
@@ -491,7 +499,7 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 	if (base < xdr->page_len) {
 		unsigned int len = xdr->page_len - base;
 		remainder -= len;
-		err = xs_send_pagedata(sock, xdr, base, remainder != 0);
+		err = xs_send_pagedata(sock, xdr, base, remainder != 0, copy);
 		if (remainder == 0 || err != len)
 			goto out;
 		sent += err;
@@ -582,7 +590,7 @@ static int xs_udp_send_request(struct rpc_task *task)
 	status = xs_sendpages(transport->sock,
 			      xs_addr(xprt),
 			      xprt->addrlen, xdr,
-			      req->rq_bytes_sent);
+			      req->rq_bytes_sent, task->tk_nrtrans);
 
 	dprintk("RPC:       xs_udp_send_request(%u) = %d\n",
 			xdr->len - req->rq_bytes_sent, status);
@@ -671,7 +679,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	 * called sendmsg(). */
 	while (1) {
 		status = xs_sendpages(transport->sock,
-					NULL, 0, xdr, req->rq_bytes_sent);
+				      NULL, 0, xdr, req->rq_bytes_sent, task->tk_nrtrans);
 
 		dprintk("RPC:       xs_tcp_send_request(%u) = %d\n",
 				xdr->len - req->rq_bytes_sent, status);


