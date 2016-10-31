Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51172 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S943816AbcJaPCS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 31 Oct 2016 11:02:18 -0400
Message-ID: <1477926132.6655.10.camel@redhat.com>
Subject: Re: [PATCH net-next] udp: do fwd memory scheduling on dequeue
From: Paolo Abeni <pabeni@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Date: Mon, 31 Oct 2016 16:02:12 +0100
In-Reply-To: <1477745013.7065.270.camel@edumazet-glaptop3.roam.corp.google.com>
References: <95bb1b780be2e35ff04fb9e1e2c41470a0a15582.1477660091.git.pabeni@redhat.com>
         <1477674975.7065.245.camel@edumazet-glaptop3.roam.corp.google.com>
         <1477677030.7065.250.camel@edumazet-glaptop3.roam.corp.google.com>
         <1477729045.5306.11.camel@redhat.com>
         <1477745013.7065.270.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-10-29 at 05:43 -0700, Eric Dumazet wrote:
> On Sat, 2016-10-29 at 10:17 +0200, Paolo Abeni wrote:
> 
> > Thank you for working on this. 
> > 
> > I just gave a very quick look (the WE has started, children are
> > screaming ;-), overall the implementation seems quite similar to our
> > one.
> > 
> > I like the additional argument to  ip_cmsg_recv_offset() instead of
> > keeping skb->sk set.
> > 
> > If I read udp_skb_destructor() correctly, the atomic manipulation of
> > both sk_rmem_alloc and udp_memory_allocated will happen under the
> > receive lock. In our experiments this increment measurably the
> > contention on the lock in respect to moving said the operations outside
> > the lock (as done in our patch). Do you foreseen any issues with that ?
> > AFAICS every in kernel UDP user of skb_recv_datagram() needs to be
> > updated with both implementation.
> 
> So if you look at tcp, we do not release forward allocation at every
> recvmsg(), but rather when we are under tcp memory pressure, or at timer
> firing when we know the flow has been idle for a while.
> 
> You hit contention on the lock, but the root cause is that right now udp
> is very conservative and also hits false sharing on
> udp_memory_allocated.
> 
> So I believe this is another problem which needs a fix anyway.
> 
> No need to make a complicated patch right now, if we know that this
> problem will be separately fixed, in another patch ?

No problem at all with incremental patches ;-)

In our experiment, touching udp_memory_allocated is only a part of the
the source of contention, with the biggest source of contention being
the sk_rmem_alloc update - which happens on every dequeue.

We experimented doing fwd alloc of the whole sk_rcvbuf; even in that
scenario we hit relevant contention if sk_rmem_alloc update was done
under the lock, while full sk_rcvbuf forward allocation and
sk_rmem_alloc update outside the spinlock gave very similar performance
to our posted patch.

I think that the next step (after the double lock on dequeue removal)
should be moving sk_rmem_alloc outside the lock: the needed changes for
doing that on top of double lock on dequeue removal are very small
(would add ~10 lines of code).

Paolo






