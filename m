Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41094 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932706AbcJUNeF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Oct 2016 09:34:05 -0400
Message-ID: <1477056841.4606.36.camel@redhat.com>
Subject: Re: [PATCH net-next v6 2/3] udp: implement memory accounting helpers
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
Date: Fri, 21 Oct 2016 15:34:01 +0200
In-Reply-To: <1477052642.7065.63.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1477043395.git.pabeni@redhat.com>
         <4d2e0fc8f5c3d1309b0fb71bc65a2719a8e82825.1477043395.git.pabeni@redhat.com>
         <1477052642.7065.63.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-10-21 at 05:24 -0700, Eric Dumazet wrote:
> On Fri, 2016-10-21 at 13:55 +0200, Paolo Abeni wrote:
> > Avoid using the generic helpers.
> > Use the receive queue spin lock to protect the memory
> > accounting operation, both on enqueue and on dequeue.
> > 
> > On dequeue perform partial memory reclaiming, trying to
> > leave a quantum of forward allocated memory.
> > 
> > On enqueue use a custom helper, to allow some optimizations:
> > - use a plain spin_lock() variant instead of the slightly
> >   costly spin_lock_irqsave(),
> > - avoid dst_force check, since the calling code has already
> >   dropped the skb dst
> > - avoid orphaning the skb, since skb_steal_sock() already did
> >   the work for us
> 
> >  
> > +static void udp_rmem_release(struct sock *sk, int size, int partial)
> > +{
> > +	int amt;
> > +
> > +	atomic_sub(size, &sk->sk_rmem_alloc);
> > +
> > +	spin_lock_bh(&sk->sk_receive_queue.lock);
> > +	sk->sk_forward_alloc += size;
> > +	amt = (sk->sk_forward_alloc - partial) & ~(SK_MEM_QUANTUM - 1);
> > +	sk->sk_forward_alloc -= amt;
> > +	spin_unlock_bh(&sk->sk_receive_queue.lock);
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
> 
> 
> It looks like you are acquiring/releasing sk_receive_queue.lock twice
> per packet in recvmsg() (the second time in the destructor above)
> 
> We could do slightly better if :
> 
> We do not set skb->destructor at all, and manage
> sk_rmem_alloc/sk_forward_alloc changes at the time we dequeue skb
>  (if !MSG_PEEK), before copy to user space.

Thank you again for reviewing this!

Updating sk_rmem_alloc would still need an atomic operation,
because it is touched also by the error queue path: we will end up
adding an atomic operation (or two, when reclaiming the fwd allocated
memory) inside the critical section. The contention will likely
increase.

The above is going to be quite intrusive: we need to pass an
additional argument all the way up to __skb_try_recv_datagram() and
change the function behavior according to its value.

If you are otherwise satisfied with the series in the current shape,
can't we instead build incrementally on top of it ? it will simplify
both reviews and re-factor tasks.

Thank you,

Paolo


