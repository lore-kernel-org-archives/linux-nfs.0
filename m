From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 2.5.21] Make NFS/RPC client use the TCP zero copy API when hardware supports it
Date: 16 Jun 2002 22:59:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <aeiua2$bre$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Jh7C-0001R4-00
	for <nfs@lists.sourceforge.net>; Sun, 16 Jun 2002 13:59:14 -0700
To: linux-kernel@vger.kernel.org
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Does anybody with 'zero copy' compatible networking cards (3c59x,
AceNIC, Tigon3, E1000, ....) notice any performance difference when
using NFS TCP mounts with/without this patch?

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.21/net/sunrpc/xprt.c linux-nfs_zerocopy/net/sunrpc/xprt.c
--- linux-2.5.21/net/sunrpc/xprt.c	Fri May 24 13:32:02 2002
+++ linux-nfs_zerocopy/net/sunrpc/xprt.c	Sun Jun 16 22:16:22 2002
@@ -67,6 +67,7 @@
 #include <net/tcp.h>
 
 #include <asm/uaccess.h>
+#include <linux/pagemap.h>
 
 extern spinlock_t rpc_queue_lock;
 
@@ -168,6 +169,121 @@
 	spin_unlock_bh(&xprt->sock_lock);
 }
 
+/* Write an iovec array to a socket */
+static int
+sock_sendkerneliovec(struct socket *sock, struct sockaddr *addr, int addrlen,
+		struct iovec *iov, size_t count, int size)
+{
+	struct msghdr msg = {
+		msg_name:	addr,
+		msg_namelen:	addrlen,
+		msg_iov:	iov,
+		msg_iovlen:	count,
+		msg_control:	NULL,
+		msg_controllen:	0,
+		msg_flags:	MSG_DONTWAIT|MSG_NOSIGNAL,
+	};
+	mm_segment_t oldfs;
+	int ret;
+
+	oldfs = get_fs(); set_fs(get_ds());
+	ret = sock_sendmsg(sock, &msg, size);
+	set_fs(oldfs);
+	return ret;
+}
+
+static int
+xprt_set_cork_sock(struct socket *sock, int val)
+{
+	mm_segment_t oldfs;
+	int ret;
+
+	oldfs = get_fs(); set_fs(get_ds());
+	ret = sock->ops->setsockopt(sock, SOL_TCP, TCP_CORK,
+				    (char *)&val, sizeof(val));
+	set_fs(oldfs);
+	return ret;
+}
+
+static inline int
+xprt_cork_sock(struct socket *sock)
+{
+	return xprt_set_cork_sock(sock, 1);
+}
+
+static inline void
+xprt_uncork_sock(struct socket *sock)
+{
+	xprt_set_cork_sock(sock, 0);
+}
+
+/* Send the XDR buffer using the zero copy socket API */
+static int
+xdr_sendpages(struct socket *sock, struct xdr_buf *xdr, size_t base)
+{
+	struct iovec iov;
+	struct page **ppage = xdr->pages;
+	unsigned int len, pglen = xdr->page_len;
+	int err, copied = 0;
+
+	if ((err = xprt_cork_sock(sock)) < 0)
+		return err;
+	len = xdr->head[0].iov_len;
+	if (base < len) {
+		len -= base;
+		iov.iov_len = len;
+		iov.iov_base = (char *)xdr->head[0].iov_base + base;
+		err = sock_sendkerneliovec(sock, NULL, 0, &iov, 1, len);
+		if (err > 0)
+			copied += err;
+		if (err != len)
+			goto out_err;
+		base = 0;
+	} else
+		base -= len;
+	if (base >= pglen) {
+		base -= pglen;
+		goto send_tail;
+	}
+	if (base || xdr->page_base) {
+		pglen -= base;
+		base  += xdr->page_base;
+		ppage += base >> PAGE_CACHE_SHIFT;
+		base &= ~PAGE_CACHE_MASK;
+	}
+	do {
+		len = PAGE_CACHE_SIZE;
+		if (base)
+			len -= base;
+		if (pglen < len)
+			len = pglen;
+		err = sock->ops->sendpage(sock, *ppage, base, len, MSG_DONTWAIT);
+		if (err > 0)
+			copied += err;
+		if (err != len)
+			goto out_err;
+		base = 0;
+		ppage++;
+	} while ((pglen -= len) != 0);
+send_tail:
+	len = xdr->tail[0].iov_len;
+	if (len && base < len) {
+		len -= base;
+		iov.iov_len = len;
+		iov.iov_base = (char *)xdr->tail[0].iov_base + base;
+		err = sock_sendkerneliovec(sock, NULL, 0, &iov, 1, len);
+		if (err > 0)
+			copied += err;
+		if (err != len)
+			goto out_err;
+	}
+	xprt_uncork_sock(sock);
+	return copied;
+out_err:
+	xprt_uncork_sock(sock);
+	return copied != 0 ? copied : err;
+}
+
 /*
  * Write data to socket.
  */
@@ -175,11 +291,8 @@
 xprt_sendmsg(struct rpc_xprt *xprt, struct rpc_rqst *req)
 {
 	struct socket	*sock = xprt->sock;
-	struct msghdr	msg;
 	struct xdr_buf	*xdr = &req->rq_snd_buf;
-	struct iovec	niv[MAX_IOVEC];
-	unsigned int	niov, slen, skip;
-	mm_segment_t	oldfs;
+	unsigned int	slen, skip;
 	int		result;
 
 	if (!sock)
@@ -192,21 +305,16 @@
 	/* Dont repeat bytes */
 	skip = req->rq_bytes_sent;
 	slen = xdr->len - skip;
-	niov = xdr_kmap(niv, xdr, skip);
-
-	msg.msg_flags   = MSG_DONTWAIT|MSG_NOSIGNAL;
-	msg.msg_iov	= niv;
-	msg.msg_iovlen	= niov;
-	msg.msg_name	= (struct sockaddr *) &xprt->addr;
-	msg.msg_namelen = sizeof(xprt->addr);
-	msg.msg_control = NULL;
-	msg.msg_controllen = 0;
-
-	oldfs = get_fs(); set_fs(get_ds());
-	result = sock_sendmsg(sock, &msg, slen);
-	set_fs(oldfs);
 
-	xdr_kunmap(xdr, skip);
+	if (xdr->page_len == 0 || !xprt->stream) {
+		struct iovec niv[MAX_IOVEC];
+		unsigned int niov;
+		niov = xdr_kmap(niv, xdr, skip);
+		result = sock_sendkerneliovec(sock, (struct sockaddr *)&xprt->addr,
+					      sizeof(xprt->addr), niv, niov, slen);
+		xdr_kunmap(xdr, skip);
+	} else
+		result = xdr_sendpages(sock, xdr, skip);
 
 	dprintk("RPC:      xprt_sendmsg(%d) = %d\n", slen, result);
 

_______________________________________________________________

Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
