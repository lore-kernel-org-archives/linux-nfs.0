Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:58458 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752363AbcDHNLe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Apr 2016 09:11:34 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 5D34E210F5
	for <linux-nfs@vger.kernel.org>; Fri,  8 Apr 2016 09:11:33 -0400 (EDT)
From: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH net-next] sock: tigthen lockdep checks for sock_owned_by_user
Date: Fri,  8 Apr 2016 15:11:27 +0200
Message-Id: <1460121087-2859-1-git-send-email-hannes@stressinduktion.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sock_owned_by_user should not be used without socket lock held. It seems
to be a common practice to check .owned before lock reclassification, so
provide a little help to abstract this check away.

Cc: linux-cifs@vger.kernel.org
Cc: linux-bluetooth@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 fs/cifs/connect.c            |  4 ++--
 include/net/sock.h           | 44 +++++++++++++++++++++++++++++---------------
 net/bluetooth/af_bluetooth.c |  2 +-
 net/llc/llc_proc.c           |  2 +-
 net/sunrpc/svcsock.c         |  3 +--
 net/sunrpc/xprtsock.c        |  3 +--
 6 files changed, 35 insertions(+), 23 deletions(-)

diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index a763cd3d9e7c80..3e37e52639394b 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -2918,7 +2918,7 @@ static inline void
 cifs_reclassify_socket4(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	BUG_ON(sock_owned_by_user(sk));
+	BUG_ON(!sock_allow_reclassification(sk));
 	sock_lock_init_class_and_name(sk, "slock-AF_INET-CIFS",
 		&cifs_slock_key[0], "sk_lock-AF_INET-CIFS", &cifs_key[0]);
 }
@@ -2927,7 +2927,7 @@ static inline void
 cifs_reclassify_socket6(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	BUG_ON(sock_owned_by_user(sk));
+	BUG_ON(!sock_allow_reclassification(sk));
 	sock_lock_init_class_and_name(sk, "slock-AF_INET6-CIFS",
 		&cifs_slock_key[1], "sk_lock-AF_INET6-CIFS", &cifs_key[1]);
 }
diff --git a/include/net/sock.h b/include/net/sock.h
index 81d6fecec0a2c0..baba58770ac593 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1316,21 +1316,6 @@ static inline void sk_wmem_free_skb(struct sock *sk, struct sk_buff *skb)
 	__kfree_skb(skb);
 }
 
-/* Used by processes to "lock" a socket state, so that
- * interrupts and bottom half handlers won't change it
- * from under us. It essentially blocks any incoming
- * packets, so that we won't get any new data or any
- * packets that change the state of the socket.
- *
- * While locked, BH processing will add new packets to
- * the backlog queue.  This queue is processed by the
- * owner of the socket lock right before it is released.
- *
- * Since ~2.3.5 it is also exclusive sleep lock serializing
- * accesses from user process context.
- */
-#define sock_owned_by_user(sk)	((sk)->sk_lock.owned)
-
 static inline void sock_release_ownership(struct sock *sk)
 {
 	if (sk->sk_lock.owned) {
@@ -1403,6 +1388,35 @@ static inline void unlock_sock_fast(struct sock *sk, bool slow)
 		spin_unlock_bh(&sk->sk_lock.slock);
 }
 
+/* Used by processes to "lock" a socket state, so that
+ * interrupts and bottom half handlers won't change it
+ * from under us. It essentially blocks any incoming
+ * packets, so that we won't get any new data or any
+ * packets that change the state of the socket.
+ *
+ * While locked, BH processing will add new packets to
+ * the backlog queue.  This queue is processed by the
+ * owner of the socket lock right before it is released.
+ *
+ * Since ~2.3.5 it is also exclusive sleep lock serializing
+ * accesses from user process context.
+ */
+
+static inline bool sock_owned_by_user(const struct sock *sk)
+{
+#ifdef CONFIG_LOCKDEP
+	WARN_ON(!lockdep_sock_is_held(sk));
+#endif
+	return sk->sk_lock.owned;
+}
+
+/* no reclassification while locks are held */
+static inline bool sock_allow_reclassification(const struct sock *csk)
+{
+	struct sock *sk = (struct sock *)csk;
+
+	return !sk->sk_lock.owned && !spin_is_locked(&sk->sk_lock.slock);
+}
 
 struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		      struct proto *prot, int kern);
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 955eda93e66f32..3df7aefb766335 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -65,7 +65,7 @@ static const char *const bt_slock_key_strings[BT_MAX_PROTO] = {
 void bt_sock_reclassify_lock(struct sock *sk, int proto)
 {
 	BUG_ON(!sk);
-	BUG_ON(sock_owned_by_user(sk));
+	BUG_ON(!sock_allow_reclassification(sk));
 
 	sock_lock_init_class_and_name(sk,
 			bt_slock_key_strings[proto], &bt_slock_key[proto],
diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index 1a3c7e0f5d0de3..29c509c54bb22d 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -195,7 +195,7 @@ static int llc_seq_core_show(struct seq_file *seq, void *v)
 		   timer_pending(&llc->pf_cycle_timer.timer),
 		   timer_pending(&llc->rej_sent_timer.timer),
 		   timer_pending(&llc->busy_state_timer.timer),
-		   !!sk->sk_backlog.tail, !!sock_owned_by_user(sk));
+		   !!sk->sk_backlog.tail, !!sk->sk_lock.owned);
 out:
 	return 0;
 }
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1413cdcc131c4a..bfe0a06530f6aa 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -85,8 +85,7 @@ static void svc_reclassify_socket(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	WARN_ON_ONCE(sock_owned_by_user(sk));
-	if (sock_owned_by_user(sk))
+	if (WARN_ON_ONCE(!sock_allow_reclassification(sk)))
 		return;
 
 	switch (sk->sk_family) {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 65e759569e4873..b7d6b76dede095 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1881,8 +1881,7 @@ static inline void xs_reclassify_socket6(struct socket *sock)
 
 static inline void xs_reclassify_socket(int family, struct socket *sock)
 {
-	WARN_ON_ONCE(sock_owned_by_user(sock->sk));
-	if (sock_owned_by_user(sock->sk))
+	if (WARN_ON_ONCE(!sock_allow_reclassification(sock->sk)))
 		return;
 
 	switch (family) {
-- 
2.5.5

