Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36256 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756295AbcECX4I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2016 19:56:08 -0400
Message-ID: <1462319763.5535.329.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: [PATCH net-next] tcp: fix lockdep splat in tcp_snd_una_update()
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Francois Romieu <romieu@fr.zoreil.com>, David Miller <davem@davemloft.net>
Cc: Fabio Estevam <festevam@gmail.com>, Eric Dumazet <edumazet@google.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Tue, 03 May 2016 16:56:03 -0700
In-Reply-To: <1462314901.5535.316.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160503223149.GA19739@electric-eye.fr.zoreil.com>
	 <1462314901.5535.316.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_snd_una_update() and tcp_rcv_nxt_update() call
u64_stats_update_begin() either from process context or BH handler.

This triggers a lockdep splat on 32bit & SMP builds.

We could add u64_stats_update_begin_bh() variant but this would
slow down 32bit builds with useless local_disable_bh() and
local_enable_bh() pairs, since we own the socket lock at this point.

I add sock_owned_by_me() helper to have proper lockdep support
even on 64bit builds, and new u64_stats_update_begin_raw()
and u64_stats_update_end_raw methods.

Fixes: c10d9310edf5 ("tcp: do not assume TCP code is non preemptible")
Reported-by: Fabio Estevam <festevam@gmail.com>
Diagnosed-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/u64_stats_sync.h |   14 ++++++++++++++
 include/net/sock.h             |    7 ++++++-
 net/ipv4/tcp_input.c           |   10 ++++++----
 3 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/include/linux/u64_stats_sync.h b/include/linux/u64_stats_sync.h
index df89c9bcba7db8dbde3bbf2b99f9af6ed562b112..d3a2bb712af3b9613b98ef9c3219f8dcd31568a5 100644
--- a/include/linux/u64_stats_sync.h
+++ b/include/linux/u64_stats_sync.h
@@ -89,6 +89,20 @@ static inline void u64_stats_update_end(struct u64_stats_sync *syncp)
 #endif
 }
 
+static inline void u64_stats_update_begin_raw(struct u64_stats_sync *syncp)
+{
+#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
+	raw_write_seqcount_begin(&syncp->seq);
+#endif
+}
+
+static inline void u64_stats_update_end_raw(struct u64_stats_sync *syncp)
+{
+#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
+	raw_write_seqcount_end(&syncp->seq);
+#endif
+}
+
 static inline unsigned int u64_stats_fetch_begin(const struct u64_stats_sync *syncp)
 {
 #if BITS_PER_LONG==32 && defined(CONFIG_SMP)
diff --git a/include/net/sock.h b/include/net/sock.h
index 45f5b492c65883cd22e2f615e019fe0d0ba31167..c9c8b19df27c558354687119db60c0716909ea3f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1421,11 +1421,16 @@ static inline void unlock_sock_fast(struct sock *sk, bool slow)
  * accesses from user process context.
  */
 
-static inline bool sock_owned_by_user(const struct sock *sk)
+static inline void sock_owned_by_me(const struct sock *sk)
 {
 #ifdef CONFIG_LOCKDEP
 	WARN_ON_ONCE(!lockdep_sock_is_held(sk) && debug_locks);
 #endif
+}
+
+static inline bool sock_owned_by_user(const struct sock *sk)
+{
+	sock_owned_by_me(sk);
 	return sk->sk_lock.owned;
 }
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6171f92be0903f5a5d17f027dbe6b31829bcc043..a914e0607895dd9321559f93c1008f8de13b73ad 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3355,9 +3355,10 @@ static void tcp_snd_una_update(struct tcp_sock *tp, u32 ack)
 {
 	u32 delta = ack - tp->snd_una;
 
-	u64_stats_update_begin(&tp->syncp);
+	sock_owned_by_me((struct sock *)tp);
+	u64_stats_update_begin_raw(&tp->syncp);
 	tp->bytes_acked += delta;
-	u64_stats_update_end(&tp->syncp);
+	u64_stats_update_end_raw(&tp->syncp);
 	tp->snd_una = ack;
 }
 
@@ -3366,9 +3367,10 @@ static void tcp_rcv_nxt_update(struct tcp_sock *tp, u32 seq)
 {
 	u32 delta = seq - tp->rcv_nxt;
 
-	u64_stats_update_begin(&tp->syncp);
+	sock_owned_by_me((struct sock *)tp);
+	u64_stats_update_begin_raw(&tp->syncp);
 	tp->bytes_received += delta;
-	u64_stats_update_end(&tp->syncp);
+	u64_stats_update_end_raw(&tp->syncp);
 	tp->rcv_nxt = seq;
 }
 


