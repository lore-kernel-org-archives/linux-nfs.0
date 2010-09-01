Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43793 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752208Ab0IALcG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Sep 2010 07:32:06 -0400
Date: Wed, 1 Sep 2010 07:31:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org, Anton Blanchard <anton@au1.ibm.com>
Subject: Re: [PATCH 1.5/6] Fix race in new request delay code.
Message-ID: <20100901113137.GA15817@fieldses.org>
References: <20100812065722.11459.18978.stgit@localhost.localdomain>
 <20100817051509.26151.91127.stgit@localhost.localdomain>
 <20100826210800.GD10636@fieldses.org>
 <20100830093608.5936a554@notabene>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100830093608.5936a554@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 30, 2010 at 09:36:08AM +1000, Neil Brown wrote:
> On Thu, 26 Aug 2010 17:08:00 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Tue, Aug 17, 2010 at 03:15:09PM +1000, NeilBrown wrote:
> > > If the 'wait_for_completion_interruptible_timeout' completes due
> > > to interrupt or timeout, just before cache_revisit request gets around
> > > to calling ->revisit and thus the completion, we have a race with bad
> > > consequences.
> > > 
> > > cache_defer_req will see that sleeper.handle.hash is empty (because
> > > cache_revisit_request has already done the list_del_init), and that
> > > CACHE_PENDING is clear, and so will exit that function leaving any
> > > local variables such as 'sleeper' undefined.
> > > 
> > > Meanwhile cache_revisit_request could delete sleeper.handle.recent
> > > from the 'pending' list, and call sleeper.hande.revisit, any of which
> > > could have new garbage values and so could trigger a BUG.
> > 
> > Thanks, this looks correct to me!
> > 
> > I wish it were simpler, but don't see how right now.
> 
> I think the way to make it simpler is to get rid of the deferral altogether.
> The more I think about it the less I like it :-)
> 
> The deferral code effectively gives you DFR_MAX extra virtual threads.  They
> each are processing one request but have (supposedly) much lower over-head
> than creating real threads.  So there are two groups of threads:
>  - those that can wait a longish time for a reply to an upcall
>  - those that only wait for IO.
> 
> This distinction could well still be useful as we don't really want all
> threads to be tied up waiting on upcalls so that no really work can be done.
> However we don't really need the deferral mechanism to achieve this.
> 
> Instead we impose a limit on the number of threads that can be in waiting on
> a completion (in cache_wait_req in your revised code).
> If the number of such threads ever reaches - say - half the total, then we
> start dropping requests and closing TCP connections (or start new threads if
> we ever work out a good way to dynamically manage the thread pool).
> 
> So I would suggest:
>   - putting in a counter and limiting the number of waiting threads to
>     half the pool size
>   - removing all the deferral code
>   - looking at cleaning up what is left to make it more readable.
> 
> ???

That makes sense to me.  We should make a quick check of how the
client's using the deferral code (since it uses the cache code for
idmapping now), but I suspect it's very simple (it should only ever need
to do idmapping in process context).

--b.
