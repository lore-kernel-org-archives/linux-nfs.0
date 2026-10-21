Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552537;
	b=4sYwXOpn/qfImY3Mo+4bD5Z2jD4xlhHV3RmLPPRLcFhR79Qk+Ujga2Ee2HF55dPFSPDj
	 Yf1Xr/XZGfp4ys++h1vkd4u6QAgbcGbvpcMVHeQVL3yqF+P+8FfYsdhIyN7fMcuEPZLAS
	 tzsyRpKaAw/ENZRZebfymKo+oizXWv2eYvA//Xm7rU8QufEf3HBo8mZF+uIFT2NDI9IZ7
	 pud6FbHz/aKJjzaKVWhRviIO3Yhr4G4bfD+t1qZM9FoK8+lvUc03GkBwav2Kek0tzyLxW
	 IMrnnVeaWkLo3azQyFfzktyb+WftjaxZ5XckqryA5Zo2PgaewbOjlJNavC0RHOOhXMA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552537;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=HMd/LhFiSsFuUYgF3DoYFaxx108CwQyplewkGi6fm7o=;
	b=TM3Nw7VhxK3uRdQTCMX/mdNdO0omuTSTYgwhQ4VlBI4wbq/P5kk8I/oXbPdeYNEPffnU
	 GpYB9BJsqHLMmhcWpNc4zN9caWWU/0tklVgAnKQQzvZNDQ2nVlvF+K7JxihYjyrSzlkKG
	 FLj/esZ5c1/zxYF9hQNj9YrKaYr1QHoZrYA0i2ybPAKUg23at5t9bhYGA3kZpO2xPlChE
	 HcoH9v1zph/Z/DLJnp4HOsRJhtYExof5dkopxg+osu4ikBdIXHkRiuJQ49uhhlRynZ9Rg
	 Vjru8MmxVW7oSC9fJeDd3mveEWHif8bd9U+lbyFHvcYUOV3Y5HeVvrbSUnuJ4HIzagA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=IgCgCTfj;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0932D60A2604;
	Wed, 21 Oct 2026 03:15:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0932D60A2604
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=IgCgCTfj
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552534; bh=V6GrFNZTl5tPKiExMQYs87W29bXvBqYm+WvAZXrbo2s=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=IgCgCTfjR9wrFqrKGOHcuNWIt+r5r0JahUnZSTNWRFLw9lXjiAnyvdkrAIxnacRuI
	 qObQYVxkMsz19mnkP6AA/ixYKKrDQqvZqmcEQX7vkh1tJwgf59Xrjr9t8ngXbiOT9u
	 TSiMVQOlsahlUUctR/+clTIdi/39x8OxpVuxn0dQsjCPjDEuuRTjwjc0U9RqByl9Xh
	 MGyMLHr43T1Fxd+r5135/5ewqb8yeZ1v585ozgi5X8bQ3sGbCmbXZVS6Q3EPL581Ps
	 PzCqn0r0/EEbGJAuthrWf6pa2PMi7lm0k6O/K7qtPK3GxXcXkbzsWx4Rp0L31+BH3p
	 W7CzUU9NI3qLg==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 064C28A0651;
	Wed, 21 Oct 2026 05:15:33 +0200 (CEST)
Message-ID: <3ace21531501a80a31350f9a178828212fc7a224.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 04/41] net: sock: read sk_uid through a seqcount
To: Christian Brauner <brauner@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>,
    "Theodore Y. Ts'o" <tytso@mit.edu>,
    Paul Moore <paul@paul-moore.com>,
    Arnd Bergmann <arnd@arndb.de>,
    linux-fsdevel@vger.kernel.org,
    linux-api@vger.kernel.org,
    linux-security-module@vger.kernel.org,
    linux-arch@vger.kernel.org,
    linux-ext4@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-cifs@vger.kernel.org,
    netdev@vger.kernel.org,
    audit@vger.kernel.org,
    keyrings@vger.kernel.org,
    linux-kernel@vger.kernel.org
Date: Wed, 21 Oct 2026 05:15:24 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

sk_uid is read without a lock, with READ_ONCE(), by the routing lookups
and the reuseport checks, while sockfs_setattr() may change it. That
only works for as long as a kuid_t is a single word, which it won't be
once ids can be UUIDs and GUIDs.

Add sk_uid_seq next to it: writers bump it around the store and hold
sk_callback_lock (sock_graft(), sockfs_setattr()) or own the socket
alone (sock_init_data_uid()); sk_uid() retries until it sees a whole
id. sk_clone() reads the parent's id the same way rather than relying
on the copy made by sock_copy().

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 include/net/sock.h | 28 +++++++++++++++++++++++++---
 net/core/sock.c    |  6 +++++-
 net/socket.c       |  5 +++--
 3 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 60ea55dc18..0986d94665 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -294,6 +294,8 @@ struct sk_filter;
   *	@sk_ack_backlog: current listen backlog
   *	@sk_max_ack_backlog: listen backlog set in listen()
   *	@sk_uid: user id of owner
+  *	@sk_uid_seq: makes lockless reads of @sk_uid see a whole id; writers
+  *		     hold @sk_callback_lock
   *	@sk_ino: inode number (zero if orphaned)
   *	@sk_prefer_busy_poll: prefer busypolling over softirq processing
   *	@sk_busy_poll_budget: napi processing budget when busypolling
