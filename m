Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3300D394788;
	Mon, 20 Jul 2026 14:28:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784557704; cv=none; b=XfVUxSD/UR9tv5c3bO6N6cMA+ROcZp02M8RcyPvg1az/lXKXuks30j5hyDNA6VdFFu1Kqict/gCwRrgX4lUQ9AkpTIuE8URYd3lnV+TwKZicBmNUYpVSWHTv3PZeYdvvmE2w5OkFt68panfPH3lw1BX1wYjlLVpzSSAK2lkZuAU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784557704; c=relaxed/simple;
	bh=y7blQxkOzOWi5vaxyZ4CuU2IFDI/zeF7u+8IgBq6DEk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=mWU7i8VJTQm2sm9vkoLECJSYPHZVPRLYdcfsm+xdumhHLCUVhR6NZJD05hIy3WJeErIT6AacQAQAQnOKNf4Ho6vviBhMEb2HZbUPIdYS0I/UFx18pZTbPVokS75n9lkVESMpnK8QK6A/AP4D12K2sU3olujfM836sxyoMdZEnvI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OsD5R1Ih; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OsD5R1Ih"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CCB961F00A3F;
	Mon, 20 Jul 2026 14:28:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784557701;
	bh=ZUll3jnGSgipZjKVxfUv9xorYxfehS/iAgUj5peDy4U=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OsD5R1Ih4IjSCKBJAJUvfD11kvZEO80PLdFgHMQbsUHHApSusSwDhImPLxLjoqEH0
	 tcRuuyfSezorJIojz6cnBKQoCvkc7fKn6pt9qZFVCvmPQomCyfGeMNm3WUnkBdHdLA
	 i7vpv28OXqXJ3mKFPkH9nV2RPay2bB6WM49g0JaZ6sh3LvZSaxvRuZyq0GhGm1bU6n
	 2/ltdODBQXtDK0AJ0Wzs8Rbmwxlo9Jdvd0icdPtvhCxAdKbxz7BHUo/63sBb/n4n+2
	 7AVeL+ubo2ejAb7uYD0Z/z1+kE7T2nMuPdv+0VJ8Ok6x/vwAFde7hvmksJkiu6bzww
	 ZLUtAcGgX5Uqw==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 20 Jul 2026 10:28:00 -0400
Subject: [PATCH net-next v2 6/6] SUNRPC: Remove sock_recvmsg path from
 svcsock TCP receives
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260720-tcp-read-sock-v2-6-29545d034f3c@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
In-Reply-To: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
To: Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Shuah Khan <shuah@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Chuck Lever <cel@kernel.org>
Cc: netdev@vger.kernel.org, kernel-tls-handshake@lists.linux.dev, 
 linux-kselftest@vger.kernel.org, linux-nfs@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=12379; i=cel@kernel.org;
 h=from:subject:message-id; bh=PiaU+SG10i7PDtuGegF6hDaBEjEBXVRKw2VdAbTPiuQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqXjB8YYx+hwYyiMr0Lqa+tuxHxlCpPyKvtW2p/
 9tQTKav5qyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCal4wfAAKCRAzarMzb2Z/
 l8RLD/9kDM2Owfi60zBcGwksHaPOJ+HS1+ektN/o9C+uIcZlWy1TadZiG6C1qCQypFKDODrFhWN
 /hFEyRtw2UVTEK7fYyaj8geXKJf+FVwFWgYAB2jeBnUKe2f5LKiJFYHe5NHG9Xisv1c2jDtgmcO
 SoD/TfrbbN1C5VyT71vaGZ8EeaxLzPtlWG7BgJCZSVnmmtMeXe2HKwc5U2q9lLGjM2YAs+pgT3k
 2HggBFn27+yPoR9laJREpzvtRNSDdhIp7iDBj/cW5hSpD7QNiCyA/V8KzVKL4IDknBz6yTrX9hQ
 x36V6gFrisHvwjlOi9ilihj2akzQ+bqoLQ1o++FDjWmBxs/RUUBxnUzo5kvwUB8j/mrynojv61p
 NEQyGZMROEikCp5MnHjqjxYILsHkzLd8Xj+lHe60NmxYD/3ClWhRBWxC31THW/vBrEf2VREshfX
 JHBPA5ixRB+mH5FNn5KVa+aq6BFPyIAG+4zrtHSarMdEZRtlrpKu8Xc8G8F3UZbR8EOjlpF+GWF
 mjqIZIfmzcKlPiMjnKxhHXfGZGhE5/ytkITyZ8nqiJRKpx/hwewnSd32lUNZBY7z1NYisOd34uL
 AFUDAggd60HD1vnT8QwGwLaDBbC54eg1+PkrOy7FW6hhIiS6QyGK1UvG9IYUrH1B+K/LIMY4Db2
 qnxi6iOwiThePnA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

