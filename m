From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 36/44] nfsd41: sunrpc: svc_tcp_recv_record()
Date: Tue, 16 Jun 2009 04:20:56 +0300
Message-ID: <1245115256-7990-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2592
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757566AbZFPBU4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:56 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Alexandros Batsakis <batsakis@netapp.com>

Factor functionality out of svc_tcp_recvfrom() to simplify routine

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/svcsock.c |   79 ++++++++++++++++++++++++++++++++-----------------
 1 files changed, 51 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 4e6d406..295582f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -815,28 +815,18 @@ failed:
 }
 
 /*
- * Receive data from a TCP socket.
+ * Receive data.
+ * If we haven't gotten the record length yet, get the next four bytes.
+ * Otherwise try to gobble up as much as possible up to the complete
+ * record length.
  */
-static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
+static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk =
-		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
-	int		len;
-	struct kvec *vec;
-	int pnum, vlen;
-
-	dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
-		svsk, test_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags),
-		test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags),
-		test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
+	int len;
 
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 
-	/* Receive data. If we haven't got the record length yet, get
-	 * the next four bytes. Otherwise try to gobble up as much as
-	 * possible up to the complete record length.
-	 */
 	if (svsk->sk_tcplen < sizeof(rpc_fraghdr)) {
 		int		want = sizeof(rpc_fraghdr) - svsk->sk_tcplen;
 		struct kvec	iov;
@@ -851,7 +841,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 			dprintk("svc: short recvfrom while reading record "
 				"length (%d of %d)\n", len, want);
 			svc_xprt_received(&svsk->sk_xprt);
-			return -EAGAIN; /* record header not complete */
+			goto err_again; /* record header not complete */
 		}
 
 		svsk->sk_reclen = ntohl(svsk->sk_reclen);
@@ -866,6 +856,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 					"per record not supported\n");
 			goto err_delete;
 		}
+
 		svsk->sk_reclen &= RPC_FRAGMENT_SIZE_MASK;
 		dprintk("svc: TCP record, %d bytes\n", svsk->sk_reclen);
 		if (svsk->sk_reclen > serv->sv_max_mesg) {
@@ -886,11 +877,45 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		dprintk("svc: incomplete TCP record (%d of %d)\n",
 			len, svsk->sk_reclen);
 		svc_xprt_received(&svsk->sk_xprt);
-		return -EAGAIN;	/* record not complete */
+		goto err_again;	/* record not complete */
 	}
 	len = svsk->sk_reclen;
 	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 
+	return len;
+ error:
+	if (len == -EAGAIN) {
+		dprintk("RPC: TCP recv_record got EAGAIN\n");
+		svc_xprt_received(&svsk->sk_xprt);
+	}
+	return len;
+ err_delete:
+	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
+ err_again:
+	return -EAGAIN;
+}
+
+/*
+ * Receive data from a TCP socket.
+ */
+static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
+{
+	struct svc_sock	*svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
+	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
+	int		len;
+	struct kvec *vec;
+	int pnum, vlen;
+
+	dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
+		svsk, test_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags),
+		test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags),
+		test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
+
+	len = svc_tcp_recv_record(svsk, rqstp);
+	if (len < 0)
+		goto error;
+
 	vec = rqstp->rq_vec;
 	vec[0] = rqstp->rq_arg.head[0];
 	vlen = PAGE_SIZE;
@@ -906,7 +931,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	/* Now receive data */
 	len = svc_recvfrom(rqstp, vec, pnum, len);
 	if (len < 0)
-		goto error;
+		goto err_again;
 
 	dprintk("svc: TCP complete record (%d bytes)\n", len);
 	rqstp->rq_arg.len = len;
@@ -932,21 +957,19 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	return len;
 
- err_delete:
-	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
-	return -EAGAIN;
-
- error:
+err_again:
 	if (len == -EAGAIN) {
 		dprintk("RPC: TCP recvfrom got EAGAIN\n");
 		svc_xprt_received(&svsk->sk_xprt);
-	} else {
+		return len;
+	}
+error:
+	if (len != -EAGAIN) {
 		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
 		       svsk->sk_xprt.xpt_server->sv_name, -len);
-		goto err_delete;
+		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
 	}
-
-	return len;
+	return -EAGAIN;
 }
 
 /*
-- 
1.6.3

