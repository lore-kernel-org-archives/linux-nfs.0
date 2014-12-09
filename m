Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34482 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753775AbaLIQ5y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 11:57:54 -0500
Date: Tue, 9 Dec 2014 11:57:52 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trondmy@gmail.com>,
        Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] sunrpc: convert to lockless lookup of queued server
 threads
Message-ID: <20141209165752.GG20526@fieldses.org>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
 <1416597571-4265-4-git-send-email-jlayton@primarydata.com>
 <20141201234759.GF30749@fieldses.org>
 <CAABAsM6cikgA-gJZUNHzoqZCGxQaS9hagy9vcY4yfOzaqi4QyQ@mail.gmail.com>
 <20141202065750.283704a7@tlielax.poochiereds.net>
 <20141202071422.5b01585d@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141202071422.5b01585d@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 02, 2014 at 07:14:22AM -0500, Jeff Layton wrote:
> On Tue, 2 Dec 2014 06:57:50 -0500
> Jeff Layton <jeff.layton@primarydata.com> wrote:
> 
> > On Mon, 1 Dec 2014 19:38:19 -0500
> > Trond Myklebust <trondmy@gmail.com> wrote:
> > 
> > > On Mon, Dec 1, 2014 at 6:47 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > >         - instead we're walking the list of all threads looking for an
> > > >           idle one.  I suppose that's tpyically not more than a few
> > > >           hundred.  Does this being fast depend on the fact that that
> > > >           list is almost never changed?  Should we be rearranging
> > > >           svc_rqst so frequently-written fields aren't nearby?
> > > 
> > > Given a 64-byte cache line, that is 8 pointers worth on a 64-bit processor.
> > > 
> > > - rq_all, rq_server, rq_pool, rq_task don't ever change, so perhaps
> > > shove them together into the same cacheline?
> > > 
> > > - rq_xprt does get set often until we have a full RPC request worth of
> > > data, so perhaps consider moving that.
> > > 
> > > - OTOH, rq_addr, rq_addrlen, rq_daddr, rq_daddrlen are only set once
> > > we have a full RPC to process, and then keep their values until that
> > > RPC call is finished. That doesn't look too bad.

By the way, one thing I forgot when writing the above comment was that
the list we're walking (sp_all_threads) is *still* per-pool (for some
reason I was thinking it was global), so it's really unlikely we're
making things worse here.

Still, reshuffling those svc_rqst fields is easy and might help.

I think your tests probably aren't hitting the worst case here, either:
even in a read-mostly case most interrupts will be handling the (less
frequent but larger) writes.  Maybe an all-stat workload would test the
case where e.g. rq_xprt is written to every time?  But I haven't thought
that through.

--b.
