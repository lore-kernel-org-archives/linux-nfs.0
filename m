From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: next-20090406: nfsd build fails
Date: Thu, 9 Apr 2009 12:12:06 -0400
Message-ID: <20090409161206.GE32589@fieldses.org>
References: <a4423d670904060027y44550d99g2cb40ce415dbb048@mail.gmail.com> <49D9C308.6020500@panasas.com> <20090406171146.GA32436@fieldses.org> <49DBA132.5000703@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Alexander Beregalov <a.beregalov@gmail.com>, andros@netapp.com,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	linux-nfs@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <49DBA132.5000703@panasas.com>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 07, 2009 at 09:53:38PM +0300, Benny Halevy wrote:
> On Apr. 06, 2009, 20:11 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Mon, Apr 06, 2009 at 11:53:28AM +0300, Benny Halevy wrote:
> >> On Apr. 06, 2009, 10:27 +0300, Alexander Beregalov <a.beregalov@gmail.com> wrote:
> >>> Hi
> >>>
> >>> fs/nfsd/nfssvc.c: In function 'set_max_drc':
> >>> fs/nfsd/nfssvc.c:240: error: 'NFSD_DRC_SIZE_SHIFT' undeclared
> >>>
> >>> CONFIG_NFSD_V4 is not set
> >> Hi Alexander,
> >>
> >> Thanks for reporting this!
> >>
> >> Andy, Bruce: please see attached 2 patches fixing compile/link errors
> >> with DRC under !defined(CONFIG_NFSD_V4):
> >>
> >> [PATCH 1/2] SQUASHEM: nfsd41: define NFSD_DRC_SIZE_SHIFT in set_max_drc
> >> [PATCH 2/2] SQUASHME: nfsd41: define nfsd4_set_statp as noop for !CONFIG_NFSD_V4
> > 
> > Thanks, applied.
> > 
> > Committing on top (not squashing) since I'd rather not rewrite history
> > on a branch I've already sent a pull request for.
> 
> Cool. Thanks!
> I wasn't aware that you already sent a pull request already...
> I got it from mainline now and I'm rebasing and testing
> the rest of our stuff on top of it.
> 
> > 
> > (In fact, I'll try to stop rebasing those for-next branches at all this
> > time around.)
> 
> I'm with you on that.
> 
> For 2.6.31, I'd like to send easy-to-swallow patch sets
> that we can review and agree upon well ahead of the merge window
> (i.e. start, e.g. with the backchannel stuff shortly after 2.6.30-rc1
> is cut) and once we're in agreement on it we can put it in linux-next
> to be visible to others and get some soak time.  This will also
> be a good time to freeze it, so it won't be rebased,

Note that it's OK to rebase things in -next; so it doesn't have to be
frozen till it goes into one of our trees.  (And I've tried once or
twice to maintain the discpline of not rebasing stuff in my tree and
have failed....  I'll make a better effort this time.)

> unless something
> important enough requires that.  How does that sound?

Sounds fine.  If you send in things as they're ready, I'll try to turn
them around a little faster (within a few days or a week anyway).

--b.

> I think that the same strategy should work for the client side too.
> Trond what do you think?
> 
> Benny
> 
> > 
> > --b.
