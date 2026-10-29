Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297194;
	b=fGuGGg3vU0NFRK7zgb+r55VGmGJqsP6jmcm22SAtajdabHhjsUzLVz5WTfzimgy9XCRQ
	 yo0izn4/SyDuA3yVUOxkPGrhZYwCi7V9nEEk/axOlVtX2ToNnVp2jb0jjYlh/7SyJBD/X
	 lKw/oYF2eEn/9wJQG5Pm67IHfwqdLaczSE06QtV633HljWtqFZx1kUAbjC8JwklIVrxlU
	 sgivetyd6TK6848oXALpnA7JT7JE0ruSxvZA9ghYzc7gjhAnaUujCVXTZdtnAlH90AO36
	 nhT3d8I2QxoSucWf7NAWQoxFtVr5hRxz3ag46aHCzWf4G9VIMh98IprdfKGTQY4Lxag==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297194;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=oGTfG9+HaRXu/Uo5E0AZ/j/OClh08L+TICEqwhiWbzg=;
	b=W6h497VetMZARTuT59QOMDKCpUxZN5LtPLStkR5oitmrqTH34HqRtZHGoo/DOjkTQRUs
	 64ZuZkgTMNwenM77i9WNjhD1CrUFZjW22hCTw2yIJIoXGrgPjUfnhdb+sX3hS/0y9fNhY
	 XlIGJfsxXMb/AdNupzqp1Ej665KgZbt3ShtZ/3b3n9vyiVxLCIX2XrwnS5DOV5VICrf+L
	 KcOl/XkMe9MJwmhTRqbylmYk/OmoKvq6yvK9tzkeaUwffoG02Ye0hi1UOP6NeukfguiWb
	 uVaJ1aFkQfaocl4aBV+RVj69UOnT2rwByVbOlpedzp6+HoGfKEZ1CV0tC5ypa79TJbw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZLoqGI1p;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFE30606A33E
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZLoqGI1p
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BD1C41F01825;
	Thu, 29 Oct 2026 18:06:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297193;
	bh=oGTfG9+HaRXu/Uo5E0AZ/j/OClh08L+TICEqwhiWbzg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ZLoqGI1pkh/FWjKDAnl7IKOmJpm6JXwJ+fXmuOZzj486afhcJtqgJzdoYEVso/AWN
	 J0x/WktxMuVk5+sI/hRVZGI6p7RL3uU1RpB+I2XXQQlu607aUY7RTji1UephGjiNlD
	 DWepMBhT/anE8waDxV/n1XV3LYH2e0+1931kBc6LchZPuX9nlSNrDXB177KP5W/8M0
	 LsdQYTCBLrEZjl2SMUf/Z4PNZIHPfC2OcMXmALbxJwyvY1kTKHcjZRAK6Xod/9BCz+
	 Ebw6Tm6/40arfzadL1zMnG6QEPAkGb5XB1IZSgk9dHuYmMRA5NNMk2ozwCXlbcBXYa
	 FM+bJLXZukFyA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 14:06:19 -0400
Subject: [PATCH v7 13/13] SUNRPC: Advance the acked position on TLS
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
Message-Id: <20261029-duplicate-reply-cache-v7-13-f3b0f3cf5bc7@kernel.org>
References: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
In-Reply-To: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=12434; i=cel@kernel.org;
 h=from:subject:message-id; bh=WuGXFkzEAZhIBSaH9wt/5Ozlyjmsfw7CEi1blnDSMYo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44scf40F8KO/LZpYetdOyg7bQ+5Ee85zdNOZR
 B7lYY3ldTCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLHAAKCRAzarMzb2Z/
 l7o6D/9GEoSF7Q5A2jvetjcR6iYoypRi4+I6TdcUW2drcCt6sq2QumZHK7xBWX6MH05QZ6XYWiu
 Db6hu1Fg7lSY7/hwAa8Q8Pl2yjaPn2aS1B48Ew0+r7j46+QgKL6ApatkdJ4NoCO5YYozenMfN1P
 6SGrH3FklB+j83MP6hKaX+lt2YkdOFidCHhtOY1vcd74u7G63x67LxOFxGx0n2dns9NcJwMhjQ2
 dnOP+RWOr88zyGoaMmpke7ub5TZbQhVVkxmeQdQnRfDaUjr2KX6NYmBPV1tcrToicE8p+SqN1JB
 HAbO0HUa8Z56gkHkHiS+EZ5in93iwbvE1wYMsTLtjXyZzDOdfAOl48Gk7UlDtzz/KiAcK6o+98z
 n0m+2K65BfoWg/1vPgR8PGsQgNsHm0B/yOpBS9JS9oa7vGatiZhw+QqZjwWKdqajuOTq1fAjhEm
 E+wipSMPQPr/6oezDqcbhYq04xjsZRtUHQ1n3AdeT+fr+5+eDGsKpMsIVCrH0t405W6eQ0WLM4w
 htPKPm7S3l9HpSQlumn/nAmpDkalz8htr0vqQdI63BQSem5SxBG5fQpEsHe3A/Fd8/VGTD63BL9
 6YxDnMW41bJ5Q9VkKHpUYswzwYZiy/Rdqh3iQ3FgCCnxAlFXWdLIpjAi6/tx7hGS5AJBk3UZLk0
 Etew9owCMUqAqWg==
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
the strparser.

