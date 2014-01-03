Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbaACRDL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jan 2014 12:03:11 -0500
Date: Fri, 3 Jan 2014 12:03:03 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, simo@redhat.com, neilb@suse.de
Subject: Re: [RFC PATCH 3/5] sunrpc: wait for gssproxy to start on initial
 upcall attempt before falling back to legacy upcall
Message-ID: <20140103120303.2e641f82@tlielax.poochiereds.net>
In-Reply-To: <20140103163347.GL28219@fieldses.org>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
	<1388579314-15255-4-git-send-email-jlayton@redhat.com>
	<20140102213547.GD28219@fieldses.org>
	<20140102181055.324ed278@tlielax.poochiereds.net>
	<20140103163347.GL28219@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 3 Jan 2014 11:33:47 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Jan 02, 2014 at 06:10:55PM -0500, Jeff Layton wrote:
> > On Thu, 2 Jan 2014 16:35:47 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Wed, Jan 01, 2014 at 07:28:32AM -0500, Jeff Layton wrote:
> > > > Currently, the only thing that waits for gssproxy to start is reads
> > > > from the use-gss-proxy procfile. That's a little odd, since nothing
> > > > but gssproxy itself will likely ever open that file, and all it does
> > > > it write to it.
> > > > 
> > > > It seems like what we really want instead is for svcrpc code to give
> > > > gssproxy a little time to start up in the event that some RPCs come
> > > > in before it's ready.
> > > 
> > > Legacy userspace will never write, so this adds an 5-second delay in
> > > that case.
> > > 
> > > I'd rather avoid any arbitrary timeout.
> > > 
> > > It seems to me all you need is for gss-proxy to ensure that it does the
> > > write to use-gss-proxy before it indicates to whoever started it that
> > > it's done starting.
> > > 
> > > Then as long as the init system orders gss-proxy startup before nfsd
> > > startup, we're good.
> > > 
> > > --b.
> > > 
> > 
> > Yep, that 5s delay on the first upcall was the part that was
> > questionable...
> > 
> > Ok, so basically the behavior you want is:
> > 
> > "If gssproxy is up and running by the time the first RPC comes in then
> >  use that. If not, then use the legacy code."
> > 
> > I'll respin the set with that behavior in mind. I need to do a bit of
> > testing with it too, so it may be a week or so before I repost.
> 
> Thanks!
> 
> On a quick skim, I thought that rendered the later patches mostly
> unnecessary, but I may not have been paying close enough attention....
> 
> --b.
> 

For the most part, yes...

There is some code that can be removed however since we don't need that
wait anymore. Also, the race between setting the variable and setting up the
client still exists, and I think the use_gssp_lock is really
unnecessary. We can use cmpxchg() to get the same result without a spinlock.

-- 
Jeff Layton <jlayton@redhat.com>
