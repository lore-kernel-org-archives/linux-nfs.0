Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40276 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753398AbcIVQO2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Sep 2016 12:14:28 -0400
Message-ID: <1474560864.4845.78.camel@redhat.com>
Subject: Re: [PATCH net-next 2/3] udp: implement memory accounting helpers
From: Paolo Abeni <pabeni@redhat.com>
To: Edward Cree <ecree@solarflare.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Date: Thu, 22 Sep 2016 18:14:24 +0200
In-Reply-To: <589839b3-5930-2527-b0a3-315be254a175@solarflare.com>
References: <cover.1474477902.git.pabeni@redhat.com>
         <93ccb49b7f037461ef436a50b907185744b093d8.1474477902.git.pabeni@redhat.com>
         <1474500682.23058.88.camel@edumazet-glaptop3.roam.corp.google.com>
         <1474540415.4845.69.camel@redhat.com>
         <589839b3-5930-2527-b0a3-315be254a175@solarflare.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-09-22 at 16:21 +0100, Edward Cree wrote:
> On 22/09/16 11:33, Paolo Abeni wrote:
> > Hi Eric,
> >
> > On Wed, 2016-09-21 at 16:31 -0700, Eric Dumazet wrote:
> >> Also does inet_diag properly give the forward_alloc to user ?
> >>
> >> $ ss -mua
> >> State      Recv-Q Send-Q Local Address:Port                 Peer Addres
> >> s:Port
> >> UNCONN     51584  0          *:52460      *:*                    
> >> 	 skmem:(r51584,rb327680,t0,tb327680,f1664,w0,o0,bl0,d575)
> > Thank you very much for reviewing this! 
> >
> > My bad, there is still a race which leads to temporary negative values
> > of fwd. I feel the fix is trivial but it needs some investigation.
> >
> >> Couldn't we instead use an union of an atomic_t and int for
> >> sk->sk_forward_alloc ?
> > That was our first attempt, but we had some issue on mem scheduling; if
> > we use:
> >
> >    if (atomic_sub_return(size, &sk->sk_forward_alloc_atomic) < 0) {
> >         // fwd alloc
> >    }
> >
> > that leads to inescapable, temporary, negative value for
> > sk->sk_forward_alloc.
> >
> > Another option would be:
> >
> > again:
> >         fwd = atomic_read(&sk->sk_forward_alloc_atomic);
> >         if (fwd > size) {
> > 		if (atomic_cmpxchg(&sk->sk_forward_alloc_atomic, fwd, fwd - size) != fwd)
> > 			goto again;
> >         } else 
> >             // fwd alloc
> >
> > which would be bad under high contention.
> Apologies if I'm misunderstanding the problem, but couldn't you have two
> atomic_t fields, 'internal' and 'external' forward_alloc.  Then
>     if (atomic_sub_return(size, &sk->sk_forward_alloc_internal) < 0) {
>         atomic_sub(size, &sk->sk_forward_alloc);
>         // fwd alloc
>     } else {
>         atomic_add(size, &sk->sk_forward_alloc_internal);
>     }
> or something like that.  Then sk->sk_forward_alloc never sees a negative
> value, and is always >= sk->sk_forward_alloc_internal.  Of course places
> that go the other way would have to add to sk->sk_forward_alloc first,
> before adding to sk->sk_forward_alloc_internal, to maintain that invariant.

I think that the idea behind using atomic ops directly on
sk_forward_alloc is to avoid adding other fields to the udp_socket. 

If we can add some fields to the udp_sock structure, the schema proposed
in this patch should fit better (modulo bugs ;-), always requiring a
single atomic operation at memory reclaiming time and at memory
allocation time.

Paolo

