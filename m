Received: from mout.gmx.net (mout.gmx.net [212.227.15.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F8A6414421;
	Sun, 18 Oct 2026 18:01:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792346517; cv=none; b=Q4JqGRQWSskZjveHEG/tYWV3AJLVtF7zTK437/PZbOfsRP9LDt2MSJ1JehVjcrRjiQy7zjV9t3U42mHHL0PN9/S02ym1hwE4YAOGnWpEBr075vEfwApPvjfzk/awiL+atzNmY8IfM+pzjQTWkNRN03uPoU8BLGGTlaRJbHTHobo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792346517; c=relaxed/simple;
	bh=MwTYH8APUnPWxegDk375Gu5imkjmzFUQwIhYFxw8VdU=;
	h=Message-ID:In-Reply-To:References:From:Subject:To:Cc:Date; b=WQ2MEdqDxIqjN7kqIwHtEs/2kFh5hCi44qTp8tMSzts6o12RoWcDGRI4NLMOs8LJE0kyBteVbPlaBNf8eCIWQzg1o60rFgzndVYK48lF0rENX5nC8V8w8S9SPfIoe7+DlTcA0X9o5pbWI0JQe2au3DOyFWE8KKzXKlRqnnA8pxw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b=OEdjB67M; arc=none smtp.client-ip=212.227.15.18
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b="OEdjB67M"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1792346498; x=1792951298; i=jan.koester@gmx.net;
	bh=iQ5SKr0/akUjeFw7s72giaEKU1jtCvJu1iRtZQ10RtM=;
	h=X-UI-Sender-Class:Message-ID:In-Reply-To:References:From:Subject:
	 To:Cc:Date:Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=OEdjB67MXvYr8EP5ZhVmr+4F58hYW56iFRUYvfGpNPohuRAP6RNq0wtWo/TbV9FJ
	 z0ZiQzeIxvRxpGFuvJhBZBpb24Faz5ZbFXARDl6zqcKy5bL3/QxspWKtZRwAvEfWu
	 yrUobQFuoh0RVPXvXO+mJ19GPKzaCpTxjnb+xQJEUKQow4UZYFE5dsfDkuhwHR/re
	 Fzp8sxq2QQCWkawNq0bcEkSdV1aEnWxSatkhIegkAsqNsDnEAvNzySRdOTDp9mzMD
	 8LFkF60up3F3tN2k5AO4kEw456/rqgrLXyU1hAu/yBNyasG23QnyJ2bha/v3uzmZb
	 MzxthfXcA/ipK4paeQ==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx004
 [212.227.17.190]) with ESMTPSA (Nemesis) id 1Ml6mE-1wtN4I2ZTg-00cWj1; Sun, 18
 Oct 2026 20:01:38 +0200
Message-ID: <17d972a9d3d72e492c700c6efe6ba4eaf80149b0.1792346472.git.jan.koester@gmx.net>
In-Reply-To: <cover.1792346472.git.jan.koester@gmx.net>
References: <cover.1792346472.git.jan.koester@gmx.net>
From: Jan Koester <jan.koester@gmx.net>
Subject: [RFC PATCH 04/41] net: sock: read sk_uid through a seqcount
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
Date: Sun, 18 Oct 2026 20:01:25 +0200
X-Provags-ID: V03:K1:K8dllvfU0DoPI/jHeKDAww9njvvhAGjXSAzELFiQGNAURdemZPq
 o+wrJuzL/YWoVOku0ZK5ONh/5hpUHK/55OW72EBRYDfYIGLVT6lmlsaUwIUzce2MZ33hyg4
 DbaLbg1NLCOnmWCCnFgnlP+/FM2M1nt3B6594kjTAWiXc9ga6e/YLXfxiAlU9i3YudTLBxT
 E0OY/eBeY6B6/BOrxuBIw==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:HLs7DWkmcYw=;skM7hgNbRE5K0txJYFVB9GDX+Rt
 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
 YAmedZKKBOqnVsc9UeMI=
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

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

Signed-off-by: Jan Koester <jan.koester@gmx.net>
=2D--
 include/net/sock.h | 28 +++++++++++++++++++++++++---
 net/core/sock.c    |  6 +++++-
 net/socket.c       |  5 +++--
 3 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 60ea55dc18..0986d94665 100644
=2D-- a/include/net/sock.h
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
@@ -2109,11 +2112,23 @@ static inline int sk_rx_queue_get(const struct soc=
k *sk)
 	return -1;
 }
