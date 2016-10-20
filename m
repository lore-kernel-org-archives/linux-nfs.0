Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41236 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752344AbcJTHCg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Oct 2016 03:02:36 -0400
Message-ID: <1476946950.5656.4.camel@redhat.com>
Subject: Re: [PATCH net-next v4 2/3] udp: implement memory accounting helpers
From: Paolo Abeni <pabeni@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Edward Cree <ecree@solarflare.com>, linux-nfs@vger.kernel.org
Date: Thu, 20 Oct 2016 09:02:30 +0200
In-Reply-To: <1476938622.5650.111.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1476877189.git.pabeni@redhat.com>
         <c5a425a33f7dc8cda35f19c0979cf3ea5c10fc96.1476877189.git.pabeni@redhat.com>
         <1476938622.5650.111.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-10-19 at 21:43 -0700, Eric Dumazet wrote:
> On Wed, 2016-10-19 at 14:47 +0200, Paolo Abeni wrote:
> > Avoid using the generic helpers.
> > Adds a new spinlock_t to the udp_sock structure and use
> > it to protect the memory accounting operation, both on
> > enqueue and on dequeue.
> > 
> > On dequeue perform partial memory reclaiming, trying to
> > leave a quantum of forward allocated memory.
> > 
> > On enqueue use a custom helper, to allow some optimizations:
> > - use a plain spin_lock() variant instead of the slightly
> >   costly spin_lock_irqsave(),
> > - avoid dst_force check, since the calling code has already
> >   dropped the skb dst
> > 
> > The above needs custom memory reclaiming on shutdown, provided
> > by the udp_destruct_sock().
> > 
> > v3 -> v4:
> >   - reworked memory accunting, simplifying the schema
> >   - provide an helper for both memory scheduling and enqueuing
> > 
> > v1 -> v2:
> >   - use a udp specific destrctor to perform memory reclaiming
> >   - remove a couple of helpers, unneeded after the above cleanup
> >   - do not reclaim memory on dequeue if not under memory
> >     pressure
> >   - reworked the fwd accounting schema to avoid potential
> >     integer overflow
> > 
> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> >  include/linux/udp.h |   1 +
> >  include/net/udp.h   |   4 ++
> >  net/ipv4/udp.c      | 111 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 116 insertions(+)
> > 
> > diff --git a/include/linux/udp.h b/include/linux/udp.h
> > index d1fd8cd..8ea7f8b 100644
> > --- a/include/linux/udp.h
> > +++ b/include/linux/udp.h
> > @@ -66,6 +66,7 @@ struct udp_sock {
> >  #define UDPLITE_RECV_CC  0x4		/* set via udplite setsocktopt        */
> >  	__u8		 pcflag;        /* marks socket as UDP-Lite if > 0    */
> >  	__u8		 unused[3];
> > +	spinlock_t	 mem_lock;	/* protects memory accounting         */
> >  	/*
> >  	 * For encapsulation sockets.
> >  	 */
> > diff --git a/include/net/udp.h b/include/net/udp.h
> > index ea53a87..18f1e6b 100644
> > --- a/include/net/udp.h
> > +++ b/include/net/udp.h
> > @@ -246,6 +246,9 @@ static inline __be16 udp_flow_src_port(struct net *net, struct sk_buff *skb,
> >  }
> >  
> >  /* net/ipv4/udp.c */
> > +void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len);
> > +int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb);
> > +
> >  void udp_v4_early_demux(struct sk_buff *skb);
> >  int udp_get_port(struct sock *sk, unsigned short snum,
> >  		 int (*saddr_cmp)(const struct sock *,
> > @@ -258,6 +261,7 @@ int udp_get_port(struct sock *sk, unsigned short snum,
> >  void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
> >  int udp_rcv(struct sk_buff *skb);
> >  int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
> > +int udp_init_sock(struct sock *sk);
> >  int udp_disconnect(struct sock *sk, int flags);
> >  unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait);
> >  struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
> > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> > index 7d96dc2..7047bb3 100644
> > --- a/net/ipv4/udp.c
> > +++ b/net/ipv4/udp.c
> > @@ -1172,6 +1172,117 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
> >  	return ret;
> >  }
> >  
> > +static void udp_rmem_release(struct sock *sk, int size, int partial)
> > +{
> > +	struct udp_sock *up = udp_sk(sk);
> > +	int amt;
> > +
> > +	atomic_sub(size, &sk->sk_rmem_alloc);
> > +
> > +	spin_lock_bh(&up->mem_lock);
> > +	sk->sk_forward_alloc += size;
> > +	amt = (sk->sk_forward_alloc - partial) & ~(SK_MEM_QUANTUM - 1);
> > +	sk->sk_forward_alloc -= amt;
> > +	spin_unlock_bh(&up->mem_lock);
> > +
> > +	if (amt)
> > +		__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
> > +}
> > +
> > +static void udp_rmem_free(struct sk_buff *skb)
> > +{
> > +	udp_rmem_release(skb->sk, skb->truesize, 1);
> > +}
> > +
> > +int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
> > +{
> > +	struct sk_buff_head *list = &sk->sk_receive_queue;
> > +	int rmem, delta, amt, err = -ENOMEM;
> > +	struct udp_sock *up = udp_sk(sk);
> > +	int size = skb->truesize;
> > +
> > +	/* try to avoid the costly atomic add/sub pair when the receive
> > +	 * queue is full
> > +	 */
> > +	if (atomic_read(&sk->sk_rmem_alloc) + size > sk->sk_rcvbuf)
> > +		goto drop;
> > +
> > +	rmem = atomic_add_return(size, &sk->sk_rmem_alloc);
> > +	if (rmem > sk->sk_rcvbuf)
> > +		goto uncharge_drop;
> 
> This is dangerous : We used to accept one packet in receive queue, even
> if sk_rcvbuf is too small. (Check __sock_queue_rcv_skb())
> 
> With your code we might drop all packets even if receive queue is empty,
> this might add regressions for some apps.

Thank you for reviewing this! 

I missed that point. I'll take care of it (and of your others comments)
in v5.

Regards,

Paolo

