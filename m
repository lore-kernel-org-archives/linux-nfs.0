Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801491;
	b=ZuU26McZ8gpVaDa5EZC9eypKq97wxFN+SoNklrgX9eeexbwMpocdQNNnhJK5GqWzzQyg
	 bn0/CM2Y7bbiC9+Ski1ovIfEU+FWvPbYo6k8tNSiqOTklZYepK2+RRliM1k/pz2H8zfQ4
	 uMDSCU3LfCc0OXI47iR82FvS1dYR/4dN3ntaGWSS1t9kXOfvgumteHVzlrYJG9wbFnUni
	 9Yza+f5LjONeXOX6wHHWlGtorquM72v1RnpRWhDc17zDh3qKV26dxmg8s1tv4fcFTbFc8
	 dH0ffySkGIFPS3fQG9I+xUAVgKG8bYnUYjBYkA1kyw6EjZRBscc8XLKFianyiLVLQnA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801491;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=lIbm011xFmW9dhLNUThahPU6leGSUpvEXe2J5N5uUlI=;
	b=HJE1ucX/K486AFA3Qu+XRcBMXDHwKT2r5o+vEYaoOAwh7PVgNVBm7uqWEZFsofosj7u0
	 zE51DinGbmnQS5e0Djj5NCD6Hv75OurNCpEcxH74lnNt6OAjvYCpB0z9yLkE3Ox4xRzaQ
	 50mu/qa6vaeO4g3kboF4KiJVJByQ+EcuAnGccirgHorHW+UDdZlZSl5d2Nor47ZvCb4G/
	 eH/r8tDwlpH+0KLrE5TRkK8zZU8exx7kpsT35qNW+Bg+BrkyuNka2kggXt4xb5E5RyJ+2
	 OvWZYSK9u0WH59nldVWr2oyEmvGsVufmcHZWvUMratHMgNF3Tv08JBKj2mUUp2+PZsw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G5on4P3C;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AC67606D80F;
	Wed,  4 Nov 2026 14:11:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G5on4P3C
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6DFAC1F000C1;
	Wed,  4 Nov 2026 14:11:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801491;
	bh=lIbm011xFmW9dhLNUThahPU6leGSUpvEXe2J5N5uUlI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=G5on4P3CRwC3OY+7AmWSyhuERySMK6KT3G5Unmg+ww5bqvvQkD+MVI+D65GnWgELv
	 Ci9822t+sTw2cgon9d0KU0AKdou7ft5ex8QXiAN7oGHv7iGTdhSFGiPy3/pN43ADei
	 ONVI5nbTfpTh6y8gQ1wlf7veWriAmG1X5MMenSCRhe2S/xeRuIVwSyAazSjj0cdl8S
	 np0Uu1pFyopRW4wnI8oO5eRwSo+5NhnElgmycnTHMhM6N2VKnUJjES6aBj3L1jFzcH
	 TTsCEK4DhWUrgwxALU1j66Q8+lU09TJyAPE7iC1f40TklmDwRzVYbbfjPy7Kq6D+8B
	 frk2/froMN+AA==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:14 -0500
