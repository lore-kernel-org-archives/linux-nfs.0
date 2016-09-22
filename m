Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34659 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754141AbcIVUeK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 16:34:10 -0400
Message-ID: <1474576448.28155.7.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next 2/3] udp: implement memory accounting helpers
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Cc: Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Date: Thu, 22 Sep 2016 13:34:08 -0700
In-Reply-To: <1474576020.7120.1.camel@redhat.com>
References: <cover.1474477902.git.pabeni@redhat.com>
         <93ccb49b7f037461ef436a50b907185744b093d8.1474477902.git.pabeni@redhat.com>
         <1474500682.23058.88.camel@edumazet-glaptop3.roam.corp.google.com>
         <1474540415.4845.69.camel@redhat.com>
         <589839b3-5930-2527-b0a3-315be254a175@solarflare.com>
         <1474560864.4845.78.camel@redhat.com>
         <1474561848.23058.133.camel@edumazet-glaptop3.roam.corp.google.com>
         <1474576020.7120.1.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-09-22 at 22:27 +0200, Paolo Abeni wrote:
> On Thu, 2016-09-22 at 09:30 -0700, Eric Dumazet wrote:
> > On Thu, 2016-09-22 at 18:14 +0200, Paolo Abeni wrote:
> > 
> > > I think that the idea behind using atomic ops directly on
> > > sk_forward_alloc is to avoid adding other fields to the udp_socket. 
> > > 
> > > If we can add some fields to the udp_sock structure, the schema proposed
> > > in this patch should fit better (modulo bugs ;-), always requiring a
> > > single atomic operation at memory reclaiming time and at memory
> > > allocation time.
> > 
> > But do we want any additional atomic to begin with ?
> > 
> > Given typical number of UDP sockets on a host, we could reserve/forward
> > alloc at socket creation time, and when SO_RCVBUF is changed.
> 
> That would be very efficient and would probably work on most scenario,
> but if/when the system will reach udp memory pressure things will be
> very bad: forward allocation on open() will fail and nobody will be able
> to create any new udp socket, right ?
> 

No, we could allow one page per socket (udp_mem[0]) and applications
would still work.

TCP has the notion of memory pressure, and behaves roughly the same in
this case (one skb is allowed to be received)

The other (fat) sockets could notice udp_memory_pressure is set and
start reclaiming their forward allocations for other sockets.

We have a counter of UDP sockets, so probably doable to compute
udp_mem[2]/number 

Anyway, just an idea.

> We are working on a v2 incorporating the feedback of your previous email
> - still keeping the new udp_sock fields.
> It looks quite simpler than v1, will work reasonably well in memory
> pressure scenario, and performance are measurably better than v1, most
> probably comparable with the above solution, since usually no additional
> atomic operations  (beyond sk_rmem_alloc updating) are performed on
> enqueue/dequeue.


