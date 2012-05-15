Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34352 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745Ab2EOKId (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 06:08:33 -0400
Date: Tue, 15 May 2012 11:08:29 +0100
From: Mel Gorman <mgorman@suse.de>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
        linux-mm@kvack.org, netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Trond.Myklebust@netapp.com,
        neilb@suse.de, hch@infradead.org, michaelc@cs.wisc.edu,
        emunson@mgebm.net
Subject: Re: [PATCH 01/12] netvm: Prevent a stream-specific deadlock
Message-ID: <20120515100829.GH29102@suse.de>
References: <1336658065-24851-2-git-send-email-mgorman@suse.de>
 <20120511.011034.557833140906762226.davem@davemloft.net>
 <20120514105604.GB29102@suse.de>
 <20120514.162634.1094732813264319951.davem@davemloft.net>
 <20120515091402.GG29102@suse.de>
 <1337075234.27694.9.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
In-Reply-To: <1337075234.27694.9.camel@twins>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 11:47:14AM +0200, Peter Zijlstra wrote:
> On Tue, 2012-05-15 at 10:14 +0100, Mel Gorman wrote:
> > @@ -289,6 +289,18 @@ void sk_clear_memalloc(struct sock *sk)
> >         sock_reset_flag(sk, SOCK_MEMALLOC);
> >         sk->sk_allocation &= ~__GFP_MEMALLOC;
> >         static_key_slow_dec(&memalloc_socks);
> > +
> > +       /*
> > +        * SOCK_MEMALLOC is allowed to ignore rmem limits to ensure forward
> > +        * progress of swapping. However, if SOCK_MEMALLOC is cleared while
> > +        * it has rmem allocations there is a risk that the user of the
> > +        * socket cannot make forward progress due to exceeding the rmem
> > +        * limits. By rights, sk_clear_memalloc() should only be called
> > +        * on sockets being torn down but warn and reset the accounting if
> > +        * that assumption breaks.
> > +        */
> > +       if (WARN_ON(sk->sk_forward_alloc))
> 
> WARN_ON_ONCE() perhaps?
> 

I do not expect SOCK_MEMALLOC to be cleared frequently at all with the
possible exception of swapon/swapoff stress tests. If the flag is being
cleared regularly with rmem tokens then that is interesting in itself
but a WARN_ON_ONCE would miss it.

> > +               sk_mem_reclaim(sk);
> >  } 

-- 
Mel Gorman
SUSE Labs
