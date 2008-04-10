From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs: infinite loop in fcntl(F_SETLKW)
Date: Thu, 10 Apr 2008 17:54:10 -0400
Message-ID: <20080410215410.GF22324@fieldses.org>
References: <E1JjcgO-0004q2-VJ@pomaz-ex.szeredi.hu> <E1Jk2oI-0007UX-MS@pomaz-ex.szeredi.hu> <1207861339.8180.14.camel@heimdal.trondhjem.org> <1207861661.8180.18.camel@heimdal.trondhjem.org> <1207862436.8180.30.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Miklos Szeredi <miklos@szeredi.hu>,
	Marc Eshel <eshel@almaden.ibm.com>, neilb@suse.de,
	akpm@linux-foundation.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1207862436.8180.30.camel@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 10, 2008 at 05:20:36PM -0400, Trond Myklebust wrote:
> 
> On Thu, 2008-04-10 at 17:07 -0400, Trond Myklebust wrote:
> > On Thu, 2008-04-10 at 17:02 -0400, Trond Myklebust wrote:
> > > On Thu, 2008-04-10 at 21:51 +0200, Miklos Szeredi wrote:
> > > > Another infinite loop, this one involving both client and server.
> > > > 
> > > > Basically what happens is that on the server nlm_fopen() calls
> > > > nfsd_open() which returns -EACCES, to which nlm_fopen() returns
> > > > NLM_LCK_DENIED.
> > > > 
> > > > On the client this will turn into a -EAGAIN (nlm_stat_to_errno()),
> > > > which in will cause fcntl_setlk() to retry forever.
> > > > 
> > > > I _think_ the solution is to turn NLM_LCK_DENIED into ENOLCK for
> > > > blocking locks, as NLM_LCK_BLOCKED is for the contended case.  For
> > > > testing the lock leave NLM_LCK_DENIED as EAGAIN.  That still could be
> > > > misleading, but at least there's no infinite loop in that case.
> > > > 
> > > > I've minimally tested this patch to verify that it cures the lockup,
> > > > and that simple blocking locks keep working.
> > > > 
> > > > Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> > > > ---
> > > >  fs/lockd/clntproc.c |    3 +++
> > > >  1 file changed, 3 insertions(+)
> > > > 
> > > > Index: linux/fs/lockd/clntproc.c
> > > > ===================================================================
> > > > --- linux.orig/fs/lockd/clntproc.c	2008-04-02 13:34:57.000000000 +0200
> > > > +++ linux/fs/lockd/clntproc.c	2008-04-10 21:23:46.000000000 +0200
> > > > @@ -536,6 +536,9 @@ again:
> > > >  		up_read(&host->h_rwsem);
> > > >  	}
> > > >  	status = nlm_stat_to_errno(resp->status);
> > > > +	/* Don't return EAGAIN, as that would make fcntl_setlk() loop */
> > > > +	if (status == -EAGAIN)
> > > > +		status = -ENOLCK;
> > > >  out_unblock:
> > > >  	nlmclnt_finish_block(block);
> > > >  	/* Cancel the blocked request if it is still pending */
> > > 
> > > 
> > > Wait. There is something really weird going on here.
> > > 
> > > According to the spec, LCK_DENIED means 'the request failed' (i.e.
> > > ENOLCK is definitely correct)
> > > 
> > > OTOH, LCK_DENIED_NOLOCKS and LCK_DENIED_GRACE_PERIOD are both temporary
> > > failures, the first because the server had a resource problem, and the
> > > second because the server rebooted and is in the grace period (i.e.
> > > EAGAIN would appear to be more appropriate). See
> > > 
> > > http://www.opengroup.org/onlinepubs/9629799/chap10.htm#tagcjh_11_02_02_02
> > > 
> > > AFAICS, the correct thing to do is to fix nlm_stat_to_errno() by
> > > swapping the return values for NLM_LCK_DENIED and
> > > NLM_LCK_DENIED_NOLOCKS/NLM_LCK_DENIED_GRACE_PERIOD.
> > > 
> > > The problem is that there appears to be a similar confusion on the Linux
> > > server side in nlmsvc_lock(). :-(
> > 
> > Duh... Sorry, EAGAIN is indeed the correct return value for fcntl() when
> > the lock attempt failed. I should have reread the manpage/posix spec
> > before replying.
> 
> OK. So the correct fix here should really be applied to fcntl_setlk().
> There is absolutely no reason why we should be looping at all if the
> filesystem has a ->lock() method.
> 
> In fact, this looping behaviour was introduced recently in commit
> 7723ec9777d9832849b76475b1a21a2872a40d20.

Apologies, that was indeed a behavioral change introduced in a commit
that claimed just to be shuffling code around.

> Marc, Bruce, why was this
> done, and how are filesystems now supposed to behave?
> 

The assumption must have been that -EAGAIN could only mean that we
needed to keep blocking, and hence was a nonsensical return from a
filesystem lock method that waited itself for the lock to become
available--such a method would return 0, -EINTR (or some more exotic
error), or continue waiting.

If we agree that EAGAIN is actually a legimate error to return from a
blocking lock, then, yes, we need take ->lock() back out of this loop.

And I don't think there's any real reason we need the new behavior.  So
we should probably revert that--I'll take a closer look tomorrow....

--b.
