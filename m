Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7E9F238D40C;
	Tue, 29 Sep 2026 07:18:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790666317; cv=none; b=ZoH3q04Ntm50H5UScgs4Lyo9stUaONFXHbSdIEdMWQEs1HmJwnxyE/3WFO8rSBgOQy5gcWst8W8RJIrMT3/ZGpC+Ejps6dDzSvM2cBznpcCqQ0FDTK+/CVB/EsKQO+5kfGRxp6SG3ss8O4eKLyjnnw2JtOFr7S0K9Qt/Odrk7kY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790666317; c=relaxed/simple;
	bh=jQmGCc2/iG+Fxzc7NtK/xVAyJnW/IOSF7+4undCVxuk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CScTLqNLx+oVrML1jEUKl/FKy0VHRy+7Je5mRxwulKOmMZHI4n8q2dGHOgHwfjXmXz2lY+vNzQhRFSDgX3kL+1lwbVQqmFz97W4uHAvZ2zpYtovR6jstOIhDfJGg+IEsKfkxFBw69Bslmbt1MrZegTekIIe9YUg4GViBTOXZHrs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QNKqNJNl; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QNKqNJNl"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B38011F00898;
	Tue, 29 Sep 2026 07:18:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790666315;
	bh=k2Vfim/g6/2BnfyDLSTpDSiAzp7UsiZpcueZY9H3mdc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=QNKqNJNl7YHdFdjAi0Dpebnz6k7OXyNfPXP8S9d5ATNnmI5ULQvWiXdm8A8c6rcWV
	 tSmDrJUQAh4PTHVGE6Aohe0xr+6RiVGYHSbA5/vbhUx5tBrVGdI7NvgGetc4veYzy3
	 pOq/DK3bysdQRinO5VEk5mlRZ1SabFJHPLRpVs5Hi0M/mXdS6jcltyVPe9wUlFQQl5
	 IllyxSaa98ynlSIpjkmfVJ9aq83IFOjaLFGl0mxIcfNB9wBtl2+2lJOw/v/pOpdvHf
	 bmPVLeDKyZUSOBGC13zrTRdCmHmgspdqNm7D/Fqd0MPkV69HOfquO7cCnQKbO+2SRU
	 qRI8t5S2Xh40w==
From: Eric Dumazet <edumazet@kernel.org>
To: "David S . Miller" <davem@davemloft.net>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>
Cc: Simon Horman <horms@kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Kuniyuki Iwashima <kuniyu@google.com>,
	edumazet@google.com,
	netdev@vger.kernel.org,
	Alexander Aring <aahringo@redhat.com>,
	David Teigland <teigland@redhat.com>,
	gfs2@lists.linux.dev,
	John Fastabend <john.fastabend@gmail.com>,
	Jakub Sitnicki <jakub@cloudflare.com>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Jiayuan Chen <jiayuan.chen@linux.dev>,
	Matthieu Baerts <matttbe@kernel.org>,
	Mat Martineau <martineau@kernel.org>,
	Geliang Tang <geliang@kernel.org>,
	mptcp@lists.linux.dev,
	Wen Gu <guwen@linux.alibaba.com>,
	Dust Li <dust.li@linux.alibaba.com>,
	"D. Wythe" <alibuda@linux.alibaba.com>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org,
	Allison Henderson <achender@kernel.org>,
	rds-devel@oss.oracle.com,
	Philipp Reisner <philipp.reisner@linbit.com>,
	Lars Ellenberg <lars.ellenberg@linbit.com>,
	=?UTF-8?q?Christoph=20B=C3=B6hmwalder?= <christoph.boehmwalder@linbit.com>,
	Jens Axboe <axboe@kernel.dk>,
	drbd-dev@lists.linux.dev,
	Keith Busch <kbusch@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Sagi Grimberg <sagi@grimberg.me>,
	Chaitanya Kulkarni <kch@nvidia.com>,
	linux-nvme@lists.infradead.org,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	ceph-devel@vger.kernel.org,
	Eric Dumazet <edumazet@kernel.org>
