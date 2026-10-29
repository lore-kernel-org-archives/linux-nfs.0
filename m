Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297190;
	b=hnosh3oY6OPR+WekcMsihwn6Fno0OYbkZWDMnrWzaKz/UPBVvqReoS57nTxrgk5g36/5
	 EXdvXLD9/9H2PkC3CZ6Lz6hQl59ZiNOk0X8aNKkG1xYs0Dc6i8Sa4iSncp1PamGTcj2MJ
	 Tsrn5+fJeUpsVfQe9W/BUWZl8YHXHfv4h8cFYxX0r5xjAcceav+kJzuaI9xe8QemE1Y65
	 xndxwseDH7LQcjUy6Y8REjo6va5Znlpws/DzEr+m2JNWp0z3VVZchabQoRnTB9P462iej
	 lTlwxsZoLEO93NLDiaEQ/wQUGW2uVY0M5LpkJ3X7EbfbmKACeyN2AjJ+rd0lfaS+NBw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297190;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=mJigB4SeNL2KtodUgx8vt/v4zGYq99iiZ72nv6Tzyn4=;
	b=bucJE54S0RNlI8fV4ejNixoENS26kMYp/7/WGWqmY5+DdHyqQMXEVCsQfIaE5dTjAltd
	 qezbH39o5MlM0eoWFugri2TtXLJJKvH+OAgl4zz/pfipWDS1ihSGXPZLhsRQvGlMfzucl
	 ZyKcXoA8Wz4Xcug6daYOf0e1obKlXcmu/r572fQvIAY1mTMeBZJNslVMj0G3+jRieqYbk
	 k6bdrjviAsBriZN5Z8VirwuIEt88FSwPpFpM/+MWy4F3s3aqQrF2hfsmPE44ODWJKgRNW
	 Ed6sTgu07PEWKJDXHfTZ9y+Gx2RmNdZI4vATEAQhkXwqSSN8l9/LoRmW4nSd2uy9dVg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YUrV4QHa;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49AFD606A31F
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YUrV4QHa
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 560CA1F01824;
	Thu, 29 Oct 2026 18:06:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297190;
	bh=mJigB4SeNL2KtodUgx8vt/v4zGYq99iiZ72nv6Tzyn4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YUrV4QHaK/Ib2H6dLmX83dYqdxAiVd3BZSJGEmBGIt2KU7l50g+b4H9Knq6emghju
	 e/fmi4WbMgDzCiSa+R+gSW7WrdwxWYAb52XJkJ5ABuA+geL9iMGZROnsu2UoUQOmNC
	 qJr7bZ3uegrBaHDQm7EAgkaI/zXsh6ugp3kma/E+vBIXap0+IpQ/UAqVPKb/YaZCbT
	 qlKQkc+1uwHXm4we/4TG4YgsYcBFb4sdxymIzIjQUWtEp8ut4dkUrS5d3OMzL5HBGA
	 xUpUOWc6REtuTSp2kuRGCvh/mb43REHyPYploo9NtTQaka9In/jFlfDRMvtvzDjU0J
	 8tyET+Wj5AYdw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 14:06:15 -0400
Subject: [PATCH v7 09/13] SUNRPC: Publish TCP reply positions
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
Message-Id: <20261029-duplicate-reply-cache-v7-9-f3b0f3cf5bc7@kernel.org>
References: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
In-Reply-To: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=11442; i=cel@kernel.org;
 h=from:subject:message-id; bh=fC9BAlcvwptctK1mbJgxksLV6F9cjn0npYYrQLLdmB8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44sctmlgycEAEg19ggcQBoRfA04EYC3Nlg8mM
 LoR8JepRpGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLHAAKCRAzarMzb2Z/
 l6beEACj6YRqrM50YMR7XPLJYW3Wzpfhjo1a5UPyhLUrY9YzILYEsduFaFva97q30zmx2KFBGiY
 yd7iikZDmv/M637dSxpD6bdMZkfKxR5UYWNmdw9cRp+GmXcHmcBQVc2VY9Dev4aKYiabSpqiNub
 qfS54+LbnO34jolnJVK1nCkdxJiYiSQjjS5u2eIoOtKxnmSEDfHpm4PgYvELb38Nc8eFcFEhclp
 JTE4+H3Nc+eJpiyXwUxadIhn1MfjMHRqFDFABGkksO198dso525wp7LN7zIIx23EFP51Eh0fg2P
 0sNthg9bLVtPsMvNTV15UpV7/1SkPwtyASeQwvmVH5/I09dEy/9mt4QvOjbjK3ZBAPEdNat6RJP
 QNHSlCJFB8bmA9b1YRhyiWttDwVzyMIyXG0RH0tPj8oY8/s8LJWwuV1aQRaa/KrGPAe1T2WDg/H
 MrP7GP58pQ69XLVQLoh84G9QkXbfj8jHVZDpJvWY6/ACPNQI8iwL1Klc0nXPiN1f+nSK9LLjtZY
 3bvWu+52vF8g/zGf/voX/HhCYw89Vf8IGG+ya3sx8mzA8cPMdGFkqpvPZW/S7RfjUFFkAFrQuoO
 yGidCP8ENYXHHNU6Frh/51r7/5+xkLbDtffp3ZH7dElPSsig7IGwXI2yK4D08tYaR+fuH6lVj3q
 IgBTuUKQoYjnNFw==
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
retransmit withholds the position too. The socket lock keeps snd_una
and rcv_nxt from moving between the two reads and orders the pair
against the reader. Each cacheable call takes the lock once, after
the first position is published, and on a busy connection the
position lags a refresh by the time the requests ahead of the mark
take to reach their lookups.

