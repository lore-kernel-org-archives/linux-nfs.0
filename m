Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58926 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933475AbcJ2IRm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 29 Oct 2016 04:17:42 -0400
Message-ID: <1477729045.5306.11.camel@redhat.com>
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
Date: Sat, 29 Oct 2016 10:17:25 +0200
In-Reply-To: <1477677030.7065.250.camel@edumazet-glaptop3.roam.corp.google.com>
References: <95bb1b780be2e35ff04fb9e1e2c41470a0a15582.1477660091.git.pabeni@redhat.com>
         <1477674975.7065.245.camel@edumazet-glaptop3.roam.corp.google.com>
         <1477677030.7065.250.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-10-28 at 10:50 -0700, Eric Dumazet wrote:
> On Fri, 2016-10-28 at 10:16 -0700, Eric Dumazet wrote:
> > Nice !
> > 
> > I was working on this as well and my implementation was somewhat
> > different.
> 
> This is my WIP
> 
> Note this can be split in two parts.
> 
> 1) One adding struct sock *sk param to ip_cmsg_recv_offset()
>  
>    This was because I left skb->sk NULL for skbs stored in receive
> queue.
>    You chose instead to set skb->sk, which is unusual (check
> skb_orphan() BUG_ON())
> 
> 2) Udp changes.
> 
> Tell me what you think, thanks again !

Thank you for working on this. 

I just gave a very quick look (the WE has started, children are
screaming ;-), overall the implementation seems quite similar to our
one.

I like the additional argument to  ip_cmsg_recv_offset() instead of
keeping skb->sk set.

If I read udp_skb_destructor() correctly, the atomic manipulation of
both sk_rmem_alloc and udp_memory_allocated will happen under the
receive lock. In our experiments this increment measurably the
contention on the lock in respect to moving said the operations outside
the lock (as done in our patch). Do you foreseen any issues with that ?
AFAICS every in kernel UDP user of skb_recv_datagram() needs to be
updated with both implementation.

Cheers,

Paolo

