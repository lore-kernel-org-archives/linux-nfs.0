Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60307 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750724AbbGMFT3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 01:19:29 -0400
Date: Mon, 13 Jul 2015 15:19:10 +1000
From: NeilBrown <neilb@suse.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150713151910.0f493f49@noble>
In-Reply-To: <20150713040258.GM17109@ZenIV.linux.org.uk>
References: <55A11010.6050005@gmail.com>
	<55A111A8.2040701@gmail.com>
	<20150713133934.6a4ef77d@noble>
	<20150713040258.GM17109@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 13 Jul 2015 05:02:58 +0100 Al Viro <viro@ZenIV.linux.org.uk>
wrote:

> On Mon, Jul 13, 2015 at 01:39:34PM +1000, NeilBrown wrote:
> > It would be nice if pin_kill() would check ->done again after calling p->kill.
> > e.g.
> > 
> > diff --git a/fs/fs_pin.c b/fs/fs_pin.c
> > index 611b5408f6ec..c2ef5c9d4c0d 100644
> > --- a/fs/fs_pin.c
> > +++ b/fs/fs_pin.c
> > @@ -47,7 +47,9 @@ void pin_kill(struct fs_pin *p)
> >  		spin_unlock_irq(&p->wait.lock);
> >  		rcu_read_unlock();
> >  		p->kill(p);
> > -		return;
> > +		if (p->done > 0)
> > +			return;
> > +		spin_lock_irq(&p->wait.lock);
> >  	}
> >  	if (p->done > 0) {
> >  		spin_unlock_irq(&p->wait.lock);
> > 
> > I think that would close the last gap, without needing extra work
> > items and completion in the nfsd code.
> > 
> > Al: would you be OK with that change to pin_kill?
> 
> Hell, no.  Intended use is to have ->kill() free the damn thing, period.

It is not possible to revise that intention?
The apparent purpose of pin_kill() is to wait until the thing is freed,
or to trigger that freeing itself.  Why not do both: trigger then wait?


> This code is very careful about how it waits in the "found it before
> ->kill() has removed all pointers leading to that object" case.  No go.
> This change would break all existing users, with arseloads of extra
> complications for no good reason whatsoever.

Given that all current uses have ->kill() call pin_remove, and as
pin_remove sets ->done to 1, and as the patch makes no change to
behaviour when ->kill() completes with ->done set to 1, I don't see how
it can break anything.
'rcu' ensures that it is still save to examine p->done, and it will be
'1'.

Thanks,
NeilBrown


> 
> And frankly, I'm still not convinced that fs_pin is a good match for the
> problem here - I'm not saying it's impossible to produce an fs_pin-based
> solution (and I hadn't reviewed the latest iteration yet), but attempts so
> far didn't look particularly promising.