The mark covers a retransmit TCP has delivered in order. When a
segment of the retransmit is lost on the wire, the acknowledgment the
peer sent after that segment arrives first. TCP processes the
acknowledgment, so snd_una covers the reply while rcv_nxt stops short
of the retransmit, and the socket does not record the gap. That
retransmit stays exposed until TCP delivers the lost segment.

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

Assisted-by: LLM
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-9-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svcsock.h |   7 +++
 include/trace/events/sunrpc.h  |  39 +++++++++++++++
 net/sunrpc/svcsock.c           | 109 ++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 154 insertions(+), 1 deletion(-)

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
index fd2f62652b93..63382f99cd74 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1120,6 +1120,15 @@ static int svc_tcp_recv_actor(read_descriptor_t *desc, struct sk_buff *skb,
 
 	len = min(len, desc->count);
 
+	/*
+	 * Once per record: an empty non-final fragment leaves sk_tcplen
+	 * and sk_datalen both zero again.
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
@@ -1382,6 +1400,91 @@ static int svc_tcp_sendmsg(struct svc_sock *svsk, struct svc_rqst *rqstp,
 	return ret;
 }
 
+/*
+ * Bytes the socket has not seen acknowledged all belong to the most
+ * recent replies, so sk_send_pos less that count is the acknowledged
+ * position.
+ *
+ * A call the peer sent before it acknowledged a reply precedes the
+ * acknowledgment in the stream, so rcv_nxt at this point covers the
+ * call unless a segment of the call was lost on the wire and the
+ * acknowledgment arrived first. TCP does not record that gap.
+ * Record that mark with the position; svc_tcp_acked_pos() releases
+ * the position once everything up to the mark has been read. The
+ * socket lock keeps write_seq, snd_una, and rcv_nxt from moving between
+ * the reads and orders them against svc_tcp_acked_pos().
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
+	u32 write_seq, snd_una;
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
+	if (svc_xprt_advance_acked(&svsk->sk_xprt, acked))
+		svsk->sk_acked_rcv = READ_ONCE(tp->rcv_nxt);
+	acked_pos = atomic64_read(&svsk->sk_xprt.xpt_acked_pos);
+	release_sock(sk);
+	trace_svcsock_tcp_acked(&svsk->sk_xprt, svsk->sk_send_pos, write_seq,
+				snd_una, acked, acked_pos);
+}
+
+/**
+ * svc_tcp_acked_pos - acknowledged position the reply cache may act on
+ * @rqstp: the request on whose behalf the position is read
+ *
+ * An acknowledgment proves the peer has the reply and sends no
+ * further retransmit of that call. A retransmit it sent earlier can
+ * still be on its way through this server: unread in the socket, or
+ * read and not yet looked up. Both were sent before the acknowledgment.
+ * Withhold the position until the socket has been read up to the mark
+ * taken with it and no request but @rqstp is counted between its read
+ * and its lookup. A record in progress is counted from its first
+ * octet, so a partially read retransmit withholds the position too.
+ *
+ * Context: process context. May take and release the socket lock.
+ * Return: xpt_acked_pos, or 0 while it cannot be acted on.
+ */
+static u64 svc_tcp_acked_pos(struct svc_rqst *rqstp)
+{
+	struct svc_xprt *xprt = rqstp->rq_xprt;
+	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
+	struct sock *sk = svsk->sk_sk;
+	int pending;
+	u64 pos;
+
+	/* The position only rises, so a zero read is final. */
+	if (!atomic64_read(&xprt->xpt_acked_pos))
+		return 0;
+
+	lock_sock(sk);
+	pos = atomic64_read(&xprt->xpt_acked_pos);
+	pending = atomic_read(&xprt->xpt_recv_pending) -
+		  !!test_bit(RQ_RECV_PENDING, &rqstp->rq_flags);
+	if (pending || before(READ_ONCE(tcp_sk(sk)->copied_seq),
+			      svsk->sk_acked_rcv))
+		pos = 0;
+	release_sock(sk);
+	return pos;
+}
+
 /**
  * svc_tcp_sendto - Send out a reply on a TCP socket
  * @rqstp: completed svc_rqst
@@ -1410,6 +1513,9 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 	trace_svcsock_tcp_send(xprt, sent);
 	if (sent < 0 || sent != (xdr->len + sizeof(marker)))
 		goto out_close;
+	svsk->sk_send_pos += sent;
+	rqstp->rq_reply_pos = svsk->sk_send_pos;
+	svc_tcp_update_acked(svsk);
 	mutex_unlock(&xprt->xpt_mutex);
 	return sent;
 
@@ -1446,6 +1552,7 @@ static const struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_accept = svc_tcp_accept,
 	.xpo_kill_temp_xprt = svc_tcp_kill_temp_xprt,
 	.xpo_handshake = svc_tcp_handshake,
+	.xpo_acked_pos = svc_tcp_acked_pos,
 };
 
 static struct svc_xprt_class svc_tcp_class = {

-- 
2.56.0

