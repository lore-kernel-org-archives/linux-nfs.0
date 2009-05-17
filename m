From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
 over NFS
Date: Sun, 17 May 2009 15:10:54 -0400
Message-ID: <1242587454.17796.2.camel@heimdal.trondhjem.org>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com>
	 <20090508120119.8c93cfd7.akpm@linux-foundation.org>
	 <20090511081415.GL4694@kernel.dk>
	 <x49skjb21b7.fsf@segfault.boston.devel.redhat.com>
	 <20090511165826.GG4694@kernel.dk>
	 <x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
	 <20090512204433.7eb69075.akpm@linux-foundation.org>
	 <x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com>
	 <x49k54ku7i2.fsf@segfault.boston.devel.redhat.com>
	 <1242258338.5407.244.camel@heimdal.trondhjem.org>
	 <x49octv7qr8.fsf@segfault.boston.devel.redhat.com>
	 <1242311620.6560.14.camel@heimdal.trondhjem.org>
	 <x49ws8j686r.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:60816 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752168AbZEQTLG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 May 2009 15:11:06 -0400
In-Reply-To: <x49ws8j686r.fsf-RRHT56Q3PSP4kTEheFKJxxDDeQx5vsVwAInAS/Ez/D0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-05-14 at 11:00 -0400, Jeff Moyer wrote:
> Sorry for the previous, stupid question.  I applied the patch in
> addition the last one and here are the results:
> 
> 70327
> 71561
> 68760
> 69199
> 65324
> 
> A packet capture for this run is available here:
>   http://people.redhat.com/jmoyer/trond2.pcap.bz2
> 
> Any more ideas?  ;)

Yep. I've got 2 more patches for you. With both of them applied, I'm
seeing decent performance on my own test rig. The first patch is
appended. I'll send the second in another email (to avoid attachments).

Cheers
 Trond
-----------------------------------------------------------------------
>From fcfdaf81eb21a996d83a2b68da2d62bb3697c1db Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Sun, 17 May 2009 12:40:05 -0400
Subject: [PATCH] SUNRPC: Fix svc_tcp_recvfrom()

Ensure that if the TCP receive window is smaller than the message length,
then we just buffer the existing data, in order to allow the client to send
more...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/svcsock.h |    1 +
 net/sunrpc/svcsock.c           |  167 +++++++++++++++++++++++++++++-----------
 2 files changed, 124 insertions(+), 44 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 483e103..b0b4546 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -28,6 +28,7 @@ struct svc_sock {
 	/* private TCP part */
 	u32			sk_reclen;	/* length of record */
 	u32			sk_tcplen;	/* current read length */
+	struct page *		sk_pages[RPCSVC_MAXPAGES];	/* received data */
 };
 
 /*
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index c4e7be5..6069489 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -323,6 +323,33 @@ static int svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr,
 	return len;
 }
 
+static int svc_partial_recvfrom(struct svc_rqst *rqstp,
+				struct kvec *iov, int nr,
+				int buflen, unsigned int base)
+{
+	size_t save_iovlen;
+	void __user *save_iovbase;
+	unsigned int i;
+	int ret;
+
+	if (base == 0)
+		return svc_recvfrom(rqstp, iov, nr, buflen);
+
+	for (i = 0; i < nr; i++) {
+		if (iov[i].iov_len > base)
+			break;
+		base -= iov[i].iov_len;
+	}
+	save_iovlen = iov[i].iov_len;
+	save_iovbase = iov[i].iov_base;
+	iov[i].iov_len -= base;
+	iov[i].iov_base += base;
+	ret = svc_recvfrom(rqstp, &iov[i], nr - i, buflen);
+	iov[i].iov_len = save_iovlen;
+	iov[i].iov_base = save_iovbase;
+	return ret;
+}
+
 /*
  * Set socket snd and rcv buffer lengths
  */
@@ -790,6 +817,56 @@ failed:
 	return NULL;
 }
 
