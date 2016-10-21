Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48660 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752880AbcJULnq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Oct 2016 07:43:46 -0400
Message-ID: <1477050221.4606.6.camel@redhat.com>
Subject: Re: [PATCH net-next v5 2/3] udp: implement memory accounting helpers
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
Date: Fri, 21 Oct 2016 13:43:41 +0200
In-Reply-To: <1476997834.7065.35.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1476979679.git.pabeni@redhat.com>
         <d932905c2581df9415449216eceeed1566290e3e.1476979679.git.pabeni@redhat.com>
         <1476997834.7065.35.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-10-20 at 14:10 -0700, Eric Dumazet wrote:
> On Thu, 2016-10-20 at 22:31 +0200, Paolo Abeni wrote:
> 
> > +
> > +int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
> > +{
> > +	struct sk_buff_head *list = &sk->sk_receive_queue;
> > +	int rmem, delta, amt, err = -ENOMEM;
> > +	int size = skb->truesize;
> > +
> > +	/* try to avoid the costly atomic add/sub pair when the receive
> > +	 * queue is full; always allow at least a packet
> > +	 */
> > +	rmem = atomic_read(&sk->sk_rmem_alloc);
> > +	if (rmem && (rmem + size > sk->sk_rcvbuf))
> > +		goto drop;
> > +
> > +	/* we drop only if the receive buf is full and the receive
> > +	 * queue contains some other skb
> > +	 */
> > +	rmem = atomic_add_return(size, &sk->sk_rmem_alloc);
> > +	if ((rmem > sk->sk_rcvbuf) && (rmem > size))
> > +		goto uncharge_drop;
> > +
> > +	skb_orphan(skb);
> 
> Minor point :
> 
> UDP should already have orphaned skbs ? (it uses skb_steal_sock())

You are right, the skb_orphan() call is redundant. 

I'll send the v6 soon.

Thank you,

Paolo


