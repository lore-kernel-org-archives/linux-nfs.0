From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Wed, 30 Oct 2002 12:18:08 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021030.121808.77062773.taka@valinux.co.jp>
References: <15805.26221.530836.279218@charged.uio.no>
	<20021029.153629.55720711.taka@valinux.co.jp>
	<15806.42148.47823.817360@charged.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186jUr-00020b-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Oct 2002 19:26:22 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <15806.42148.47823.817360@charged.uio.no>
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

I've modified the patch simple as you said.

> Hmmm... What if we just drop actually storing a pointer to the
> ZERO_PAGE? Instead, define the convention that
> 
> if (xdr_buf->tail[0].iov_base == NULL)
> 	padding = xdr_buf->tail[0].iov_len;
> 
> and just have xprt_sendmsg() magically append 'padding' bytes from
> your ZERO_PAGE.


--- linux/net/sunrpc/xdr.c.ORG	Sat Oct 26 21:21:16 2030
+++ linux/net/sunrpc/xdr.c	Wed Oct 30 11:11:03 2030
@@ -113,7 +113,8 @@ xdr_encode_pages(struct xdr_buf *xdr, st
 		struct iovec *iov = xdr->tail;
 		unsigned int pad = 4 - (len & 3);
 
-		iov->iov_base = (void *) "\0\0\0";
+		/* NULL means a request to pad it with zero. */
+		iov->iov_base = NULL;
 		iov->iov_len  = pad;
 		len += pad;
 	}
--- linux/net/sunrpc/xprt.c.ORG	Sun Oct 27 17:07:17 2030
+++ linux/net/sunrpc/xprt.c	Wed Oct 30 12:16:05 2030
@@ -60,6 +60,7 @@
 #include <linux/unistd.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/file.h>
+#include <linux/pagemap.h>
 
 #include <net/sock.h>
 #include <net/checksum.h>
@@ -207,48 +208,113 @@ xprt_release_write(struct rpc_xprt *xprt
 	spin_unlock_bh(&xprt->sock_lock);
 }
 
-/*
- * Write data to socket.
- */
 static inline int
