Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753837Ab1EDLyP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 May 2011 07:54:15 -0400
Date: Wed, 4 May 2011 07:54:10 -0400
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, andros@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
Message-ID: <20110504075410.5e59c6b4@tlielax.poochiereds.net>
In-Reply-To: <20110504120726.347df3fc@notabene.brown>
References: <1304386808-2733-1-git-send-email-andros@netapp.com>
	<1304386808-2733-2-git-send-email-andros@netapp.com>
	<20110503202023.699435f4@corrin.poochiereds.net>
	<1304469890.26184.16.camel@lade.trondhjem.org>
	<20110504111825.6f26f75a@notabene.brown>
	<1304473563.26184.28.camel@lade.trondhjem.org>
	<20110504120726.347df3fc@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 4 May 2011 12:07:26 +1000
NeilBrown <neilb@suse.de> wrote:

> On Tue, 03 May 2011 21:46:03 -0400 Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> 
> > On Wed, 2011-05-04 at 11:18 +1000, NeilBrown wrote:
> > > For rpc slots, I doubt you need mempools at all.
> > > Mempools are only needed if failure is not an option and you would rather
> > > wait, but you cannot wait for regular writeback because you are on the
> > > writeback path.  So you use a mempool which waits for a previous request to
> > > complete.  I don't think that describes rpc slots at all.
> > > For rpc slots, you can afford to wait when setting up the transport, as you
> > > are not on the writeout path yet, and later you can always cope with failure.
> > > So just use kmalloc.
> > 
> > Errr.... No. By the time you get to allocating an RPC slot, you may be
> > bang smack in the middle of the writeout path.
> > 
> > The scenario would be that something triggers a writeback (kswapd,
> > direct reclaim,...) which triggers an RPC call, which requires you to
> > allocate at least one rpc slot before you can put the write on the wire.
> > 
> > I agree with your assertion that we only need one successful slot
> > allocation in order to make overall forward progress, but we definitely
> > do need that one...
> > 
> 
> Probably I misunderstood the code, but I thought that there was a base set of
> slots preallocated.  Eventually one of those will become free won't it?
> 
> Looking at the code again, it only ever returns entries to the mempool when
> it is about to destroy the xprt.  That makes no sense.  If you are using a
> mempool, then you allocate when you need to use space, and free it as soon as
> you have finished with it, so the next request can get a turn.
> 

That was sort of my point, though I didn't articulate it very well.

I don't think we want to keep this "static" set of rqsts and the
mempool. It seems like that's somewhat redundant and more complex than
is warranted. The question is...which should we keep?

I think it sort of depends on what the intended model is. If we want to
allocate out of the "guaranteed" pool first and only when that's
exhausted fall back to doing dynamic allocations, then we probably want
to keep the static list of entries.

If we want to allocate dynamically most of the time and only dip into
the "guaranteed" pool when that can't be satisfied, then basing all of
this around mempools might make more sense.

-- 
Jeff Layton <jlayton@redhat.com>