=20
+/*
+ * sk_uid is too big for WRITE_ONCE(): writers hold sk_callback_lock (or =
own
+ * the socket alone, before it is published) and bump sk_uid_seq around t=
he
+ * store, so sk_uid() can read it without a lock.
+ */
+static inline void __sk_set_uid(struct sock *sk, kuid_t uid)
+{
+	write_seqcount_begin(&sk->sk_uid_seq);
+	sk->sk_uid =3D uid;
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
=20
 static inline kuid_t sk_uid(const struct sock *sk)
 {
-	/* Paired with WRITE_ONCE() in sockfs_setattr() */
-	return READ_ONCE(sk->sk_uid);
+	unsigned int seq;
+	kuid_t uid;
+
+	/* Paired with __sk_set_uid() */
+	do {
+		seq =3D read_seqcount_begin(&sk->sk_uid_seq);
+		uid =3D sk->sk_uid;
+	} while (read_seqcount_retry(&sk->sk_uid_seq, seq));
+	return uid;
 }
=20
 static inline kuid_t sock_net_uid(const struct net *net, const struct soc=
k *sk)
diff --git a/net/core/sock.c b/net/core/sock.c
index e8551df833..300bc75ce1 100644
=2D-- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2449,6 +2449,7 @@ static void sk_init_common(struct sock *sk)
 	skb_queue_head_init(&sk->sk_error_queue);
=20
 	rwlock_init(&sk->sk_callback_lock);
+	seqcount_init(&sk->sk_uid_seq);
 	lockdep_set_class_and_name(&sk->sk_receive_queue.lock,
 			af_rlock_keys + sk->sk_family,
 			af_family_rlock_key_strings[sk->sk_family]);
@@ -2529,6 +2530,8 @@ struct sock *sk_clone(const struct sock *sk, const g=
fp_t priority,
=20
 	atomic_set(&newsk->sk_omem_alloc, 0);
 	sk_init_common(newsk);
+	/* sock_copy() may have caught a half written sk_uid */
+	newsk->sk_uid =3D sk_uid(sk);
=20
 	newsk->sk_dst_cache	=3D NULL;
 	newsk->sk_dst_pending_confirm =3D 0;
@@ -3773,7 +3776,7 @@ void sock_init_data_uid(struct socket *sock, struct =
sock *sk, kuid_t uid)
 	} else {
 		RCU_INIT_POINTER(sk->sk_wq, NULL);
 	}
-	sk->sk_uid	=3D	uid;
+	__sk_set_uid(sk, uid);
=20
 	sk->sk_state_change	=3D	sock_def_wakeup;
 	sk->sk_data_ready	=3D	sock_def_readable;
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
=2D-- a/net/socket.c
+++ b/net/socket.c
@@ -679,8 +679,9 @@ static int sockfs_setattr(struct mnt_idmap *idmap,
 		struct socket *sock =3D SOCKET_I(d_inode(dentry));
=20
 		if (sock->sk) {
-			/* Paired with READ_ONCE() in sk_uid() */
-			WRITE_ONCE(sock->sk->sk_uid, iattr->ia_uid);
+			write_lock_bh(&sock->sk->sk_callback_lock);
+			__sk_set_uid(sock->sk, iattr->ia_uid);
+			write_unlock_bh(&sock->sk->sk_callback_lock);
 		} else {
 			err =3D -ENOENT;
 		}
=2D-=20
2.56.0

