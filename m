From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [PATCH] zerocopy NFS for 2.5.43
Date: Fri, 18 Oct 2002 22:11:03 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021018.221103.35656279.taka@valinux.co.jp>
References: <20020918.171431.24608688.taka@valinux.co.jp>
	<15786.23306.84580.323313@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Fri_Oct_18_22:11:03_2002_141)--"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 182X1B-0002ZK-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Oct 2002 06:18:22 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <15786.23306.84580.323313@notabene.cse.unsw.edu.au>
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

----Next_Part(Fri_Oct_18_22:11:03_2002_141)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hello,

I've ported the zerocopy patches against linux-2.5.43 with
davem's udp-sendfile patches and your patches which you posted
on Wed,16 Oct.

It's sad that zerocopy NFS doesn't work with NFSv4 yet.
kNFSd won't use zerocopy mechanism against NFSv4 requests.
If possible I can make NFSv4 use zerocopy after Halloween.

And I also fixed a small bug that pages might be lost
when nfsd_readdir happens to have an error.


Thank you,
Hirokazu Takahashi.


----Next_Part(Fri_Oct_18_22:11:03_2002_141)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="rpcfix2.5.43-2.patch"

--- linux/net/sunrpc/svcsock.c.ORG	Thu Oct 17 14:10:43 2030
+++ linux/net/sunrpc/svcsock.c	Fri Oct 18 11:20:27 2030
@@ -882,17 +882,18 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	dprintk("svc: TCP complete record (%d bytes)\n", len);
 
+	rqstp->rq_skbuff         = 0;
+	rqstp->rq_argbuf.buf    += 1;
+	rqstp->rq_argbuf.len     = (len >> 2) + 1;
+	rqstp->rq_argbuf.buflen  = (len >> 2) + 1;
+
 	/* Position reply write pointer immediately args,
 	 * allowing for record length */
-	rqstp->rq_resbuf.base = rqstp->rq_argbuf.base + (len>>2);
-	rqstp->rq_resbuf.buf  = rqstp->rq_resbuf.base + 1;
-	rqstp->rq_resbuf.len  = 1;
-	rqstp->rq_resbuf.buflen= rqstp->rq_argbuf.buflen - (len>>2) - 1;
+	rqstp->rq_resbuf.base   += rqstp->rq_argbuf.buflen;
+	rqstp->rq_resbuf.buf     = rqstp->rq_resbuf.base + 1;
+	rqstp->rq_resbuf.len     = 1;
+	rqstp->rq_resbuf.buflen -= rqstp->rq_argbuf.buflen;
 
-	rqstp->rq_skbuff      = 0;
-	rqstp->rq_argbuf.buf += 1;
-	rqstp->rq_argbuf.len  = (len >> 2);
-	rqstp->rq_argbuf.buflen = (len >> 2);
 	rqstp->rq_prot	      = IPPROTO_TCP;
 
 	/* Reset TCP read info */

----Next_Part(Fri_Oct_18_22:11:03_2002_141)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="va01-zerocopy-rpc-2.5.43.patch"

