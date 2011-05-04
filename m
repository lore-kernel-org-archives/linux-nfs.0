Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:43857 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754167Ab1EDCHh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 May 2011 22:07:37 -0400
Date: Wed, 4 May 2011 12:07:26 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: andros@netapp.com, Jeff Layton <jlayton@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
Message-ID: <20110504120726.347df3fc@notabene.brown>
In-Reply-To: <1304473563.26184.28.camel@lade.trondhjem.org>
References: <1304386808-2733-1-git-send-email-andros@netapp.com>
	<1304386808-2733-2-git-send-email-andros@netapp.com>
	<20110503202023.699435f4@corrin.poochiereds.net>
	<1304469890.26184.16.camel@lade.trondhjem.org>
	<20110504111825.6f26f75a@notabene.brown>
	<1304473563.26184.28.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 03 May 2011 21:46:03 -0400 Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:

> On Wed, 2011-05-04 at 11:18 +1000, NeilBrown wrote:
> > For rpc slots, I doubt you need mempools at all.
> > Mempools are only needed if failure is not an option and you would rather
> > wait, but you cannot wait for regular writeback because you are on the
> > writeback path.  So you use a mempool which waits for a previous request to
> > complete.  I don't think that describes rpc slots at all.
> > For rpc slots, you can afford to wait when setting up the transport, as you
> > are not on the writeout path yet, and later you can always cope with failure.
> > So just use kmalloc.
> 
> Errr.... No. By the time you get to allocating an RPC slot, you may be
> bang smack in the middle of the writeout path.
> 
> The scenario would be that something triggers a writeback (kswapd,
> direct reclaim,...) which triggers an RPC call, which requires you to
> allocate at least one rpc slot before you can put the write on the wire.
> 
> I agree with your assertion that we only need one successful slot
> allocation in order to make overall forward progress, but we definitely
> do need that one...
> 

Probably I misunderstood the code, but I thought that there was a base set of
slots preallocated.  Eventually one of those will become free won't it?

Looking at the code again, it only ever returns entries to the mempool when
it is about to destroy the xprt.  That makes no sense.  If you are using a
mempool, then you allocate when you need to use space, and free it as soon as
you have finished with it, so the next request can get a turn.

NeilBrown