The svcsock TCP receive path maintains two code paths: one
using read_sock/read_sock_rectype and a legacy path using
sock_recvmsg. Plain TCP sockets already provide read_sock
(tcp_read_sock) in their proto_ops, so a single
read_sock-based receive path handles all cases relevant to
NFSD, using read_sock_rectype under kTLS and read_sock
otherwise.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svcsock.c | 329 ++++-----------------------------------------------
 1 file changed, 26 insertions(+), 303 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index e40931d11491..9b9e0da9e73c 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -8,15 +8,6 @@
  * evenly when servicing a single client. May need to modify the
  * svc_xprt_enqueue procedure...
  *
- * TCP support is largely untested and may be a little slow. The problem
- * is that we currently do two separate recvfrom's, one for the 4-byte
- * record length, and the second for the actual record. This could possibly
- * be improved by always reading a minimum size of around 100 bytes and
- * tucking any superfluous bytes away in a temporary store. Still, that
- * leaves write requests out in the rain. An alternative may be to peek at
- * the first skb in the queue, and if it matches the next TCP sequence
- * number, to extract the record marker. Yuck.
- *
  * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
  */
 
@@ -238,138 +229,6 @@ static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 	return len;
 }
 
-static int
-svc_tcp_sock_process_cmsg(struct socket *sock, struct msghdr *msg,
-			  struct cmsghdr *cmsg, int ret)
-{
-	u8 content_type = tls_get_record_type(sock->sk, cmsg);
-	u8 level, description;
-
-	switch (content_type) {
-	case 0:
-		break;
-	case TLS_RECORD_TYPE_DATA:
-		/* TLS sets EOR at the end of each application data
-		 * record, even though there might be more frames
-		 * waiting to be decrypted.
-		 */
-		msg->msg_flags &= ~MSG_EOR;
-		break;
-	case TLS_RECORD_TYPE_ALERT:
-		tls_alert_recv(sock->sk, msg, &level, &description);
-		ret = (level == TLS_ALERT_LEVEL_FATAL) ?
-			-ENOTCONN : -EAGAIN;
-		break;
-	default:
-		/* discard this record type */
-		ret = -EAGAIN;
-	}
-	return ret;
-}
-
-static int
-svc_tcp_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags)
-{
-	union {
-		struct cmsghdr	cmsg;
-		u8		buf[CMSG_SPACE(sizeof(u8))];
-	} u;
-	u8 alert[2];
-	struct kvec alert_kvec = {
-		.iov_base = alert,
-		.iov_len = sizeof(alert),
-	};
-	struct msghdr msg = {
-		.msg_flags = *msg_flags,
-		.msg_control = &u,
-		.msg_controllen = sizeof(u),
-	};
-	int ret;
-
-	iov_iter_kvec(&msg.msg_iter, ITER_DEST, &alert_kvec, 1,
-		      alert_kvec.iov_len);
-	ret = sock_recvmsg(sock, &msg, MSG_DONTWAIT);
-	if (ret > 0 &&
-	    tls_get_record_type(sock->sk, &u.cmsg) == TLS_RECORD_TYPE_ALERT) {
-		iov_iter_revert(&msg.msg_iter, ret);
-		ret = svc_tcp_sock_process_cmsg(sock, &msg, &u.cmsg, -EAGAIN);
-	}
-	return ret;
-}
-
-static int
-svc_tcp_sock_recvmsg(struct svc_sock *svsk, struct msghdr *msg)
-{
-	int ret;
-	struct socket *sock = svsk->sk_sock;
-
-	ret = sock_recvmsg(sock, msg, MSG_DONTWAIT);
-	if (msg->msg_flags & MSG_CTRUNC) {
-		msg->msg_flags &= ~(MSG_CTRUNC | MSG_EOR);
-		if (ret == 0 || ret == -EIO)
-			ret = svc_tcp_sock_recv_cmsg(sock, &msg->msg_flags);
-	}
-	return ret;
-}
-
-#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE
-static void svc_flush_bvec(const struct bio_vec *bvec, size_t size, size_t seek)
-{
-	struct bvec_iter bi = {
-		.bi_size	= size + seek,
-	};
-	struct bio_vec bv;
-
-	bvec_iter_advance(bvec, &bi, seek & PAGE_MASK);
-	for_each_bvec(bv, bvec, bi, bi)
-		flush_dcache_page(bv.bv_page);
-}
-#else
-static inline void svc_flush_bvec(const struct bio_vec *bvec, size_t size,
-				  size_t seek)
-{
-}
-#endif
-
-/*
- * Read from @rqstp's transport socket. The incoming message fills whole
- * pages in @rqstp's rq_pages array until the last page of the message
- * has been received into a partial page.
- */
-static ssize_t svc_tcp_read_msg(struct svc_rqst *rqstp, size_t buflen,
-				size_t seek)
-{
-	struct svc_sock *svsk =
-		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
-	struct bio_vec *bvec = rqstp->rq_bvec;
-	struct msghdr msg = { NULL };
-	unsigned int i;
-	ssize_t len;
-	size_t t;
-
-	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-
-	for (i = 0, t = 0; t < buflen; i++, t += PAGE_SIZE)
-		bvec_set_page(&bvec[i], rqstp->rq_pages[i], PAGE_SIZE, 0);
-
-	iov_iter_bvec(&msg.msg_iter, ITER_DEST, bvec, i, buflen);
-	if (seek) {
-		iov_iter_advance(&msg.msg_iter, seek);
-		buflen -= seek;
-	}
-	len = svc_tcp_sock_recvmsg(svsk, &msg);
-	if (len > 0)
-		svc_flush_bvec(bvec, len, seek);
-
-	/* If we read a full record, then assume there may be more
-	 * data to read (stream based sockets only!)
-	 */
-	if (len == buflen)
-		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-
-	return len;
-}
-
 /*
  * Set socket snd and rcv buffer lengths
  */