Subject: [PATCH v3 net-next 9/9] tcp: add tp->tcp_nospace
Date: Tue, 29 Sep 2026 07:17:43 +0000
Message-ID: <20260929071743.23624-10-edumazet@kernel.org>
X-Mailer: git-send-email 2.56.0.rc1.315.gc6ed9934b7-goog
In-Reply-To: <20260929071743.23624-1-edumazet@kernel.org>
References: <20260929071743.23624-1-edumazet@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

tcp_check_space() runs for every incoming ACK and for every packet we
send, and reads SOCK_NOSPACE from sk->sk_socket->flags.

struct socket lives in its own cache line, which the TCP fast paths do
not otherwise touch, so testing sk->sk_socket->flags pulls in an extra
cache line that is cold when the working set is large.

Add tp->tcp_nospace, a mirror of SOCK_NOSPACE placed right after
tp->chrono_type in the tcp_sock_write_tx group, in a cache line both
the transmit and the ACK paths already touch (bytes_sent, data_segs_out,
delivered, bytes_acked, chrono_type).  It fits in an existing 3-byte
hole before chrono_start, so no other field moves and sizeof(struct
tcp_sock) is unchanged.

The two flags are now only changed from sk_set_nospace() and
sk_clear_nospace(), which maintain this invariant:

	SOCK_NOSPACE set  =>  tp->tcp_nospace set

sk_set_nospace() sets SOCK_NOSPACE before tp->tcp_nospace (using
smp_mb__after_atomic() and smp_store_mb()), while sk_clear_nospace()
clears tp->tcp_nospace before SOCK_NOSPACE (using
smp_mb__before_atomic()).  If a lockless sk_set_nospace() from
tcp_poll() races with sk_clear_nospace() and SOCK_NOSPACE ends up set,
set_bit(SOCK_NOSPACE) happened after clear_bit(SOCK_NOSPACE), so
tp->tcp_nospace = 1 happens after tp->tcp_nospace = 0 as well.

tcp_check_space() can thus test tp->tcp_nospace alone and leave the
authoritative SOCK_NOSPACE test to __tcp_check_space().  The
invariant is one directional on purpose: a stale tp->tcp_nospace only
costs an extra call to __tcp_check_space(), which is what we do
unconditionally today, while a stale SOCK_NOSPACE would cost a
missed EPOLLOUT.

Note the smp_mb() is kept.  tcp_poll() sets the flag without the
socket lock, and the store-buffer pattern it forms with
tcp_check_space() needs a full barrier on both sides.

MPTCP subflows share the struct socket of their parent, hence its
SOCK_NOSPACE bit, which can not be mirrored in the subflow tcp_sock.
Pin their tp->tcp_nospace in subflow_ulp_init(), so that they always
reach __tcp_check_space() and keep the current behavior.

Microbenchmark on an AMD EPYC 7B13, 64 threads, each thread calling
tcp_check_space() in a loop over a private set of sockets.  Numbers
are cycles per call above a baseline loop that performs the work the
callers already did (the cache lines tcp_write_xmit() and
tcp_clean_rtx_queue() touched) but not tcp_check_space() itself, so
they are the marginal cost of the function.  Median of 11 runs.
The set size controls whether struct socket is still cached:

    sockets/thread	before	 after
    1			  +0.6	  +0.7
    256    (64 KB)	  +8.3	  +3.9
    4096   (1 MB)	 +22.4	  +1.1
    262144 (64 MB)	 +48.4	  -0.8

Signed-off-by: Eric Dumazet <edumazet@kernel.org>
---
 .../networking/net_cachelines/tcp_sock.rst    |  1 +
 include/linux/tcp.h                           |  3 ++
 include/net/tcp.h                             | 30 ++++++++++++++++++-
 net/core/sock.c                               | 17 ++++++++---
 net/ipv4/tcp.c                                |  1 +
 net/ipv4/tcp_input.c                          |  8 ++++-
 net/mptcp/subflow.c                           |  5 ++++
 7 files changed, 59 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/net_cachelines/tcp_sock.rst b/Documentation/networking/net_cachelines/tcp_sock.rst
