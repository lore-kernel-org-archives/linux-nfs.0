From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 5 - Use ->sendpage to send nfsd (and lockd) replies.
Date: Thu, 07 Nov 2002 11:56:30 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E189ayE-0008Je-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189ayO-0001bV-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Nov 2002 16:56:40 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Thu, 7 Nov 2002 11:56:30 +1100
To: Linus Torvalds <torvalds@transmeta.com>
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


These patches conitnue the work started earlier to get nfsd to work nicely
with page lists instead of one big buffer.

### Comments for ChangeSet

From: Hirokazu Takahashi <taka@valinux.co.jp>

As all rpc server replies are now in well defined pages,
we can use ->sendpage to send these replies, and so
make use for zero-copy transmit on network cards that
support it.






 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3xdr.c              |    4 -
 ./fs/nfsd/nfsxdr.c               |    4 -
 ./include/linux/sunrpc/svc.h     |   24 ++++++
 ./include/linux/sunrpc/svcsock.h |    1 
 ./net/sunrpc/svc.c               |   10 +-
 ./net/sunrpc/svcsock.c           |  138 ++++++++++++++++++++-------------------
 6 files changed, 106 insertions(+), 75 deletions(-)

--- ./include/linux/sunrpc/svc.h	2002/11/06 23:12:04	1.1
+++ ./include/linux/sunrpc/svc.h	2002/11/06 23:12:08	1.2
@@ -15,6 +15,7 @@
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svcauth.h>
 #include <linux/wait.h>
+#include <linux/mm.h>
 
 /*
  * RPC service.
@@ -171,7 +172,7 @@ xdr_ressize_check(struct svc_rqst *rqstp
 	return vec->iov_len <= PAGE_SIZE;
 }
 
-static int inline take_page(struct svc_rqst *rqstp)
+static int inline svc_take_page(struct svc_rqst *rqstp)
 {
 	if (rqstp->rq_arghi <= rqstp->rq_argused)
 		return -ENOMEM;
@@ -180,6 +181,27 @@ static int inline take_page(struct svc_r
 	return 0;
 }
 
+static void inline svc_pushback_allpages(struct svc_rqst *rqstp)
+{
+        while (rqstp->rq_resused) {
+		if (rqstp->rq_respages[--rqstp->rq_resused] == NULL)
+			continue;
+		rqstp->rq_argpages[rqstp->rq_arghi++] =
+			rqstp->rq_respages[rqstp->rq_resused];
+		rqstp->rq_respages[rqstp->rq_resused] = NULL;
+	}
+}
+
+static void inline svc_free_allpages(struct svc_rqst *rqstp)
+{
+        while (rqstp->rq_resused) {
+		if (rqstp->rq_respages[--rqstp->rq_resused] == NULL)
+			continue;
+		put_page(rqstp->rq_respages[rqstp->rq_resused]);
+		rqstp->rq_respages[rqstp->rq_resused] = NULL;
+	}
+}
+
 struct svc_deferred_req {
 	struct svc_serv		*serv;
 	u32			prot;	/* protocol (UDP or TCP) */