@@ -1048,50 +907,6 @@ static void svc_tcp_clear_pages(struct svc_sock *svsk)
 	svsk->sk_datalen = 0;
 }
 
-/*
- * Receive fragment record header into sk_marker.
- */
-static ssize_t svc_tcp_read_marker(struct svc_sock *svsk,
-				   struct svc_rqst *rqstp)
-{
-	ssize_t want, len;
-
-	/* If we haven't gotten the record length yet,
-	 * get the next four bytes.
-	 */
-	if (svsk->sk_tcplen < sizeof(rpc_fraghdr)) {
-		struct msghdr	msg = { NULL };
-		struct kvec	iov;
-
-		want = sizeof(rpc_fraghdr) - svsk->sk_tcplen;
-		iov.iov_base = ((char *)&svsk->sk_marker) + svsk->sk_tcplen;
-		iov.iov_len  = want;
-		iov_iter_kvec(&msg.msg_iter, ITER_DEST, &iov, 1, want);
-		len = svc_tcp_sock_recvmsg(svsk, &msg);
-		if (len < 0)
-			return len;
-		svsk->sk_tcplen += len;
-		if (len < want) {
-			/* call again to read the remaining bytes */
-			goto err_short;
-		}
-		trace_svcsock_marker(&svsk->sk_xprt, svsk->sk_marker);
-		if (svc_sock_reclen(svsk) + svsk->sk_datalen >
-		    svsk->sk_xprt.xpt_server->sv_max_mesg)
-			goto err_too_large;
-	}
-	return svc_sock_reclen(svsk);
-
-err_too_large:
-	net_notice_ratelimited("svc: %s oversized RPC fragment (%u octets) from %pISpc\n",
-			       svsk->sk_xprt.xpt_server->sv_name,
-			       svc_sock_reclen(svsk),
-			       (struct sockaddr *)&svsk->sk_xprt.xpt_remote);
-	svc_xprt_deferred_close(&svsk->sk_xprt);
-err_short:
-	return -EAGAIN;
-}
-
 static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
 {
 	struct rpc_xprt *bc_xprt = svsk->sk_xprt.xpt_bc_xprt;
@@ -1135,10 +950,10 @@ static void svc_tcp_fragment_received(struct svc_sock *svsk)
 }
 
 /*
- * read_sock_rectype data actor: receives decrypted application data
- * from the TLS layer, parsing the RPC record stream (fragment
- * headers and message bodies) and assembling complete RPC messages
- * into rqstp->rq_pages.
+ * read_sock data actor: receives application data from the
+ * transport socket, parsing the RPC record stream (fragment
+ * headers and message bodies) and assembling complete RPC
+ * messages into rqstp->rq_pages.
  */
 static int svc_tcp_recv_actor(read_descriptor_t *desc,
 			      struct sk_buff *skb,
@@ -1266,7 +1081,21 @@ static int svc_tcp_rectype_actor(read_descriptor_t *desc,
 	return 0;
 }
 
-static int svc_tcp_recvfrom_readsock(struct svc_rqst *rqstp)
+/**
+ * svc_tcp_recvfrom - Receive data from a TCP socket
+ * @rqstp: request structure into which to receive an RPC Call
+ *
+ * Called in a loop when XPT_DATA has been set.
+ *
+ * Returns:
+ *   On success, the number of bytes in a received RPC Call, or
+ *   %0 if a complete RPC Call message was not ready to return
+ *
+ * The zero return case handles partial receives and callback Replies.
+ * The state of a partial receive is preserved in the svc_sock for
+ * the next call to svc_tcp_recvfrom.
+ */
+static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk =
 		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
@@ -1286,9 +1115,13 @@ static int svc_tcp_recvfrom_readsock(struct svc_rqst *rqstp)
 
 	desc.count = serv->sv_max_mesg;
 	lock_sock(sk);
-	len = svsk->sk_sock->ops->read_sock_rectype(sk, &desc,
-						    svc_tcp_recv_actor,
-						    svc_tcp_rectype_actor);
+	if (svsk->sk_sock->ops->read_sock_rectype)
+		len = svsk->sk_sock->ops->read_sock_rectype(sk, &desc,
+							    svc_tcp_recv_actor,
+							    svc_tcp_rectype_actor);
+	else
+		len = svsk->sk_sock->ops->read_sock(sk, &desc,
+						     svc_tcp_recv_actor);
 	release_sock(sk);
 
 	if (desc.error < 0) {
@@ -1375,116 +1208,6 @@ static int svc_tcp_recvfrom_readsock(struct svc_rqst *rqstp)
 	return 0;
 }
 
-/**
- * svc_tcp_recvfrom - Receive data from a TCP socket
- * @rqstp: request structure into which to receive an RPC Call
- *
- * Called in a loop when XPT_DATA has been set.
- *
- * Read the 4-byte stream record marker, then use the record length
- * in that marker to set up exactly the resources needed to receive
- * the next RPC message into @rqstp.
- *
- * Returns:
- *   On success, the number of bytes in a received RPC Call, or
- *   %0 if a complete RPC Call message was not ready to return
- *
- * The zero return case handles partial receives and callback Replies.
- * The state of a partial receive is preserved in the svc_sock for
- * the next call to svc_tcp_recvfrom.
- */
-static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
-{
-	struct svc_sock	*svsk =
-		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
-	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
-	size_t want, base;
-	ssize_t len;
-	__be32 *p;
-	__be32 calldir;
-
-	if (svsk->sk_sock->ops->read_sock_rectype)
-		return svc_tcp_recvfrom_readsock(rqstp);
-
-	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-	len = svc_tcp_read_marker(svsk, rqstp);
-	if (len < 0)
-		goto error;
-
-	base = svc_tcp_restore_pages(svsk, rqstp);
-	want = len - (svsk->sk_tcplen - sizeof(rpc_fraghdr));
-	len = svc_tcp_read_msg(rqstp, base + want, base);
-	if (len >= 0) {
-		trace_svcsock_tcp_recv(&svsk->sk_xprt, len);
-		svsk->sk_tcplen += len;
-		svsk->sk_datalen += len;
-	}
-	if (len != want || !svc_sock_final_rec(svsk))
-		goto err_incomplete;
-	if (svsk->sk_datalen < 8)
-		goto err_nuts;
-
-	rqstp->rq_arg.len = svsk->sk_datalen;
-	rqstp->rq_arg.page_base = 0;
-	if (rqstp->rq_arg.len <= rqstp->rq_arg.head[0].iov_len) {
-		rqstp->rq_arg.head[0].iov_len = rqstp->rq_arg.len;
-		rqstp->rq_arg.page_len = 0;
-	} else
-		rqstp->rq_arg.page_len = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
-
-	rqstp->rq_xprt_ctxt   = NULL;
-	rqstp->rq_prot	      = IPPROTO_TCP;
-	if (test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags))
-		set_bit(RQ_LOCAL, &rqstp->rq_flags);
-	else
-		clear_bit(RQ_LOCAL, &rqstp->rq_flags);
-
-	p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
-	calldir = p[1];
-	if (calldir)
-		len = receive_cb_reply(svsk, rqstp);
-
-	/* Reset TCP read info */
-	svsk->sk_datalen = 0;
-	svc_tcp_fragment_received(svsk);
-
-	if (len < 0)
-		goto error;
-
-	svc_xprt_copy_addrs(rqstp, &svsk->sk_xprt);
-	if (serv->sv_stats)
-		serv->sv_stats->nettcpcnt++;
-
-	svc_sock_secure_port(rqstp);
-	svc_xprt_received(rqstp->rq_xprt);
-	return rqstp->rq_arg.len;
-
-err_incomplete:
-	svc_tcp_save_pages(svsk, rqstp);
-	if (len < 0 && len != -EAGAIN)
-		goto err_delete;
-	if (len == want)
-		svc_tcp_fragment_received(svsk);
-	else
-		trace_svcsock_tcp_recv_short(&svsk->sk_xprt,
-				svc_sock_reclen(svsk),
-				svsk->sk_tcplen - sizeof(rpc_fraghdr));
-	goto err_noclose;
-error:
-	if (len != -EAGAIN)
-		goto err_delete;
-	trace_svcsock_tcp_recv_eagain(&svsk->sk_xprt, 0);
-	goto err_noclose;
-err_nuts:
-	svsk->sk_datalen = 0;
-err_delete:
-	trace_svcsock_tcp_recv_err(&svsk->sk_xprt, len);
-	svc_xprt_deferred_close(&svsk->sk_xprt);
-err_noclose:
-	svc_xprt_received(rqstp->rq_xprt);
-	return 0;	/* record not complete */
-}
-
 /*
  * MSG_SPLICE_PAGES is used exclusively to reduce the number of
  * copy operations in this path. Therefore the caller must ensure

-- 
2.54.0

