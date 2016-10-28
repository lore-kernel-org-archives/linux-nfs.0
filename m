Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33765 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964900AbcJ1RQS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Oct 2016 13:16:18 -0400
Message-ID: <1477674975.7065.245.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next] udp: do fwd memory scheduling on dequeue
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Date: Fri, 28 Oct 2016 10:16:15 -0700
In-Reply-To: <95bb1b780be2e35ff04fb9e1e2c41470a0a15582.1477660091.git.pabeni@redhat.com>
References: <95bb1b780be2e35ff04fb9e1e2c41470a0a15582.1477660091.git.pabeni@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Nice !

I was working on this as well and my implementation was somewhat
different.

I then stopped when I found the UDP checksum bug and was waiting for net
to be merged into net-next
( https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=10df8e6152c6c400a563a673e9956320bfce1871 )

On Fri, 2016-10-28 at 15:20 +0200, Paolo Abeni wrote:
> A new argument is added to __skb_recv_datagram, it allows
> the caller to perform protocol specific action on dequeue
> under the receive queue spinlock.
> The UDP protocol uses such argument to perform fwd memory
> reclaiming on dequeue, while protocol memory and rmem updatating
> is delayed after the lock release, to keep the time spent
> under the lock as low as possible.
> The UDP specific skb desctructor is not used anymore, instead
> explicit memory reclaiming is performed at close() time and
> when skbs are removed from the receive queue.
> The in kernel UDP procotol users now need to use an
> skb_recv_udp() variant instead of skb_recv_datagram() to
> properly perform memory accounting on dequeue.
> 
> Overall, this allows acquiring only once the receive queue
> lock on dequeue.
> 
> Tested using pktgen with random src port, 64 bytes packet,
> wire-speed on a 10G link as sender and udp_sink as the receiver,
> using an l4 tuple rxhash to stress the contention, and one or more
> udp_sink instances with reuseport.
> 
> nr sinks	vanilla		patched
> 1		440		560
> 3		2150		2300
> 6		3650		3800
> 9		4450		4600
> 12		6250		6450
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  include/linux/skbuff.h |  4 ++++
>  include/net/udp.h      | 10 ++++++++
>  net/core/datagram.c    | 11 ++++++---
>  net/ipv4/udp.c         | 65 ++++++++++++++++++++++++++++++++++++++++----------
>  net/ipv6/udp.c         |  3 +--
>  net/rxrpc/input.c      |  7 +++---
>  net/sunrpc/svcsock.c   |  2 +-
>  net/sunrpc/xprtsock.c  |  2 +-
>  net/unix/af_unix.c     |  4 ++--
>  9 files changed, 83 insertions(+), 25 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 601258f..dd171a9 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -3028,13 +3028,17 @@ static inline void skb_frag_list_init(struct sk_buff *skb)
>  #define skb_walk_frags(skb, iter)	\
>  	for (iter = skb_shinfo(skb)->frag_list; iter; iter = iter->next)
>  
> +typedef void (*skb_dequeue_cb_t)(struct sock *sk, struct sk_buff *skb,
> +				 int flags);
>  
>  int __skb_wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
>  				const struct sk_buff *skb);
>  struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned flags,
> +					skb_dequeue_cb_t dequeue_cb,
>  					int *peeked, int *off, int *err,
>  					struct sk_buff **last);
>  struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
> +				    skb_dequeue_cb_t dequeue_cb,
>  				    int *peeked, int *off, int *err);
>  struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags, int noblock,
>  				  int *err);
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 18f1e6b..983c861 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -48,6 +48,7 @@ struct udp_skb_cb {
>  	} header;
>  	__u16		cscov;
>  	__u8		partial_cov;
> +	int		fwd_memory_released;

I was not adding this field.

>  };
>  #define UDP_SKB_CB(__skb)	((struct udp_skb_cb *)((__skb)->cb))
>  
> @@ -248,6 +249,15 @@ static inline __be16 udp_flow_src_port(struct net *net, struct sk_buff *skb,
>  /* net/ipv4/udp.c */
>  void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len);
>  int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb);
> +struct sk_buff *__skb_recv_udp(struct sock *sk, unsigned int flags, int noblock,
> +			       int *peeked, int *off, int *err);
> +static inline struct sk_buff *skb_recv_udp(struct sock *sk, unsigned int flags,
> +					   int noblock, int *err)
> +{
> +	int peeked, off = 0;
> +
> +	return __skb_recv_udp(sk, flags, noblock, &peeked, &off, err);
> +}
>  
>  void udp_v4_early_demux(struct sk_buff *skb);
>  int udp_get_port(struct sock *sk, unsigned short snum,
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index bfb973a..226548b 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -165,6 +165,7 @@ static struct sk_buff *skb_set_peeked(struct sk_buff *skb)
>   *	__skb_try_recv_datagram - Receive a datagram skbuff
>   *	@sk: socket
>   *	@flags: MSG_ flags
> + *	@dequeue_cb: invoked under the receive lock on successful dequeue
>   *	@peeked: returns non-zero if this packet has been seen before
>   *	@off: an offset in bytes to peek skb from. Returns an offset
>   *	      within an skb where data actually starts
> @@ -197,6 +198,7 @@ static struct sk_buff *skb_set_peeked(struct sk_buff *skb)
>   *	the standard around please.
>   */
>  struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
> +					skb_dequeue_cb_t dequeue_cb,
>  					int *peeked, int *off, int *err,
>  					struct sk_buff **last)
>  {
> @@ -244,6 +246,8 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
>  			} else
>  				__skb_unlink(skb, queue);
>  
> +			if (dequeue_cb)
> +				dequeue_cb(sk, skb, flags);

