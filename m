From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Thu, 25 Sep 2008 16:00:14 -0400
Message-ID: <20080925200014.GA14078@fieldses.org>
References: <48D19C74.8000303@panasas.com> <48D2AAF7.6060808@panasas.com> <20080924163528.GB5772@fieldses.org> <1222275582.7390.8.camel@localhost> <20080924172134.GI5772@fieldses.org> <1222277168.7390.19.camel@localhost> <20080924174230.GJ5772@fieldses.org> <1222281745.7390.34.camel@localhost> <20080924184934.GK5772@fieldses.org> <48DBE6D9.3010603@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Trond Myklebust <trond@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58558 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752819AbYIYUA2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2008 16:00:28 -0400
In-Reply-To: <48DBE6D9.3010603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 25, 2008 at 10:30:33PM +0300, Benny Halevy wrote:
> On 09/24/2008 9:49:34 pm +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Wed, Sep 24, 2008 at 02:42:25PM -0400, Trond Myklebust wrote:
> >> On Wed, 2008-09-24 at 13:42 -0400, J. Bruce Fields wrote:
> >>
> >>> If by "broken" you mean, "introduces a new kernel bug", I don't see it.
> >> I mean it introduces utterly unnecessary complications that may return
> >> to bite us in the arse at a future time.
> > 
> > OK, that's the answer I was looking for, thanks.
> > 
> >> Remember how we once said that it would never make sense for child
> >> clones to call the portmapper, and so we added the BUG_ON() in
> >> rpcb_getport_async; well guess what, we currently have a bug to fix...
> > 
> > No, I don't remember that.  But yes, I can see how in general this sort
> > of thing could make the code harder to maintain.
> > 
> >> One pretty obvious fix is to simply move the release method so that it
> >> doesn't occur when you release a child. The disadvantage is that a child
> >> may then not change its program to one that requires a release method
> >> (do we need that?).
> > 
> > I doubt we need that, but...
> > 
> >> Another fix would be to add a refcount to the rpc_program structure...
> > 
> > ... a refcount seems more straightforward.  Benny, what do you think?
> 
> I agree.  I'll send a patch hopefully tomorrow.
> Would you like that combined with the one I sent or as a separate one?
> (I'm inclined towards the latter).

That'd be fine.

> One more thing that seems to need fixing is rpc_bind_new_program
> which now uses the passed-in program->cl_stats but doesn't point
> to the passed-in program, but rather it only extracts its
> name, number, and stats.
> Since program->stats may possibly go away with the program
> in the refcounted world I think we should get a reference on the
> program here too.
> 
> That observed, it may also be a good idea to get rid of clnt->cl_stats
> altogether and use clnt->program->stats instead to prevent any
> discrepancy.

Sounds good to me.

--b.