+static unsigned int svc_tcp_restore_pages(struct svc_sock *svsk, struct svc_rqst *rqstp)
+{
+	unsigned int i, len, npages;
+
+	if (svsk->sk_tcplen <= sizeof(rpc_fraghdr))
+		return 0;
+	len = svsk->sk_tcplen - sizeof(rpc_fraghdr);
+	npages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	for (i = 0; i < npages; i++) {
+		if (rqstp->rq_pages[i] != NULL)
+			put_page(rqstp->rq_pages[i]);
+		BUG_ON(svsk->sk_pages[i] == NULL);
+		rqstp->rq_pages[i] = svsk->sk_pages[i];
+		svsk->sk_pages[i] = NULL;
+	}
+	rqstp->rq_arg.head[0].iov_base = page_address(rqstp->rq_pages[0]);
+	return len;
+}
+
+static void svc_tcp_save_pages(struct svc_sock *svsk, struct svc_rqst *rqstp)
+{
+	unsigned int i, len, npages;
+
+	if (svsk->sk_tcplen <= sizeof(rpc_fraghdr))
+		return;
+	len = svsk->sk_tcplen - sizeof(rpc_fraghdr);
+	npages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	for (i = 0; i < npages; i++) {
+		svsk->sk_pages[i] = rqstp->rq_pages[i];
+		rqstp->rq_pages[i] = NULL;
+	}
+}
+
+static void svc_tcp_clear_pages(struct svc_sock *svsk)
+{
+	unsigned int i, len, npages;
+
+	if (svsk->sk_tcplen <= sizeof(rpc_fraghdr))
+		goto out;
+	len = svsk->sk_tcplen - sizeof(rpc_fraghdr);
+	npages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	for (i = 0; i < npages; i++) {
+		BUG_ON(svsk->sk_pages[i] == NULL);
+		put_page(svsk->sk_pages[i]);
+		svsk->sk_pages[i] = NULL;
+	}
+out:
+	svsk->sk_tcplen = 0;
+}
+
 /*
  * Receive data from a TCP socket.
  */
@@ -800,7 +877,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int		len;
 	struct kvec *vec;
-	int pnum, vlen;
+	unsigned int want, base, vlen;
+	int pnum;
 
 	dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
 		svsk, test_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags),
@@ -814,9 +892,9 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	 * possible up to the complete record length.
 	 */
 	if (svsk->sk_tcplen < sizeof(rpc_fraghdr)) {
-		int		want = sizeof(rpc_fraghdr) - svsk->sk_tcplen;
 		struct kvec	iov;
 
+		want = sizeof(rpc_fraghdr) - svsk->sk_tcplen;
 		iov.iov_base = ((char *) &svsk->sk_reclen) + svsk->sk_tcplen;
 		iov.iov_len  = want;
 		if ((len = svc_recvfrom(rqstp, &iov, 1, want)) < 0)
@@ -826,8 +904,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		if (len < want) {
 			dprintk("svc: short recvfrom while reading record "
 				"length (%d of %d)\n", len, want);
-			svc_xprt_received(&svsk->sk_xprt);
-			return -EAGAIN; /* record header not complete */
+			goto err_noclose;
 		}
 
 		svsk->sk_reclen = ntohl(svsk->sk_reclen);
@@ -853,25 +930,14 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		}
 	}
 
-	/* Check whether enough data is available */
-	len = svc_recv_available(svsk);
-	if (len < 0)
-		goto error;
-
-	if (len < svsk->sk_reclen) {
-		dprintk("svc: incomplete TCP record (%d of %d)\n",
-			len, svsk->sk_reclen);
-		svc_xprt_received(&svsk->sk_xprt);
-		return -EAGAIN;	/* record not complete */
-	}
-	len = svsk->sk_reclen;
-	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+	base = svc_tcp_restore_pages(svsk, rqstp);
+	want = svsk->sk_reclen - base;
 
 	vec = rqstp->rq_vec;
 	vec[0] = rqstp->rq_arg.head[0];
 	vlen = PAGE_SIZE;
 	pnum = 1;
