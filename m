Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39847 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756966Ab1DFXGd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 19:06:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 6/7] SUNRPC: Don't wait for full record to receive tcp data
Date: Wed,  6 Apr 2011 19:06:25 -0400
Message-Id: <1302131186-6578-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1302131186-6578-1-git-send-email-bfields@redhat.com>
References: <1302131186-6578-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Ensure that we immediately read and buffer data from the incoming TCP
stream so that we grow the receive window quickly, and don't deadlock on
large READ or WRITE requests.

Also do some minor exit cleanup.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/svcsock.h |    1 +
 net/sunrpc/svcsock.c           |  144 +++++++++++++++++++++++++++++++---------
 2 files changed, 113 insertions(+), 32 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 04dba23..85c50b4 100644
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
index f248bd4..fdb8ea5 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -387,6 +387,33 @@ static int svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr,
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
@@ -878,6 +905,56 @@ failed:
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
  * Receive data.
  * If we haven't gotten the record length yet, get the next four bytes.
@@ -922,7 +999,7 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 		if (len < want) {
 			dprintk("svc: short recvfrom while reading record "
 				"length (%d of %d)\n", len, want);
-			goto err_again; /* record header not complete */
+			return -EAGAIN;
 		}
 
 		svsk->sk_reclen = ntohl(svsk->sk_reclen);
@@ -952,26 +1029,14 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	if (svsk->sk_reclen < 8)
 		goto err_delete; /* client is nuts. */
 
-	/* Check whether enough data is available */
-	len = svc_recv_available(svsk);
-	if (len < 0)
-		goto error;
-
-	if (len < svsk->sk_reclen) {
-		dprintk("svc: incomplete TCP record (%d of %d)\n",
-			len, svsk->sk_reclen);
-		goto err_again;	/* record not complete */
-	}
 	len = svsk->sk_reclen;
 
 	return len;
- error:
-	if (len == -EAGAIN)
-		dprintk("RPC: TCP recv_record got EAGAIN\n");
+error:
+	dprintk("RPC: TCP recv_record got %d\n", len);
 	return len;
- err_delete:
+err_delete:
 	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
- err_again:
 	return -EAGAIN;
 }
 
@@ -1029,6 +1094,7 @@ static int copy_pages_to_kvecs(struct kvec *vec, struct page **pages, int len)
 	return i;
 }
 
+
 /*
  * Receive data from a TCP socket.
  */
@@ -1039,6 +1105,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int		len;
 	struct kvec *vec;
+	unsigned int want, base;
 	__be32 *p;
 	__be32 calldir;
 	int pnum;
@@ -1052,6 +1119,9 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	if (len < 0)
 		goto error;
 
+	base = svc_tcp_restore_pages(svsk, rqstp);
+	want = svsk->sk_reclen - base;
+
 	vec = rqstp->rq_vec;
 
 	pnum = copy_pages_to_kvecs(&vec[0], &rqstp->rq_pages[0],
@@ -1060,11 +1130,18 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_respages = &rqstp->rq_pages[pnum];
 
 	/* Now receive data */
-	len = svc_recvfrom(rqstp, vec, pnum, svsk->sk_reclen);
-	if (len < 0)
-		goto err_again;
+	len = svc_partial_recvfrom(rqstp, vec, pnum, want, base);
+	if (len >= 0)
+		svsk->sk_tcplen += len;
+	if (len != want) {
+		if (len < 0 && len != -EAGAIN)
+			goto err_other;
+		svc_tcp_save_pages(svsk, rqstp);
+		dprintk("svc: incomplete TCP record (%d of %d)\n",
+			svsk->sk_tcplen, svsk->sk_reclen);
+		goto err_noclose;
+	}
 
-	dprintk("svc: TCP complete record (%d bytes)\n", svsk->sk_reclen);
 	rqstp->rq_arg.len = svsk->sk_reclen;
 	rqstp->rq_arg.page_base = 0;
 	if (rqstp->rq_arg.len <= rqstp->rq_arg.head[0].iov_len) {
@@ -1081,7 +1158,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	if (calldir) {
 		len = receive_cb_reply(svsk, rqstp);
 		if (len < 0)
-			goto err_again;
+			goto error;
 	}
 
 	/* Reset TCP read info */
@@ -1096,20 +1173,20 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpcnt++;
 
+	dprintk("svc: TCP complete record (%d bytes)\n", rqstp->rq_arg.len);
 	return rqstp->rq_arg.len;
 
-err_again:
-	if (len == -EAGAIN) {
-		dprintk("RPC: TCP recvfrom got EAGAIN\n");
-		return len;
-	}
 error:
-	if (len != -EAGAIN) {
-		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
-		       svsk->sk_xprt.xpt_server->sv_name, -len);
-		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
-	}
+	if (len != -EAGAIN)
+		goto err_other;
+	dprintk("RPC: TCP recvfrom got EAGAIN\n");
 	return -EAGAIN;
+err_other:
+	printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
+	       svsk->sk_xprt.xpt_server->sv_name, -len);
+	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
+err_noclose:
+	return -EAGAIN;	/* record not complete */
 }
 
 /*
@@ -1280,6 +1357,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 
 		svsk->sk_reclen = 0;
 		svsk->sk_tcplen = 0;
+		memset(&svsk->sk_pages[0], 0, sizeof(svsk->sk_pages));
 
 		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
 
@@ -1536,8 +1614,10 @@ static void svc_tcp_sock_detach(struct svc_xprt *xprt)
 
 	svc_sock_detach(xprt);
 
-	if (!test_bit(XPT_LISTENER, &xprt->xpt_flags))
+	if (!test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
+		svc_tcp_clear_pages(svsk);
 		kernel_sock_shutdown(svsk->sk_sock, SHUT_RDWR);
+	}
 }
 
 /*
-- 
1.7.1

