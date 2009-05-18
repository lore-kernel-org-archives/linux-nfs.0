From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/3] SUNRPC: Fix svc_tcp_recvfrom()
Date: Mon, 18 May 2009 17:47:56 -0400
Message-ID: <20090518214756.786.64058.stgit@heimdal.trondhjem.org>
References: <20090518214756.786.28129.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Moyer <jmoyer@redhat.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38684 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754183AbZERVv2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 17:51:28 -0400
In-Reply-To: <20090518214756.786.28129.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we immediately read and buffer data from the incoming TCP
stream so that we grow the receive window quickly, and don't deadlock on
large READ or WRITE requests.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/svcsock.h |    1 
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
index eed978e..7dd65b0 100644
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
@@ -1042,6 +1118,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 
 		svsk->sk_reclen = 0;
 		svsk->sk_tcplen = 0;
+		memset(&svsk->sk_pages[0], 0, sizeof(svsk->sk_pages));
 
 		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
 
@@ -1290,8 +1367,10 @@ static void svc_tcp_sock_detach(struct svc_xprt *xprt)
 
 	svc_sock_detach(xprt);
 
-	if (!test_bit(XPT_LISTENER, &xprt->xpt_flags))
+	if (!test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
+		svc_tcp_clear_pages(svsk);
 		kernel_sock_shutdown(svsk->sk_sock, SHUT_RDWR);
+	}
 }
 
 /*

