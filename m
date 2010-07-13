From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 14/30] net: sk_allocation() - concentrate socket related allocations
Date: Tue, 13 Jul 2010 06:19:28 -0400
Message-ID: <20100713101928.2835.65030.sendpatchset@danny.redhat>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Cc: riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl,
        Xiaotian Feng <dfeng@redhat.com>, linux-kernel@vger.kernel.org,
        lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org,
        davem@davemloft.net
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-nfs.vger.kernel.org>

>From 3bc4f5211d8716267891ff85385177f181e418ea Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 11:04:45 +0800
Subject: [PATCH 14/30] net: sk_allocation() - concentrate socket related allocations

Introduce sk_allocation(), this function allows to inject sock specific
flags to each sock related allocation.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 include/linux/skbuff.h |    3 +++
 include/net/sock.h     |    5 +++++
 net/ipv4/tcp.c         |    3 ++-
 net/ipv4/tcp_output.c  |   11 ++++++-----
 net/ipv6/tcp_ipv6.c    |   15 +++++++++++----
 5 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ac74ee0..988a4dc 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1119,6 +1119,9 @@ static inline void skb_fill_page_desc(struct sk_buff *skb, int i,
 extern void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page,
 			    int off, int size);
 
+extern void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page,
+			    int off, int size);
+
 #define SKB_PAGE_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->nr_frags)
 #define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_has_frags(skb))
 #define SKB_LINEAR_ASSERT(skb)  BUG_ON(skb_is_nonlinear(skb))
diff --git a/include/net/sock.h b/include/net/sock.h
index 4f26f2f..9ddb37b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -563,6 +563,11 @@ static inline int sock_flag(struct sock *sk, enum sock_flags flag)
 	return test_bit(flag, &sk->sk_flags);
 }
 
+static inline gfp_t sk_allocation(struct sock *sk, gfp_t gfp_mask)
+{
+	return gfp_mask;
+}
+
 static inline void sk_acceptq_removed(struct sock *sk)
 {
 	sk->sk_ack_backlog--;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4e6ddfb..8ffe2c8 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -683,7 +683,8 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
 	/* The TCP header must be at least 32-bit aligned.  */
 	size = ALIGN(size, 4);
 
-	skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
+	skb = alloc_skb_fclone(size + sk->sk_prot->max_header,
+			       sk_allocation(sk, gfp));
 	if (skb) {
 		if (sk_wmem_schedule(sk, skb->truesize)) {
 			/*
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 25ff62e..a5ca337 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2307,7 +2307,7 @@ void tcp_send_fin(struct sock *sk)
 		/* Socket is locked, keep trying until memory is available. */
 		for (;;) {
 			skb = alloc_skb_fclone(MAX_TCP_HEADER,
-					       sk->sk_allocation);
+					       sk_allocation(sk, sk->sk_allocation));
 			if (skb)
 				break;
 			yield();
@@ -2333,7 +2333,7 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 	struct sk_buff *skb;
 
 	/* NOTE: No TCP options attached and we never retransmit this. */
-	skb = alloc_skb(MAX_TCP_HEADER, priority);
+	skb = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, priority));
 	if (!skb) {
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
 		return;
@@ -2406,7 +2406,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	if (cvp != NULL && cvp->s_data_constant && cvp->s_data_desired)
 		s_data_desired = cvp->s_data_desired;
-	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1, GFP_ATOMIC);
+	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1,
+			sk_allocation(sk, GFP_ATOMIC));
 	if (skb == NULL)
 		return NULL;
 
@@ -2686,7 +2687,7 @@ void tcp_send_ack(struct sock *sk)
 	 * tcp_transmit_skb() will set the ownership to this
 	 * sock.
 	 */
-	buff = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	buff = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, GFP_ATOMIC));
 	if (buff == NULL) {
 		inet_csk_schedule_ack(sk);
 		inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
@@ -2721,7 +2722,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 	struct sk_buff *skb;
 
 	/* We don't queue it, tcp_transmit_skb() sets ownership. */
-	skb = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	skb = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, GFP_ATOMIC));
 	if (skb == NULL)
 		return -1;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5ebc27e..cb8bd13 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -589,7 +589,8 @@ static int tcp_v6_md5_do_add(struct sock *sk, struct in6_addr *peer,
 	} else {
 		/* reallocate new list if current one is full. */
 		if (!tp->md5sig_info) {
-			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info), GFP_ATOMIC);
+			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info),
+					sk_allocation(sk, GFP_ATOMIC));
 			if (!tp->md5sig_info) {
 				kfree(newkey);
 				return -ENOMEM;
@@ -602,7 +603,8 @@ static int tcp_v6_md5_do_add(struct sock *sk, struct in6_addr *peer,
 		}
 		if (tp->md5sig_info->alloced6 == tp->md5sig_info->entries6) {
 			keys = kmalloc((sizeof (tp->md5sig_info->keys6[0]) *
-				       (tp->md5sig_info->entries6 + 1)), GFP_ATOMIC);
+				       (tp->md5sig_info->entries6 + 1)),
+				       sk_allocation(sk, GFP_ATOMIC));
 
 			if (!keys) {
 				tcp_free_md5sig_pool();
@@ -726,7 +728,8 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 		struct tcp_sock *tp = tcp_sk(sk);
 		struct tcp_md5sig_info *p;
 
-		p = kzalloc(sizeof(struct tcp_md5sig_info), GFP_KERNEL);
+		p = kzalloc(sizeof(struct tcp_md5sig_info),
+				   sk_allocation(sk, GFP_KERNEL));
 		if (!p)
 			return -ENOMEM;
 
@@ -997,6 +1000,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	unsigned int tot_len = sizeof(struct tcphdr);
 	struct dst_entry *dst;
 	__be32 *topt;
+	gfp_t gfp_mask = GFP_ATOMIC;
 
 	if (ts)
 		tot_len += TCPOLEN_TSTAMP_ALIGNED;
@@ -1006,7 +1010,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 #endif
 
 	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
-			 GFP_ATOMIC);
+			 gfp_mask);
 	if (buff == NULL)
 		return;
 
@@ -1083,6 +1087,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	struct tcphdr *th = tcp_hdr(skb);
 	u32 seq = 0, ack_seq = 0;
 	struct tcp_md5sig_key *key = NULL;
+	gfp_t gfp_mask = GFP_ATOMIC;
 
 	if (th->rst)
 		return;
@@ -1094,6 +1099,8 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	if (sk)
 		key = tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr);
 #endif
+	if (sk)
+		gfp_mask = sk_allocation(sk, gfp_mask);
 
 	if (th->ack)
 		seq = ntohl(th->ack_seq);
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
