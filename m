From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [2.6.26-rc4] mount.nfsv4/memory poisoning issues...
Date: Tue, 10 Jun 2008 16:13:52 -0400
Message-ID: <20080610161352.4e588653@tleilax.poochiereds.net>
References: <6278d2220806041633n3bfe3dd2ke9602697697228b@mail.gmail.com>
	<20080604203504.62730951@tleilax.poochiereds.net>
	<1213124088.20459.16.camel@localhost>
	<20080610151357.150b6f69@tleilax.poochiereds.net>
	<1213127909.20459.48.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Daniel J Blueman <daniel.blueman@gmail.com>,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36169 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257AbYFJUOK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 16:14:10 -0400
In-Reply-To: <1213127909.20459.48.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 10 Jun 2008 15:58:29 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Tue, 2008-06-10 at 15:13 -0400, Jeff Layton wrote:
> 
> > I think you're basically correct, but it looks to me like the
> > nfs_callback_mutex actually protects nfs_callback_info.task as well.
> > 
> > If we're starting the thread, then we can't call kthread_stop on it
> > until we release the mutex. So the thread can't exit until we release
> > the mutex, and we can be guaranteed that this:
> > 
> >      nfs_callback_info.task = NULL;
> > 
> > ...can't happen until after kthread_run returns and nfs_callback_up
> > sets it.
> > 
> > If that's right, then maybe this (untested, RFC only) patch would make sense?
> 
> Hmm... I suppose that is correct, but what if nfs_alloc_client() does
> 
> 	nfs_callback_up();
> 	<kstrdup() fails>
> 	nfs_callback_down();
> 
> AFAICS, if nfs_callback_down() gets called before the kthread() function
> gets scheduled back in, then you can get left with a value of
> nfs_callback_info.task != NULL, since nfs_callback_svc() will never be
> called.
> 

I don't see this race.

We can't call nfs_callback_down() until after nfs_callback_up()
returns, so we're guaranteed to have "task" set to a valid task
(presuming that nfs_callback_up() doesn't return error). We also can't
return from nfs_callback_down() until after the nfs_callback_svc() has
exited. kthread_stop() will block until it does.

> Wouldn't it therefore make more sense to clear nfs_callback_info.task in
> nfs_callback_down()?
> 

I suppose that makes just as much sense. It also seems more symmetrical
given that we also set the var in nfs_callback_up(). I'll roll that into
the BKL removal patch, and give it some testing. Look for it in a day
or two...

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
