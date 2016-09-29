Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49508 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754922AbcI2Her (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Sep 2016 03:34:47 -0400
Message-ID: <1475134482.4676.11.camel@redhat.com>
Subject: Re: [PATCH net-next v3 2/3] udp: implement memory accounting helpers
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
Date: Thu, 29 Sep 2016 09:34:42 +0200
In-Reply-To: <1475113378.28155.124.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1475048434.git.pabeni@redhat.com>
         <6f445861ef2ce2e626a1df4946bc3f43f3d43e3f.1475048434.git.pabeni@redhat.com>
         <1475113378.28155.124.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Eric,

On Wed, 2016-09-28 at 18:42 -0700, Eric Dumazet wrote:
> On Wed, 2016-09-28 at 12:52 +0200, Paolo Abeni wrote:
> 
> > +static void udp_rmem_release(struct sock *sk, int partial)
> > +{
> > +	struct udp_sock *up = udp_sk(sk);
> > +	int fwd, amt;
> > +
> > +	if (partial && !udp_under_memory_pressure(sk))
> > +		return;
> > +
> > +	/* we can have concurrent release; if we catch any conflict
> > +	 * we let only one of them do the work
> > +	 */
> > +	if (atomic_dec_if_positive(&up->can_reclaim) < 0)
> > +		return;
> > +
> > +	fwd = __udp_forward(up, atomic_read(&sk->sk_rmem_alloc));
> > +	if (fwd < SK_MEM_QUANTUM + partial) {
> > +		atomic_inc(&up->can_reclaim);
> > +		return;
> > +	}
> > +
> > +	amt = (fwd - partial) & ~(SK_MEM_QUANTUM - 1);
> > +	atomic_sub(amt, &up->mem_allocated);
> > +	atomic_inc(&up->can_reclaim);
> > +
> > +	__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
> > +	sk->sk_forward_alloc = fwd - amt;
> > +}

Thank you for reviewing this!

> This is racy... 

Could you please elaborate? 

> all these atomics make me nervous...

I'd like to drop some of them if possible.

atomic_inc(&up->can_reclaim);

could probably be replaced with atomic_set(&up->can_reclaim, 1) since we
don't have concurrent processes doing that and can_reclaim.counter is
known to be 0 at that point.
Performance wise the impact is minimal, since in normal condition we do
the reclaim only on socket shutdown.

Paolo

