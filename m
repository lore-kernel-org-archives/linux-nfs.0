Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57635 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752277Ab2LDM6u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 07:58:50 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/5] svcrpc: support multiple-fragment rpc's
Date: Tue,  4 Dec 2012 07:58:46 -0500
Message-Id: <1354625926-18527-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1354625926-18527-1-git-send-email-bfields@redhat.com>
References: <1354625926-18527-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Over TCP, RPC's are preceded by a single 4-byte field telling you how
long the rpc is (in bytes).  The spec also allows you to send an RPC in
multiple such records (the high bit of the length field is used to tell
you whether this is the final record).

We've survived for years without supporting this because in practice the
clients we care about don't use it.  But the userland rpc libraries do,
and every now and then an experimental client will run into this.  (Most
recently I noticed it while trying to write a pynfs check.)  And we're
really on the wrong side of the spec here--let's fix this.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |   50 +++++++++++++++++++++++++-------------------------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 2b09e23..38ec968 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -949,20 +949,11 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 			return -EAGAIN;
 		}
 
-		if (!(svc_sock_final_rec(svsk))) {
-			/* FIXME: technically, a record can be fragmented,
-			 *  and non-terminal fragments will not have the top
-			 *  bit set in the fragment length header.
-			 *  But apparently no known nfs clients send fragmented
-			 *  records. */
-			net_notice_ratelimited("RPC: multiple fragments per record not supported\n");
-			goto err_delete;
-		}
-
 		dprintk("svc: TCP record, %d bytes\n", svc_sock_reclen(svsk));
-		if (svc_sock_reclen(svsk) > serv->sv_max_mesg) {
+		if (svc_sock_reclen(svsk) + svsk->sk_datalen >
+							serv->sv_max_mesg) {
 			net_notice_ratelimited("RPC: fragment too large: 0x%08lx\n",
-					(unsigned long)svc_sock_reclen(svsk));
+					       (unsigned long)svsk->sk_reclen);
 			goto err_delete;
 		}
 	}
@@ -1030,6 +1021,17 @@ static int copy_pages_to_kvecs(struct kvec *vec, struct page **pages, int len)
 	return i;
 }
 
+static void svc_tcp_fragment_received(struct svc_sock *svsk)
+{
+	/* If we have more data, signal svc_xprt_enqueue() to try again */
+	if (svc_recv_available(svsk) > sizeof(rpc_fraghdr))
+		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+	dprintk("svc: TCP %s record (%d bytes)\n",
+		svc_sock_final_rec(svsk) ? "final" : "nonfinal",
+		svc_sock_reclen(svsk));
+	svsk->sk_tcplen = 0;
+	svsk->sk_reclen = 0;
+}
 
 /*
  * Receive data from a TCP socket.
@@ -1056,12 +1058,12 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		goto error;
 
 	base = svc_tcp_restore_pages(svsk, rqstp);
-	want = svc_sock_reclen(svsk) - base;
+	want = svc_sock_reclen(svsk) - (svsk->sk_tcplen - sizeof(rpc_fraghdr));
 
 	vec = rqstp->rq_vec;
 
 	pnum = copy_pages_to_kvecs(&vec[0], &rqstp->rq_pages[0],
-						svc_sock_reclen(svsk));
+						svsk->sk_datalen + want);
 
 	rqstp->rq_respages = &rqstp->rq_pages[pnum];
 
@@ -1071,20 +1073,23 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		svsk->sk_tcplen += len;
 		svsk->sk_datalen += len;
 	}
-	if (len != want) {
+	if (len != want || !svc_sock_final_rec(svsk)) {
 		svc_tcp_save_pages(svsk, rqstp);
 		if (len < 0 && len != -EAGAIN)
 			goto err_delete;
-		dprintk("svc: incomplete TCP record (%d of %d)\n",
-			svsk->sk_tcplen - sizeof(rpc_fraghdr),
-			svc_sock_reclen(svsk));
+		if (len == want)
+			svc_tcp_fragment_received(svsk);
+		else
+			dprintk("svc: incomplete TCP record (%ld of %d)\n",
+				svsk->sk_tcplen - sizeof(rpc_fraghdr),
+				svc_sock_reclen(svsk));
 		goto err_noclose;
 	}
 
 	if (svc_sock_reclen(svsk) < 8)
 		goto err_delete; /* client is nuts. */
 
-	rqstp->rq_arg.len = svc_sock_reclen(svsk);
+	rqstp->rq_arg.len = svsk->sk_datalen;
 	rqstp->rq_arg.page_base = 0;
 	if (rqstp->rq_arg.len <= rqstp->rq_arg.head[0].iov_len) {
 		rqstp->rq_arg.head[0].iov_len = rqstp->rq_arg.len;
@@ -1101,12 +1106,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		len = receive_cb_reply(svsk, rqstp);
 
 	/* Reset TCP read info */
-	svsk->sk_reclen = 0;
-	svsk->sk_tcplen = 0;
 	svsk->sk_datalen = 0;
-	/* If we have more data, signal svc_xprt_enqueue() to try again */
-	if (svc_recv_available(svsk) > sizeof(rpc_fraghdr))
-		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+	svc_tcp_fragment_received(svsk);
 
 	if (len < 0)
 		goto error;
@@ -1115,7 +1116,6 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpcnt++;
 
-	dprintk("svc: TCP complete record (%d bytes)\n", rqstp->rq_arg.len);
 	return rqstp->rq_arg.len;
 
 error:
-- 
1.7.9.5

