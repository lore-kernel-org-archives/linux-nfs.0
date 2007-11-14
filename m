From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] - [7/15] - remove defconfig ptr comparisons to 0 -
	fs/lockd
Date: Wed, 14 Nov 2007 12:50:46 -0500
Message-ID: <1195062646.7584.27.camel@heimdal.trondhjem.org>
References: <1195005918.5163.93.camel@localhost>
	 <18234.24623.742782.328651@notabene.brown>
	 <1195015507.7468.86.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Joe Perches <joe@perches.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761980AbXKNRvH@vger.kernel.org>
In-Reply-To: <1195015507.7468.86.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Tue, 2007-11-13 at 23:45 -0500, Trond Myklebust wrote:
> On Wed, 2007-11-14 at 13:40 +1100, Neil Brown wrote:
> > On Tuesday November 13, joe@perches.com wrote:
> > > Remove defconfig ptr comparison to 0
> > > 
> > > Remove sparse warning: Using plain integer as NULL pointer
> > > 
> > > Signed-off-by: Joe Perches <joe@perches.com>
> > > 
> > > ---
> > > 
> > > diff --git a/fs/lockd/svcshare.c b/fs/lockd/svcshare.c
> > > index 068886d..98548ad 100644
> > > --- a/fs/lockd/svcshare.c
> > > +++ b/fs/lockd/svcshare.c
> > > @@ -71,7 +71,7 @@ nlmsvc_unshare_file(struct nlm_host *host, struct nlm_file *file,
> > >  	struct nlm_share	*share, **shpp;
> > >  	struct xdr_netobj	*oh = &argp->lock.oh;
> > >  
> > > -	for (shpp = &file->f_shares; (share = *shpp) != 0; shpp = &share->s_next) {
> > > +	for (shpp = &file->f_shares; (share = *shpp); shpp = &share->s_next) {
> > >  		if (share->s_host == host && nlm_cmp_owner(share, oh)) {
> > >  			*shpp = share->s_next;
> > >  			kfree(share);
> > > 
> > 
> > I particularly disagree with this change as it now looked like it
> > could be an '==' comparison that was mistyped.  Making it 
> >         ....; (share = *shpp) != NULL; ....
> 
> There would also be the minor fact that the original test is being
> inverted in this 'fix'. An accurate fix should at the very least be
>    !(share = *shpp).

Apologies to Joe. I must have been tired when I typed the above. However
I'm still NACKing the patch: removing the '!= 0' altogether reduces code
legibility rather than improving it, particularly when we have that ugly
assignment.
If the intent is just to silence 'sparse', then replace with '!= NULL'.

> > makes the intent clear.
> 
> It would be a lot cleaner just to pull the entire assignment out of the
> for() statement. IOW:
> 
> 	for (shpp = &file->f_shares; *shpp != NULL; shpp = &(*shpp)->s_next) {
> 		struct nlm_share *share = *shpp;

...however doing something like the above would be altogether
preferable, since that cleans up the assignment which is the source of
the ugliness.

Cheers
  Trond