--- linux.ORG/include/linux/sunrpc/svc.h	Fri Oct 18 12:26:43 2030
+++ linux/include/linux/sunrpc/svc.h	Fri Oct 18 12:29:31 2030
@@ -48,7 +48,7 @@ struct svc_serv {
  * This is use to determine the max number of pages nfsd is
  * willing to return in a single READ operation.
  */
-#define RPCSVC_MAXPAYLOAD	16384u
+#define RPCSVC_MAXPAYLOAD	(1024u*64)
 
 /*
  * Buffer to store RPC requests or replies in.
@@ -61,7 +61,7 @@ struct svc_serv {
  *
  * The array of iovecs can hold additional data that the server process
  * may not want to copy into the RPC reply buffer, but pass to the 
- * network sendmsg routines directly. The prime candidate for this
+ * network sendmsg/sendpage routines directly. The prime candidate for this
  * will of course be NFS READ operations, but one might also want to
  * do something about READLINK and READDIR. It might be worthwhile
  * to implement some generic readdir cache in the VFS layer...
@@ -70,7 +70,7 @@ struct svc_serv {
  * the list of IP fragments once we get to process fragmented UDP
  * datagrams directly.
  */
-#define RPCSVC_MAXIOV		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE + 1)
+#define RPCSVC_MAXIOV		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE + 2)
 struct svc_buf {
 	u32 *			area;	/* allocated memory */
 	u32 *			base;	/* base of RPC datagram */
@@ -78,10 +78,24 @@ struct svc_buf {
 	u32 *			buf;	/* read/write pointer */
 	int			len;	/* current end of buffer */
 
-	/* iovec for zero-copy NFS READs */
-	struct iovec		iov[RPCSVC_MAXIOV];
+	/* 
+	 * iovec for zero-copy NFS READs
+	 * pages and non-page data can be mixed.
+	 */
+	struct rpcio_vec {
+		struct page		*rpc_page;
+		union {
+			void		*riov_base;
+			unsigned long	riov_offset;
+		} u;
+		__kernel_size_t		rpc_len;
+	} iov[RPCSVC_MAXIOV];
 	int			nriov;
 };
+
+#define rpc_base	u.riov_base
+#define rpc_offset	u.riov_offset
+
 #define svc_getu32(argp, val)	{ (val) = *(argp)->buf++; (argp)->len--; }
 #define svc_putu32(resp, val)	{ *(resp)->buf++ = (val); (resp)->len++; }
 
--- linux.ORG/include/linux/sunrpc/svcsock.h	Fri Oct 18 12:26:43 2030
+++ linux/include/linux/sunrpc/svcsock.h	Fri Oct 18 12:29:31 2030
@@ -10,6 +10,7 @@
 #define SUNRPC_SVCSOCK_H
 
 #include <linux/sunrpc/svc.h>
+#include <asm/semaphore.h>
 
 /*
  * RPC server socket.
@@ -37,6 +38,7 @@ struct svc_sock {
 
 	struct list_head	sk_deferred;	/* deferred requests that need to
 						 * be revisted */
+	struct semaphore	sk_sem;		/* serialize sending data */
 
 	int			(*sk_recvfrom)(struct svc_rqst *rqstp);
 	int			(*sk_sendto)(struct svc_rqst *rqstp);
--- linux.ORG/net/sunrpc/svc.c	Fri Oct 18 12:26:48 2030
+++ linux/net/sunrpc/svc.c	Fri Oct 18 12:29:31 2030
@@ -106,8 +106,7 @@ svc_destroy(struct svc_serv *serv)
 
 /*
  * Allocate an RPC server buffer
- * Later versions may do nifty things by allocating multiple pages
- * of memory directly and putting them into the bufp->iov.
+ * Multiple pages can be put into the bufp->iov.
  */
 int
 svc_init_buffer(struct svc_buf *bufp, unsigned int size)
@@ -119,8 +118,9 @@ svc_init_buffer(struct svc_buf *bufp, un
 	bufp->len    = 0;
 	bufp->buflen = size >> 2;
 
-	bufp->iov[0].iov_base = bufp->area;
-	bufp->iov[0].iov_len  = size;
+	bufp->iov[0].rpc_base = bufp->area;
+	bufp->iov[0].rpc_len  = size;
+	bufp->iov[0].rpc_page = NULL;
 	bufp->nriov = 1;
 
 	return 1;
--- linux.ORG/net/sunrpc/svcsock.c	Fri Oct 18 12:28:35 2030
+++ linux/net/sunrpc/svcsock.c	Fri Oct 18 12:29:31 2030
@@ -22,6 +22,7 @@
 #include <linux/sched.h>
 #include <linux/errno.h>
 #include <linux/fcntl.h>
+#include <linux/pagemap.h>
 #include <linux/net.h>
 #include <linux/in.h>
 #include <linux/inet.h>
@@ -270,6 +271,8 @@ static void
 svc_sock_release(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_buf	*bufp = &rqstp->rq_resbuf;
+	int i;
 
 	svc_release_skb(rqstp);
 
@@ -283,6 +286,13 @@ svc_sock_release(struct svc_rqst *rqstp)
 		       rqstp->rq_reserved,
 		       rqstp->rq_resbuf.len<<2);
 
+	for (i = 0; i < bufp->nriov; i++) {
+		if (bufp->iov[i].rpc_page) {
+			put_page(bufp->iov[i].rpc_page);
+			bufp->iov[i].rpc_page = NULL;
+		}
+	}
+
 	rqstp->rq_resbuf.buf = rqstp->rq_resbuf.base;
 	rqstp->rq_resbuf.len = 0;
 	svc_reserve(rqstp, 0);
@@ -318,38 +328,55 @@ svc_wake_up(struct svc_serv *serv)
  * Generic sendto routine
  */
 static int
-svc_sendto(struct svc_rqst *rqstp, struct iovec *iov, int nr)
+svc_sendto(struct svc_rqst *rqstp, struct rpcio_vec *iov, int nr)
 {
 	mm_segment_t	oldfs;
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct socket	*sock = svsk->sk_sock;
 	struct msghdr	msg;
-	int		i, buflen, len;
-
-	for (i = buflen = 0; i < nr; i++)
-		buflen += iov[i].iov_len;
+	unsigned int	flags = MSG_MORE;
+	int		len = 0;
+	int		result, i;
 
 	msg.msg_name    = &rqstp->rq_addr;
 	msg.msg_namelen = sizeof(rqstp->rq_addr);
-	msg.msg_iov     = iov;
-	msg.msg_iovlen  = nr;
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
+	msg.msg_iovlen  = 1;
 
-	/* This was MSG_DONTWAIT, but I now want it to wait.
-	 * The only thing that it would wait for is memory and
-	 * if we are fairly low on memory, then we aren't likely
-	 * to make much progress anyway.
-	 * sk->sndtimeo is set to 30seconds just in case.
-	 */
-	msg.msg_flags	= 0;
+	/* Grab svsk->sk_sem to serialize outgoing data. */
+	down(&svsk->sk_sem);
 
-	oldfs = get_fs(); set_fs(KERNEL_DS);
-	len = sock_sendmsg(sock, &msg, buflen);
-	set_fs(oldfs);
+	/* 
+	 * svc_sendto() assumes rqstp->rq_resbuf.page[0] is NULL
+	 * when RPC over UDP is used as sendpage interface cannot
+	 * pass destination address.
+	 */
+	for (i = 0; i < nr; i++) {
+		if (i == nr - 1)
+			flags = 0;
+		if (iov[i].rpc_page) {
+			result = sock->ops->sendpage(sock, iov[i].rpc_page, iov[i].rpc_offset, iov[i].rpc_len, flags);
+		} else {
+			struct iovec uiov;
+			uiov.iov_base   = iov[i].rpc_base;
+			uiov.iov_len    = iov[i].rpc_len;
+			msg.msg_iov     = &uiov;
+			msg.msg_flags	= flags;
+			oldfs = get_fs(); set_fs(KERNEL_DS);
+			result = sock_sendmsg(sock, &msg, iov[i].rpc_len);
+			set_fs(oldfs);
+		}
+		if (result < 0) {
+			if (!len) len = result;
+			break;
+		}
+		len += result;
+	}
+	up(&svsk->sk_sem);
 
-	dprintk("svc: socket %p sendto([%p %Zu... ], %d, %d) = %d\n",
-			rqstp->rq_sock, iov[0].iov_base, iov[0].iov_len, nr, buflen, len);
+	dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d\n",
+			rqstp->rq_sock, iov[0].rpc_base, iov[0].rpc_len, nr, len);
 
 	return len;
 }
@@ -375,19 +402,25 @@ svc_recv_available(struct svc_sock *svsk
  * Generic recvfrom routine.
  */
 static int
-svc_recvfrom(struct svc_rqst *rqstp, struct iovec *iov, int nr, int buflen)
+svc_recvfrom(struct svc_rqst *rqstp, struct rpcio_vec *iov, int nr, int buflen)
 {
 	mm_segment_t	oldfs;
 	struct msghdr	msg;
 	struct socket	*sock;
-	int		len, alen;
+	int		len, alen, i;
+	struct iovec uiov[RPCSVC_MAXIOV];
 
 	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
 	sock = rqstp->rq_sock->sk_sock;
 
+	for (i = 0; i < nr; i++) {
+		uiov[i].iov_base = iov[i].rpc_base;
+		uiov[i].iov_len  = iov[i].rpc_len;
+	}
+
 	msg.msg_name    = &rqstp->rq_addr;
 	msg.msg_namelen = sizeof(rqstp->rq_addr);
-	msg.msg_iov     = iov;
+	msg.msg_iov     = uiov;
 	msg.msg_iovlen  = nr;
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
@@ -406,7 +439,7 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	sock->ops->getname(sock, (struct sockaddr *)&rqstp->rq_addr, &alen, 1);
 
 	dprintk("svc: socket %p recvfrom(%p, %Zu) = %d\n",
-		rqstp->rq_sock, iov[0].iov_base, iov[0].iov_len, len);
+		rqstp->rq_sock, iov[0].rpc_base, iov[0].rpc_len, len);
 
 	return len;
 }
@@ -567,8 +600,8 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 	 * care of by the server implementation itself.
 	 */
 	/* bufp->base = bufp->area; */
-	bufp->iov[0].iov_base = bufp->base;
-	bufp->iov[0].iov_len  = bufp->len << 2;
+	bufp->iov[0].rpc_base = bufp->base;
+	bufp->iov[0].rpc_len  = bufp->len << 2;
 
 	error = svc_sendto(rqstp, bufp->iov, bufp->nriov);
 	if (error == -ECONNREFUSED)
@@ -827,10 +860,11 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	 */
 	if (svsk->sk_tcplen < 4) {
 		unsigned long	want = 4 - svsk->sk_tcplen;
-		struct iovec	iov;
+		struct rpcio_vec	iov;
 
-		iov.iov_base = ((char *) &svsk->sk_reclen) + svsk->sk_tcplen;
-		iov.iov_len  = want;
+		iov.rpc_base = ((char *) &svsk->sk_reclen) + svsk->sk_tcplen;
+		iov.rpc_len  = want;
+		iov.rpc_page  = NULL;
 		if ((len = svc_recvfrom(rqstp, &iov, 1, want)) < 0)
 			goto error;
 		svsk->sk_tcplen += len;
@@ -872,8 +906,8 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	set_bit(SK_DATA, &svsk->sk_flags);
 
 	/* Frob argbuf */
-	bufp->iov[0].iov_base += 4;
-	bufp->iov[0].iov_len  -= 4;
+	bufp->iov[0].rpc_base += 4;
+	bufp->iov[0].rpc_len  -= 4;
 
 	/* Now receive data */
 	len = svc_recvfrom(rqstp, bufp->iov, bufp->nriov, svsk->sk_reclen);
@@ -931,21 +965,25 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 {
 	struct svc_buf	*bufp = &rqstp->rq_resbuf;
 	int sent;
+	int buflen = bufp->len << 2;
+	int i;
 
 	/* Set up the first element of the reply iovec.
 	 * Any other iovecs that may be in use have been taken
 	 * care of by the server implementation itself.
 	 */
-	bufp->iov[0].iov_base = bufp->base;
-	bufp->iov[0].iov_len  = bufp->len << 2;
-	bufp->base[0] = htonl(0x80000000|((bufp->len << 2) - 4));
+	bufp->iov[0].rpc_base = bufp->base;
+	bufp->iov[0].rpc_len  = buflen;
+	for (i = 1; i < bufp->nriov; i++)
+		buflen += bufp->iov[i].rpc_len;
+	bufp->base[0] = htonl(0x80000000|(buflen - 4));
 
 	sent = svc_sendto(rqstp, bufp->iov, bufp->nriov);
-	if (sent != bufp->len<<2) {
+	if (sent != buflen) {
 		printk(KERN_NOTICE "rpc-srv/tcp: %s: %s %d when sending %d bytes - shutting down socket\n",
 		       rqstp->rq_sock->sk_server->sv_name,
 		       (sent<0)?"got error":"sent only",
-		       sent, bufp->len << 2);
+		       sent, buflen);
 		svc_delete_socket(rqstp->rq_sock);
 		sent = -EAGAIN;
 	}
@@ -1185,6 +1223,7 @@ svc_setup_socket(struct svc_serv *serv, 
 	svsk->sk_server = serv;
 	svsk->sk_lastrecv = CURRENT_TIME;
 	INIT_LIST_HEAD(&svsk->sk_deferred);
+	sema_init(&svsk->sk_sem, 1);
 
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM)

----Next_Part(Fri_Oct_18_22:11:03_2002_141)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="va02-zerocopy-nfsdread-2.5.43.patch"

--- linux.ORG/fs/nfsd/nfs3xdr.c	Fri Oct 18 12:26:29 2030
+++ linux/fs/nfsd/nfs3xdr.c	Fri Oct 18 12:32:35 2030
@@ -13,6 +13,7 @@
 #include <linux/spinlock.h>
 #include <linux/dcache.h>
 #include <linux/namei.h>
+#include <linux/pagemap.h>
 
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svc.h>
@@ -78,6 +79,34 @@ encode_fh(u32 *p, struct svc_fh *fhp)
 }
 
 /*
+ * Pad extra data at the end of the packet as the length of RPC packet
+ * must be multiple of u32.
+ */
+static inline u32 *
+xdr_pack_data(struct svc_rqst *rqstp, u32 *p, unsigned long count)
+{
+	int pad = (XDR_QUADLEN(count) << 2) - count;
+	unsigned int index = rqstp->rq_resbuf.nriov;
+	struct rpcio_vec *iov = rqstp->rq_resbuf.iov;
+
+	if (index == 1)
+		return p + XDR_QUADLEN(count);
+
+	/* The last page may have enough room to pad. */
+	if (iov[index-1].rpc_page &&
+	    iov[index-1].rpc_offset + iov[index-1].rpc_len + pad <= PAGE_SIZE) {
+		iov[index - 1].rpc_len += pad;
+	} else {
+		static long dummy = 0;
+		iov[index].rpc_base = &dummy;
+		iov[index].rpc_len = pad;
+		iov[index].rpc_page = NULL;
+		rqstp->rq_resbuf.nriov++;
+	}
+	return p;
+}
+
+/*
  * Decode a file name and make sure that the path contains
  * no slashes or null bytes.
  */
@@ -569,7 +598,7 @@ nfs3svc_encode_readlinkres(struct svc_rq
 	p = encode_post_op_attr(rqstp, p, &resp->fh);
 	if (resp->status == 0) {
 		*p++ = htonl(resp->len);
-		p += XDR_QUADLEN(resp->len);
+		p = xdr_pack_data(rqstp, p, resp->len);
 	}
 	return xdr_ressize_check(rqstp, p);
 }
@@ -584,7 +613,7 @@ nfs3svc_encode_readres(struct svc_rqst *
 		*p++ = htonl(resp->count);
 		*p++ = htonl(resp->eof);
 		*p++ = htonl(resp->count);	/* xdr opaque count */
-		p += XDR_QUADLEN(resp->count);
+		p = xdr_pack_data(rqstp, p, resp->count);
 	}
 	return xdr_ressize_check(rqstp, p);
 }
@@ -647,7 +676,7 @@ nfs3svc_encode_readdirres(struct svc_rqs
 	if (resp->status == 0) {
 		/* stupid readdir cookie */
 		memcpy(p, resp->verf, 8); p += 2;
-		p += XDR_QUADLEN(resp->count);
+		p = xdr_pack_data(rqstp, p, resp->count);
 	}
 
 	return xdr_ressize_check(rqstp, p);
--- linux.ORG/fs/nfsd/nfsxdr.c	Fri Oct 18 12:26:29 2030
+++ linux/fs/nfsd/nfsxdr.c	Fri Oct 18 12:32:35 2030
@@ -55,6 +55,35 @@ encode_fh(u32 *p, struct svc_fh *fhp)
 	return p + (NFS_FHSIZE>> 2);
 }
 
+
+/*
+ * Pad extra data at the end of the packet as the length of RPC packet
+ * must be multiple of u32.
+ */
+static inline u32 *
+xdr_pack_data(struct svc_rqst *rqstp, u32 *p, unsigned long count)
+{
+	int pad = (XDR_QUADLEN(count) << 2) - count;
+	unsigned int index = rqstp->rq_resbuf.nriov;
+	struct rpcio_vec *iov = rqstp->rq_resbuf.iov;
+
+	if (index == 1)
+		return p + XDR_QUADLEN(count);
+
+	/* The last page may have enough room to pad. */
+	if (iov[index-1].rpc_page &&
+	    iov[index-1].rpc_offset + iov[index-1].rpc_len + pad <= PAGE_SIZE) {
+		iov[index - 1].rpc_len += pad;
+	} else {
+		static long dummy = 0;
+		iov[index].rpc_base = &dummy;
+		iov[index].rpc_len = pad;
+		iov[index].rpc_page = NULL;
+		rqstp->rq_resbuf.nriov++;
+	}
+	return p;
+}
+
 /*
  * Decode a file name and make sure that the path contains
  * no slashes or null bytes.
@@ -361,7 +390,7 @@ nfssvc_encode_readlinkres(struct svc_rqs
 					struct nfsd_readlinkres *resp)
 {
 	*p++ = htonl(resp->len);
-	p += XDR_QUADLEN(resp->len);
+	p = xdr_pack_data(rqstp, p, resp->len);
 	return xdr_ressize_check(rqstp, p);
 }
 
@@ -371,7 +400,7 @@ nfssvc_encode_readres(struct svc_rqst *r
 {
 	p = encode_fattr(rqstp, p, &resp->fh);
 	*p++ = htonl(resp->count);
-	p += XDR_QUADLEN(resp->count);
+	p = xdr_pack_data(rqstp, p, resp->count);
 
 	return xdr_ressize_check(rqstp, p);
 }
@@ -380,7 +409,7 @@ int
 nfssvc_encode_readdirres(struct svc_rqst *rqstp, u32 *p,
 					struct nfsd_readdirres *resp)
 {
-	p += XDR_QUADLEN(resp->count);
+	p = xdr_pack_data(rqstp, p, resp->count);
 	return xdr_ressize_check(rqstp, p);
 }
 
--- linux.ORG/fs/nfsd/vfs.c	Fri Oct 18 12:26:29 2030
+++ linux/fs/nfsd/vfs.c	Fri Oct 18 12:36:13 2030
@@ -13,6 +13,7 @@
  * dentry, don't worry--they have been taken care of.
  *
  * Copyright (C) 1995-1999 Olaf Kirch <okir@monad.swb.de>
+ * Zerocpy NFS support (C) 2002 Hirokazu Takahashi <taka@valinux.co.jp>
  */
 
 #include <linux/config.h>
@@ -28,6 +29,7 @@
 #include <linux/net.h>
 #include <linux/unistd.h>
 #include <linux/slab.h>
+#include <linux/pagemap.h>
 #include <linux/in.h>
 #include <linux/module.h>
 #include <linux/namei.h>
@@ -571,6 +573,61 @@ found:
 }
 
 /*
+ * Grab and keep cached pages assosiated with a file in the svc_rqst
+ * so that they can be passed to the netowork sendmsg/sendpage routines
+ * directrly. They will be released after the sending has completed.
+ */
+static int
+nfsd_read_actor(read_descriptor_t *desc, struct page *page, unsigned long offset , unsigned long size)
+{
+	unsigned long count = desc->count;
+	struct svc_rqst *rqstp = (struct svc_rqst *)desc->buf;
+	unsigned int index = rqstp->rq_resbuf.nriov;
+	struct rpcio_vec *iov = rqstp->rq_resbuf.iov;
+
+	if (size > count)
+		size = count;
+
+	if (page == iov[index-1].rpc_page
+		  && offset == iov[index-1].rpc_offset + iov[index-1].rpc_len) {
+		/* the page can be coalesced */
+		iov[index-1].rpc_len += size;
+	} else {
+		rqstp->rq_resbuf.nriov++;
+		get_page(page);
+		iov[index].rpc_page = page;
+		iov[index].rpc_offset = offset;
+		iov[index].rpc_len = size;
+	}
+
+	desc->count = count - size;
+	desc->written += size;
+	return size;
+}
+
+static inline ssize_t
+nfsd_getpages(struct file *filp, struct svc_rqst *rqstp, unsigned long count)
+{
+	read_descriptor_t desc;
+	ssize_t	retval;
+
+	if (!count)
+		return 0;
+
+	desc.written = 0;
+	desc.count = count;
+	desc.buf = (char *)rqstp;
+	desc.error = 0;
+	do_generic_file_read(filp, &filp->f_pos, &desc, nfsd_read_actor);
+
+	retval = desc.written;
+	if (!retval)
+		retval = desc.error;
+	return retval;
+}
+
+
+/*
  * Read data from a file. count must contain the requested read count
  * on entry. On return, *count contains the number of bytes actually read.
  * N.B. After this call fhp needs an fh_put
@@ -601,10 +658,17 @@ nfsd_read(struct svc_rqst *rqstp, struct
 	if (ra)
 		file.f_ra = ra->p_ra;
 
-	oldfs = get_fs();
-	set_fs(KERNEL_DS);
-	err = vfs_read(&file, buf, *count, &offset);
-	set_fs(oldfs);
+	/* ToDo: NFSv4 can't handle fragmented data yet. */
+/* 	if (inode->i_mapping->a_ops->readpage) { */
+	if (inode->i_mapping->a_ops->readpage && rqstp->rq_vers <= 3) {
+		file.f_pos = offset;
+		err = nfsd_getpages(&file, rqstp, *count);
+	} else {
+		oldfs = get_fs();
+		set_fs(KERNEL_DS);
+		err = vfs_read(&file, buf, *count, &offset);
+		set_fs(oldfs);
+	}
 
 	/* Write back readahead params */
 	if (ra)

----Next_Part(Fri_Oct_18_22:11:03_2002_141)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="va03-zerocopy-nfsdreaddir-2.5.43.patch"

--- linux.ORG/fs/nfsd/vfs.c	Fri Oct 18 21:24:43 2030
+++ linux/fs/nfsd/vfs.c	Fri Oct 18 21:23:48 2030
@@ -1460,6 +1460,7 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 	int		oldlen, eof, err;
 	struct file	file;
 	struct readdir_cd cd;
+	struct page *page = NULL;
 
 	err = nfsd_open(rqstp, fhp, S_IFDIR, MAY_READ, &file);
 	if (err)
@@ -1469,6 +1470,15 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 
 	file.f_pos = offset;
 
+	/* ToDo: NFSv4 can't handle fragmented data yet. */
+/* 	if (*countp <= (PAGE_SIZE >> 2)) { */
+	if (*countp <= (PAGE_SIZE >> 2) && rqstp->rq_vers <= 3) {
+		/* Don't care if we couldn't get a page. */
+		page = alloc_page(GFP_KERNEL);
+		if (page)
+			buffer = page_address(page);
+	}
+
 	/* Set up the readdir context */
 	memset(&cd, 0, sizeof(cd));
 	cd.rqstp  = rqstp;
@@ -1518,11 +1528,22 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 	*p++ = htonl(eof);		/* end of directory */
 	*countp = (caddr_t) p - (caddr_t) buffer;
 
+	if (page) {
+		int index = rqstp->rq_resbuf.nriov;
+		get_page(page);
+		rqstp->rq_resbuf.iov[index].rpc_page = page;
+		rqstp->rq_resbuf.iov[index].rpc_base = NULL;
+		rqstp->rq_resbuf.iov[index].rpc_len = *countp;
+		rqstp->rq_resbuf.nriov++;
+	}
+
 	dprintk("nfsd: readdir result %d bytes, eof %d offset %d\n",
 				*countp, eof,
 				cd.offset? ntohl(*cd.offset) : -1);
 	err = 0;
 out_close:
+	if (page)
+		put_page(page);
 	nfsd_close(&file);
 out:
 	return err;

----Next_Part(Fri_Oct_18_22:11:03_2002_141)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="va04-zerocopy-shadowsock-2.5.43.patch"

--- linux.ORG/include/linux/sunrpc/svcsock.h	Fri Oct 18 12:32:04 2030
+++ linux/include/linux/sunrpc/svcsock.h	Fri Oct 18 12:42:02 2030
@@ -52,6 +52,7 @@ struct svc_sock {
 	int			sk_reclen;	/* length of record */
 	int			sk_tcplen;	/* current read length */
 	time_t			sk_lastrecv;	/* time of last received request */
+	struct svc_sock		**sk_shadow;	/* shadow sockets for sending */
 };
 
 /*
--- linux.ORG/net/sunrpc/svcsock.c	Fri Oct 18 12:32:04 2030
+++ linux/net/sunrpc/svcsock.c	Fri Oct 18 12:42:02 2030
@@ -65,7 +65,9 @@
 
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
-					 int *errp, int pmap_reg);
+					 int *errp, int type);
+#define SVSK_PMAP_REGISTER	1
+#define SVSK_SHADOW		2
 static void		svc_udp_data_ready(struct sock *, int);
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
@@ -260,6 +262,8 @@ svc_sock_put(struct svc_sock *svsk)
 	if (!--(svsk->sk_inuse) && test_bit(SK_DEAD, &svsk->sk_flags)) {
 		spin_unlock_bh(&serv->sv_lock);
 		dprintk("svc: releasing dead socket\n");
+		if (svsk->sk_shadow)
+			kfree(svsk->sk_shadow);
 		sock_release(svsk->sk_sock);
 		kfree(svsk);
 	}
@@ -328,10 +332,10 @@ svc_wake_up(struct svc_serv *serv)
  * Generic sendto routine
  */
 static int
-svc_sendto(struct svc_rqst *rqstp, struct rpcio_vec *iov, int nr)
+svc_sendto(struct svc_rqst *rqstp, struct svc_sock *svsk,
+				 struct rpcio_vec *iov, int nr)
 {
 	mm_segment_t	oldfs;
-	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct socket	*sock = svsk->sk_sock;
 	struct msghdr	msg;
 	unsigned int	flags = MSG_MORE;
@@ -593,6 +597,7 @@ static int
 svc_udp_sendto(struct svc_rqst *rqstp)
 {
 	struct svc_buf	*bufp = &rqstp->rq_resbuf;
+	struct svc_sock	*svsk = rqstp->rq_sock;
 	int		error;
 
 	/* Set up the first element of the reply iovec.
@@ -603,10 +608,25 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 	bufp->iov[0].rpc_base = bufp->base;
 	bufp->iov[0].rpc_len  = bufp->len << 2;
 
-	error = svc_sendto(rqstp, bufp->iov, bufp->nriov);
+#ifdef CONFIG_SMP
+	if (svsk->sk_shadow) {
+		struct svc_sock	*shadow = svsk->sk_shadow[smp_processor_id()];
+		if (shadow) {
+			struct svc_serv	*serv = svsk->sk_server;
+			svsk = shadow;
+			if (test_and_clear_bit(SK_CHNGBUF, &svsk->sk_flags))
+				svc_sock_setbufsize(svsk->sk_sock,
+					(serv->sv_nrthreads+3) * serv->sv_bufsz,
+					(serv->sv_nrthreads+3) * serv->sv_bufsz);
+		}
+
+	}
+#endif
+
+	error = svc_sendto(rqstp, svsk, bufp->iov, bufp->nriov);
 	if (error == -ECONNREFUSED)
 		/* ICMP error on earlier request. */
-		error = svc_sendto(rqstp, bufp->iov, bufp->nriov);
+		error = svc_sendto(rqstp, svsk, bufp->iov, bufp->nriov);
 
 	return error;
 }
@@ -978,7 +998,7 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 		buflen += bufp->iov[i].rpc_len;
 	bufp->base[0] = htonl(0x80000000|(buflen - 4));
 
-	sent = svc_sendto(rqstp, bufp->iov, bufp->nriov);
+	sent = svc_sendto(rqstp, rqstp->rq_sock, bufp->iov, bufp->nriov);
 	if (sent != buflen) {
 		printk(KERN_NOTICE "rpc-srv/tcp: %s: %s %d when sending %d bytes - shutting down socket\n",
 		       rqstp->rq_sock->sk_server->sv_name,
@@ -1201,7 +1221,7 @@ svc_send(struct svc_rqst *rqstp)
  */
 static struct svc_sock *
 svc_setup_socket(struct svc_serv *serv, struct socket *sock,
-					int *errp, int pmap_register)
+					int *errp, int type)
 {
 	struct svc_sock	*svsk;
 	struct sock	*inet;
@@ -1222,6 +1242,7 @@ svc_setup_socket(struct svc_serv *serv, 
 	svsk->sk_owspace = inet->write_space;
 	svsk->sk_server = serv;
 	svsk->sk_lastrecv = CURRENT_TIME;
+	svsk->sk_shadow = NULL;
 	INIT_LIST_HEAD(&svsk->sk_deferred);
 	sema_init(&svsk->sk_sem, 1);
 
@@ -1234,7 +1255,7 @@ if (svsk->sk_sk == NULL)
 	printk(KERN_WARNING "svsk->sk_sk == NULL after svc_prot_init!\n");
 
 	/* Register socket with portmapper */
-	if (*errp >= 0 && pmap_register)
+	if (*errp >= 0 && type == SVSK_PMAP_REGISTER)
 		*errp = svc_register(serv, inet->protocol,
 				     ntohs(inet_sk(inet)->sport));
 
@@ -1246,13 +1267,13 @@ if (svsk->sk_sk == NULL)
 
 
 	spin_lock_bh(&serv->sv_lock);
-	if (!pmap_register) {
+	if (type == SVSK_PMAP_REGISTER || type == SVSK_SHADOW) {
+		clear_bit(SK_TEMP, &svsk->sk_flags);
+		list_add(&svsk->sk_list, &serv->sv_permsocks);
+	} else {
 		set_bit(SK_TEMP, &svsk->sk_flags);
 		list_add(&svsk->sk_list, &serv->sv_tempsocks);
 		serv->sv_tmpcnt++;
-	} else {
-		clear_bit(SK_TEMP, &svsk->sk_flags);
-		list_add(&svsk->sk_list, &serv->sv_permsocks);
 	}
 	spin_unlock_bh(&serv->sv_lock);
 
@@ -1261,6 +1282,61 @@ if (svsk->sk_sk == NULL)
 	return svsk;
 }
 
+
+/*
+ * Create a shadow socket which has the same sport of given svsk.
+ * Let each cpu have its own socket to send packets. 
+ */
+static int
+svc_create_shadow_socket(struct svc_serv *serv, struct svc_sock	*svsk,
+				int protocol, struct sockaddr_in *sin)
+{
+#ifdef CONFIG_SMP
+	int		error;
+	struct socket	*newsock;
+	struct svc_sock	*newsvsk;
+	int		i;
+
+	if (num_online_cpus() == 1)
+		return 0;
+
+	svsk->sk_shadow = kmalloc(sizeof(struct svc_sock*)*NR_CPUS, GFP_KERNEL);
+	if (!svsk->sk_shadow)
+		return -ENOMEM;
+
+	memset(svsk->sk_shadow, 0, sizeof(struct svc_sock*)*NR_CPUS);
+
+	for (i = 0; i < NR_CPUS; i++) {
+		if (!cpu_online(i))
+			continue;
+
+		if ((error = sock_create(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &newsock)) < 0)
+			return error;
+		if ((newsvsk = svc_setup_socket(serv, newsock, &error, SVSK_SHADOW)) == NULL) {
+			sock_release(newsock);
+			return error;
+		}
+		/*
+		 * Make the newsvsk as shadow of the svsk.
+		 */
+		newsock->sk->reuse = 1; /* allow address reuse */
+		error = newsock->ops->bind(newsock, (struct sockaddr *) sin,
+						sizeof(*sin));
+		if (error < 0) {
+			sock_release(newsock);
+			kfree(newsvsk);
+			return error;
+		}
+		/*
+		 * Unhash the newsocket not to receive packets.
+		 */
+		newsock->sk->prot->unhash(newsock->sk);
+		svsk->sk_shadow[i] = newsvsk;
+	}
+#endif
+	return 0;
+}
+
 /*
  * Create socket for RPC service.
  */
@@ -1300,8 +1376,13 @@ svc_create_socket(struct svc_serv *serv,
 			goto bummer;
 	}
 
-	if ((svsk = svc_setup_socket(serv, sock, &error, 1)) != NULL)
-		return 0;
+	if ((svsk = svc_setup_socket(serv, sock, &error, SVSK_PMAP_REGISTER)) == NULL)
+		goto bummer;
+
+	if (protocol == IPPROTO_UDP && sin != NULL)
+		svc_create_shadow_socket(serv, svsk, protocol, sin);
+
+	return 0;
 
 bummer:
 	dprintk("svc: svc_create_socket error = %d\n", -error);
@@ -1340,6 +1421,8 @@ svc_delete_socket(struct svc_sock *svsk)
 
 	if (!svsk->sk_inuse) {
 		spin_unlock_bh(&serv->sv_lock);
+		if (svsk->sk_shadow)
+			kfree(svsk->sk_shadow);
 		sock_release(svsk->sk_sock);
 		kfree(svsk);
 	} else {

----Next_Part(Fri_Oct_18_22:11:03_2002_141)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="va05-zerocopy-nfsdwrite-2.5.43.patch"

--- linux.ORG/include/linux/sunrpc/svc.h	Fri Oct 18 21:24:38 2030
+++ linux/include/linux/sunrpc/svc.h	Fri Oct 18 21:26:01 2030
@@ -70,7 +70,7 @@ struct svc_serv {
  * the list of IP fragments once we get to process fragmented UDP
  * datagrams directly.
  */
-#define RPCSVC_MAXIOV		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE + 2)
+#define RPCSVC_MAXIOV		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE*3 + 2)
 struct svc_buf {
 	u32 *			area;	/* allocated memory */
 	u32 *			base;	/* base of RPC datagram */
@@ -79,7 +79,7 @@ struct svc_buf {
 	int			len;	/* current end of buffer */
 
 	/* 
-	 * iovec for zero-copy NFS READs
+	 * iovec for zero-copy NFS READs/WRITEs
 	 * pages and non-page data can be mixed.
 	 */
 	struct rpcio_vec {
@@ -204,7 +204,13 @@ struct svc_procedure {
 	unsigned int		pc_count;	/* call count */
 	unsigned int		pc_cachetype;	/* cache info (NFS) */
 	unsigned int		pc_xdrressize;	/* maximum size of XDR reply */
+	unsigned int		pc_flags;
 };
+
+/*
+ * pc_flags
+ */
+#define RPC_HANDLE_IOVARG	0x1	/* can accept separated arg buffers */
 
 /*
  * This is the RPC server thread function prototype
--- linux.ORG/net/sunrpc/svcsock.c	Fri Oct 18 21:26:29 2030
+++ linux/net/sunrpc/svcsock.c	Fri Oct 18 21:26:01 2030
@@ -514,6 +514,98 @@ svc_write_space(struct sock *sk)
 	}
 }
 
+static inline int
+svc_map_skb_rpciovec_one(struct sk_buff *skb, struct rpcio_vec *iov, int *slotp)
+{
+	int i;
+	int slot = *slotp;
+
+	if (slot >= RPCSVC_MAXIOV)
+		return 1;
+
+	iov[slot].rpc_page = NULL;
+	iov[slot].rpc_base = skb->data;
+	iov[slot].rpc_len = skb_headlen(skb);
+	slot++;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		if (slot >= RPCSVC_MAXIOV)
+			return 1;
+		/* TODO: Highmem is not supported yet.  */
+		if (PageHighMem(frag->page))
+			return 1;
+		/* 
+		 * Some drivers would split skb into some pages in the near
+		 * future as slab for jumbo frames of GbE causes memory
+		 * pressure too much.
+		 */
+		iov[slot].rpc_page = frag->page;
+		iov[slot].rpc_offset = frag->page_offset;
+		iov[slot].rpc_len = frag->size;
+		slot++;
+	}
+	*slotp = slot;
+	return 0;
+}
+
+/*
+ * Map fragments in the skb into rpc_iovec if possible.
+ */
+static inline int
+svc_map_skb_rpciovec(struct sk_buff *skb, struct svc_buf *bufp)
+{
+	int slot = 0;
+	struct sk_buff *list;
+
+	/* 
+	 * Make sure the first buffer big so that knfsd or other services
+	 * can handle it easily.
+	 */
+	if (skb_headlen(skb) < 1400)
+		return 1;
+
+	if (svc_map_skb_rpciovec_one(skb, bufp->iov, &slot))
+		return 1;
+
+	bufp->iov[0].rpc_base += sizeof(struct udphdr);
+	bufp->iov[0].rpc_len -= sizeof(struct udphdr);
+
+	for (list = skb_shinfo(skb)->frag_list; list; list = list->next) {
+		if (svc_map_skb_rpciovec_one(list, bufp->iov, &slot))
+			return 1;
+	}
+	bufp->nriov = slot;
+	return 0;
+}
+
+/*
+ * Copy data from fragmented UDP frame into the RPC buffer.
+ */
+static inline u32*
+svc_copy_skb_argbuf(struct svc_rqst *rqstp, struct sk_buff *skb)
+{
+	struct iovec iov;
+	mm_segment_t		oldfs;
+	int err;
+
+	iov.iov_base = rqstp->rq_argbuf.buf;
+	iov.iov_len = skb->len - sizeof(struct udphdr);
+
+	oldfs = get_fs(); set_fs(KERNEL_DS);
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr), &iov, iov.iov_len);
+	} else {
+		err = skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr), &iov);
+	}
+	set_fs(oldfs);
+	if (err)
+		return NULL;
+
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	return rqstp->rq_argbuf.buf;
+}
+
 /*
  * Receive a datagram from a UDP socket.
  */
@@ -549,9 +641,13 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	}
 	set_bit(SK_DATA, &svsk->sk_flags); /* there may be more data... */
 
-	/* Sorry. */
-	if (skb_is_nonlinear(skb)) {
-		if (skb_linearize(skb, GFP_KERNEL) != 0) {
+	len  = skb->len - sizeof(struct udphdr);
+	data = (u32 *) (skb->data + sizeof(struct udphdr));
+
+	if (skb_is_nonlinear(skb) &&
+			svc_map_skb_rpciovec(skb, &rqstp->rq_argbuf)) {
+		data = svc_copy_skb_argbuf(rqstp, skb);
+		if (data == NULL) {
 			kfree_skb(skb);
 			svc_sock_received(svsk);
 			return 0;
@@ -566,16 +662,15 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		}
 	}
 
-
-	len  = skb->len - sizeof(struct udphdr);
-	data = (u32 *) (skb->data + sizeof(struct udphdr));
-
 	rqstp->rq_skbuff      = skb;
 	rqstp->rq_argbuf.base = data;
 	rqstp->rq_argbuf.buf  = data;
 	rqstp->rq_argbuf.len  = (len >> 2);
 	rqstp->rq_argbuf.buflen = (len >> 2);
-	/* rqstp->rq_resbuf      = rqstp->rq_defbuf; */
+
+	rqstp->rq_resbuf.base   += rqstp->rq_argbuf.buflen;
+	rqstp->rq_resbuf.buf     = rqstp->rq_resbuf.base;
+	rqstp->rq_resbuf.buflen -= rqstp->rq_argbuf.buflen;
 	rqstp->rq_prot        = IPPROTO_UDP;
 
 	/* Get sender address */
@@ -1067,6 +1162,17 @@ svc_sock_update_bufs(struct svc_serv *se
 	spin_unlock_bh(&serv->sv_lock);
 }
 
+inline void
+svc_clear_buffer(struct svc_buf *target, struct svc_buf *defbuf)
+{
+	target->base   = defbuf->base;
+	target->buflen = defbuf->buflen;
+	target->buf    = defbuf->buf;
+	target->len    = defbuf->len;
+	target->iov[0] = defbuf->iov[0];
+	target->nriov  = defbuf->nriov;
+}
+
 /*
  * Receive the next request on any socket.
  */
@@ -1090,8 +1196,8 @@ svc_recv(struct svc_serv *serv, struct s
 			 rqstp);
 
 	/* Initialize the buffers */
-	rqstp->rq_argbuf = rqstp->rq_defbuf;
-	rqstp->rq_resbuf = rqstp->rq_defbuf;
+	svc_clear_buffer(&rqstp->rq_argbuf, &rqstp->rq_defbuf);
+	svc_clear_buffer(&rqstp->rq_resbuf, &rqstp->rq_defbuf);
 
 	if (signalled())
 		return -EINTR;
--- linux.ORG/net/sunrpc/svc.c	Fri Oct 18 21:24:38 2030
+++ linux/net/sunrpc/svc.c	Fri Oct 18 21:26:01 2030
@@ -13,6 +13,7 @@
 #include <linux/net.h>
 #include <linux/in.h>
 #include <linux/unistd.h>
+#include <linux/pagemap.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
@@ -233,6 +234,40 @@ svc_register(struct svc_serv *serv, int 
 	return error;
 }
 
+static inline void
+svc_linearize_argbuf(struct svc_rqst *rqstp)
+{
+	struct svc_buf *argp = &rqstp->rq_argbuf;
+	char *newbuf;
+	char *base;
+	char *p;
+	unsigned int skip, len;
+	int i;
+
+	skip = (char*)argp->buf - (char*)argp->iov[0].rpc_base;
+	len = argp->iov[0].rpc_len - skip;
+	newbuf = (char*)rqstp->rq_defbuf.base + skip;
+
+	memcpy(newbuf, argp->buf, len);
+	p = newbuf + len;
+
+	for (i = 1; i < argp->nriov; i++) {
+		if (argp->iov[i].rpc_page) {
+			base = kmap(argp->iov[i].rpc_page) + argp->iov[i].rpc_offset;
+		} else {
+			base = argp->iov[i].rpc_base;
+		}
+		memcpy(p, base, argp->iov[i].rpc_len);
+		p += argp->iov[i].rpc_len;
+		if (argp->iov[i].rpc_page)
+			kunmap(argp->iov[i].rpc_page);
+	}
+	rqstp->rq_argbuf.base = rqstp->rq_defbuf.base;
+	rqstp->rq_argbuf.buf = (u32*)newbuf;
+	rqstp->rq_argbuf.nriov = 1;
+}
+
+
 /*
  * Process the RPC request.
  */
@@ -322,6 +357,15 @@ svc_process(struct svc_serv *serv, struc
 	 */
 	if (procp->pc_xdrressize)
 		svc_reserve(rqstp, procp->pc_xdrressize<<2);
+
+	/* Linearize argbuf when the procedure can't handle it.
+	 * It rarely happens on NFS v2/v3 but it would sometimes happen on
+	 * NFS v4 according to its compound procedures. NFSv4 xdr routines
+	 * have to handle splitted buffers or don't set RPC_HANDLE_IOVARG
+	 * flag in the beginning.
+	 */
+	if (argp->nriov > 1 && !(procp->pc_flags & RPC_HANDLE_IOVARG))
+		svc_linearize_argbuf(rqstp);
 
 	/* Call the function that processes the request. */
 	if (!versp->vs_dispatch) {
--- linux.ORG/fs/nfsd/vfs.c	Fri Oct 18 21:26:22 2030
+++ linux/fs/nfsd/vfs.c	Fri Oct 18 21:26:01 2030
@@ -686,6 +686,61 @@ out:
 	return err;
 }
 
+static inline int
+nfsd_writev(struct svc_rqst *rqstp, struct file	*file,
+				char *buf, unsigned long cnt)
+{
+	struct iovec		iov[RPCSVC_MAXIOV];
+	struct rpcio_vec	*rpciov = rqstp->rq_argbuf.iov;
+	unsigned int		len, sub;
+	char			*base = NULL;
+	int			slot = 0;
+	int			i;
+	mm_segment_t		oldfs;
+	int			err;
+
+	/* Look for the starting rpciov including the buf. */
+	for (i = 0; i < rqstp->rq_argbuf.nriov; i++) {
+		if (rpciov->rpc_page) {
+			/* HighMem is not supported yet. */
+			if (PageHighMem(rpciov->rpc_page))
+				BUG();
+			base = page_address(rpciov->rpc_page) + rpciov->rpc_offset;
+		} else {
+			base = rpciov->rpc_base;
+		}
+		if (base <= buf && buf < base + rpciov->rpc_len)
+			break;
+	}
+
+	iov[slot].iov_base = buf;
+	iov[slot].iov_len = rpciov->rpc_len - (buf - base);
+	len = iov[slot].iov_len;
+	for (i++, slot++, rpciov++ ; i < rqstp->rq_argbuf.nriov; i++, slot++, rpciov++) {
+		if (rpciov->rpc_page) {
+			/* HighMem is not supported yet. */
+			if (PageHighMem(rpciov->rpc_page))
+				BUG();
+			iov[slot].iov_base = page_address(rpciov->rpc_page) + rpciov->rpc_offset;
+		} else {
+			iov[slot].iov_base = rpciov->rpc_base;
+		}
+		iov[slot].iov_len = rpciov->rpc_len;
+		len += iov[slot].iov_len;
+	}
+	while (len > cnt) {
+		sub = min_t(unsigned int, iov[slot-1].iov_len, len - cnt);
+		len -= sub;
+		iov[slot-1].iov_len -= sub;
+		if (iov[slot-1].iov_len == 0)
+			slot--;
+	}
+	oldfs = get_fs(); set_fs(KERNEL_DS);
+	err = file->f_op->writev(file, iov, slot, &file->f_pos);
+	set_fs(oldfs);
+	return err;
+}
+
 /*
  * Write data to a file.
  * The stable flag requests synchronous writes.
@@ -740,11 +795,16 @@ nfsd_write(struct svc_rqst *rqstp, struc
 		file.f_flags |= O_SYNC;
 
 	/* Write the data. */
-	oldfs = get_fs(); set_fs(KERNEL_DS);
-	err = vfs_write(&file, buf, cnt, &offset);
+	if (rqstp->rq_argbuf.nriov == 1) {
+		oldfs = get_fs(); set_fs(KERNEL_DS);
+		err = vfs_write(&file, buf, cnt, &offset);
+		set_fs(oldfs);
+	} else {
+		file.f_pos = offset;		/* set write offset */
+		err = nfsd_writev(rqstp, &file, buf, cnt);
+	}
 	if (err >= 0)
 		nfsdstats.io_write += cnt;
-	set_fs(oldfs);
 
 	/* clear setuid/setgid flag after write */
 	if (err >= 0 && (inode->i_mode & (S_ISUID | S_ISGID))) {
--- linux.ORG/fs/nfsd/nfsproc.c	Fri Oct 18 21:18:42 2030
+++ linux/fs/nfsd/nfsproc.c	Fri Oct 18 21:26:01 2030
@@ -522,7 +522,7 @@ nfsd_proc_statfs(struct svc_rqst * rqstp
 #define nfssvc_release_none	NULL
 struct nfsd_void { int dummy; };
 
-#define PROC(name, argt, rest, relt, cache, respsize)	\
+#define PROC(name, argt, rest, relt, cache, respsize, flags)	\
  { (svc_procfunc) nfsd_proc_##name,		\
    (kxdrproc_t) nfssvc_decode_##argt,		\
    (kxdrproc_t) nfssvc_encode_##rest,		\
@@ -532,6 +532,7 @@ struct nfsd_void { int dummy; };
    0,						\
    cache,					\
    respsize,				       	\
+   flags,					\
  }
 
 #define ST 1		/* status */
@@ -539,24 +540,24 @@ struct nfsd_void { int dummy; };
 #define	AT 18		/* attributes */
 
 static struct svc_procedure		nfsd_procedures2[18] = {
-  PROC(null,	 void,		void,		none,		RC_NOCACHE, ST),
-  PROC(getattr,	 fhandle,	attrstat,	fhandle,	RC_NOCACHE, ST+AT),
-  PROC(setattr,  sattrargs,	attrstat,	fhandle,	RC_REPLBUFF, ST+AT),
-  PROC(none,	 void,		void,		none,		RC_NOCACHE, ST),
-  PROC(lookup,	 diropargs,	diropres,	fhandle,	RC_NOCACHE, ST+FH+AT),
-  PROC(readlink, fhandle,	readlinkres,	none,		RC_NOCACHE, ST+1+NFS_MAXPATHLEN/4),
-  PROC(read,	 readargs,	readres,	fhandle,	RC_NOCACHE, ST+AT+1+NFSSVC_MAXBLKSIZE),
-  PROC(none,	 void,		void,		none,		RC_NOCACHE, ST),
-  PROC(write,	 writeargs,	attrstat,	fhandle,	RC_REPLBUFF, ST+AT),
-  PROC(create,	 createargs,	diropres,	fhandle,	RC_REPLBUFF, ST+FH+AT),
-  PROC(remove,	 diropargs,	void,		none,		RC_REPLSTAT, ST),
-  PROC(rename,	 renameargs,	void,		none,		RC_REPLSTAT, ST),
-  PROC(link,	 linkargs,	void,		none,		RC_REPLSTAT, ST),
-  PROC(symlink,	 symlinkargs,	void,		none,		RC_REPLSTAT, ST),
-  PROC(mkdir,	 createargs,	diropres,	fhandle,	RC_REPLBUFF, ST+FH+AT),
-  PROC(rmdir,	 diropargs,	void,		none,		RC_REPLSTAT, ST),
-  PROC(readdir,	 readdirargs,	readdirres,	none,		RC_REPLBUFF, 0),
-  PROC(statfs,	 fhandle,	statfsres,	none,		RC_NOCACHE, ST+5),
+  PROC(null,	 void,		void,		none,		RC_NOCACHE, ST, 0),
+  PROC(getattr,	 fhandle,	attrstat,	fhandle,	RC_NOCACHE, ST+AT, 0),
+  PROC(setattr,  sattrargs,	attrstat,	fhandle,	RC_REPLBUFF, ST+AT, 0),
+  PROC(none,	 void,		void,		none,		RC_NOCACHE, ST, 0),
+  PROC(lookup,	 diropargs,	diropres,	fhandle,	RC_NOCACHE, ST+FH+AT, 0),
+  PROC(readlink, fhandle,	readlinkres,	none,		RC_NOCACHE, ST+1+NFS_MAXPATHLEN/4, 0),
+  PROC(read,	 readargs,	readres,	fhandle,	RC_NOCACHE, ST+AT+1+NFSSVC_MAXBLKSIZE, 0),
+  PROC(none,	 void,		void,		none,		RC_NOCACHE, ST, 0),
+  PROC(write,	 writeargs,	attrstat,	fhandle,	RC_REPLBUFF, ST+AT, RPC_HANDLE_IOVARG),
+  PROC(create,	 createargs,	diropres,	fhandle,	RC_REPLBUFF, ST+FH+AT, 0),
+  PROC(remove,	 diropargs,	void,		none,		RC_REPLSTAT, ST, 0),
+  PROC(rename,	 renameargs,	void,		none,		RC_REPLSTAT, ST, 0),
+  PROC(link,	 linkargs,	void,		none,		RC_REPLSTAT, ST, 0),
+  PROC(symlink,	 symlinkargs,	void,		none,		RC_REPLSTAT, ST, 0),
+  PROC(mkdir,	 createargs,	diropres,	fhandle,	RC_REPLBUFF, ST+FH+AT, 0),
+  PROC(rmdir,	 diropargs,	void,		none,		RC_REPLSTAT, ST, 0),
+  PROC(readdir,	 readdirargs,	readdirres,	none,		RC_REPLBUFF, 0, 0),
+  PROC(statfs,	 fhandle,	statfsres,	none,		RC_NOCACHE, ST+5, 0),
 };
 
 
--- linux.ORG/fs/nfsd/nfs3proc.c	Fri Oct 18 21:18:42 2030
+++ linux/fs/nfsd/nfs3proc.c	Fri Oct 18 21:26:01 2030
@@ -645,7 +645,7 @@ nfsd3_proc_commit(struct svc_rqst * rqst
 #define nfsd3_voidres			nfsd3_voidargs
 struct nfsd3_voidargs { int dummy; };
 
-#define PROC(name, argt, rest, relt, cache, respsize)	\
+#define PROC(name, argt, rest, relt, cache, respsize, flags)	\
  { (svc_procfunc) nfsd3_proc_##name,		\
    (kxdrproc_t) nfs3svc_decode_##argt##args,	\
    (kxdrproc_t) nfs3svc_encode_##rest##res,	\
@@ -655,6 +655,7 @@ struct nfsd3_voidargs { int dummy; };
    0,						\
    cache,					\
    respsize,					\
+   flags,					\
  }
 
 #define ST 1		/* status*/
@@ -664,28 +665,28 @@ struct nfsd3_voidargs { int dummy; };
 #define WC (7+pAT)	/* WCC attributes */
 
 static struct svc_procedure		nfsd_procedures3[22] = {
-  PROC(null,	 void,		void,		void,	  RC_NOCACHE, ST),
-  PROC(getattr,	 fhandle,	attrstat,	fhandle,  RC_NOCACHE, ST+AT),
-  PROC(setattr,  sattr,		wccstat,	fhandle,  RC_REPLBUFF, ST+WC),
-  PROC(lookup,	 dirop,		dirop,		fhandle2, RC_NOCACHE, ST+FH+pAT+pAT),
-  PROC(access,	 access,	access,		fhandle,  RC_NOCACHE, ST+pAT+1),
-  PROC(readlink, fhandle,	readlink,	fhandle,  RC_NOCACHE, ST+pAT+1+NFS3_MAXPATHLEN/4),
-  PROC(read,	 read,		read,		fhandle,  RC_NOCACHE, ST+pAT+4+NFSSVC_MAXBLKSIZE),
-  PROC(write,	 write,		write,		fhandle,  RC_REPLBUFF, ST+WC+4),
-  PROC(create,	 create,	create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC),
-  PROC(mkdir,	 mkdir,		create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC),
-  PROC(symlink,	 symlink,	create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC),
-  PROC(mknod,	 mknod,		create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC),
-  PROC(remove,	 dirop,		wccstat,	fhandle,  RC_REPLBUFF, ST+WC),
-  PROC(rmdir,	 dirop,		wccstat,	fhandle,  RC_REPLBUFF, ST+WC),
-  PROC(rename,	 rename,	rename,		fhandle2, RC_REPLBUFF, ST+WC+WC),
-  PROC(link,	 link,		link,		fhandle2, RC_REPLBUFF, ST+pAT+WC),
-  PROC(readdir,	 readdir,	readdir,	fhandle,  RC_NOCACHE, 0),
-  PROC(readdirplus,readdirplus,	readdir,	fhandle,  RC_NOCACHE, 0),
-  PROC(fsstat,	 fhandle,	fsstat,		void,     RC_NOCACHE, ST+pAT+2*6+1),
-  PROC(fsinfo,   fhandle,	fsinfo,		void,     RC_NOCACHE, ST+pAT+12),
-  PROC(pathconf, fhandle,	pathconf,	void,     RC_NOCACHE, ST+pAT+6),
-  PROC(commit,	 commit,	commit,		fhandle,  RC_NOCACHE, ST+WC+2),
+  PROC(null,	 void,		void,		void,	  RC_NOCACHE, ST, 0),
+  PROC(getattr,	 fhandle,	attrstat,	fhandle,  RC_NOCACHE, ST+AT, 0),
+  PROC(setattr,  sattr,		wccstat,	fhandle,  RC_REPLBUFF, ST+WC, 0),
+  PROC(lookup,	 dirop,		dirop,		fhandle2, RC_NOCACHE, ST+FH+pAT+pAT, 0),
+  PROC(access,	 access,	access,		fhandle,  RC_NOCACHE, ST+pAT+1, 0),
+  PROC(readlink, fhandle,	readlink,	fhandle,  RC_NOCACHE, ST+pAT+1+NFS3_MAXPATHLEN/4, 0),
+  PROC(read,	 read,		read,		fhandle,  RC_NOCACHE, ST+pAT+4+NFSSVC_MAXBLKSIZE, 0),
+  PROC(write,	 write,		write,		fhandle,  RC_REPLBUFF, ST+WC+4, RPC_HANDLE_IOVARG),
+  PROC(create,	 create,	create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC, 0),
+  PROC(mkdir,	 mkdir,		create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC, 0),
+  PROC(symlink,	 symlink,	create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC, 0),
+  PROC(mknod,	 mknod,		create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC, 0),
+  PROC(remove,	 dirop,		wccstat,	fhandle,  RC_REPLBUFF, ST+WC, 0),
+  PROC(rmdir,	 dirop,		wccstat,	fhandle,  RC_REPLBUFF, ST+WC, 0),
+  PROC(rename,	 rename,	rename,		fhandle2, RC_REPLBUFF, ST+WC+WC, 0),
+  PROC(link,	 link,		link,		fhandle2, RC_REPLBUFF, ST+pAT+WC, 0),
+  PROC(readdir,	 readdir,	readdir,	fhandle,  RC_NOCACHE, 0, 0),
+  PROC(readdirplus,readdirplus,	readdir,	fhandle,  RC_NOCACHE, 0, 0),
+  PROC(fsstat,	 fhandle,	fsstat,		void,     RC_NOCACHE, ST+pAT+2*6+1, 0),
+  PROC(fsinfo,   fhandle,	fsinfo,		void,     RC_NOCACHE, ST+pAT+12, 0),
+  PROC(pathconf, fhandle,	pathconf,	void,     RC_NOCACHE, ST+pAT+6, 0),
+  PROC(commit,	 commit,	commit,		fhandle,  RC_NOCACHE, ST+WC+2, 0),
 };
 
 struct svc_version	nfsd_version3 = {
--- linux.ORG/fs/nfsd/nfs4proc.c	Fri Oct 18 21:18:42 2030
+++ linux/fs/nfsd/nfs4proc.c	Fri Oct 18 21:26:01 2030
@@ -711,7 +711,7 @@ out:
 #define nfs4svc_release_compound	NULL
 struct nfsd4_voidargs { int dummy; };
 
-#define PROC(name, argt, rest, relt, cache, respsize)	\
+#define PROC(name, argt, rest, relt, cache, respsize, flags)	\
  { (svc_procfunc) nfsd4_proc_##name,		\
    (kxdrproc_t) nfs4svc_decode_##argt##args,	\
    (kxdrproc_t) nfs4svc_encode_##rest##res,	\
@@ -721,6 +721,7 @@ struct nfsd4_voidargs { int dummy; };
    0,						\
    cache,					\
    respsize,					\
+   flags,					\
  }
 
 /*
@@ -734,8 +735,8 @@ struct nfsd4_voidargs { int dummy; };
  * better XID's.
  */
 static struct svc_procedure		nfsd_procedures4[2] = {
-  PROC(null,	 void,		void,		void,	  RC_NOCACHE, 1),
-  PROC(compound, compound,	compound,	compound, RC_NOCACHE, NFSD_BUFSIZE)
+  PROC(null,	 void,		void,		void,	  RC_NOCACHE, 1, 0),
+  PROC(compound, compound,	compound,	compound, RC_NOCACHE, NFSD_BUFSIZE, 0)
 };
 
 struct svc_version	nfsd_version4 = {
--- linux.ORG/fs/lockd/svcproc.c	Fri Oct 18 21:18:42 2030
+++ linux/fs/lockd/svcproc.c	Fri Oct 18 21:26:01 2030
@@ -553,6 +553,7 @@ struct nlm_void			{ int dummy; };
    .pc_argsize	= sizeof(struct nlm_##argt),		\
    .pc_ressize	= sizeof(struct nlm_##rest),		\
    .pc_xdrressize = respsize,				\
+   .pc_flags	 = 0,					\
  }
 
 #define	Ck	(1+8)	/* cookie */
--- linux.ORG/fs/lockd/svc4proc.c	Fri Oct 18 21:18:42 2030
+++ linux/fs/lockd/svc4proc.c	Fri Oct 18 21:26:01 2030
@@ -527,6 +527,7 @@ struct nlm_void			{ int dummy; };
    .pc_argsize	= sizeof(struct nlm_##argt),		\
    .pc_ressize	= sizeof(struct nlm_##rest),		\
    .pc_xdrressize = respsize,				\
+   .pc_flags	 = 0,					\
  }
 #define	Ck	(1+8)	/* cookie */
 #define	No	(1+1024/4)	/* netobj */

----Next_Part(Fri_Oct_18_22:11:03_2002_141)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="va07-nfsbigbuf-2.5.43.patch"

--- linux.ORG/include/linux/nfsd/const.h	Sat Oct 12 13:22:12 2002
+++ linux/include/linux/nfsd/const.h	Sun Oct 13 22:07:37 2030
@@ -20,9 +20,9 @@
 #define NFSSVC_MAXVERS		3
 
 /*
- * Maximum blocksize supported by daemon currently at 32K
+ * Maximum blocksize supported by daemon currently at 60K
  */
-#define NFSSVC_MAXBLKSIZE	(32*1024)
+#define NFSSVC_MAXBLKSIZE	((60*1024)&~(PAGE_SIZE-1))
 
 #ifdef __KERNEL__
 

----Next_Part(Fri_Oct_18_22:11:03_2002_141)----


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
