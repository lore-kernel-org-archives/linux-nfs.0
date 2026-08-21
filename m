Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60A1F38238F;
	Fri, 21 Aug 2026 17:22:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787332980; cv=none; b=L48ZcAHOhxSuexTrS7Sh2kOegr4zTgZt9EE0D2rcZ7WenOZzfXqev6grwQ0nK+l7mycOwBQt+rmm71MbvKRtNT5HWJywBQEw6lVGCV8+HMbQy2ARnX/3+n/ONdlQwzLTxXPwtI9DVEANpjDj2Px9i3H4dvjwDlgKs68j7fX1VdM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787332980; c=relaxed/simple;
	bh=nPMmEWeScS5U4N06w4d9AHk9woEaVPFvnGSxYgZ5XBM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=UvLAkpKWrWd0PLH78LkTUolL7yLviTOF1VV5S21AlE1p9yLKaKabRT813KXo3hxcFpt1vwBMJII42Sq3vbvVqO5T+dIiEIc3kgCgfHaVtFegOaFiLq82VZy20mQKZwIpWU2M+tWq3eJK9Daq2NSdxlnDLY/YfCjzUP/QV09Vss4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=a6skd8HJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="a6skd8HJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 33EC41F00A3D;
	Fri, 21 Aug 2026 17:22:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787332978;
	bh=VzM9s8lQA7fFZuESIB64dl6cN5m2iOXATnm7NAHWtLo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=a6skd8HJO3gNN3bElKkxftE8rDWdI1pHpungKjKwicNQ2YFvJN9TdREZGt1iEeeds
	 LLpD5syxRTQu9s/PM2QYVJPrVBxA+4D8FPZC5C82EfcPFrRl/DQEptoBaJniOIPYk3
	 p6PFSYERaGMhwQ7wMZ+uGAaKgwjjzWGH0dr4Whlz8etbcJu/bloT596QKCa+fGRhCT
	 8eDOeyEhp0w5yMMTqiNCpYMBeL85MJeIgv6hjyBoY0/RbYbW1a8FIvALclFdXQF4Sm
	 rdn/+MPyQRdXNZvEvzFlTjYOxeyPoIUGwf8yBHTgGFhfc6W1GGtRKDrxWYm9JJUizE
	 jgru3+F4VhnHQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 21 Aug 2026 13:22:42 -0400
Subject: [PATCH 4/5] SUNRPC: Receive RPC records with ->read_sock
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260821-tls-read-sock-2-v1-4-7ffce164eb45@kernel.org>
References: <20260821-tls-read-sock-2-v1-0-7ffce164eb45@kernel.org>
In-Reply-To: <20260821-tls-read-sock-2-v1-0-7ffce164eb45@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=19179; i=cel@kernel.org;
 h=from:subject:message-id; bh=nPMmEWeScS5U4N06w4d9AHk9woEaVPFvnGSxYgZ5XBM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqiIlrREfjmnN2S8VTPZmzbW5xmmmu+TnveHZCc
 +II7xXZhOaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoiJawAKCRAzarMzb2Z/
 l3YAD/0TnREFBl+fakMP3tAR3pGOFOyNTvl6VYqjcy2VuL8xwL2BPmi8yNlHujVCDKwROp7XFjg
 dEPReD3X15LHntY79+iNtfGCLLBObtRUsJp4tFNFLdODCcd9/A5DH35y5+2n0fwlF9dtx6Ft9pG
 N06Ej/A5RT+CFBuDom9/FqDeUDxtKH+EsCh/3QygbE/BjOVEg1Fnqq6D7JM8vCtp4UNyVnT9z4B
 WkFmtBS5zdeVOowq/ZzhQVnE8oRXsE3IpDB1P+bym5K7cKA39Q8laObLX+vpOvn+KPN+YmqwHkD
 TVu1MkBMrPlESIVQDNX0VENVJd5n55E9y/oorlxs0tPko0m21Pcx5yUuAagw+3+7sLELWuGgarA
 e1PLywNs+prlUOCAnXC7KK76NnE/YtUubMAeLj2wvBlS75oofwaKJtHeF3lcp0onsFLVLpRA/78
 Hew7aqrvdm/8KPAHBkLCySPGZEsVPlE8+D0F5mMOgtFZw+s2ZJ/eydGpOszVjbl5gTe0bjMRvED
 nQ8gZIu4Vx0KxiZYU6w97FBbiXthk2wzwZNcDDpgNB+ZhjLPJaI1E8l6aUq09fqO212d/PmELXi
 llvOO5rrkv4TFxYMB37nUFSs4Po/AtLBJzlW2NQyJn/BrB87f/GfUCyOQKvWatZjJn2x7fdUlOC
 sMDJphuQGzfmYkw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_recvfrom() reads an RPC record with two recvmsg() calls, one
