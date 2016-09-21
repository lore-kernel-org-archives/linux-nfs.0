Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34093 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755947AbcIUXbZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2016 19:31:25 -0400
Message-ID: <1474500682.23058.88.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next 2/3] udp: implement memory accounting helpers
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Date: Wed, 21 Sep 2016 16:31:22 -0700
In-Reply-To: <93ccb49b7f037461ef436a50b907185744b093d8.1474477902.git.pabeni@redhat.com>
References: <cover.1474477902.git.pabeni@redhat.com>
         <93ccb49b7f037461ef436a50b907185744b093d8.1474477902.git.pabeni@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-09-21 at 19:23 +0200, Paolo Abeni wrote:
> Avoid usage of common memory accounting functions, since
> the logic is pretty much different.
> 
> To account for forward allocation, a couple of new atomic_t
> members are added to udp_sock: 'mem_alloced' and 'mem_freed'.
> The current forward allocation is estimated as 'mem_alloced'
>  minus 'mem_freed' minus 'sk_rmem_alloc'.
> 
> When the forward allocation can't cope with the packet to be
> enqueued, 'mem_alloced' is incremented by the packet size
> rounded-up to the next SK_MEM_QUANTUM.
> After a dequeue, we try to partially reclaim of the forward
> allocated memory rounded down to an SK_MEM_QUANTUM and
> 'mem_freed' is increased by that amount.
> sk->sk_forward_alloc is set after each allocated/freed memory
> update, to the currently estimated forward allocation, without
> any lock or protection.
> This value is updated/maintained only to expose some
> semi-reasonable value to the eventual reader, and is guaranteed
> to be 0 at socket destruction time.
> 
> The above needs custom memory reclaiming on shutdown, provided
> by the udp_destruct_sock() helper, which completely reclaim
> the allocated forward memory.
> 
> Helpers are provided for skb free, consume and purge, respecting
> the above constraints.
> 
> The socket lock is still used to protect the updates to sk_peek_off,
> but is acquired only if peeking with offset is enabled.
> 
> As a consequence of the above schema, enqueue to sk_error_queue
> will cause larger forward allocation on following normal data
> (due to sk_rmem_alloc grow), but this allows amortizing the cost
> of the atomic operation on SK_MEM_QUANTUM/skb->truesize packets.
> The use of separate atomics for 'mem_alloced' and 'mem_freed'
> allows the use of a single atomic operation to protect against
> concurrent dequeue.
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  include/linux/udp.h |   2 +
>  include/net/udp.h   |   5 ++
>  net/ipv4/udp.c      | 151 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 158 insertions(+)
> 
> diff --git a/include/linux/udp.h b/include/linux/udp.h
> index d1fd8cd..cd72645 100644
> --- a/include/linux/udp.h
> +++ b/include/linux/udp.h
> @@ -42,6 +42,8 @@ static inline u32 udp_hashfn(const struct net *net, u32 num, u32 mask)
>  struct udp_sock {
>  	/* inet_sock has to be the first member */
>  	struct inet_sock inet;
> +	atomic_t	 mem_allocated;
> +	atomic_t	 mem_freed;

Hi Paolo, thanks for working on this.

All this code looks quite invasive to me ?

Also does inet_diag properly give the forward_alloc to user ?

$ ss -mua
State      Recv-Q Send-Q Local Address:Port                 Peer Addres
s:Port
UNCONN     51584  0          *:52460      *:*                    
	 skmem:(r51584,rb327680,t0,tb327680,f1664,w0,o0,bl0,d575)


Couldn't we instead use an union of an atomic_t and int for
sk->sk_forward_alloc ?

All udp queues/dequeues would manipulate the atomic_t using regular
atomic ops and use a special skb destructor (instead of sock_rfree())

Also I would not bother 'reclaiming' forward_alloc at dequeue, unless
udp is under memory pressure.

Please share your performance numbers, thanks !