index 0f6088c4ab8bb872e7fc86f02479592e84c0247a..103328dc409e4485a3f989c95348c1bc74ab20c6 100644
--- a/Documentation/networking/net_cachelines/tcp_sock.rst
+++ b/Documentation/networking/net_cachelines/tcp_sock.rst
@@ -50,6 +50,7 @@ u8:1                          tcp_usec_ts             read_mostly         read_m
 u32                           chrono_start            read_write                              tcp_chrono_start/stop(tcp_write_xmit,tcp_cwnd_validate,tcp_send_syn_data)
 u32[3]                        chrono_stat             read_write                              tcp_chrono_start/stop(tcp_write_xmit,tcp_cwnd_validate,tcp_send_syn_data)
 u8:2                          chrono_type             read_write                              tcp_chrono_start/stop(tcp_write_xmit,tcp_cwnd_validate,tcp_send_syn_data)
+u8                            tcp_nospace             read_mostly         read_mostly         tcp_check_space(tx);tcp_check_space(rx)
 u8:1                          rate_app_limited                            read_write          tcp_rate_gen
 u8:1                          fastopen_connect
 u8:1                          fastopen_no_cookie
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 6a8c77719322f9caee305d954a107892c76d4ef7..e4d1720f49f08f3c12f5ba66fe8fe3379d71b1e0 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -269,6 +269,9 @@ struct tcp_sock {
 				 */
 	u32	snd_sml;	/* Last byte of the most recently transmitted small packet */
 	u8	chrono_type;	/* current chronograph type */
+	u8	tcp_nospace;	/* mirrors SOCK_NOSPACE, must be set whenever
+				 * SOCK_NOSPACE is set.
+				 */
 	u32	chrono_start;	/* Start time in jiffies of a TCP chrono */
 	u32	chrono_stat[3];	/* Time in jiffies for chrono_stat stats */
 	u32	write_seq;	/* Tail(+1) of data held in tcp send buffer */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 96a1a23e47fac9b2f8717a4e129f468d40c6cfb5..08c04f7b32960e66ae5885dc93710569abda62e5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -783,14 +783,42 @@ void tcp_done_with_error(struct sock *sk, int err);
 void tcp_reset(struct sock *sk, struct sk_buff *skb);
 void tcp_fin(struct sock *sk);
 void __tcp_check_space(struct sock *sk);
+
+/* Mirror of SOCK_NOSPACE in tcp_sock, maintained by sk_set_nospace()
+ * and sk_clear_nospace().
+ *
+ * MPTCP subflows share the parent socket, and thus its SOCK_NOSPACE bit.
+ * Keep their mirror always set (see subflow_ulp_init()) so that they
+ * always reach __tcp_check_space() and behave as before.
+ */
+static inline void tcp_set_nospace(struct sock *sk)
+{
+	if (sk_is_tcp(sk)) {
+		/* pairs with smp_mb__before_atomic() in tcp_clear_nospace() */
+		smp_mb__after_atomic();
+		/* pairs with smp_mb() in tcp_check_space() */
+		smp_store_mb(tcp_sk(sk)->tcp_nospace, 1);
+	}
+}
+
+static inline void tcp_clear_nospace(struct sock *sk)
+{
+	if (sk_is_tcp(sk) && !sk_is_mptcp(sk)) {
+		WRITE_ONCE(tcp_sk(sk)->tcp_nospace, 0);
+		/* pairs with smp_mb__after_atomic() in tcp_set_nospace() */
+		smp_mb__before_atomic();
+	}
+}
+
 static inline void tcp_check_space(struct sock *sk)
 {
 	/* pairs with tcp_poll() */
 	smp_mb();
 
-	if (sk->sk_socket && test_bit(SOCK_NOSPACE, &sk->sk_socket->flags))
+	if (unlikely(READ_ONCE(tcp_sk(sk)->tcp_nospace)))
 		__tcp_check_space(sk);
 }
+
 void tcp_sack_compress_send_ack(struct sock *sk);
 
 static inline void tcp_cleanup_skb(struct sk_buff *skb)
diff --git a/net/core/sock.c b/net/core/sock.c
index 11a22aec7e414152aab115e8d11e30067ab3775f..946f614f665b3608d1f310da908d82de622ec5c0 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2969,8 +2969,15 @@ void sk_set_nospace(struct sock *sk)
 {
 	struct socket *sock = sk->sk_socket;
 
-	if (sock)
-		set_bit(SOCK_NOSPACE, &sock->flags);
+	if (!sock)
+		return;
+	/* Set SOCK_NOSPACE before tp->tcp_nospace (paired with
+	 * sk_clear_nospace() clearing tp->tcp_nospace before SOCK_NOSPACE)
+	 * so a concurrent clear cannot leave SOCK_NOSPACE set with
+	 * tp->tcp_nospace cleared.
+	 */
+	set_bit(SOCK_NOSPACE, &sock->flags);
+	tcp_set_nospace(sk);
 }
 EXPORT_SYMBOL(sk_set_nospace);
 
@@ -2985,8 +2992,10 @@ void sk_clear_nospace(struct sock *sk)
 {
 	struct socket *sock = sk->sk_socket;
 
-	if (sock)
-		clear_bit(SOCK_NOSPACE, &sock->flags);
+	if (!sock)
+		return;
+	tcp_clear_nospace(sk);
+	clear_bit(SOCK_NOSPACE, &sock->flags);
 }
 EXPORT_SYMBOL(sk_clear_nospace);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1cde000cfab4704e6756872f6ddec16851ccc55d..f44cbd3e76178a5ec5b40e420b32836477c29266 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -5242,6 +5242,7 @@ static void __init tcp_struct_check(void)
 	CACHELINE_ASSERT_GROUP_MEMBER(struct tcp_sock, tcp_sock_write_tx, first_tx_mstamp);
 	CACHELINE_ASSERT_GROUP_MEMBER(struct tcp_sock, tcp_sock_write_tx, delivered_mstamp);
 	CACHELINE_ASSERT_GROUP_MEMBER(struct tcp_sock, tcp_sock_write_tx, snd_sml);
+	CACHELINE_ASSERT_GROUP_MEMBER(struct tcp_sock, tcp_sock_write_tx, tcp_nospace);
 	CACHELINE_ASSERT_GROUP_MEMBER(struct tcp_sock, tcp_sock_write_tx, chrono_start);
 	CACHELINE_ASSERT_GROUP_MEMBER(struct tcp_sock, tcp_sock_write_tx, chrono_stat);
 	CACHELINE_ASSERT_GROUP_MEMBER(struct tcp_sock, tcp_sock_write_tx, write_seq);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 892ff256e235272a8483a11949cc98b319dd7cc9..cdea30d07fe2c2a38c3d38da27ad3274221d5958 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6098,8 +6098,14 @@ static void tcp_new_space(struct sock *sk)
  */
 void __tcp_check_space(struct sock *sk)
 {
+	struct socket *sock = sk->sk_socket;
+
+	/* tp->tcp_nospace is only a hint, SOCK_NOSPACE is authoritative. */
+	if (!sock || !test_bit(SOCK_NOSPACE, &sock->flags))
+		return;
+
 	tcp_new_space(sk);
-	if (!test_bit(SOCK_NOSPACE, &sk->sk_socket->flags))
+	if (!test_bit(SOCK_NOSPACE, &sock->flags))
 		tcp_chrono_stop(sk, TCP_CHRONO_SNDBUF_LIMITED);
 }
 
diff --git a/net/mptcp/subflow.c b/net/mptcp/subflow.c
index f0a6725d2c3762def75c879e769e9da37f92215a..e297c88be503b42979886baaf43acfb6b7e78055 100644
--- a/net/mptcp/subflow.c
+++ b/net/mptcp/subflow.c
@@ -2001,6 +2001,11 @@ static int subflow_ulp_init(struct sock *sk)
 	pr_debug("subflow=%p, family=%d\n", ctx, sk->sk_family);
 
 	tp->is_mptcp = 1;
+	/* Subflows share the MPTCP socket, and thus its SOCK_NOSPACE bit,
+	 * which tcp_check_space() can not mirror. Pin the mirror so that
+	 * __tcp_check_space() always tests the shared bit.
+	 */
+	tp->tcp_nospace = 1;
 	ctx->icsk_af_ops = icsk->icsk_af_ops;
 	icsk->icsk_af_ops = subflow_default_af_ops(sk);
 	ctx->tcp_state_change = sk->sk_state_change;
-- 
2.56.0.rc1.315.gc6ed9934b7-goog

