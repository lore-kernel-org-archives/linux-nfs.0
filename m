From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Sun, 27 Oct 2002 19:39:17 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021027.193917.78705070.taka@valinux.co.jp>
References: <20021024.065015.74750854.taka@valinux.co.jp>
	<15799.14062.275890.83768@charged.uio.no>
	<20021024.103349.26272209.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 185kwl-00081p-00
	for <nfs@lists.sourceforge.net>; Sun, 27 Oct 2002 02:47:07 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <20021024.103349.26272209.taka@valinux.co.jp>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

> >      > I was thinking about the nfs clients.  Why don't we make
> >      > xprt_sendmsg() use the sendpage interface instead of calling
> >      > sock_sendmsg() so that we can avoid dead-lock which multiple
> >      > kmap()s in xprt_sendmsg() might cause on heavily loaded
> >      > machines.
> > 
> > I'm definitely in favour of such a change. Particularly so if the UDP
> > interface is ready.

I just modified the xprt_sendmsg() to use the sendpage interface.
I've checked it works fine on both of TCP and UDP.

I think this code need to be cleaned up but I don't have any good ideas
about it.


Thank you,
Hirokazu Takahashi.



--- linux/net/sunrpc/xdr.c.ORG	Sat Oct 26 21:21:16 2030
+++ linux/net/sunrpc/xdr.c	Sun Oct 27 19:07:05 2030
@@ -110,12 +110,15 @@ xdr_encode_pages(struct xdr_buf *xdr, st
 	xdr->page_len = len;
 
 	if (len & 3) {
-		struct iovec *iov = xdr->tail;
 		unsigned int pad = 4 - (len & 3);
-
-		iov->iov_base = (void *) "\0\0\0";
-		iov->iov_len  = pad;
 		len += pad;
+		if (((base + len) & ~PAGE_CACHE_MASK) + pad <= PAGE_CACHE_SIZE) {
+			xdr->page_len += pad;
+		} else {
+			struct iovec *iov = xdr->tail;
+			iov->iov_base = (void *) "\0\0\0";
+			iov->iov_len  = pad;
+		}
 	}
 	xdr->len += len;
 }
--- linux/net/sunrpc/xprt.c.ORG	Sun Oct 27 17:07:17 2030
+++ linux/net/sunrpc/xprt.c	Sun Oct 27 19:07:38 2030
@@ -60,6 +60,7 @@
 #include <linux/unistd.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/file.h>
+#include <linux/pagemap.h>
 
 #include <net/sock.h>
 #include <net/checksum.h>
@@ -207,48 +208,107 @@ xprt_release_write(struct rpc_xprt *xprt
 	spin_unlock_bh(&xprt->sock_lock);
 }
 
+static inline int
+__xprt_sendmsg(struct socket *sock, struct xdr_buf *xdr, struct msghdr *msg, size_t skip)
+{
+	unsigned int	slen = xdr->len - skip;
+	mm_segment_t	oldfs;
+	int		result = 0;
+	struct page	**ppage = xdr->pages;
+	unsigned int	len, pglen = xdr->page_len;
+	size_t		base = 0;
+	int		flags;
+	int		ret;
+	struct iovec	niv;
+
+	msg->msg_iov	= &niv;
+	msg->msg_iovlen	= 1;
+
+	if (xdr->head[0].iov_len > skip) {
+		len = xdr->head[0].iov_len - skip;
+		niv.iov_base = xdr->head[0].iov_base + skip;
+		niv.iov_len = len;
+		if (slen > len)
+			msg->msg_flags |= MSG_MORE;
+		oldfs = get_fs(); set_fs(get_ds());
+		clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+		result = sock_sendmsg(sock, msg, len);
+		set_fs(oldfs);
+		if (result != len)
+			return result;
+		slen -= len;
+		skip = 0;
+	} else {
+		skip -= xdr->head[0].iov_len;
+	}
+	if (pglen == 0)
+		goto send_tail;
+	if (skip >= pglen) {
+		skip -= pglen;
+		goto send_tail;
+	}
+	if (skip || xdr->page_base) {
+		pglen -= skip;
+		base = xdr->page_base + skip;
+		ppage += base >> PAGE_CACHE_SHIFT;
+		base &= ~PAGE_CACHE_MASK;
+	}
+	len = PAGE_CACHE_SIZE - base;
+	if (len > pglen) len = pglen;
+	flags = MSG_MORE;
+	while (pglen > 0) {
+		if (slen == len)
+			flags = 0;
+		ret = sock->ops->sendpage(sock, *ppage, base, len, flags);
+		if (ret > 0)
+			result += ret;
+		if (ret != len) {
+			if (result == 0)
+				result = ret;
+			return result;
+		}
+		slen -= len;
+		pglen -= len;
+		len = PAGE_CACHE_SIZE < pglen ? PAGE_CACHE_SIZE : pglen;
+		base = 0;
+		ppage++;
+	}
+	skip = 0;
+send_tail:
+	if (xdr->tail[0].iov_len) {
+		niv.iov_base = xdr->tail[0].iov_base + skip;
+		niv.iov_len = xdr->tail[0].iov_len - skip;
+		msg->msg_flags &= ~MSG_MORE;
+		oldfs = get_fs(); set_fs(get_ds());
+		clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+		ret = sock_sendmsg(sock, msg, niv.iov_len);
+		set_fs(oldfs);
+		if (ret > 0)
+			result += ret;
+		if (result == 0)
+			result = ret;
+	}
+	return result;
+}
+
 /*
  * Write data to socket.
  */
 static inline int
 xprt_sendmsg(struct rpc_xprt *xprt, struct rpc_rqst *req)
 {
-	struct socket	*sock = xprt->sock;
 	struct msghdr	msg;
-	struct xdr_buf	*xdr = &req->rq_snd_buf;
-	struct iovec	niv[MAX_IOVEC];
-	unsigned int	niov, slen, skip;
-	mm_segment_t	oldfs;
 	int		result;
 
-	if (!sock)
-		return -ENOTCONN;
-
-	xprt_pktdump("packet data:",
-				req->rq_svec->iov_base,
-				req->rq_svec->iov_len);
-
-	/* Dont repeat bytes */
-	skip = req->rq_bytes_sent;
-	slen = xdr->len - skip;
-	niov = xdr_kmap(niv, xdr, skip);
-
 	msg.msg_flags   = MSG_DONTWAIT|MSG_NOSIGNAL;
-	msg.msg_iov	= niv;
-	msg.msg_iovlen	= niov;
 	msg.msg_name	= (struct sockaddr *) &xprt->addr;
 	msg.msg_namelen = sizeof(xprt->addr);
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
 
-	oldfs = get_fs(); set_fs(get_ds());
-	clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
-	result = sock_sendmsg(sock, &msg, slen);
-	set_fs(oldfs);
-
-	xdr_kunmap(xdr, skip);
+	result = __xprt_sendmsg(xprt->sock, &req->rq_snd_buf, &msg, req->rq_bytes_sent);
 
-	dprintk("RPC:      xprt_sendmsg(%d) = %d\n", slen, result);
+	dprintk("RPC:      xprt_sendmsg(%d) = %d\n", req->rq_snd_buf.len - req->rq_bytes_sent, result);
 
 	if (result >= 0)
 		return result;


-------------------------------------------------------
This SF.net email is sponsored by: ApacheCon, November 18-21 in
Las Vegas (supported by COMDEX), the only Apache event to be
fully supported by the ASF. http://www.apachecon.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