-xprt_sendmsg(struct rpc_xprt *xprt, struct rpc_rqst *req)
+__xprt_sendmsg(struct rpc_xprt *xprt, struct xdr_buf *xdr, size_t skip)
 {
 	struct socket	*sock = xprt->sock;
+	unsigned int	slen = xdr->len - skip;
+	struct page	**ppage = xdr->pages;
+	unsigned int	len, pglen = xdr->page_len;
+	size_t		base = 0;
 	struct msghdr	msg;
-	struct xdr_buf	*xdr = &req->rq_snd_buf;
-	struct iovec	niv[MAX_IOVEC];
-	unsigned int	niov, slen, skip;
+	struct iovec	niv;
+	int		flags;
 	mm_segment_t	oldfs;
-	int		result;
-
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
+	int		result = 0;
+	int		ret;
 
 	msg.msg_flags   = MSG_DONTWAIT|MSG_NOSIGNAL;
-	msg.msg_iov	= niv;
-	msg.msg_iovlen	= niov;
 	msg.msg_name	= (struct sockaddr *) &xprt->addr;
 	msg.msg_namelen = sizeof(xprt->addr);
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
+	msg.msg_iov	= &niv;
+	msg.msg_iovlen	= 1;
 
-	oldfs = get_fs(); set_fs(get_ds());
-	clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
-	result = sock_sendmsg(sock, &msg, slen);
-	set_fs(oldfs);
+	if (xdr->head[0].iov_len > skip) {
+		len = xdr->head[0].iov_len - skip;
+		niv.iov_base = xdr->head[0].iov_base + skip;
+		niv.iov_len = len;
+		if (slen > len)
+			msg.msg_flags |= MSG_MORE;
+		oldfs = get_fs(); set_fs(get_ds());
+		clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+		result = sock_sendmsg(sock, &msg, len);
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
+		if (xdr->tail[0].iov_base == NULL) {
+			/* tail[0].iov_base == NULL requires zero padding */
+			ret = sock->ops->sendpage(sock, sunrpc_get_zeropage(),
+					0, xdr->tail[0].iov_len - skip, 0);
+		} else {
+			niv.iov_base = xdr->tail[0].iov_base + skip;
+			niv.iov_len = xdr->tail[0].iov_len - skip;
+			msg.msg_flags &= ~MSG_MORE;
+			oldfs = get_fs(); set_fs(get_ds());
+			clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+			ret = sock_sendmsg(sock, &msg, niv.iov_len);
+			set_fs(oldfs);
+		}
+		if (ret > 0)
+			result += ret;
+		if (result == 0)
+			result = ret;
+	}
+	return result;
+}
+
+/*
+ * Write data to socket.
+ */
+static inline int
+xprt_sendmsg(struct rpc_xprt *xprt, struct rpc_rqst *req)
+{
+	int		result;
 
-	xdr_kunmap(xdr, skip);
+	result = __xprt_sendmsg(xprt, &req->rq_snd_buf, req->rq_bytes_sent);
 
-	dprintk("RPC:      xprt_sendmsg(%d) = %d\n", slen, result);
+	dprintk("RPC:      xprt_sendmsg(%d) = %d\n", req->rq_snd_buf.len - req->rq_bytes_sent, result);
 
 	if (result >= 0)
 		return result;
--- linux/net/sunrpc/sunrpc_syms.c.ORG	Tue Oct 29 14:18:45 2030
+++ linux/net/sunrpc/sunrpc_syms.c	Tue Oct 29 14:15:27 2030
@@ -101,6 +101,7 @@ EXPORT_SYMBOL(auth_unix_lookup);
 EXPORT_SYMBOL(cache_check);
 EXPORT_SYMBOL(cache_clean);
 EXPORT_SYMBOL(cache_flush);
+EXPORT_SYMBOL(cache_purge);
 EXPORT_SYMBOL(cache_fresh);
 EXPORT_SYMBOL(cache_init);
 EXPORT_SYMBOL(cache_register);
@@ -130,6 +131,36 @@ EXPORT_SYMBOL(nfsd_debug);
 EXPORT_SYMBOL(nlm_debug);
 #endif
 
+/* RPC general use */
+EXPORT_SYMBOL(sunrpc_get_zeropage);
+
+static struct page *sunrpc_zero_page;
+
+struct page *
+sunrpc_get_zeropage(void)
+{
+	return sunrpc_zero_page;
+}
+
+static int __init
+sunrpc_init_zeropage(void)
+{
+	sunrpc_zero_page = alloc_page(GFP_ATOMIC);
+	if (sunrpc_zero_page == NULL) {
+		printk(KERN_ERR "RPC: couldn't allocate zero_page.\n");
+		return 1;
+	}
+	clear_page(page_address(sunrpc_zero_page));
+	return 0;
+}
+
+static void __exit
+sunrpc_cleanup_zeropage(void)
+{
+	put_page(sunrpc_zero_page);
+	sunrpc_zero_page = NULL;
+}
+
 static int __init
 init_sunrpc(void)
 {
@@ -141,12 +172,14 @@ init_sunrpc(void)
 #endif
 	cache_register(&auth_domain_cache);
 	cache_register(&ip_map_cache);
+	sunrpc_init_zeropage();
 	return 0;
 }
 
 static void __exit
 cleanup_sunrpc(void)
 {
+	sunrpc_cleanup_zeropage();
 	cache_unregister(&auth_domain_cache);
 	cache_unregister(&ip_map_cache);
 #ifdef RPC_DEBUG
--- linux/include/linux/sunrpc/types.h.ORG	Tue Oct 29 11:31:13 2030
+++ linux/include/linux/sunrpc/types.h	Tue Oct 29 11:37:49 2030
@@ -13,10 +13,14 @@
 #include <linux/workqueue.h>
 #include <linux/sunrpc/debug.h>
 #include <linux/list.h>
+#include <linux/mm.h>
 
 /*
  * Shorthands
  */
 #define signalled()		(signal_pending(current))
+
+extern struct page * sunrpc_get_zeropage(void);
+
 
 #endif /* _LINUX_SUNRPC_TYPES_H_ */


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
