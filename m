Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:34668 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbaHCRD2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:03:28 -0400
Received: by mail-qa0-f46.google.com with SMTP id v10so5905168qac.5
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:03:28 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 11/11] SUNRPC: Optimise away svc_recv_available
Date: Sun,  3 Aug 2014 13:03:13 -0400
Message-Id: <1407085393-3175-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407085393-3175-11-git-send-email-trond.myklebust@primarydata.com>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-6-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-7-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-8-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-9-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-10-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-11-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We really do not want to do ioctls in the server's fast path. Instead, let's
use the fact that we managed to read a full record as the indicator that
we should try to read the socket again.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svcsock.c | 23 ++++++-----------------
 1 file changed, 6 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 72597d7fe60a..949bb2bb8f07 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -312,19 +312,6 @@ static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 }
 
 /*
- * Check input queue length
- */
-static int svc_recv_available(struct svc_sock *svsk)
-{
-	struct socket	*sock = svsk->sk_sock;
-	int		avail, err;
-
-	err = kernel_sock_ioctl(sock, TIOCINQ, (unsigned long) &avail);
-
-	return (err >= 0)? avail : err;
-}
-
-/*
  * Generic recvfrom routine.
  */
 static int svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr,
@@ -339,8 +326,14 @@ static int svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr,
 
 	rqstp->rq_xprt_hlen = 0;
 
+	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 	len = kernel_recvmsg(svsk->sk_sock, &msg, iov, nr, buflen,
 				msg.msg_flags);
+	/* If we read a full record, then assume there may be more
+	 * data to read (stream based sockets only!)
+	 */
+	if (len == buflen)
+		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 
 	dprintk("svc: socket %p recvfrom(%p, %Zu) = %d\n",
 		svsk, iov[0].iov_base, iov[0].iov_len, len);
@@ -979,8 +972,6 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	unsigned int want;
 	int len;
 
-	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-
 	if (svsk->sk_tcplen < sizeof(rpc_fraghdr)) {
 		struct kvec	iov;
 
@@ -1072,8 +1063,6 @@ static int copy_pages_to_kvecs(struct kvec *vec, struct page **pages, int len)
 static void svc_tcp_fragment_received(struct svc_sock *svsk)
 {
 	/* If we have more data, signal svc_xprt_enqueue() to try again */
-	if (svc_recv_available(svsk) > sizeof(rpc_fraghdr))
-		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 	dprintk("svc: TCP %s record (%d bytes)\n",
 		svc_sock_final_rec(svsk) ? "final" : "nonfinal",
 		svc_sock_reclen(svsk));
-- 
1.9.3

