From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W}
	usage
Date: Thu, 9 Jul 2009 21:17:46 +0800
Message-ID: <20090709131746.GA27965@localhost>
References: <20090608023757.GA6244@localhost> <20090706105216.GA19124@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090706105216.GA19124@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 06, 2009 at 06:52:16PM +0800, Herbert Xu wrote:
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > This lockdep warning appears when doing stress memory tests over NFS.
> > 
> > page reclaim => nfs_writepage => tcp_sendmsg => lock sk_lock
> > 
> > tcp_close => lock sk_lock => tcp_send_fin => alloc_skb_fclone => page reclaim
> 
> Well perhaps not this particular path, but it is certainly possible
> if an existing NFS socket dies and NFS tries to reestablish it.
> 
> I suggest that NFS should utilise the sk_allocation field and
> set an appropriate value.  Note that you may have to patch TCP
> so that it uses sk_allocation everywhere necessary, e.g., in
> tcp_send_fin.

Good suggestion! NFS already sets sk_allocation to GFP_ATOMIC in
linux/net/sunrpc/xprtsock.c <<xs_tcp_finish_connecting>>.

To fix this warning and possible recursions, I converted some
GPF_KERNEL cases to sk_allocation in the tcp/ipv4 code:

---
tcp: replace hard coded GFP_KERNEL with sk_allocation

This fixed a lockdep warning which appeared when doing stress
memory tests over NFS:

	inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.

	mount_root => nfs_root_data => tcp_close => lock sk_lock =>
			tcp_send_fin => alloc_skb_fclone => page reclaim

	page reclaim => nfs_writepage => tcp_sendmsg => lock sk_lock

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
