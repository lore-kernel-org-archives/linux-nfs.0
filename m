Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801487;
	b=HZcyqbGfwEkSOn0gnfTGjdHpkG1EGPeEenP5zxE6LzHg3wboUfvEVyLMMKp8zaCHrgFq
	 6zWRxF6mNLJeN+zhk63/G25hF9sGnladth5FmXbipQGw4U5wigOij6g1ti3f4s9zAGc52
	 IFE0OYDh4tDH5+rxvkNwF3zWuMz5Vj3EvqNAhSPjsYZvwohqCRPBaJCPx5D4YoqVow4WR
	 OCUBK1NJTuQZPPDM0YAPVlQnjKmz1bXugP29jhCxWOYSFPa4r/3TOsYFVPPCOCO9rNOQY
	 hcsHVtrtIscQtltN83ztE8MMNduAwWZLtAe5eYdGYlsGEHN1Sa8UMMZ9zMfJmB3CAUQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801487;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Hg6GGq8hBUAWKZxMHRLsBRJ8+AEdIXuCAbscQZDrU48=;
	b=zyurO9NAyV6kIY3lUklBrwVegVurTsTFVnxule84oe+ZnFhW7CrYCDmgfMxDa7lH3qWo
	 pcji/PNUY9qcav3aslCRTGR/ln30bR/Vd/UtE0rWD6faVBw/m69JYun3QY4cy3YkhU1k1
	 Xa+4jtx6IbiQDAY/umkjHm2bQKZ3T2Yo8D0hTULFoAxazH8cc+UL52bAFdKAU2FwhB2Zb
	 3seTc2y/9jyRL/U0J3/8KEeKu/rpjoIQeJW7NKoqPU1cRG0OtZuIayXZi19EvjDZzvoFD
	 J1RvjXxBIruOf3TTSWiI3xuPeVIyfwyvt6nCTTK0uhPDxYET9sihp+tcmqx3I5BjBIw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aZeZVwc3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EDE32606EEB1;
	Wed,  4 Nov 2026 14:11:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aZeZVwc3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C84B81F00A15;
	Wed,  4 Nov 2026 14:11:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801486;
	bh=Hg6GGq8hBUAWKZxMHRLsBRJ8+AEdIXuCAbscQZDrU48=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=aZeZVwc3YAaGSNJOCHXmi+TT1OANUjGWGND9mkN+VI72SojMsiNJrdkzn9A13WQ+2
	 BmLqGToh2l0AnNCPDOWFF2Eu3sQGBdIhNW6odp4xR0nU83Yl4/dxjPLJbZmhtM8jCV
	 af6Pe0Co2LlgAc7+hUa/aDxNH0Au/WYovxaDiW18RwhfOU+nTQ7sQr/3ATxF67vWd3
	 8TJfwGr8oIccvMZjkMsmSIf7p3s+UEVHWHjmWjMCTspkMpsDXEItnqaxU/8Y267AUU
	 1RWD6xtLJgXX7vV2LpVwGvmZiB/b4tf2A3gi+Q6y0gGKGkZxPqogg3jh9tAL5UDYxJ
	 vMBzrAeMfo88w==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:10 -0500
Subject: [PATCH v8 10/14] SUNRPC: Publish TCP reply positions
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261104-duplicate-reply-cache-v8-10-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=12688; i=cel@kernel.org;
 h=from:subject:message-id; bh=sKSqUf1nug/Y6keFYXAeVeWlq+mDYszjvQfq2h9S2/g=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0B/ZP1aHqnmJdHiWYArIJXgA+OzbqFSMv6v
 FIsyrSMwYiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AQAKCRAzarMzb2Z/
 lyoNEACMbHaKoxHouN8eB1aB8m4ETJFu+qYEWZatrqB3lwcnfWPA+rXwufP1nMjtKG0kDNEq0XA
 t+HfZaa539QBQ3tFxiFK3Hhy6zrMXH9Srk/SW0lEwl5/lhRYlkSOvNaVyun7xpYjSqnyZoo2WQI
 lbWTSGUTMsUWHBTFM4ppbPN5wn0/+rjAYZGfnbPWjpmuJJxYTewi98Qx35wo9wLr9716T5GV5gB
 R0gtqgXNekC3p07Z35R4zWcZKMQnLoFJfXMb9Lvjl6fhuvFKlijguU8ydQhL7aAoTi63yivGaf1
 SVTuyHiu9CR7WqyPW0K1FYpu1j4ARodWhKiaLQxr6DvOPdxvzsbxE/XP2FMes2fm/nuiY98QQvV
 7ghJPH4cv+lOOqmTWHkdnYsoHnLm36+YlsmiJze1ikYtwQZPjR5A4FMb1eTS/BsOzFX7lxn6QFp
 YelCcCUYhGRxkxMyAw6yPO5dmalGlXN2rndvljT1Ji3PRzA83NmPOU01eHpC7061pNOjj5Bus/8
 IN6SNA9dcux7+II/VM79nD6IJ3p2gINJvJaeEQ4cPLdRDRqYlRf7x46FX3Cz21oPBd282iyCp1y
 yKrvpvGAOa+ilrNpSKLM0KWoCQHS9oDFYI0N1SgU+Gkcf5T0sqUu6BwjReVOm4wprFSgiwhIT3k
 W/gFeSUk+PQ+3Kg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Add the svcsock side of reply-position reporting. A reply's position
