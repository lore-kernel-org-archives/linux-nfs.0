Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34019 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754619AbcJUMYF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2016 08:24:05 -0400
Message-ID: <1477052642.7065.63.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next v6 2/3] udp: implement memory accounting helpers
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Edward Cree <ecree@solarflare.com>, linux-nfs@vger.kernel.org
Date: Fri, 21 Oct 2016 05:24:02 -0700
In-Reply-To: <4d2e0fc8f5c3d1309b0fb71bc65a2719a8e82825.1477043395.git.pabeni@redhat.com>
References: <cover.1477043395.git.pabeni@redhat.com>
         <4d2e0fc8f5c3d1309b0fb71bc65a2719a8e82825.1477043395.git.pabeni@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-10-21 at 13:55 +0200, Paolo Abeni wrote:
> Avoid using the generic helpers.
> Use the receive queue spin lock to protect the memory
> accounting operation, both on enqueue and on dequeue.
> 
> On dequeue perform partial memory reclaiming, trying to
> leave a quantum of forward allocated memory.
> 
> On enqueue use a custom helper, to allow some optimizations:
> - use a plain spin_lock() variant instead of the slightly
>   costly spin_lock_irqsave(),
> - avoid dst_force check, since the calling code has already
>   dropped the skb dst
> - avoid orphaning the skb, since skb_steal_sock() already did
>   the work for us

>  
> +static void udp_rmem_release(struct sock *sk, int size, int partial)
> +{
> +	int amt;
> +
> +	atomic_sub(size, &sk->sk_rmem_alloc);
> +
> +	spin_lock_bh(&sk->sk_receive_queue.lock);
> +	sk->sk_forward_alloc += size;
> +	amt = (sk->sk_forward_alloc - partial) & ~(SK_MEM_QUANTUM - 1);
> +	sk->sk_forward_alloc -= amt;
> +	spin_unlock_bh(&sk->sk_receive_queue.lock);
> +
> +	if (amt)
> +		__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
> +}
> +
> +static void udp_rmem_free(struct sk_buff *skb)
> +{
> +	udp_rmem_release(skb->sk, skb->truesize, 1);
> +}
> +


It looks like you are acquiring/releasing sk_receive_queue.lock twice
per packet in recvmsg() (the second time in the destructor above)

We could do slightly better if :

We do not set skb->destructor at all, and manage
sk_rmem_alloc/sk_forward_alloc changes at the time we dequeue skb
 (if !MSG_PEEK), before copy to user space.





