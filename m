Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53490 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751187AbcIVKdk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Sep 2016 06:33:40 -0400
Message-ID: <1474540415.4845.69.camel@redhat.com>
Subject: Re: [PATCH net-next 2/3] udp: implement memory accounting helpers
From: Paolo Abeni <pabeni@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Date: Thu, 22 Sep 2016 12:33:35 +0200
In-Reply-To: <1474500682.23058.88.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1474477902.git.pabeni@redhat.com>
         <93ccb49b7f037461ef436a50b907185744b093d8.1474477902.git.pabeni@redhat.com>
         <1474500682.23058.88.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Eric,

On Wed, 2016-09-21 at 16:31 -0700, Eric Dumazet wrote:
> Also does inet_diag properly give the forward_alloc to user ?
> 
> $ ss -mua
> State      Recv-Q Send-Q Local Address:Port                 Peer Addres
> s:Port
> UNCONN     51584  0          *:52460      *:*                    
> 	 skmem:(r51584,rb327680,t0,tb327680,f1664,w0,o0,bl0,d575)

Thank you very much for reviewing this! 

My bad, there is still a race which leads to temporary negative values
of fwd. I feel the fix is trivial but it needs some investigation.

> Couldn't we instead use an union of an atomic_t and int for
> sk->sk_forward_alloc ?

That was our first attempt, but we had some issue on mem scheduling; if
we use:

   if (atomic_sub_return(size, &sk->sk_forward_alloc_atomic) < 0) {
        // fwd alloc
   }

that leads to inescapable, temporary, negative value for
sk->sk_forward_alloc.

Another option would be:

again:
        fwd = atomic_read(&sk->sk_forward_alloc_atomic);
        if (fwd > size) {
		if (atomic_cmpxchg(&sk->sk_forward_alloc_atomic, fwd, fwd - size) != fwd)
			goto again;
        } else 
            // fwd alloc

which would be bad under high contention.

I think that using a single atomic to track both scheduling and reclaim
requires a similar loop to resolve reclaim contention. They should be
very rare, especially if we can avoid reclaiming on dequeue, but still
will complicate the code.

Finally, pahole shows that the number of cacheline used by an udp socket
on x86_64 does not change adding the two new atomic fields.

> All udp queues/dequeues would manipulate the atomic_t using regular
> atomic ops and use a special skb destructor (instead of sock_rfree())

I tried the special skb destructor and discarded it, but thinking again,
now I feel it can simplify the code, regardless of the used schema.

We will still need to replace the current in-kernel
skb_free_datagram_locked() for udp with something else, so a bit of
noise in the sunrpc subsystem will remain.

> Also I would not bother 'reclaiming' forward_alloc at dequeue, unless
> udp is under memory pressure.

We discarded that option because it would change significantly the
system behavior, but if there is agreement on it, I think that it would
make a really relevant (positive) difference!

> Please share your performance numbers, thanks !

Tested using pktgen with random src port, 64 bytes packet, wire-speed on
an 10G link as sender and udp_sink by Jesper
(https://github.com/netoptimizer/network-testing/blob/master/src/udp_sink.c) as receiver, using l4 tuple rxhash to stress the contention, and one or more udp_sink instance with reuseport. 

nr readers	Kpps (vanilla)	Kpps (patched)
1		241		600
3		1800		2200
6		3450		3950
9		5100		5400
12		6400		6650

Thank you for the very nice suggestions!

Paolo

