From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] - [7/15] - remove defconfig ptr comparisons to 0 -
	fs/lockd
Date: Tue, 13 Nov 2007 23:45:07 -0500
Message-ID: <1195015507.7468.86.camel@heimdal.trondhjem.org>
References: <1195005918.5163.93.camel@localhost>
	 <18234.24623.742782.328651@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Joe Perches <joe@perches.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761770AbXKNEof@vger.kernel.org>
In-Reply-To: <18234.24623.742782.328651@notabene.brown>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Wed, 2007-11-14 at 13:40 +1100, Neil Brown wrote:
> On Tuesday November 13, joe@perches.com wrote:
> > Remove defconfig ptr comparison to 0
> > 
> > Remove sparse warning: Using plain integer as NULL pointer
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> > 
> > ---
> > 
> > diff --git a/fs/lockd/svcshare.c b/fs/lockd/svcshare.c
> > index 068886d..98548ad 100644
> > --- a/fs/lockd/svcshare.c
> > +++ b/fs/lockd/svcshare.c
> > @@ -71,7 +71,7 @@ nlmsvc_unshare_file(struct nlm_host *host, struct nlm_file *file,
> >  	struct nlm_share	*share, **shpp;
> >  	struct xdr_netobj	*oh = &argp->lock.oh;
> >  
> > -	for (shpp = &file->f_shares; (share = *shpp) != 0; shpp = &share->s_next) {
> > +	for (shpp = &file->f_shares; (share = *shpp); shpp = &share->s_next) {
> >  		if (share->s_host == host && nlm_cmp_owner(share, oh)) {
> >  			*shpp = share->s_next;
> >  			kfree(share);
> > 
> 
> I particularly disagree with this change as it now looked like it
> could be an '==' comparison that was mistyped.  Making it 
>         ....; (share = *shpp) != NULL; ....

There would also be the minor fact that the original test is being
inverted in this 'fix'. An accurate fix should at the very least be
   !(share = *shpp).

> makes the intent clear.

It would be a lot cleaner just to pull the entire assignment out of the
for() statement. IOW:

	for (shpp = &file->f_shares; *shpp != NULL; shpp = &(*shpp)->s_next) {
		struct nlm_share *share = *shpp;
