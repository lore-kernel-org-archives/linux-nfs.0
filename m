Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45009 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932356Ab0GTPnm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 11:43:42 -0400
Date: Tue, 20 Jul 2010 11:43:35 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/5] nfsd: just keep single lockd reference for nfsd
Message-ID: <20100720114335.3b7a08a6@tlielax.poochiereds.net>
In-Reply-To: <20100720150237.GB28972@fieldses.org>
References: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
	<1279572608-7234-6-git-send-email-jlayton@redhat.com>
	<20100720150237.GB28972@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 20 Jul 2010 11:02:37 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jul 19, 2010 at 04:50:08PM -0400, Jeff Layton wrote:
> > This patch should replace the other patches that I proposed to make
> > sure that each sv_permsock entry holds a lockd refrence.
> > 
> > Right now, nfsd keeps a lockd reference for each socket that it has
> > open. This is unnecessary and complicates the error handling on
> > startup and shutdown. Change it to just do a lockd_up when creating
> > the nfsd_serv and just do a single lockd_down when taking down the
> > last nfsd thread.
> > 
> > This patch also changes the error handling in nfsd_create_serv a
> > bit too. There doesn't seem to be any need to reset the nfssvc_boot
> > time if the nfsd startup failed.
> > 
> > Note though that this does change the user-visible behavior slightly.
> > Today when someone writes a text socktype and port to the portlist file
> > prior to starting nfsd, lockd is not started when nfsd threads are
> > brought up. With this change, it will be started any time that
> > the nfsd_serv is created.
> 
> OK, so it may be started earlier in the process than it was before.
> 
> > I'm making the assumption that that's not a
> > problem. If it is then we'll need to take a different approach to fixing
> > this.
> 
> Especially in the case of a later failure, it does worry me a little
> that we could leave lockd running without having started nfsd.
> 
> Is there a clean way to defer starting lock till we start the first
> server threads?  Maybe fs/nfsd/nfssvc.c:nfsd() could (at the start,
> while under nfsd_mutex), check if lockd is up and start it if not??  But
> I think that can leave us calling lockd_down and not lockd_up in some
> cases.  Maybe start lockd in svc_set_num_threads()?
> 

That's a good point. We do have to consider that starting lockd starts
the grace period...

I suppose we could add a global flag that indicates whether the
nfsd_serv currently holds a lockd reference yet, and only conditionally
do the lockd_down if it does. That seems pretty kludgey, but I don't
really see a better way to handle it without a more substantial
overhaul.

-- 
Jeff Layton <jlayton@redhat.com>
