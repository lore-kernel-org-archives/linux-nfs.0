From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH][RESEND] tcp: replace hard coded GFP_KERNEL with
	sk_allocation
Date: Thu, 3 Sep 2009 12:04:07 +0800
Message-ID: <20090903040407.GA20094@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751988AbZICEEQ@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixed a lockdep warning which appeared when doing stress
memory tests over NFS:

	inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.

	page reclaim => nfs_writepage => tcp_sendmsg => lock sk_lock

	mount_root => nfs_root_data => tcp_close => lock sk_lock =>
			tcp_send_fin => alloc_skb_fclone => page reclaim

David raised a concern that if the allocation fails in tcp_send_fin(), and it's
GFP_ATOMIC, we are going to yield() (which sleeps) and loop endlessly waiting
for the allocation to succeed.

But fact is, the original GFP_KERNEL also sleeps. GFP_ATOMIC+yield() looks
weird, but it is no worse the implicit sleep inside GFP_KERNEL. Both could
loop endlessly under memory pressure.

CC: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
CC: David S. Miller <davem@davemloft.net>
CC: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 net/ipv4/tcp.c        |    4 ++--
 net/ipv4/tcp_ipv4.c   |    5 +++--
 net/ipv4/tcp_output.c |    5 +++--
 3 files changed, 8 insertions(+), 6 deletions(-)

--- linux.orig/net/ipv4/tcp_ipv4.c
+++ linux/net/ipv4/tcp_ipv4.c
@@ -970,8 +970,9 @@ static int tcp_v4_parse_md5_keys(struct 
 
 	if (!tcp_sk(sk)->md5sig_info) {
 		struct tcp_sock *tp = tcp_sk(sk);
-		struct tcp_md5sig_info *p = kzalloc(sizeof(*p), GFP_KERNEL);
+		struct tcp_md5sig_info *p;
 
+		p = kzalloc(sizeof(*p), sk->sk_allocation);
 		if (!p)
 			return -EINVAL;
 
@@ -979,7 +980,7 @@ static int tcp_v4_parse_md5_keys(struct 
 		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
 
-	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
+	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, sk->sk_allocation);
 	if (!newkey)
 		return -ENOMEM;
 	return tcp_v4_md5_do_add(sk, sin->sin_addr.s_addr,
--- linux.orig/net/ipv4/tcp_output.c
+++ linux/net/ipv4/tcp_output.c
@@ -2100,7 +2100,8 @@ void tcp_send_fin(struct sock *sk)
 	} else {
 		/* Socket is locked, keep trying until memory is available. */
 		for (;;) {
-			skb = alloc_skb_fclone(MAX_TCP_HEADER, GFP_KERNEL);
+			skb = alloc_skb_fclone(MAX_TCP_HEADER,
+					       sk->sk_allocation);
 			if (skb)
 				break;
 			yield();
@@ -2358,7 +2359,7 @@ int tcp_connect(struct sock *sk)
 	sk->sk_wmem_queued += buff->truesize;
 	sk_mem_charge(sk, buff->truesize);
 	tp->packets_out += tcp_skb_pcount(buff);
-	tcp_transmit_skb(sk, buff, 1, GFP_KERNEL);
+	tcp_transmit_skb(sk, buff, 1, sk->sk_allocation);
 
 	/* We change tp->snd_nxt after the tcp_transmit_skb() call
 	 * in order to make this packet get counted in tcpOutSegs.
--- linux.orig/net/ipv4/tcp.c
+++ linux/net/ipv4/tcp.c
@@ -1834,7 +1834,7 @@ void tcp_close(struct sock *sk, long tim
 		/* Unread data was tossed, zap the connection. */
 		NET_INC_STATS_USER(sock_net(sk), LINUX_MIB_TCPABORTONCLOSE);
 		tcp_set_state(sk, TCP_CLOSE);
-		tcp_send_active_reset(sk, GFP_KERNEL);
+		tcp_send_active_reset(sk, sk->sk_allocation);
 	} else if (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime) {
 		/* Check zero linger _after_ checking for unread data. */
 		sk->sk_prot->disconnect(sk, 0);
@@ -2666,7 +2666,7 @@ static struct tcp_md5sig_pool **__tcp_al
 		struct tcp_md5sig_pool *p;
 		struct crypto_hash *hash;
 
-		p = kzalloc(sizeof(*p), GFP_KERNEL);
+		p = kzalloc(sizeof(*p), sk->sk_allocation);
 		if (!p)
 			goto out_free;
 		*per_cpu_ptr(pool, cpu) = p;
