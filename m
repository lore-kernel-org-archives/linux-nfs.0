Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:43998 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755981Ab0IUIf3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 04:35:29 -0400
Date: Tue, 21 Sep 2010 18:35:21 +1000
From: Neil Brown <neilb@suse.de>
To: Neil Brown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1.5/6] Fix race in new request delay code.
Message-ID: <20100921183521.4510af63@notabene>
In-Reply-To: <20100830093608.5936a554@notabene>
References: <20100812065722.11459.18978.stgit@localhost.localdomain>
	<20100817051509.26151.91127.stgit@localhost.localdomain>
	<20100826210800.GD10636@fieldses.org>
	<20100830093608.5936a554@notabene>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 30 Aug 2010 09:36:08 +1000
Neil Brown <neilb@suse.de> wrote:

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

I was in the process of doing this "getting rid of deferral" when I
discovered that lockd now uses deferral too (and has done for 4 years! I am
out of touch!!).  This is for NFS exporting cluster filesystems where 'lock'
might take a while, but returns a 'grant'.

As lockd is single-threads we cannot just let it wait for the grant
in-process.

So I guess I cannot rip all that code out after all :-(

NeilBrown




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
> 
> NeilBrown