is the running count of bytes handed to the socket, kept per socket
under xpt_mutex. A TCP sequence number cannot serve as the position:
the 32-bit space wraps in a few hundred milliseconds at 40 GbE, and
a duplicate reply cache entry lives for two minutes.

The acknowledged position is derived from the socket's unacknowledged
byte count, write_seq minus snd_una, after each successful send.
Refreshing the position only in the send path means a consumer sees
the acknowledgment state as of the previous reply on that connection,
stale by one round trip but never ahead of the peer. A failed or
refused send leaves rq_reply_pos at zero, so the reply is never
reported as acknowledged.

A call the peer sent before it acknowledged a reply precedes the
acknowledgment in the stream, so the socket has received that call by
the time the acknowledgment raises the position. Record rcv_nxt as a
mark whenever the position rises, and withhold the position from
svc_tcp_acked_pos() until copied_seq has reached the mark and no
request but the caller's is counted in xpt_recv_pending. A record in
progress is counted from its first octet, so a partially read
retransmit withholds the position too. The socket lock keeps snd_una,
rcv_nxt, and the out-of-order queue from moving between the reads
and orders them against the reader. A zero return is always safe, so
the count is tested before the lock as well: a cacheable call takes
the lock only after the first position is published and only while
no other request is counted. On a busy connection the position lags
a refresh by the time the requests ahead of the mark take to reach
their lookups. A service that installs no sv_reply_sent hook never
reads the position, so svc_tcp_sendto() skips the refresh for it.

When a segment of the retransmit is lost on the wire, the
acknowledgment the peer sent after that segment arrives first. TCP
processes the acknowledgment, so snd_una covers the reply while
rcv_nxt stops short of the retransmit. The segments behind the hole
sit on the out-of-order queue. When every segment of the retransmit
is lost, the acknowledgment arrives alone: tcp_data_queue() frees a
segment that carries no data without queuing it, and only snd_wl1,
which tcp_ack_update_window() sets to the sequence number of each
segment that advances snd_una, records how far the peer has sent.
The mark is therefore the furthest of rcv_nxt, the end of the
out-of-order queue, and snd_wl1. copied_seq cannot reach that mark
until TCP has delivered the lost segments and the record behind them
has been read.

Under kTLS the socket counts ciphertext while svcsock counts
plaintext, and tls_sw_sendmsg() can return the full plaintext count
with part of a record still waiting for socket write space. The
unacknowledged count then understates what the peer has yet to
receive. Whether a record is pending is state private to net/tls, so
a TLS session publishes no acknowledged position and its replies
are retained for the full interval.

The svcsock_tcp_send tracepoint fires before the position is
updated and logs only the byte count, so a trace cannot show whether
xpt_acked_pos ever claimed more than the client had acknowledged.
Add svcsock_tcp_acked, recording write_seq, snd_una, and sk_send_pos,
the candidate position they yield, and the position published after
the monotonic clamp. The clamp can hold the published position above
the candidate, so the record carries both. xpt_id separates samples
from successive connections that share a remote address.

Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-9-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svcsock.h |   7 +++
 include/trace/events/sunrpc.h  |  39 +++++++++++++
 net/sunrpc/svcsock.c           | 126 ++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 171 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 372a00882ca6..0fa62f9c6465 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -38,9 +38,16 @@ struct svc_sock {
 	/* Total length of the data (not including fragment headers)
 	 * received so far in the fragments making up this rpc: */
 	u32			sk_datalen;
+	/* The record in progress is counted in xpt_recv_pending */
+	bool			sk_recv_counted;
 
 	struct page_frag_cache  sk_frag_cache;
 
+	/* reply bytes handed to the socket; protected by xpt_mutex */
+	u64			sk_send_pos;
+	/* rcv_nxt when xpt_acked_pos was last raised; socket lock */
+	u32			sk_acked_rcv;
+
 	struct completion	sk_handshake_done;
 
 	/* received data */
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 77efe63d2c14..a5d914376627 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -2349,6 +2349,45 @@ TRACE_EVENT(svcsock_tcp_recv_short,
 	)
 );
 
