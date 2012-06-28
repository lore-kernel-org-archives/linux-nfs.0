Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47301 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751079Ab2F1OsZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jun 2012 10:48:25 -0400
Date: Thu, 28 Jun 2012 10:47:59 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Harshula <harshula@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "mgorman@suse.de" <mgorman@suse.de>
Subject: Re: rpciod process is blocked in nfs_release_page waiting for
 nfs_commit_inode to complete
Message-ID: <20120628104759.19746f05@tlielax.poochiereds.net>
In-Reply-To: <1340890837.5293.11.camel@lade.trondhjem.org>
References: <1339764850.30233.11.camel@serendib>
	<20120615092103.15cc2b11@corrin.poochiereds.net>
	<1339795503.16363.9.camel@lade.trondhjem.org>
	<20120627115447.0fdf8c6e@corrin.poochiereds.net>
	<1340822635.2398.7.camel@lade.trondhjem.org>
	<20120627152814.4774048b@tlielax.poochiereds.net>
	<1340826996.2398.15.camel@lade.trondhjem.org>
	<20120627161913.05229538@tlielax.poochiereds.net>
	<1340830004.2398.26.camel@lade.trondhjem.org>
	<20120628091905.11825707@corrin.poochiereds.net>
	<1340890837.5293.11.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 28 Jun 2012 13:40:37 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2012-06-28 at 09:19 -0400, Jeff Layton wrote:
> > On Wed, 27 Jun 2012 20:46:49 +0000
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Wed, 2012-06-27 at 16:19 -0400, Jeff Layton wrote:
> > > > On Wed, 27 Jun 2012 19:56:38 +0000
> > > > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > > > 
> > > > > On Wed, 2012-06-27 at 15:28 -0400, Jeff Layton wrote:
> > > > > > On Wed, 27 Jun 2012 18:43:56 +0000
> > > > > > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > > > > > If there really is no alternative to freeing the socket, then the only
> > > > > > real fix I can see is to set PF_MEMALLOC when we go to create it and
> > > > > > then reset it afterward. That's a pretty ugly fix though...
> > > > > 
> > > > > I can think of 2 possible alternatives:
> > > > > 
> > > > >      1. Use the PF_FSTRANS flag to tell nfs_release_page that this is a
> > > > >         direct reclaim from rpciod.
> > > > 
> > > > Hmm...that's a bit indiscriminate, isn't it? Looks like only XFS uses
> > > > that flag now...
> > > > 
> > > > Suppose we're in some XFS allocation and then want to commit a NFS
> > > > page to satisfy it. There's no real reason we couldn't but that would
> > > > prevent it...
> > > 
> > > So do all the GFP_NOFS allocations. How is this any different?
> > > 
> > 
> > Good point. Now that I've looked closer, I think this is probably the
> > best approach. Proposed patch below. It builds but is otherwise
> > untested so far...
> > 
> > > > >      2. Add a 'congested' flag to the rpc client that could tell reclaim
> > > > >         type operations to give up if a socket allocation is in
> > > > >         progress.
> > > > > 
> > > > 
> > > > That's not a bad idea. That has the benefit of only skipping reclaim
> > > > when it's directly associated with the socket being reconnected. Seems
> > > > like that would have to hang off of the rpc_xprt, but we could do
> > > > something along those lines. Presumably Mel's swap-over-nfs patches
> > > > could be converted to do something similar instead of using PF_MEMALLOC
> > > > there too.
> > > 
> > 
> > The problem with the above scheme is that it would be racy. It would
> > easily be possible for the congested flag to flip just after you
> > checked it but before issuing the commit.
> > 
> > Maybe we could push handling for that down into the commit call itself
> > -- allow it to give up if "congested" goes true while we're blocked and
> > waiting for the the reply, but that sounds complicated...
> > 
> > Anyway, here's a proposed patch for the PF_FSTRANS scheme. It builds
> > but I haven't otherwise tested it yet. For now, it just covers the
> > socket allocation and ->releasepage. Eventually I guess we'll probably
> > want to set and check for PF_FSTRANS in other places:
> 
> Is there any reason why we might not want all rpciod work to run under
> PF_FSTRANS? IOW: couldn't we just set/clear it unconditionally when
> entering/exiting rpc_async_schedule(), and xs_*_setup_socket()?
> 
> We shouldn't need to worry about the remaining rpciod work structures in
> rpc_timeout_upcall_queue and xprt_autoclose, since those don't ever need
> to do any allocations.
> 


I wasn't sure that that was really necessary. Just because we have
rpciod sleeping and waiting for memory to be reclaimed doesn't
necessarily mean that other RPCs can't go through.

IIUC, the CMWQ implementation will spawn a new execution context as
needed, even on a UP box, because we have WQ_MEM_RECLAIM set. The socket
reconnect is a bit of a special case since that *has* to be done before
anything can happen.

Still, I suppose there is a possible corner case here. If we're blocked
while in the middle of trying to commit, then the releasepage's commit
might end up stuck behind the commit_lock. I'll send a revised patch
separately...

Thanks for the help so far...
-- 
Jeff Layton <jlayton@redhat.com>