Subject: [PATCH v8 14/14] SUNRPC: Advance the acked position on TLS
 connections
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
Message-Id: <20261104-duplicate-reply-cache-v8-14-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=13338; i=cel@kernel.org;
 h=from:subject:message-id; bh=6xH5emS8YEgMDxK/hkVBBlyGydjhA8RC4HA2SyQlC8o=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0B2sXIc6Q++o1OeKnQl+qMzbjYT8lHVZjsu
 Bl5wbfyPS2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AQAKCRAzarMzb2Z/
 l12AEAC5MSXYBpe9Z0G3eK4DoPf/rdl4F4dpH22IHtJT5+aRsmNmEOJSoqha89WZhtrxOBpfEHZ
 oXVCbv85axZKaF8rRGHbAkrC6rUqKz6Rst8Tbefo3B+v1qjk/JaUHlUVJQwgPcU5idySE1OG4nJ
 pWSxANWyv40RyBG/ZknoRI8hn5TYxaoONcdaw21KQZW6ggucSHKM2S7ed6iU9rvS0QegeAvfHLB
 zTm7naBMg7gNJKiDDRmf01gVsVgw+bEeqbRc87FeNHpBNvgQPzNF1e1B3W+ekIwOb+S6ha5qJnK
 fs9YYXUA87rWgdNj/+pFmSVsmYd4uDcg1b7U+5VCwgola/iZt1SRZ1dAFSM+mrUpMjdDAw5tDTq
 89zZ8RnMV1OKkOjOqgYMWKh3edMsi9iTiQSZW83uFqoG+SsM8UKptdGDPV7KAEWpmjpxCtMRTso
 AFDwRDAXVURiSzCNuwNiIDLmANk3FyrpPf+vmzQzkkD4Q5ntD2dyH8S1dCSb+Srnb1NM8r7Nv18
 UDgvNiE/aXPgAh/Af3lgZn4skWG0PWboXIAWVxF8AeLcwkcn0GROyghf4FPfIhlUFVfawHQlfQ4
 0g5iS2/weMvOK4J0RSXQwXO2YDd7JD8diz2q5Tl5ot/yx0/uLdHhQIvDclfQ/wD4RdPFTnYCkBo
 n5f4Qht1ykcpB0w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The DRC retires an entry once its reply lies at or below the
transport's xpt_acked_pos, the position svc_tcp_update_acked()
advances as TCP acknowledgments arrive. When XPT_TLS_SESSION is set,
svc_tcp_update_acked() leaves xpt_acked_pos alone, because kTLS can
return a full count from sendmsg() while a record is still waiting to
reach TCP. DRC entries on TLS connections therefore never retire by
acknowledgment.

Advance xpt_acked_pos on a TLS connection when no record is open,
awaiting encryption, or parked on a short TCP send. Every field the
check reads is declared in include/net/tls.h, so the predicate lives
beside its one caller rather than in net/tls. After the change,
a TLS connection takes the socket lock once per reply, as a plain
TCP connection already does. Record in svcsock_tcp_acked why a reply
published no position.

On the receive side, copied_seq does not track plaintext under kTLS.
tls_strp_msg_consume() advances copied_seq by the whole ciphertext
record once the record is decrypted, before svc_tcp_recv_actor()
sees any of its plaintext, and in copy mode the strparser advances
copied_seq while pulling the ciphertext in. A record that spans the
end of one call and the start of a retransmit leaves the
retransmit's plaintext on rx_list, uncounted in xpt_recv_pending,
with copied_seq already at the mark. Withhold the position while
sk_is_readable() reports plaintext on rx_list or a record ready in
the strparser. A record the strparser is still copying in is neither
readable nor ready, so withhold the position while the strparser's
copy_mode is set as well. The strparser fields are declared in
include/net/tls.h with the socket lock named as their guard.

The close_notify alert and the FIN sent at detach go out without
xpt_mutex. Both are non-blocking and never drop the socket lock
mid-push, so their bytes either reach write_seq and lower the position,
or park and hold it.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svcsock.h |   9 ++++
 include/trace/events/sunrpc.h  |  23 +++++++--
 net/sunrpc/svcsock.c           | 111 +++++++++++++++++++++++++++++++++++------
 3 files changed, 125 insertions(+), 18 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 0fa62f9c6465..bd5cd79c1870 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -49,12 +49,21 @@ struct svc_sock {
 	u32			sk_acked_rcv;
 
 	struct completion	sk_handshake_done;
+	/* tls ULP installed, recorded once; the ULP has no removal path */
+	bool			sk_tls_ulp;
 
 	/* received data */
 	unsigned long		sk_maxpages;
 	struct page *		sk_pages[] __counted_by(sk_maxpages);
 };
 
+/* Why svc_tcp_update_acked() did or did not publish a position */
+enum svc_tcp_acked_reason {
+	SVC_TCP_ACKED_PUBLISHED,
+	SVC_TCP_ACKED_NO_ULP,
+	SVC_TCP_ACKED_TX_PENDING,
+};
+
 static inline u32 svc_sock_reclen(struct svc_sock *svsk)
 {
 	return be32_to_cpu(svsk->sk_marker) & RPC_FRAGMENT_SIZE_MASK;
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index a5d914376627..a7e96e49e0d0 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -10,6 +10,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/xprtsock.h>
 #include <linux/sunrpc/svc_xprt.h>
+#include <linux/sunrpc/svcsock.h>
 #include <net/tcp_states.h>
 #include <linux/net.h>
 #include <linux/tracepoint.h>
@@ -2349,6 +2350,16 @@ TRACE_EVENT(svcsock_tcp_recv_short,
 	)
 );
 
