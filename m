Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39845 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756952Ab1DFXGd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 19:06:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/7] SUNRPC: svc_tcp_recvfrom cleanup
Date: Wed,  6 Apr 2011 19:06:21 -0400
Message-Id: <1302131186-6578-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1302131186-6578-1-git-send-email-bfields@redhat.com>
References: <1302131186-6578-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Minor cleanup in preparation for later patches.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |   34 +++++++++++++++-------------------
 1 files changed, 15 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 29b31df..828fff7 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -887,6 +887,7 @@ failed:
 static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 {
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
+	unsigned int want;
 	int len;
 
 	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
@@ -909,9 +910,9 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 
 	if (svsk->sk_tcplen < sizeof(rpc_fraghdr)) {
-		int		want = sizeof(rpc_fraghdr) - svsk->sk_tcplen;
 		struct kvec	iov;
 
+		want = sizeof(rpc_fraghdr) - svsk->sk_tcplen;
 		iov.iov_base = ((char *) &svsk->sk_reclen) + svsk->sk_tcplen;
 		iov.iov_len  = want;
 		if ((len = svc_recvfrom(rqstp, &iov, 1, want)) < 0)
@@ -1034,8 +1035,9 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int		len;
 	struct kvec *vec;
-	int pnum, vlen;
 	struct rpc_rqst *req = NULL;
+	unsigned int vlen;
+	int pnum;
 
 	dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
 		svsk, test_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags),
@@ -1066,7 +1068,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	}
 
 	pnum = 1;
-	while (vlen < len) {
+	while (vlen < svsk->sk_reclen - 8) {
 		vec[pnum].iov_base = (req) ?
 			page_address(req->rq_private_buf.pages[pnum - 1]) :
 			page_address(rqstp->rq_pages[pnum]);
@@ -1077,29 +1079,23 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_respages = &rqstp->rq_pages[pnum];
 
 	/* Now receive data */
-	len = svc_recvfrom(rqstp, vec, pnum, len);
+	len = svc_recvfrom(rqstp, vec, pnum, svsk->sk_reclen - 8);
 	if (len < 0)
 		goto err_again;
 
-	/*
-	 * Account for the 8 bytes we read earlier
-	 */
-	len += 8;
-
 	if (req) {
-		xprt_complete_rqst(req->rq_task, len);
-		len = 0;
+		xprt_complete_rqst(req->rq_task, svsk->sk_reclen);
+		rqstp->rq_arg.len = 0;
 		goto out;
 	}
-	dprintk("svc: TCP complete record (%d bytes)\n", len);
-	rqstp->rq_arg.len = len;
+	dprintk("svc: TCP complete record (%d bytes)\n", svsk->sk_reclen);
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
@@ -1117,7 +1113,7 @@ out:
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpcnt++;
 
-	return len;
+	return rqstp->rq_arg.len;
 
 err_again:
 	if (len == -EAGAIN) {
-- 
1.7.1