--- ./include/linux/sunrpc/svcsock.h	2002/11/06 23:12:04	1.1
+++ ./include/linux/sunrpc/svcsock.h	2002/11/06 23:12:08	1.2
@@ -37,6 +37,7 @@ struct svc_sock {
 
 	struct list_head	sk_deferred;	/* deferred requests that need to
 						 * be revisted */
+	struct semaphore        sk_sem;		/* to serialize sending data */
 
 	int			(*sk_recvfrom)(struct svc_rqst *rqstp);
 	int			(*sk_sendto)(struct svc_rqst *rqstp);
--- ./fs/nfsd/nfsxdr.c	2002/11/06 23:12:04	1.1
+++ ./fs/nfsd/nfsxdr.c	2002/11/06 23:12:08	1.2
@@ -239,7 +239,7 @@ nfssvc_decode_readargs(struct svc_rqst *
 	v=0;
 	while (len > 0) {
 		pn=rqstp->rq_resused;
-		take_page(rqstp);
+		svc_take_page(rqstp);
 		args->vec[v].iov_base = page_address(rqstp->rq_respages[pn]);
 		args->vec[v].iov_len = len < PAGE_SIZE?len:PAGE_SIZE;
 		v++;
@@ -388,7 +388,7 @@ nfssvc_encode_readres(struct svc_rqst *r
 	rqstp->rq_res.page_base = 0;
 	rqstp->rq_res.page_len = resp->count;
 	if (resp->count & 3) {
-		/* need to pad with tail */
+		/* need to pad the tail */
 		rqstp->rq_res.tail[0].iov_base = p;
 		*p = 0;
 		rqstp->rq_res.tail[0].iov_len = 4 - (resp->count&3);
--- ./fs/nfsd/nfs3xdr.c	2002/11/06 23:12:04	1.1
+++ ./fs/nfsd/nfs3xdr.c	2002/11/06 23:12:08	1.2
@@ -338,7 +338,7 @@ nfs3svc_decode_readargs(struct svc_rqst 
 	v=0;
 	while (len > 0) {
 		pn = rqstp->rq_resused;
-		take_page(rqstp);
+		svc_take_page(rqstp);
 		args->vec[v].iov_base = page_address(rqstp->rq_respages[pn]);
 		args->vec[v].iov_len = len < PAGE_SIZE? len : PAGE_SIZE;
 		v++;
@@ -603,7 +603,7 @@ nfs3svc_encode_readres(struct svc_rqst *
 		rqstp->rq_res.page_base = 0;
 		rqstp->rq_res.page_len = resp->count;
 		if (resp->count & 3) {
-			/* need to page with tail */
+			/* need to pad the tail */
 			rqstp->rq_res.tail[0].iov_base = p;
 			*p = 0;
 			rqstp->rq_res.tail[0].iov_len = 4 - (resp->count & 3);
--- ./net/sunrpc/svcsock.c	2002/11/06 23:12:04	1.1
+++ ./net/sunrpc/svcsock.c	2002/11/06 23:12:08	1.2
@@ -273,6 +273,11 @@ svc_sock_release(struct svc_rqst *rqstp)
 
 	svc_release_skb(rqstp);
 
+	svc_free_allpages(rqstp);
+	rqstp->rq_res.page_len = 0;
+	rqstp->rq_res.page_base = 0;
+
+
 	/* Reset response buffer and release
 	 * the reservation.
 	 * But first, check that enough space was reserved
@@ -317,38 +322,82 @@ svc_wake_up(struct svc_serv *serv)
  * Generic sendto routine
  */
 static int
-svc_sendto(struct svc_rqst *rqstp, struct iovec *iov, int nr)
+svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 {
 	mm_segment_t	oldfs;
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct socket	*sock = svsk->sk_sock;
 	struct msghdr	msg;
-	int		i, buflen, len;
+	int		slen;
+	int		len = 0;
+	int		result;
+	int		size;
+	struct page	**ppage = xdr->pages;
+	size_t		base = xdr->page_base;
+	unsigned int	pglen = xdr->page_len;
+	unsigned int	flags = MSG_MORE;
 
-	for (i = buflen = 0; i < nr; i++)
-		buflen += iov[i].iov_len;
+	slen = xdr->len;
 
 	msg.msg_name    = &rqstp->rq_addr;
 	msg.msg_namelen = sizeof(rqstp->rq_addr);
-	msg.msg_iov     = iov;
-	msg.msg_iovlen  = nr;
+	msg.msg_iov     = NULL;
+	msg.msg_iovlen  = 0;
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
+	msg.msg_flags	= MSG_MORE;
 
-	/* This was MSG_DONTWAIT, but I now want it to wait.
-	 * The only thing that it would wait for is memory and
-	 * if we are fairly low on memory, then we aren't likely
-	 * to make much progress anyway.
-	 * sk->sndtimeo is set to 30seconds just in case.
-	 */
-	msg.msg_flags	= 0;
+	/* Grab svsk->sk_sem to serialize outgoing data. */
+	down(&svsk->sk_sem);
 
+	/* set the destination */
 	oldfs = get_fs(); set_fs(KERNEL_DS);
-	len = sock_sendmsg(sock, &msg, buflen);
+	len = sock_sendmsg(sock, &msg, 0);
 	set_fs(oldfs);
+	if (len < 0)
+		goto out;
+
+	/* send head */
+	if (slen == xdr->head[0].iov_len)
+		flags = 0;
+	len = sock->ops->sendpage(sock, rqstp->rq_respages[0], 0, xdr->head[0].iov_len, flags);
+	if (len != xdr->head[0].iov_len)
+		goto out;
+	slen -= xdr->head[0].iov_len;
+	if (slen == 0)
+		goto out;
+
+	/* send page data */
+	size = PAGE_SIZE - base < pglen ? PAGE_SIZE - base : pglen;
+	while (pglen > 0) {
+		if (slen == size)
+			flags = 0;
+		result = sock->ops->sendpage(sock, *ppage, base, size, flags);
+		if (result > 0)
+			len += result;
+		if (result != size)
+			goto out;
+		slen -= size;
+		pglen -= size;
+		size = PAGE_SIZE < pglen ? PAGE_SIZE : pglen;
+		base = 0;
+		ppage++;
+	}
+	/* send tail */
+	if (xdr->tail[0].iov_len) {
+		/* The tail *will* be in respages[0]; */
+		result = sock->ops->sendpage(sock, rqstp->rq_respages[0], 
+					     ((unsigned long)xdr->tail[0].iov_base)& (PAGE_SIZE-1),
+					     xdr->tail[0].iov_len, 0);
+
+		if (result > 0)
+			len += result;
+	}
+out:
+	up(&svsk->sk_sem);
 
-	dprintk("svc: socket %p sendto([%p %Zu... ], %d, %d) = %d (addr %x)\n",
-			rqstp->rq_sock, iov[0].iov_base, iov[0].iov_len, nr, buflen, len,
+	dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d (addr %x)\n",
+			rqstp->rq_sock, xdr->head[0].iov_base, xdr->head[0].iov_len, xdr->len, len,
 		rqstp->rq_addr.sin_addr.s_addr);
 
 	return len;
@@ -550,35 +599,11 @@ static int
 svc_udp_sendto(struct svc_rqst *rqstp)
 {
 	int		error;
-	struct iovec vec[RPCSVC_MAXPAGES];
-	int v;
-	int base, len;
 
-	/* Set up the first element of the reply iovec.
-	 * Any other iovecs that may be in use have been taken
-	 * care of by the server implementation itself.
-	 */
-	vec[0] = rqstp->rq_res.head[0];
-	v=1;
-	base=rqstp->rq_res.page_base;
-	len = rqstp->rq_res.page_len;
-	while (len) {
-		vec[v].iov_base = page_address(rqstp->rq_res.pages[v-1]) + base;
-		vec[v].iov_len = PAGE_SIZE-base;
-		if (len <= vec[v].iov_len)
-			vec[v].iov_len = len;
-		len -= vec[v].iov_len;
-		base = 0;
-		v++;
-	}
-	if (rqstp->rq_res.tail[0].iov_len) {
-		vec[v] = rqstp->rq_res.tail[0];
-		v++;
-	}
-	error = svc_sendto(rqstp, vec, v);
+	error = svc_sendto(rqstp, &rqstp->rq_res);
 	if (error == -ECONNREFUSED)
 		/* ICMP error on earlier request. */
-		error = svc_sendto(rqstp, vec, v);
+		error = svc_sendto(rqstp, &rqstp->rq_res);
 
 	return error;
 }
@@ -940,9 +965,6 @@ static int
 svc_tcp_sendto(struct svc_rqst *rqstp)
 {
 	struct xdr_buf	*xbufp = &rqstp->rq_res;
-	struct iovec vec[RPCSVC_MAXPAGES];
-	int v;
-	int base, len;
 	int sent;
 	u32 reclen;
 
@@ -953,25 +975,7 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	reclen = htonl(0x80000000|((xbufp->len ) - 4));
 	memcpy(xbufp->head[0].iov_base, &reclen, 4);
 
-	vec[0] = rqstp->rq_res.head[0];
-	v=1;
-	base= xbufp->page_base;
-	len = xbufp->page_len;
-	while (len) {
-		vec[v].iov_base = page_address(xbufp->pages[v-1]) + base;
-		vec[v].iov_len = PAGE_SIZE-base;
-		if (len <= vec[v].iov_len)
-			vec[v].iov_len = len;
-		len -= vec[v].iov_len;
-		base = 0;
-		v++;
-	}
-	if (xbufp->tail[0].iov_len) {
-		vec[v] = xbufp->tail[0];
-		v++;
-	}
-
-	sent = svc_sendto(rqstp, vec, v);
+	sent = svc_sendto(rqstp, &rqstp->rq_res);
 	if (sent != xbufp->len) {
 		printk(KERN_NOTICE "rpc-srv/tcp: %s: %s %d when sending %d bytes - shutting down socket\n",
 		       rqstp->rq_sock->sk_server->sv_name,
@@ -1066,9 +1070,8 @@ svc_recv(struct svc_serv *serv, struct s
 
 	/* Initialize the buffers */
 	/* first reclaim pages that were moved to response list */
-	while (rqstp->rq_resused) 
-		rqstp->rq_argpages[rqstp->rq_arghi++] =
-			rqstp->rq_respages[--rqstp->rq_resused];
+	svc_pushback_allpages(rqstp);
+
 	/* now allocate needed pages.  If we get a failure, sleep briefly */
 	pages = 2 + (serv->sv_bufsz + PAGE_SIZE -1) / PAGE_SIZE;
 	while (rqstp->rq_arghi < pages) {
@@ -1238,6 +1241,7 @@ svc_setup_socket(struct svc_serv *serv, 
 	svsk->sk_server = serv;
 	svsk->sk_lastrecv = CURRENT_TIME;
 	INIT_LIST_HEAD(&svsk->sk_deferred);
+	sema_init(&svsk->sk_sem, 1);
 
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM)
--- ./net/sunrpc/svc.c	2002/11/06 23:12:04	1.1
+++ ./net/sunrpc/svc.c	2002/11/06 23:12:09	1.2
@@ -138,8 +138,11 @@ svc_release_buffer(struct svc_rqst *rqst
 {
 	while (rqstp->rq_arghi)
 		put_page(rqstp->rq_argpages[--rqstp->rq_arghi]);
-	while (rqstp->rq_resused)
-		put_page(rqstp->rq_respages[--rqstp->rq_resused]);
+	while (rqstp->rq_resused) {
+		if (rqstp->rq_respages[--rqstp->rq_resused] == NULL)
+			continue;
+		put_page(rqstp->rq_respages[rqstp->rq_resused]);
+	}
 	rqstp->rq_argused = 0;
 }
 
@@ -264,13 +267,14 @@ svc_process(struct svc_serv *serv, struc
 	/* setup response xdr_buf.
 	 * Initially it has just one page 
 	 */
-	take_page(rqstp); /* must succeed */
+	svc_take_page(rqstp); /* must succeed */
 	resv->iov_base = page_address(rqstp->rq_respages[0]);
 	resv->iov_len = 0;
 	rqstp->rq_res.pages = rqstp->rq_respages+1;
 	rqstp->rq_res.len = 0;
 	rqstp->rq_res.page_base = 0;
 	rqstp->rq_res.page_len = 0;
+	rqstp->rq_res.tail[0].iov_len = 0;
 	/* tcp needs a space for the record length... */
 	if (rqstp->rq_prot == IPPROTO_TCP)
 		svc_putu32(resv, 0);


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
