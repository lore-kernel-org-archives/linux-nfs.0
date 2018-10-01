Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f171.google.com ([209.85.166.171]:40293 "EHLO
        mail-it1-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729499AbeJAVUi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 17:20:38 -0400
Received: by mail-it1-f171.google.com with SMTP id i191-v6so5961278iti.5
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2018 07:42:30 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 11/15] SUNRPC: Simplify TCP receive code
Date: Mon,  1 Oct 2018 10:41:53 -0400
Message-Id: <20181001144157.3515-12-trond.myklebust@hammerspace.com>
In-Reply-To: <20181001144157.3515-11-trond.myklebust@hammerspace.com>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
 <20181001144157.3515-3-trond.myklebust@hammerspace.com>
 <20181001144157.3515-4-trond.myklebust@hammerspace.com>
 <20181001144157.3515-5-trond.myklebust@hammerspace.com>
 <20181001144157.3515-6-trond.myklebust@hammerspace.com>
 <20181001144157.3515-7-trond.myklebust@hammerspace.com>
 <20181001144157.3515-8-trond.myklebust@hammerspace.com>
 <20181001144157.3515-9-trond.myklebust@hammerspace.com>
 <20181001144157.3515-10-trond.myklebust@hammerspace.com>
 <20181001144157.3515-11-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the fact that the iov iterators already have functionality for
skipping a base offset.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/svcsock.c | 53 ++++++++++++--------------------------------
 1 file changed, 14 insertions(+), 39 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 5445145e639c..64765f08ae07 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -325,59 +325,34 @@ static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 /*
  * Generic recvfrom routine.
  */
-static int svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr,
-			int buflen)
+static ssize_t svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov,
+			    unsigned int nr, size_t buflen, unsigned int base)
 {
 	struct svc_sock *svsk =
 		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
-	struct msghdr msg = {
-		.msg_flags	= MSG_DONTWAIT,
-	};
-	int len;
+	struct msghdr msg = { NULL };
+	ssize_t len;
 
 	rqstp->rq_xprt_hlen = 0;
 
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 	iov_iter_kvec(&msg.msg_iter, READ | ITER_KVEC, iov, nr, buflen);
-	len = sock_recvmsg(svsk->sk_sock, &msg, msg.msg_flags);
+	if (base != 0) {
+		iov_iter_advance(&msg.msg_iter, base);
+		buflen -= base;
+	}
+	len = sock_recvmsg(svsk->sk_sock, &msg, MSG_DONTWAIT);
 	/* If we read a full record, then assume there may be more
 	 * data to read (stream based sockets only!)
 	 */
 	if (len == buflen)
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 
-	dprintk("svc: socket %p recvfrom(%p, %zu) = %d\n",
+	dprintk("svc: socket %p recvfrom(%p, %zu) = %zd\n",
 		svsk, iov[0].iov_base, iov[0].iov_len, len);
 	return len;
 }
 
-static int svc_partial_recvfrom(struct svc_rqst *rqstp,
-				struct kvec *iov, int nr,
-				int buflen, unsigned int base)
-{
-	size_t save_iovlen;
-	void *save_iovbase;
-	unsigned int i;
-	int ret;
-
-	if (base == 0)
-		return svc_recvfrom(rqstp, iov, nr, buflen);
-
-	for (i = 0; i < nr; i++) {
-		if (iov[i].iov_len > base)
-			break;
-		base -= iov[i].iov_len;
-	}
-	save_iovlen = iov[i].iov_len;
-	save_iovbase = iov[i].iov_base;
-	iov[i].iov_len -= base;
-	iov[i].iov_base += base;
-	ret = svc_recvfrom(rqstp, &iov[i], nr - i, buflen);
-	iov[i].iov_len = save_iovlen;
-	iov[i].iov_base = save_iovbase;
-	return ret;
-}
-
 /*
  * Set socket snd and rcv buffer lengths
  */
@@ -962,7 +937,8 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 		want = sizeof(rpc_fraghdr) - svsk->sk_tcplen;
 		iov.iov_base = ((char *) &svsk->sk_reclen) + svsk->sk_tcplen;
 		iov.iov_len  = want;
-		if ((len = svc_recvfrom(rqstp, &iov, 1, want)) < 0)
+		len = svc_recvfrom(rqstp, &iov, 1, want, 0);
+		if (len < 0)
 			goto error;
 		svsk->sk_tcplen += len;
 
@@ -1088,14 +1064,13 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	vec = rqstp->rq_vec;
 
-	pnum = copy_pages_to_kvecs(&vec[0], &rqstp->rq_pages[0],
-						svsk->sk_datalen + want);
+	pnum = copy_pages_to_kvecs(&vec[0], &rqstp->rq_pages[0], base + want);
 
 	rqstp->rq_respages = &rqstp->rq_pages[pnum];
 	rqstp->rq_next_page = rqstp->rq_respages + 1;
 
 	/* Now receive data */
-	len = svc_partial_recvfrom(rqstp, vec, pnum, want, base);
+	len = svc_recvfrom(rqstp, vec, pnum, base + want, base);
 	if (len >= 0) {
 		svsk->sk_tcplen += len;
 		svsk->sk_datalen += len;
-- 
2.17.1