I was doing this only if the packet was unlinked few lines above.

>  			spin_unlock_irqrestore(&queue->lock, cpu_flags);
>  			*off = _off;
>  			return skb;
> @@ -262,6 +266,7 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
>  EXPORT_SYMBOL(__skb_try_recv_datagram);
>  
>  struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
> +				    skb_dequeue_cb_t dequeue_cb,
>  				    int *peeked, int *off, int *err)
>  {
>  	struct sk_buff *skb, *last;
> @@ -270,8 +275,8 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
>  	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
>  
>  	do {
> -		skb = __skb_try_recv_datagram(sk, flags, peeked, off, err,
> -					      &last);
> +		skb = __skb_try_recv_datagram(sk, flags, dequeue_cb, peeked,
> +					      off, err, &last);
>  		if (skb)
>  			return skb;
>  
> @@ -290,7 +295,7 @@ struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned int flags,
>  	int peeked, off = 0;
>  
>  	return __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
> -				   &peeked, &off, err);
> +				   NULL, &peeked, &off, err);
>  }
>  EXPORT_SYMBOL(skb_recv_datagram);
>  
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index c833271..2f1a727 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1172,26 +1172,61 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
>  	return ret;
>  }
>  
> +/* fully reclaim rmem/fwd memory allocated for skb */
>  static void udp_rmem_release(struct sock *sk, int size, int partial)
>  {
>  	int amt;
>  
>  	atomic_sub(size, &sk->sk_rmem_alloc);
> -
> -	spin_lock_bh(&sk->sk_receive_queue.lock);
>  	sk->sk_forward_alloc += size;
>  	amt = (sk->sk_forward_alloc - partial) & ~(SK_MEM_QUANTUM - 1);
>  	sk->sk_forward_alloc -= amt;
> -	spin_unlock_bh(&sk->sk_receive_queue.lock);
>  
>  	if (amt)
>  		__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
>  }
>  
> -static void udp_rmem_free(struct sk_buff *skb)
> +/* if we are not peeking the skb, reclaim fwd allocated memory;
> + * rmem and protocol memory updating is delayed outside the lock
> + */
> +static void udp_dequeue(struct sock *sk, struct sk_buff *skb, int flags)
> +{
> +	int amt;
> +
> +	if (flags & MSG_PEEK)
> +		return;
> +
> +	sk->sk_forward_alloc += skb->truesize;
> +	amt = (sk->sk_forward_alloc - 1) & ~(SK_MEM_QUANTUM - 1);
> +	sk->sk_forward_alloc -= amt;
> +	UDP_SKB_CB(skb)->fwd_memory_released = amt >> SK_MEM_QUANTUM_SHIFT;
> +}
> +
> +/* complete the memory reclaiming started with udp_dequeue */
> +static void __udp_rmem_release(struct sock *sk, struct sk_buff *skb, int flags)
> +{
> +	int amt = UDP_SKB_CB(skb)->fwd_memory_released;
> +
> +	if (flags & MSG_PEEK)
> +		return;
> +
> +	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
> +	if (amt)
> +		__sk_mem_reduce_allocated(sk, amt);
> +}
> +
> +struct sk_buff *__skb_recv_udp(struct sock *sk, unsigned int flags,
> +			       int noblock, int *peeked, int *off, int *err)
>  {
> -	udp_rmem_release(skb->sk, skb->truesize, 1);
> +	struct sk_buff *skb;
> +
> +	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
> +				  udp_dequeue, peeked, off, err);
> +	if (skb)
> +		__udp_rmem_release(sk, skb, flags);
> +	return skb;
>  }
> +EXPORT_SYMBOL(__skb_recv_udp);
>  
>  int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
>  {
> @@ -1230,7 +1265,6 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
>  
>  	/* the skb owner in now the udp socket */
>  	skb->sk = sk;
> -	skb->destructor = udp_rmem_free;
>  	skb->dev = NULL;
>  	sock_skb_set_dropcount(sk, skb);
>  
> @@ -1254,8 +1288,13 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
>  static void udp_destruct_sock(struct sock *sk)
>  {
>  	/* reclaim completely the forward allocated memory */
> -	__skb_queue_purge(&sk->sk_receive_queue);
> -	udp_rmem_release(sk, 0, 0);
> +	struct sk_buff *skb;
> +
> +	while ((skb = __skb_dequeue(&sk->sk_receive_queue)) != NULL) {
> +		udp_rmem_release(sk, skb->truesize, 0);
> +		kfree_skb(skb);
> +	}
> +

I was using instead :

+       unsigned int total = 0;
+       struct sk_buff *skb;
+
+       while ((skb = __skb_dequeue(&sk->sk_receive_queue)) != NULL) {
+               total += skb->truesize;
+               kfree_skb(skb);
+       }
+       udp_rmem_release(sk, total, 0);


>  	inet_sock_destruct(sk);
>  }
>  
> @@ -1303,11 +1342,11 @@ static int first_packet_length(struct sock *sk)
>  		atomic_inc(&sk->sk_drops);
>  		__skb_unlink(skb, rcvq);
>  		__skb_queue_tail(&list_kill, skb);
> +		udp_rmem_release(sk, skb->truesize, 1);
> +		kfree_skb(skb);
>  	}
>  	res = skb ? skb->len : -1;
>  	spin_unlock_bh(&rcvq->lock);
> -




