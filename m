Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59954 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753664Ab2BGOt7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 09:49:59 -0500
Date: Tue, 7 Feb 2012 09:49:56 -0500
From: "J.Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NeilBrown <neilb@suse.de>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] lockd: fix arg parsing for grace_period and timeout.
Message-ID: <20120207144956.GA4868@fieldses.org>
References: <20120207153542.3df498ad@notabene.brown>
 <1328623124.4124.5.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1328623124.4124.5.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 07, 2012 at 01:58:43PM +0000, Myklebust, Trond wrote:
> On Tue, 2012-02-07 at 15:35 +1100, NeilBrown wrote:
> > If you try to set grace_period or timeout via a module parameter
> > to lockd, and do this on a big-endian machine where
> > 
> >    sizeof(int) != sizeof(unsigned long)
> > 
> > it won't work.  This number given will be effectively shifted right
> > by the difference in those two sizes.
> > 
> > So cast kp->arg properly to get correct result.
> > 
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > 
> > diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> > index c061b9a..2444780 100644
> > --- a/fs/lockd/svc.c
> > +++ b/fs/lockd/svc.c
> > @@ -440,7 +440,7 @@ static int param_set_##name(const char *val, struct kernel_param *kp)	\
> >  	__typeof__(type) num = which_strtol(val, &endp, 0);		\
> >  	if (endp == val || *endp || num < (min) || num > (max))		\
> >  		return -EINVAL;						\
> > -	*((int *) kp->arg) = num;					\
> > +	*((type *) kp->arg) = num;					\
> >  	return 0;							\
> >  }
> >  
> Wow, that's a seriously old bug...

Looking at a historical git repo, it was probably from "[PATCH] make NFS
lockd port numbers assignable at run time", attributed to Jamie Lokier
in August 2003, in 2.6.0.

Anyway:

> Bruce, do you want to carry it?

Sure.  I'm a little slow getting stuff pushed out while I track down a
couple very tricky bugs, but it should show up in my git tree in a few
days....

--b.