@@ -509,6 +511,7 @@ struct sock {
 	u32			sk_priority;
 	u32			sk_mark;
 	kuid_t			sk_uid;
+	seqcount_t		sk_uid_seq;
 	u16			sk_protocol;
 	u16			sk_type;
 	struct dst_entry __rcu	*sk_dst_cache;
@@ -2109,11 +2112,23 @@ static inline int sk_rx_queue_get(const struct sock *sk)
 	return -1;
 }
 
+/*
+ * sk_uid is too big for WRITE_ONCE(): writers hold sk_callback_lock (or own
+ * the socket alone, before it is published) and bump sk_uid_seq around the
+ * store, so sk_uid() can read it without a lock.
+ */
+static inline void __sk_set_uid(struct sock *sk, kuid_t uid)
+{
+	write_seqcount_begin(&sk->sk_uid_seq);
+	sk->sk_uid = uid;
+	write_seqcount_end(&sk->sk_uid_seq);
+}
+
 static inline void sk_set_socket(struct sock *sk, struct socket *sock)
 {
 	WRITE_ONCE(sk->sk_socket, sock);
 	if (sock) {
-		WRITE_ONCE(sk->sk_uid, SOCK_INODE(sock)->i_uid);
+		__sk_set_uid(sk, SOCK_INODE(sock)->i_uid);
 		WRITE_ONCE(sk->sk_ino, SOCK_INODE(sock)->i_ino);
 	} else {
 		/* Note: sk_uid is unchanged. */
@@ -2161,8 +2176,15 @@ static inline u64 sock_i_ino(const struct sock *sk)
 
 static inline kuid_t sk_uid(const struct sock *sk)
 {
-	/* Paired with WRITE_ONCE() in sockfs_setattr() */
-	return READ_ONCE(sk->sk_uid);
+	unsigned int seq;
+	kuid_t uid;
+
+	/* Paired with __sk_set_uid() */
+	do {
+		seq = read_seqcount_begin(&sk->sk_uid_seq);
+		uid = sk->sk_uid;
+	} while (read_seqcount_retry(&sk->sk_uid_seq, seq));
+	return uid;
 }
 
 static inline kuid_t sock_net_uid(const struct net *net, const struct sock *sk)
diff --git a/net/core/sock.c b/net/core/sock.c
index e8551df833..300bc75ce1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2449,6 +2449,7 @@ static void sk_init_common(struct sock *sk)
 	skb_queue_head_init(&sk->sk_error_queue);
 
 	rwlock_init(&sk->sk_callback_lock);
+	seqcount_init(&sk->sk_uid_seq);
 	lockdep_set_class_and_name(&sk->sk_receive_queue.lock,
 			af_rlock_keys + sk->sk_family,
 			af_family_rlock_key_strings[sk->sk_family]);
@@ -2529,6 +2530,8 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority,
 
 	atomic_set(&newsk->sk_omem_alloc, 0);
 	sk_init_common(newsk);
+	/* sock_copy() may have caught a half written sk_uid */
+	newsk->sk_uid = sk_uid(sk);
 
 	newsk->sk_dst_cache	= NULL;
 	newsk->sk_dst_pending_confirm = 0;
@@ -3773,7 +3776,7 @@ void sock_init_data_uid(struct socket *sock, struct sock *sk, kuid_t uid)
 	} else {
 		RCU_INIT_POINTER(sk->sk_wq, NULL);
 	}
-	sk->sk_uid	=	uid;
+	__sk_set_uid(sk, uid);
 
 	sk->sk_state_change	=	sock_def_wakeup;
 	sk->sk_data_ready	=	sock_def_readable;
@@ -4614,6 +4617,7 @@ static int __init sock_struct_check(void)
 	CACHELINE_ASSERT_GROUP_MEMBER(struct sock, sock_read_tx, sk_priority);
 	CACHELINE_ASSERT_GROUP_MEMBER(struct sock, sock_read_tx, sk_mark);
 	CACHELINE_ASSERT_GROUP_MEMBER(struct sock, sock_read_tx, sk_uid);
+	CACHELINE_ASSERT_GROUP_MEMBER(struct sock, sock_read_tx, sk_uid_seq);
 	CACHELINE_ASSERT_GROUP_MEMBER(struct sock, sock_read_tx, sk_protocol);
 	CACHELINE_ASSERT_GROUP_MEMBER(struct sock, sock_read_tx, sk_dst_cache);
 	CACHELINE_ASSERT_GROUP_MEMBER(struct sock, sock_read_tx, sk_route_caps);
diff --git a/net/socket.c b/net/socket.c
index c05d86e63a..09658f3958 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -679,8 +679,9 @@ static int sockfs_setattr(struct mnt_idmap *idmap,
 		struct socket *sock = SOCKET_I(d_inode(dentry));
 
 		if (sock->sk) {
-			/* Paired with READ_ONCE() in sk_uid() */
-			WRITE_ONCE(sock->sk->sk_uid, iattr->ia_uid);
+			write_lock_bh(&sock->sk->sk_callback_lock);
+			__sk_set_uid(sock->sk, iattr->ia_uid);
+			write_unlock_bh(&sock->sk->sk_callback_lock);
 		} else {
 			err = -ENOENT;
 		}
-- 
2.56.0

