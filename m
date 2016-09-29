Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44681 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932451AbcI2Jb7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Sep 2016 05:31:59 -0400
Message-ID: <1475141514.4676.28.camel@redhat.com>
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
Date: Thu, 29 Sep 2016 11:31:54 +0200
In-Reply-To: <1475113378.28155.124.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1475048434.git.pabeni@redhat.com>
         <6f445861ef2ce2e626a1df4946bc3f43f3d43e3f.1475048434.git.pabeni@redhat.com>
         <1475113378.28155.124.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
> 
> 
> This is racy... all these atomics make me nervous...

Ah, perhaps I got it: if we have a concurrent memory scheduling, we
could end up with a value of mem_allocated below the real need. 

That mismatch will not drift: at worst we can end up with mem_allocated
being single SK_MEM_QUANTUM below what is strictly needed.

A possible alternative could be:

static void udp_rmem_release(struct sock *sk, int partial)
{
	struct udp_sock *up = udp_sk(sk);
	int fwd, amt, alloc_old, alloc;

	if (partial && !udp_under_memory_pressure(sk))
		return;

	alloc = atomic_read(&up->mem_allocated);
	fwd = alloc - atomic_read(&sk->sk_rmem_alloc);
	if (fwd < SK_MEM_QUANTUM + partial)
		return;

	amt = (fwd - partial) & ~(SK_MEM_QUANTUM - 1);
	alloc_old = atomic_cmpxchg(&up->mem_allocated, alloc, alloc - amt);
	/* if a concurrent update is detected, just do nothing; if said update
	 * is due to another memory release, that release take care of
	 * reclaiming the memory for us, too.
	 * Otherwise we will be able to release on later dequeue, since
	 * we will eventually stop colliding with the writer when it will
	 * consume all the fwd allocated memory
	 */
	if (alloc_old != alloc)
		return;

	__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
	sk->sk_forward_alloc = fwd - amt;
}

which is even more lazy in reclaiming but should never underestimate the
needed forward allocation, and under pressure should eventually free the
needed memory.