The close_notify alert and the FIN sent at detach go out without
xpt_mutex. Both are non-blocking and never drop the socket lock
mid-push, so their bytes either reach write_seq and lower the position,
or park and hold it.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svcsock.h |  9 ++++
 include/trace/events/sunrpc.h  | 23 ++++++++--
 net/sunrpc/svcsock.c           | 96 +++++++++++++++++++++++++++++++++++-------
 3 files changed, 109 insertions(+), 19 deletions(-)

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
index 63382f99cd74..0db448ce7729 100644
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
@@ -1401,9 +1415,45 @@ static int svc_tcp_sendmsg(struct svc_sock *svsk, struct svc_rqst *rqstp,
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
+ * Unacknowledged bytes follow every older reply, and each reply occupies at
+ * least as many wire bytes as sk_send_pos counts for it. sk_send_pos less
+ * the unacknowledged count is therefore at or below the position the client
+ * has acknowledged. Backchannel calls, TLS framing, alerts, the FIN sent at
+ * detach, and a stale snd_una only lower the result.
  *
  * A call the peer sent before it acknowledged a reply precedes the
  * acknowledgment in the stream, so rcv_nxt at this point covers the
@@ -1414,13 +1464,17 @@ static int svc_tcp_sendmsg(struct svc_sock *svsk, struct svc_rqst *rqstp,
  * socket lock keeps write_seq, snd_una, and rcv_nxt from moving between
  * the reads and orders them against svc_tcp_acked_pos().
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
@@ -1428,22 +1482,28 @@ static void svc_tcp_update_acked(struct svc_sock *svsk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	u64 unacked, acked = 0, acked_pos;
 	u32 write_seq, snd_una;
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
 	if (svc_xprt_advance_acked(&svsk->sk_xprt, acked))
 		svsk->sk_acked_rcv = READ_ONCE(tp->rcv_nxt);
 	acked_pos = atomic64_read(&svsk->sk_xprt.xpt_acked_pos);
 	release_sock(sk);
 	trace_svcsock_tcp_acked(&svsk->sk_xprt, svsk->sk_send_pos, write_seq,
-				snd_una, acked, acked_pos);
+				snd_una, acked, acked_pos, reason);
 }
 
 /**
@@ -1459,6 +1519,12 @@ static void svc_tcp_update_acked(struct svc_sock *svsk)
  * and its lookup. A record in progress is counted from its first
  * octet, so a partially read retransmit withholds the position too.
  *
+ * Under kTLS, copied_seq advances by the whole ciphertext record when
+ * the strparser consumes it, before svc_tcp_recv_actor() sees any of
+ * its plaintext. Plaintext left on rx_list and a record ready in the
+ * strparser withhold the position as well; sk_is_readable() reports
+ * both.
+ *
  * Context: process context. May take and release the socket lock.
  * Return: xpt_acked_pos, or 0 while it cannot be acted on.
  */
@@ -1478,8 +1544,8 @@ static u64 svc_tcp_acked_pos(struct svc_rqst *rqstp)
 	pos = atomic64_read(&xprt->xpt_acked_pos);
 	pending = atomic_read(&xprt->xpt_recv_pending) -
 		  !!test_bit(RQ_RECV_PENDING, &rqstp->rq_flags);
-	if (pending || before(READ_ONCE(tcp_sk(sk)->copied_seq),
-			      svsk->sk_acked_rcv))
+	if (pending || sk_is_readable(sk) ||
+	    before(READ_ONCE(tcp_sk(sk)->copied_seq), svsk->sk_acked_rcv))
 		pos = 0;
 	release_sock(sk);
 	return pos;

-- 
2.56.0