+TRACE_EVENT(svcsock_tcp_acked,
+	TP_PROTO(
+		const struct svc_xprt *xprt,
+		u64 send_pos,
+		u32 write_seq,
+		u32 snd_una,
+		u64 candidate,
+		u64 acked_pos
+	),
+
+	TP_ARGS(xprt, send_pos, write_seq, snd_una, candidate, acked_pos),
+
+	TP_STRUCT__entry(
+		__field(u64, xpt_id)
+		__field(u64, send_pos)
+		__field(u64, candidate)
+		__field(u64, acked_pos)
+		__field(u32, write_seq)
+		__field(u32, snd_una)
+		__string(addr, xprt->xpt_remotebuf)
+	),
+
+	TP_fast_assign(
+		__entry->xpt_id = xprt->xpt_id;
+		__entry->send_pos = send_pos;
+		__entry->candidate = candidate;
+		__entry->acked_pos = acked_pos;
+		__entry->write_seq = write_seq;
+		__entry->snd_una = snd_una;
+		__assign_str(addr);
+	),
+
+	TP_printk("addr=%s xpt_id=%llu send_pos=%llu write_seq=%u snd_una=%u candidate=%llu acked_pos=%llu",
+		__get_str(addr), __entry->xpt_id, __entry->send_pos,
+		__entry->write_seq, __entry->snd_una, __entry->candidate,
+		__entry->acked_pos
+	)
+);
+
 TRACE_EVENT(svcsock_tcp_state,
 	TP_PROTO(
 		const struct svc_xprt *xprt,
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index fd2f62652b93..4eaa8eb4d537 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1120,6 +1120,15 @@ static int svc_tcp_recv_actor(read_descriptor_t *desc, struct sk_buff *skb,
 
 	len = min(len, desc->count);
 
+	/*
+	 * sk_tcplen cannot gate the count: an empty non-final fragment
+	 * returns sk_tcplen and sk_datalen to zero mid-record.
+	 */
+	if (!svsk->sk_recv_counted) {
+		atomic_inc(&svsk->sk_xprt.xpt_recv_pending);
+		svsk->sk_recv_counted = true;
+	}
+
 	if (svsk->sk_tcplen < sizeof(rpc_fraghdr)) {
 		want = sizeof(rpc_fraghdr) - svsk->sk_tcplen;
 		n = min(want, len);
@@ -1296,11 +1305,16 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
 	calldir = p[1];
-	if (calldir)
+	if (calldir) {
+		atomic_dec(&svsk->sk_xprt.xpt_recv_pending);
 		len = receive_cb_reply(svsk, rqstp);
+	} else {
+		set_bit(RQ_RECV_PENDING, &rqstp->rq_flags);
+	}
 
 	/* Reset TCP read info */
 	svsk->sk_datalen = 0;
+	svsk->sk_recv_counted = false;
 	svc_tcp_fragment_received(svsk);
 
 	if (len < 0)
@@ -1335,6 +1349,10 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	 */
 	svsk->sk_datalen = 0;
 err_delete:
+	if (svsk->sk_recv_counted) {
+		atomic_dec(&svsk->sk_xprt.xpt_recv_pending);
+		svsk->sk_recv_counted = false;
+	}
 	trace_svcsock_tcp_recv_err(&svsk->sk_xprt, len);
 	svc_xprt_deferred_close(&svsk->sk_xprt);
 err_noclose:
@@ -1382,6 +1400,107 @@ static int svc_tcp_sendmsg(struct svc_sock *svsk, struct svc_rqst *rqstp,
 	return ret;
 }
 
+/*
+ * Bytes the socket has not seen acknowledged all belong to the most
+ * recent replies, so sk_send_pos less that count is the acknowledged
+ * position.
+ *
+ * A call the peer sent before it acknowledged a reply precedes the
+ * acknowledgment in the stream. When a segment of the call is lost on
+ * the wire, rcv_nxt stops short of the call and the segments behind
+ * the hole sit on the out-of-order queue. When every segment of the
+ * call is lost, the acknowledgment arrives alone and TCP keeps its
+ * sequence number in snd_wl1. The furthest of rcv_nxt, the end of the
+ * out-of-order queue, and snd_wl1 covers the call. Record that mark
+ * with the position; svc_tcp_acked_pos() releases the position once
+ * everything up to the mark has been read. The socket lock keeps
+ * write_seq, snd_una, rcv_nxt, snd_wl1, and the out-of-order queue
+ * from moving between the reads and orders them against
+ * svc_tcp_acked_pos().
+ *
+ * Under kTLS, tls_sw_sendmsg() can return the full plaintext count
+ * with part of a record still waiting for socket write space, leaving
+ * write_seq short of the reply. Whether a record is pending is private
+ * to net/tls, so a TLS session publishes no acknowledged position.
+ * tlshd installs the ULP before XPT_TLS_SESSION reports the session,
+ * so neither does a reply sent while XPT_HANDSHAKE is set. Test
+ * XPT_HANDSHAKE first: it is cleared after XPT_TLS_SESSION is set.
+ */
+static void svc_tcp_update_acked(struct svc_sock *svsk)
+{
+	struct sock *sk = svsk->sk_sk;
+	struct tcp_sock *tp = tcp_sk(sk);
+	u64 unacked, acked = 0, acked_pos;
+	u32 write_seq, snd_una, mark;
+
+	if (test_bit(XPT_HANDSHAKE, &svsk->sk_xprt.xpt_flags) ||
+	    test_bit(XPT_TLS_SESSION, &svsk->sk_xprt.xpt_flags))
+		return;
+	lock_sock(sk);
+	write_seq = READ_ONCE(tp->write_seq);
+	snd_una = READ_ONCE(tp->snd_una);
+	unacked = write_seq - snd_una;
+	if (unacked < svsk->sk_send_pos)
+		acked = svsk->sk_send_pos - unacked;
+	if (svc_xprt_advance_acked(&svsk->sk_xprt, acked)) {
+		if (RB_EMPTY_ROOT(&tp->out_of_order_queue))
+			mark = READ_ONCE(tp->rcv_nxt);
+		else
+			mark = TCP_SKB_CB(tp->ooo_last_skb)->end_seq;
+		if (after(tp->snd_wl1, mark))
+			mark = tp->snd_wl1;
+		svsk->sk_acked_rcv = mark;
+	}
+	acked_pos = atomic64_read(&svsk->sk_xprt.xpt_acked_pos);
+	release_sock(sk);
+	trace_svcsock_tcp_acked(&svsk->sk_xprt, svsk->sk_send_pos, write_seq,
+				snd_una, acked, acked_pos);
+}
+
+static int svc_tcp_recv_pending(const struct svc_rqst *rqstp)
+{
+	return atomic_read(&rqstp->rq_xprt->xpt_recv_pending) -
+	       !!test_bit(RQ_RECV_PENDING, &rqstp->rq_flags);
+}
+
+/**
+ * svc_tcp_acked_pos - acknowledged position the reply cache may act on
+ * @rqstp: the request on whose behalf the position is read
+ *
+ * A retransmit the peer sent before the acknowledgment can still be
+ * on its way through svcsock: unread in the socket, or read and not
+ * yet looked up. Withhold the position until the socket has been read
+ * up to the mark taken with it and no request but @rqstp is counted
+ * between its read and its lookup. A record in progress is counted
+ * from its first octet, so a partially read retransmit withholds the
+ * position too.
+ *
+ * Context: process context. May take and release the socket lock.
+ * Return: xpt_acked_pos, or 0 while it cannot be acted on.
+ */
+static u64 svc_tcp_acked_pos(struct svc_rqst *rqstp)
+{
+	struct svc_xprt *xprt = rqstp->rq_xprt;
+	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
+	struct sock *sk = svsk->sk_sk;
+	u64 pos;
+
+	/* The position only rises, so a zero read is final. */
+	if (!atomic64_read(&xprt->xpt_acked_pos))
+		return 0;
+	/* A zero return is always safe, so test the count unlocked first. */
+	if (svc_tcp_recv_pending(rqstp))
+		return 0;
+
+	lock_sock(sk);
+	pos = atomic64_read(&xprt->xpt_acked_pos);
+	if (svc_tcp_recv_pending(rqstp) ||
+	    before(READ_ONCE(tcp_sk(sk)->copied_seq), svsk->sk_acked_rcv))
+		pos = 0;
+	release_sock(sk);
+	return pos;
+}
+
 /**
  * svc_tcp_sendto - Send out a reply on a TCP socket
  * @rqstp: completed svc_rqst
@@ -1410,6 +1529,10 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 	trace_svcsock_tcp_send(xprt, sent);
 	if (sent < 0 || sent != (xdr->len + sizeof(marker)))
 		goto out_close;
+	svsk->sk_send_pos += sent;
+	rqstp->rq_reply_pos = svsk->sk_send_pos;
+	if (rqstp->rq_server->sv_reply_sent)
+		svc_tcp_update_acked(svsk);
 	mutex_unlock(&xprt->xpt_mutex);
 	return sent;
 
@@ -1446,6 +1569,7 @@ static const struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_accept = svc_tcp_accept,
 	.xpo_kill_temp_xprt = svc_tcp_kill_temp_xprt,
 	.xpo_handshake = svc_tcp_handshake,
+	.xpo_acked_pos = svc_tcp_acked_pos,
 };
 
 static struct svc_xprt_class svc_tcp_class = {

-- 
2.56.0

