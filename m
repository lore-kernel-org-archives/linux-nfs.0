Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:49406 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbaHKQkl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 12:40:41 -0400
Received: by mail-qa0-f50.google.com with SMTP id s7so7829040qap.23
        for <linux-nfs@vger.kernel.org>; Mon, 11 Aug 2014 09:40:41 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 11 Aug 2014 12:40:39 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd: allow find_any_file to return a fi_deleg_file
 reference
Message-ID: <20140811124039.7b57888d@tlielax.poochiereds.net>
In-Reply-To: <20140811160840.GB9095@fieldses.org>
References: <1407594162-28342-1-git-send-email-jlayton@primarydata.com>
	<1407594162-28342-4-git-send-email-jlayton@primarydata.com>
	<20140811160840.GB9095@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 11 Aug 2014 12:08:40 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Sat, Aug 09, 2014 at 10:22:42AM -0400, Jeff Layton wrote:
> > It's possible that we'll have a nfs4_file that has nothing in its fds
> > array, but that has a populated fi_deleg_file field.
> 
> Is it really possible?  On a quick skim it looks like this is only used
> in the presence of lock stateid's, when we should have an open.
> 
> OK with the cleanup I'm just not seeing a reason either one way or the
> other for the fi_deleg_file change.
> 
> --b.
> 

You're correct. The existing code doesn't specifically require this
patch since find_any_file is only used with lock stateids. It
should be harmless but it won't hurt anything to drop it.

I did however need this when I rebased some pnfsd patches on top of the
state overhaul, and it seemed like a reasonable change from a
"future-proofing" standpoint.

Do you intend to the take the first two in the series? I would like to
see those go in since they move the lease removal outside of spinlocks.


> > Since that function
> > is generally happy with any file reference, allow it to find and take
> > a reference to it in that situation. Also, clean up find_any_file for
> > better readability.
> > 
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/nfsd/nfs4state.c | 19 ++++++++++++++-----
> >  1 file changed, 14 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 4356d32479b2..5c5873811bd9 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -355,11 +355,20 @@ find_any_file(struct nfs4_file *f)
> >  
> >  	spin_lock(&f->fi_lock);
> >  	ret = __nfs4_get_fd(f, O_RDWR);
> > -	if (!ret) {
> > -		ret = __nfs4_get_fd(f, O_WRONLY);
> > -		if (!ret)
> > -			ret = __nfs4_get_fd(f, O_RDONLY);
> > -	}
> > +	if (ret)
> > +		goto out;
> > +
> > +	ret = __nfs4_get_fd(f, O_WRONLY);
> > +	if (ret)
> > +		goto out;
> > +
> > +	ret = __nfs4_get_fd(f, O_RDONLY);
> > +	if (ret)
> > +		goto out;
> > +
> > +	if (f->fi_deleg_file)
> > +		ret = get_file(f->fi_deleg_file);
> > +out:
> >  	spin_unlock(&f->fi_lock);
> >  	return ret;
> >  }
> > -- 
> > 1.9.3
> > 


-- 
Jeff Layton <jlayton@primarydata.com>