+TRACE_DEFINE_ENUM(SVC_TCP_ACKED_PUBLISHED);
+TRACE_DEFINE_ENUM(SVC_TCP_ACKED_NO_ULP);
+TRACE_DEFINE_ENUM(SVC_TCP_ACKED_TX_PENDING);
+
+#define show_svc_tcp_acked_reason(reason)				\
+	__print_symbolic(reason,					\
+		{ SVC_TCP_ACKED_PUBLISHED,	"published" },		\
+		{ SVC_TCP_ACKED_NO_ULP,		"no_ulp" },		\
+		{ SVC_TCP_ACKED_TX_PENDING,	"tx_pending" })
+
 TRACE_EVENT(svcsock_tcp_acked,
 	TP_PROTO(
 		const struct svc_xprt *xprt,
@@ -2356,10 +2367,12 @@ TRACE_EVENT(svcsock_tcp_acked,
 		u32 write_seq,
 		u32 snd_una,
 		u64 candidate,
-		u64 acked_pos
+		u64 acked_pos,
+		enum svc_tcp_acked_reason reason
 	),
 
-	TP_ARGS(xprt, send_pos, write_seq, snd_una, candidate, acked_pos),
+	TP_ARGS(xprt, send_pos, write_seq, snd_una, candidate, acked_pos,
+		reason),
 
 	TP_STRUCT__entry(
 		__field(u64, xpt_id)
@@ -2368,6 +2381,7 @@ TRACE_EVENT(svcsock_tcp_acked,
 		__field(u64, acked_pos)
 		__field(u32, write_seq)
 		__field(u32, snd_una)
+		__field(unsigned int, reason)
 		__string(addr, xprt->xpt_remotebuf)
 	),
 
@@ -2378,13 +2392,14 @@ TRACE_EVENT(svcsock_tcp_acked,
 		__entry->acked_pos = acked_pos;
 		__entry->write_seq = write_seq;
 		__entry->snd_una = snd_una;
+		__entry->reason = reason;
 		__assign_str(addr);
 	),
 
-	TP_printk("addr=%s xpt_id=%llu send_pos=%llu write_seq=%u snd_una=%u candidate=%llu acked_pos=%llu",
+	TP_printk("addr=%s xpt_id=%llu send_pos=%llu write_seq=%u snd_una=%u candidate=%llu acked_pos=%llu reason=%s",
 		__get_str(addr), __entry->xpt_id, __entry->send_pos,
 		__entry->write_seq, __entry->snd_una, __entry->candidate,
-		__entry->acked_pos
+		__entry->acked_pos, show_svc_tcp_acked_reason(__entry->reason)
 	)
 );
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 4eaa8eb4d537..79d8d4e2c90d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -36,6 +36,7 @@
 #include <net/udp.h>
 #include <net/tcp.h>
 #include <net/tcp_states.h>
+#include <net/tls.h>
 #include <net/tls_prot.h>
 #include <net/handshake.h>
 #include <linux/uaccess.h>
@@ -409,6 +410,14 @@ static void svc_tcp_kill_temp_xprt(struct svc_xprt *xprt)
 	sock_no_linger(svsk->sk_sock->sk);
 }
 
+/* XPT_TLS_SESSION reflects tlshd's report, not an installed TLS ULP. */
+static bool svc_tcp_has_tls_ulp(struct sock *sk)
+{
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+
+	return icsk->icsk_ulp_ops && !strcmp(icsk->icsk_ulp_ops->name, "tls");
+}
+
 /**
  * svc_tcp_handshake_done - Handshake completion handler
  * @data: address of xprt to wake
@@ -426,8 +435,13 @@ static void svc_tcp_handshake_done(void *data, int status, key_serial_t peerid)
 	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
 
 	if (!status) {
+		struct sock *sk = svsk->sk_sk;
+
 		if (peerid != TLS_NO_PEERID)
 			set_bit(XPT_PEER_AUTH, &xprt->xpt_flags);
+		lock_sock(sk);
+		WRITE_ONCE(svsk->sk_tls_ulp, svc_tcp_has_tls_ulp(sk));
+		release_sock(sk);
 		set_bit(XPT_TLS_SESSION, &xprt->xpt_flags);
 	}
 	clear_bit(XPT_HANDSHAKE, &xprt->xpt_flags);
@@ -1401,9 +1415,60 @@ static int svc_tcp_sendmsg(struct svc_sock *svsk, struct svc_rqst *rqstp,
 }
 
 /*
- * Bytes the socket has not seen acknowledged all belong to the most
- * recent replies, so sk_send_pos less that count is the acknowledged
- * position.
+ * A false return means every byte sendmsg() has accepted has reached the
+ * TCP write queue, provided no other blocking sender is on the socket. With
+ * TLS_HW, a sender can drop the socket lock inside tcp_sendmsg_locked()
+ * while its record sits in neither partially_sent_record nor an
+ * open record. TLS_SW keeps the record on tx_list until the push
+ * succeeds. TLS_HW_RECORD keeps its send accounting in the TOE driver,
+ * beyond this check's reach, so TLS_HW_RECORD always counts as pending.
+ *
+ * tx_lock is the documented guard for the partially_sent_* fields, but
+ * every store to them and to tx_list runs with the socket owned: sendmsg(),
+ * the tx worker, and the write-space callback, which the backlog defers
+ * while a process owns the socket. Owning the socket therefore reads a
+ * consistent snapshot without contending with the worker for tx_lock.
+ */
+static bool svc_tls_tx_pending(const struct sock *sk)
+{
+	struct tls_context *ctx = tls_get_ctx(sk);
+	struct tls_sw_context_tx *sw;
+
+	sock_owned_by_me(sk);
+	if (ctx->partially_sent_record || ctx->pending_open_record_frags)
+		return true;
+	switch (ctx->tx_conf) {
+	case TLS_SW:
+		sw = tls_sw_ctx_tx(ctx);
+		return sw->open_rec || !list_empty(&sw->tx_list);
+	case TLS_HW:
+		return false;
+	default:
+		return true;
+	}
+}
+
+/*
+ * In copy mode the strparser pulls a record's segments out of the
+ * receive queue as they arrive, advancing copied_seq, and reports the
+ * record readable only once the last segment is in. copy_mode stays
+ * set until the record is consumed. include/net/tls.h documents the
+ * bitfield as serialized by the socket lock.
+ */
+static bool svc_tls_rx_pending(const struct sock *sk)
+{
+	struct tls_context *ctx = tls_get_ctx(sk);
+
+	sock_owned_by_me(sk);
+	return tls_sw_ctx_rx(ctx) && tls_sw_ctx_rx(ctx)->strp.copy_mode;
+}
+
+/*
+ * Unacknowledged bytes follow every older reply, and each reply occupies at
+ * least as many wire bytes as sk_send_pos counts for it. sk_send_pos less
+ * the unacknowledged count is therefore at or below the position the client
+ * has acknowledged. Backchannel calls, TLS framing, alerts, the FIN sent at
+ * detach, and a stale snd_una only lower the result.
  *
  * A call the peer sent before it acknowledged a reply precedes the
  * acknowledgment in the stream. When a segment of the call is lost on
@@ -1418,13 +1483,17 @@ static int svc_tcp_sendmsg(struct svc_sock *svsk, struct svc_rqst *rqstp,
  * from moving between the reads and orders them against
  * svc_tcp_acked_pos().
  *
- * Under kTLS, tls_sw_sendmsg() can return the full plaintext count
- * with part of a record still waiting for socket write space, leaving
- * write_seq short of the reply. Whether a record is pending is private
- * to net/tls, so a TLS session publishes no acknowledged position.
+ * kTLS can return a full count from sendmsg() with a record not yet
+ * handed to TCP, and the tls tx worker advances write_seq outside
+ * xpt_mutex. Evaluate svc_tls_tx_pending() and read both sequence numbers
+ * under one lock_sock() so all three describe the same instant. xpt_mutex
+ * keeps every other blocking sender off the socket, as svc_tls_tx_pending()
+ * requires.
+ *
  * tlshd installs the ULP before XPT_TLS_SESSION reports the session,
- * so neither does a reply sent while XPT_HANDSHAKE is set. Test
- * XPT_HANDSHAKE first: it is cleared after XPT_TLS_SESSION is set.
+ * so a reply sent while XPT_HANDSHAKE is set publishes no position. Test
+ * XPT_HANDSHAKE first: svc_tcp_handshake_done() sets XPT_TLS_SESSION before
+ * clearing XPT_HANDSHAKE.
  */
 static void svc_tcp_update_acked(struct svc_sock *svsk)
 {
@@ -1432,15 +1501,21 @@ static void svc_tcp_update_acked(struct svc_sock *svsk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	u64 unacked, acked = 0, acked_pos;
 	u32 write_seq, snd_una, mark;
+	enum svc_tcp_acked_reason reason = SVC_TCP_ACKED_PUBLISHED;
+	bool tls;
 
-	if (test_bit(XPT_HANDSHAKE, &svsk->sk_xprt.xpt_flags) ||
-	    test_bit(XPT_TLS_SESSION, &svsk->sk_xprt.xpt_flags))
+	if (test_bit(XPT_HANDSHAKE, &svsk->sk_xprt.xpt_flags))
 		return;
+	tls = test_bit(XPT_TLS_SESSION, &svsk->sk_xprt.xpt_flags);
+	if (tls && !READ_ONCE(svsk->sk_tls_ulp))
+		reason = SVC_TCP_ACKED_NO_ULP;
 	lock_sock(sk);
+	if (tls && reason == SVC_TCP_ACKED_PUBLISHED && svc_tls_tx_pending(sk))
+		reason = SVC_TCP_ACKED_TX_PENDING;
 	write_seq = READ_ONCE(tp->write_seq);
 	snd_una = READ_ONCE(tp->snd_una);
 	unacked = write_seq - snd_una;
-	if (unacked < svsk->sk_send_pos)
+	if (reason == SVC_TCP_ACKED_PUBLISHED && unacked < svsk->sk_send_pos)
 		acked = svsk->sk_send_pos - unacked;
 	if (svc_xprt_advance_acked(&svsk->sk_xprt, acked)) {
 		if (RB_EMPTY_ROOT(&tp->out_of_order_queue))
@@ -1454,7 +1529,7 @@ static void svc_tcp_update_acked(struct svc_sock *svsk)
 	acked_pos = atomic64_read(&svsk->sk_xprt.xpt_acked_pos);
 	release_sock(sk);
 	trace_svcsock_tcp_acked(&svsk->sk_xprt, svsk->sk_send_pos, write_seq,
-				snd_una, acked, acked_pos);
+				snd_una, acked, acked_pos, reason);
 }
 
 static int svc_tcp_recv_pending(const struct svc_rqst *rqstp)
@@ -1475,6 +1550,13 @@ static int svc_tcp_recv_pending(const struct svc_rqst *rqstp)
  * from its first octet, so a partially read retransmit withholds the
  * position too.
  *
+ * Under kTLS, copied_seq advances by the whole ciphertext record when
+ * the strparser consumes it, before svc_tcp_recv_actor() sees any of
+ * its plaintext. Plaintext left on rx_list and a record ready in the
+ * strparser withhold the position as well; sk_is_readable() reports
+ * both. A record the strparser is still copying in is neither, and
+ * svc_tls_rx_pending() withholds the position for it.
+ *
  * Context: process context. May take and release the socket lock.
  * Return: xpt_acked_pos, or 0 while it cannot be acted on.
  */
@@ -1494,7 +1576,8 @@ static u64 svc_tcp_acked_pos(struct svc_rqst *rqstp)
 
 	lock_sock(sk);
 	pos = atomic64_read(&xprt->xpt_acked_pos);
-	if (svc_tcp_recv_pending(rqstp) ||
+	if (svc_tcp_recv_pending(rqstp) || sk_is_readable(sk) ||
+	    (READ_ONCE(svsk->sk_tls_ulp) && svc_tls_rx_pending(sk)) ||
 	    before(READ_ONCE(tcp_sk(sk)->copied_seq), svsk->sk_acked_rcv))
 		pos = 0;
 	release_sock(sk);

-- 
2.56.0