for the four-octet fragment marker and one for the body. Neither
supplies a control-message buffer, so kTLS reports a TLS control
record on either one by raising MSG_CTRUNC and delivering nothing.
Both receives have to recognize that outcome and hand off to a
recovery path that re-reads the record. Commit bee47cb026e7 ("sunrpc:
fix handling of server side tls alerts") built that recovery path. It
stays on both receives for as long as one recvmsg() serves data and
control alike.

Instead, parse the record stream in a ->read_sock actor. The data
path then carries no control-message buffer at all. A control record
at the head stops ->read_sock short, so svc_tcp_recv_ctrl_record()
classifies the head of the receive queue with MSG_PEEK before
consuming anything.

skb_copy_bits() walks an skb from its head to reach the copy offset,
so an actor that copies a page at a time rewalks a large GRO or kTLS
skb once per page. Copy each callback's share of the record into
rq_bvec with one skb_copy_datagram_iter() instead.

A non-final fragment carries four octets of marker and may carry no
payload. sk_datalen advances only by the payload, so neither a run
of empty fragments nor a run of one-octet fragments trips the
sv_max_mesg check before desc->count runs out. Only desc->count
bounds such a run, four or five octets at a time. Cap the fragments
per socket-lock hold.

recvmsg() skips an urgent octet and clears the condition, so the old
receive path advanced past it. ->read_sock consumes what precedes
the urgent octet and then stops there for good. The data path calls
no recvmsg() now, so the record stream cannot advance again. An RPC
stream carries no urgent data, so close the connection. The read
that first reaches the mark returns a positive count, so a
zero-length read does not mark the stop. Key the close on an
incomplete record.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 390 +++++++++++++++++++++++++++++++--------------------
 1 file changed, 238 insertions(+), 152 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index c7b94bd1898b..fe307d8314c4 100644
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
 
@@ -263,10 +254,10 @@ static int svc_tcp_recv_cmsg(struct socket *sock, int flags,
 	return ret;
 }
 
-static int
-svc_tcp_sock_recv_cmsg(struct socket *sock)
+static int svc_tcp_recv_ctrl_record(struct svc_sock *svsk)
 {
 	u8 alert[2], type, level, description;
+	struct socket *sock = svsk->sk_sock;
 	struct kvec recv_kvec = {
 		.iov_base	= alert,
 		.iov_len	= sizeof(alert),
@@ -275,18 +266,41 @@ svc_tcp_sock_recv_cmsg(struct socket *sock)
 	struct msghdr msg = {};
 	int ret;
 
-	ret = svc_tcp_recv_cmsg(sock, MSG_DONTWAIT, &recv_kvec, &type,
-				&msg_flags);
-	if (ret < 0 || !type)
-		return ret;
-	/* A data record reaches here only when kTLS queued an empty one
-	 * ahead of the control record. Consuming it takes no payload,
-	 * and the retry picks up the control record.
+	if (!test_bit(XPT_TLS_SESSION, &svsk->sk_xprt.xpt_flags))
+		return 0;
+
+	/* A data record can become ready between ->read_sock returning
+	 * and this probe. A plain receive would take two octets of it
+	 * as RPC payload, so peek.
 	 */
-	if (type == TLS_RECORD_TYPE_DATA)
-		return -EAGAIN;
+	ret = svc_tcp_recv_cmsg(sock, MSG_DONTWAIT | MSG_PEEK,
+				&recv_kvec, &type, &msg_flags);
+	if (ret == -EAGAIN || (!ret && !type))
+		return 0;
+	if (ret < 0)
+		return ret;
+	if (type == TLS_RECORD_TYPE_DATA) {
+		/* The peek parks the decrypted record on ctx->rx_list,
+		 * where it draws no further data_ready. Re-arm or the
+		 * RPC hangs until the client times out.
+		 */
+		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+		return 0;
+	}
 	if (type != TLS_RECORD_TYPE_ALERT)
 		return -EPROTO;
+
+	ret = svc_tcp_recv_cmsg(sock, MSG_DONTWAIT, &recv_kvec, &type,
+				&msg_flags);
+	/* The peek found a record at the head, so an -EAGAIN here is
+	 * spurious. Propagating it strands the record with no later
+	 * announcement, so return -EBADMSG, which closes the transport.
+	 */
+	if (ret == -EAGAIN)
+		return -EBADMSG;
+	if (ret < 0)
+		return ret;
+
 	/* An Alert record carries exactly one two-octet message (RFC
 	 * 8446 Section 5.1). recv_kvec caps the receive at two, so a
 	 * longer record produces the same count. MSG_EOR appears only
@@ -300,77 +314,19 @@ svc_tcp_sock_recv_cmsg(struct socket *sock)
 	tls_alert_recv(sock->sk, &msg, &level, &description);
 
 	/* RFC 8446 Section 6: every alert but a closure alert is
-	 * an error alert.
+	 * an error alert. kTLS raises no data_ready for records it
+	 * already holds, so re-arm for what sits behind the alert.
 	 */
 	switch (description) {
 	case TLS_ALERT_DESC_CLOSE_NOTIFY:
 	case TLS_ALERT_DESC_USER_CANCELED:
+		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		return -EAGAIN;
 	default:
 		return -ENOTCONN;
 	}
 }
 
-static int
-svc_tcp_sock_recvmsg(struct svc_sock *svsk, struct msghdr *msg)
-{
-	int ret;
-	struct socket *sock = svsk->sk_sock;
-
-	ret = sock_recvmsg(sock, msg, MSG_DONTWAIT);
-	if (msg->msg_flags & MSG_CTRUNC) {
-		msg->msg_flags &= ~(MSG_CTRUNC | MSG_EOR);
-		if (ret == 0 || ret == -EIO) {
-			ret = svc_tcp_sock_recv_cmsg(sock);
-			/* A control record delivers nothing to the caller,
-			 * and kTLS announces no data_ready for records it
-			 * already holds. Mark the transport ready so that
-			 * the records behind this one can be received.
-			 */
-			if (ret == -EAGAIN)
-				set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-		}
-	}
-	return ret;
-}
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
@@ -993,14 +949,14 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	return NULL;
 }
 
-static size_t svc_tcp_restore_pages(struct svc_sock *svsk,
-				    struct svc_rqst *rqstp)
+static void svc_tcp_restore_pages(struct svc_sock *svsk,
+				  struct svc_rqst *rqstp)
 {
 	size_t len = svsk->sk_datalen;
 	unsigned int i, npages;
 
 	if (!len)
-		return 0;
+		return;
 	npages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	for (i = 0; i < npages; i++) {
 		if (rqstp->rq_pages[i] != NULL)
@@ -1010,7 +966,6 @@ static size_t svc_tcp_restore_pages(struct svc_sock *svsk,
 		svsk->sk_pages[i] = NULL;
 	}
 	rqstp->rq_arg.head[0].iov_base = page_address(rqstp->rq_pages[0]);
-	return len;
 }
 
 static void svc_tcp_save_pages(struct svc_sock *svsk, struct svc_rqst *rqstp)
@@ -1049,50 +1004,6 @@ static void svc_tcp_clear_pages(struct svc_sock *svsk)
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
@@ -1130,14 +1041,31 @@ static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
 
 static void svc_tcp_fragment_received(struct svc_sock *svsk)
 {
-	/* If we have more data, signal svc_xprt_enqueue() to try again */
 	svsk->sk_tcplen = 0;
 	svsk->sk_marker = xdr_zero;
 }
 
 /*
- * Nothing reads the message body before the record is complete, so
- * a single flush after the last fragment is enough.
+ * A non-final fragment carries four octets of marker and may carry
+ * no payload at all. sk_datalen advances only by the payload, so a
+ * run of tiny fragments exhausts ->read_sock's byte budget before
+ * the sv_max_mesg check trips, and a run of empty ones never trips
+ * it. Cap the fragments per socket-lock hold. The cap leaves the
+ * record incomplete, and svc_tcp_recvfrom() resumes it on the next
+ * call.
+ */
+#define SVC_TCP_MAX_FRAGS		256
+
+struct svc_tcp_recv_ctx {
+	struct svc_rqst		*rqstp;
+	unsigned int		frags;
+	bool			complete;
+};
+
+/*
+ * Nothing reads the message body before the message is complete, and
+ * partial receives refill the same pages. Flush once here, after the
+ * socket lock is released, rather than once per copy in the actor.
  */
 static void svc_tcp_flush_pages(struct svc_sock *svsk,
 				struct svc_rqst *rqstp)
@@ -1148,15 +1076,127 @@ static void svc_tcp_flush_pages(struct svc_sock *svsk,
 		flush_dcache_page(rqstp->rq_pages[pg]);
 }
 
+/*
+ * Mapping the message's unfilled remainder would re-map untouched
+ * pages on every call, at a cost that grows with the message rather
+ * than with the octets copied.
+ */
+static void svc_tcp_recv_iter_init(struct svc_rqst *rqstp,
+				   struct iov_iter *iter, size_t body_off,
+				   size_t len)
+{
+	unsigned int first = body_off >> PAGE_SHIFT;
+	size_t seek = offset_in_page(body_off);
+	unsigned int i, pages = DIV_ROUND_UP(seek + len, PAGE_SIZE);
+
+	for (i = 0; i < pages; i++)
+		bvec_set_page(&rqstp->rq_bvec[i], rqstp->rq_pages[first + i],
+			      PAGE_SIZE, 0);
+
+	iov_iter_bvec(iter, ITER_DEST, rqstp->rq_bvec, pages, seek + len);
+	iov_iter_advance(iter, seek);
+}
+
+/*
+ * ->read_sock actor, called under the socket lock. sk_datalen is both
+ * the count of body octets received so far and their write offset into
+ * rq_pages.
+ */
+static int svc_tcp_recv_actor(read_descriptor_t *desc, struct sk_buff *skb,
+			      unsigned int offset, size_t len)
+{
+	struct svc_tcp_recv_ctx *ctx = desc->arg.data;
+	struct svc_rqst *rqstp = ctx->rqstp;
+	struct svc_sock *svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
+	size_t reclen, received, want, take, n;
+	size_t consumed = 0;
+
+	if (!desc->count)
+		return 0;
+
+	len = min(len, desc->count);
+
+	if (svsk->sk_tcplen < sizeof(rpc_fraghdr)) {
+		want = sizeof(rpc_fraghdr) - svsk->sk_tcplen;
+		n = min(want, len);
+
+		if (skb_copy_bits(skb, offset,
+				  (char *)&svsk->sk_marker + svsk->sk_tcplen,
+				  n))
+			goto fault;
+		svsk->sk_tcplen += n;
+		offset += n;
+		len -= n;
+		consumed += n;
+		desc->count -= n;
+
+		if (svsk->sk_tcplen < sizeof(rpc_fraghdr))
+			return consumed;
+
+		trace_svcsock_marker(&svsk->sk_xprt, svsk->sk_marker);
+		if (svc_sock_reclen(svsk) + svsk->sk_datalen >
+		    svsk->sk_xprt.xpt_server->sv_max_mesg) {
+			net_notice_ratelimited("svc: %s oversized RPC fragment (%u octets) from %pISpc\n",
+					       svsk->sk_xprt.xpt_server->sv_name,
+					       svc_sock_reclen(svsk),
+					       (struct sockaddr *)&svsk->sk_xprt.xpt_remote);
+			desc->error = -EMSGSIZE;
+			desc->count = 0;
+			return consumed;
+		}
+	}
+
+	reclen = svc_sock_reclen(svsk);
+	received = svsk->sk_tcplen - sizeof(rpc_fraghdr);
+	want = reclen - received;
+	take = min(want, len);
+
+	if (take) {
+		struct iov_iter iter;
+
+		svc_tcp_recv_iter_init(rqstp, &iter, svsk->sk_datalen, take);
+		if (skb_copy_datagram_iter(skb, offset, &iter, take))
+			goto fault;
+		svsk->sk_datalen += take;
+		svsk->sk_tcplen += take;
+		consumed += take;
+		desc->count -= take;
+	}
+
+	if (take == want) {
+		if (svc_sock_final_rec(svsk)) {
+			ctx->complete = true;
+			desc->count = 0;
+		} else {
+			svc_tcp_fragment_received(svsk);
+			if (++ctx->frags >= SVC_TCP_MAX_FRAGS)
+				desc->count = 0;
+		}
+	}
+
+	return consumed;
+
+fault:
+	desc->error = -EFAULT;
+	desc->count = 0;
+	return consumed;
+}
+
+static bool svc_tcp_at_urg_mark(struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+
+	return tp->urg_data && tp->urg_seq == tp->copied_seq;
+}
+
 /**
  * svc_tcp_recvfrom - Receive data from a TCP socket
  * @rqstp: request structure into which to receive an RPC Call
  *
  * Called in a loop when XPT_DATA has been set.
  *
- * Read the 4-byte stream record marker, then use the record length
- * in that marker to set up exactly the resources needed to receive
- * the next RPC message into @rqstp.
+ * Context: Process context. Takes and releases the socket lock.
  *
  * Returns:
  *   On success, the number of bytes in a received RPC Call, or
@@ -1171,26 +1211,64 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	struct svc_sock	*svsk =
 		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
-	size_t want, base;
+	struct svc_tcp_recv_ctx ctx = {
+		.rqstp		= rqstp,
+	};
+	read_descriptor_t desc = {
+		.arg.data	= &ctx,
+		.count		= serv->sv_max_mesg + sizeof(rpc_fraghdr),
+	};
+	struct socket *sock = svsk->sk_sock;
 	ssize_t len;
 	__be32 *p;
 	__be32 calldir;
 
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-	len = svc_tcp_read_marker(svsk, rqstp);
-	if (len < 0)
-		goto error;
+	svc_tcp_restore_pages(svsk, rqstp);
 
-	base = svc_tcp_restore_pages(svsk, rqstp);
-	want = len - (svsk->sk_tcplen - sizeof(rpc_fraghdr));
-	len = svc_tcp_read_msg(rqstp, base + want, base);
-	if (len >= 0) {
-		trace_svcsock_tcp_recv(&svsk->sk_xprt, len);
-		svsk->sk_tcplen += len;
-		svsk->sk_datalen += len;
+	lock_sock(sock->sk);
+	len = sock->ops->read_sock(sock->sk, &desc, svc_tcp_recv_actor);
+	/* ->read_sock stops at urgent data and consumes none of it.
+	 * Only recvmsg() clears the condition, and this path calls
+	 * none, so every later read stops at the same octet. An RPC
+	 * stream carries no urgent data, so close the connection.
+	 *
+	 * The read that first reaches the mark consumes the octets
+	 * ahead of it, so the stop does not show up as a zero len. A
+	 * record completed ahead of the mark is returned first. The
+	 * XPT_DATA set below brings the next call back here with
+	 * nothing left to consume.
+	 */
+	if (!ctx.complete && svc_tcp_at_urg_mark(sock->sk))
+		desc.error = -EPROTO;
+	release_sock(sock->sk);
+
+	/* ->read_sock returns the octets consumed before an actor
+	 * failure, so a positive len can accompany desc.error.
+	 */
+	if (desc.error < 0) {
+		len = desc.error;
+		goto err_nuts;
 	}
-	if (len != want || !svc_sock_final_rec(svsk))
+	if (len >= 0)
+		trace_svcsock_tcp_recv(&svsk->sk_xprt, len);
+
+	if (!ctx.complete) {
+		if (!desc.count) {
+			set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+			goto err_incomplete;
+		}
+		/* A zero return leaves no record at the head to classify.
+		 * -EINVAL means a control record sits there. Screen the
+		 * other errors out first, because a probe calls
+		 * sock_error(), whose xchg clears sk->sk_err as it reads.
+		 */
+		if (len <= 0 && len != -EINVAL)
+			goto err_incomplete;
+
+		len = svc_tcp_recv_ctrl_record(svsk);
 		goto err_incomplete;
+	}
 	if (svsk->sk_datalen < 8)
 		goto err_nuts;
 
@@ -1211,6 +1289,12 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	else
 		clear_bit(RQ_LOCAL, &rqstp->rq_flags);
 
+	/* Completing one message stops ->read_sock with whatever
+	 * follows still queued, and no path from here re-arms XPT_DATA.
+	 * The queued message would wait for unrelated traffic.
+	 */
+	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+
 	p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
 	calldir = p[1];
 	if (calldir)
@@ -1235,19 +1319,21 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	svc_tcp_save_pages(svsk, rqstp);
 	if (len < 0 && len != -EAGAIN)
 		goto err_delete;
-	if (len == want)
-		svc_tcp_fragment_received(svsk);
-	else
+	if (svsk->sk_tcplen >= sizeof(rpc_fraghdr))
 		trace_svcsock_tcp_recv_short(&svsk->sk_xprt,
 				svc_sock_reclen(svsk),
 				svsk->sk_tcplen - sizeof(rpc_fraghdr));
+	else
+		trace_svcsock_tcp_recv_eagain(&svsk->sk_xprt, 0);
 	goto err_noclose;
 error:
-	if (len != -EAGAIN)
-		goto err_delete;
 	trace_svcsock_tcp_recv_eagain(&svsk->sk_xprt, 0);
 	goto err_noclose;
 err_nuts:
+	/* svc_tcp_save_pages() has not run, so svsk->sk_pages[] is
+	 * empty. A non-zero sk_datalen makes the teardown-time
+	 * svc_tcp_clear_pages() walk empty slots and WARN.
+	 */
 	svsk->sk_datalen = 0;
 err_delete:
 	trace_svcsock_tcp_recv_err(&svsk->sk_xprt, len);

-- 
2.54.0