-	while (vlen < len) {
+	while (vlen < svsk->sk_reclen) {
 		vec[pnum].iov_base = page_address(rqstp->rq_pages[pnum]);
 		vec[pnum].iov_len = PAGE_SIZE;
 		pnum++;
@@ -880,19 +946,26 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_respages = &rqstp->rq_pages[pnum];
 
 	/* Now receive data */
-	len = svc_recvfrom(rqstp, vec, pnum, len);
-	if (len < 0)
-		goto error;
+	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+	len = svc_partial_recvfrom(rqstp, vec, pnum, want, base);
+	if (len != want) {
+		if (len >= 0)
+			svsk->sk_tcplen += len;
+		else if (len != -EAGAIN)
+			goto err_other;
+		svc_tcp_save_pages(svsk, rqstp);
+		dprintk("svc: incomplete TCP record (%d of %d)\n",
+			svsk->sk_tcplen, svsk->sk_reclen);
+		goto err_noclose;
+	}
 
-	dprintk("svc: TCP complete record (%d bytes)\n", len);
-	rqstp->rq_arg.len = len;
+	rqstp->rq_arg.len = svsk->sk_reclen;
 	rqstp->rq_arg.page_base = 0;
-	if (len <= rqstp->rq_arg.head[0].iov_len) {
-		rqstp->rq_arg.head[0].iov_len = len;
+	if (rqstp->rq_arg.len <= rqstp->rq_arg.head[0].iov_len) {
+		rqstp->rq_arg.head[0].iov_len = rqstp->rq_arg.len;
 		rqstp->rq_arg.page_len = 0;
-	} else {
-		rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
-	}
+	} else
+		rqstp->rq_arg.page_len = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
 
 	rqstp->rq_xprt_ctxt   = NULL;
 	rqstp->rq_prot	      = IPPROTO_TCP;
@@ -900,29 +973,32 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	/* Reset TCP read info */
 	svsk->sk_reclen = 0;
 	svsk->sk_tcplen = 0;
+	/* If we have more data, signal svc_xprt_enqueue() to try again */
+	if (svc_recv_available(svsk) > sizeof(rpc_fraghdr))
+		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+
 
 	svc_xprt_copy_addrs(rqstp, &svsk->sk_xprt);
 	svc_xprt_received(&svsk->sk_xprt);
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpcnt++;
 
-	return len;
-
- err_delete:
+	dprintk("svc: TCP complete record (%d bytes)\n", rqstp->rq_arg.len);
+	return rqstp->rq_arg.len;
+error:
+	if (len == -EAGAIN)
+		goto err_got_eagain;
+err_other:
+	printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
+	       svsk->sk_xprt.xpt_server->sv_name, -len);
+err_delete:
 	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
 	return -EAGAIN;
-
- error:
-	if (len == -EAGAIN) {
-		dprintk("RPC: TCP recvfrom got EAGAIN\n");
-		svc_xprt_received(&svsk->sk_xprt);
-	} else {
-		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
-		       svsk->sk_xprt.xpt_server->sv_name, -len);
-		goto err_delete;
-	}
-
-	return len;
+err_got_eagain:
+	dprintk("RPC: TCP recvfrom got EAGAIN\n");
+err_noclose:
+	svc_xprt_received(&svsk->sk_xprt);
+	return -EAGAIN;	/* record not complete */
 }
 
 /*
@@ -1043,6 +1119,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 
 		svsk->sk_reclen = 0;
 		svsk->sk_tcplen = 0;
+		memset(&svsk->sk_pages[0], 0, sizeof(svsk->sk_pages));
 
 		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
 
@@ -1291,8 +1368,10 @@ static void svc_tcp_sock_detach(struct svc_xprt *xprt)
 
 	svc_sock_detach(xprt);
 
-	if (!test_bit(XPT_LISTENER, &xprt->xpt_flags))
+	if (!test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
+		svc_tcp_clear_pages(svsk);
 		kernel_sock_shutdown(svsk->sk_sock, SHUT_RDWR);
+	}
 }
 
 /*
-- 
1.6.0.4



