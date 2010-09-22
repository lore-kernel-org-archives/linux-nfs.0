From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1.5/6] Fix race in new request delay code.
Date: Tue, 21 Sep 2010 22:15:18 -0400
Message-ID: <20100922021518.GB22021@fieldses.org>
References: <20100812065722.11459.18978.stgit@localhost.localdomain>
 <20100817051509.26151.91127.stgit@localhost.localdomain>
 <20100826210800.GD10636@fieldses.org>
 <20100830093608.5936a554@notabene>
 <20100921183521.4510af63@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41654 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923Ab0IVCQq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 22:16:46 -0400
In-Reply-To: <20100921183521.4510af63@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 21, 2010 at 06:35:21PM +1000, Neil Brown wrote:
> On Mon, 30 Aug 2010 09:36:08 +1000
> Neil Brown <neilb@suse.de> wrote:
> 
> > On Thu, 26 Aug 2010 17:08:00 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Tue, Aug 17, 2010 at 03:15:09PM +1000, NeilBrown wrote:
> > > > If the 'wait_for_completion_interruptible_timeout' completes due
> > > > to interrupt or timeout, just before cache_revisit request gets around
> > > > to calling ->revisit and thus the completion, we have a race with bad
> > > > consequences.
> > > > 
> > > > cache_defer_req will see that sleeper.handle.hash is empty (because
> > > > cache_revisit_request has already done the list_del_init), and that
> > > > CACHE_PENDING is clear, and so will exit that function leaving any
> > > > local variables such as 'sleeper' undefined.
> > > > 
> > > > Meanwhile cache_revisit_request could delete sleeper.handle.recent
> > > > from the 'pending' list, and call sleeper.hande.revisit, any of which
> > > > could have new garbage values and so could trigger a BUG.
> > > 
> > > Thanks, this looks correct to me!
> > > 
> > > I wish it were simpler, but don't see how right now.
> > 
> > I think the way to make it simpler is to get rid of the deferral altogether.
> > The more I think about it the less I like it :-)
> 
> I was in the process of doing this "getting rid of deferral" when I
> discovered that lockd now uses deferral too (and has done for 4 years! I am
> out of touch!!).  This is for NFS exporting cluster filesystems where 'lock'
> might take a while, but returns a 'grant'.
> 
> As lockd is single-threads we cannot just let it wait for the grant
> in-process.
> 
> So I guess I cannot rip all that code out after all :-(

Yeah, I'd forgotten about that.  Eventually perhaps we can fix lockd....

--b.
