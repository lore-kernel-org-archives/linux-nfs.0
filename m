From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 097/100] NLM: have nlm_shutdown_hosts kill off all NLM
 RPC tasks
Date: Fri, 25 Jan 2008 20:02:25 -0500
Message-ID: <20080125200225.32ae60ef@tupile.poochiereds.net>
References: <1201303040-7779-89-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-90-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-91-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-92-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-93-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-94-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-95-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-96-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-97-git-send-email-bfields@citi.umich.edu>
	<20080125185548.5363f046@tleilax.poochiereds.net>
	<20080126003156.GK25141@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752978AbYAZBDc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 20:03:32 -0500
In-Reply-To: <20080126003156.GK25141@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 25 Jan 2008 19:31:56 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Jan 25, 2008 at 06:55:48PM -0500, Jeff Layton wrote:
> > On Fri, 25 Jan 2008 18:17:17 -0500
> > "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > 
> > > From: Jeff Layton <jlayton@redhat.com>
> > > 
> > > If we're shutting down all the nlm_hosts anyway, then it doesn't make
> > > sense to allow RPC calls to linger. Allowing them to do so can mean
> > > that the RPC calls can outlive the currently running lockd and can
> > > lead to a use after free situation.
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > Reviewed-by: NeilBrown <neilb@suse.de>
> > > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > > ---
> > >  fs/lockd/host.c |    4 +++-
> > >  1 files changed, 3 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> > > index ebec009..76e4bf5 100644
> > > --- a/fs/lockd/host.c
> > > +++ b/fs/lockd/host.c
> > > @@ -379,8 +379,10 @@ nlm_shutdown_hosts(void)
> > >  	/* First, make all hosts eligible for gc */
> > >  	dprintk("lockd: nuking all hosts...\n");
> > >  	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH;
> > > ++chain) {
> > > -		hlist_for_each_entry(host, pos, chain, h_hash)
> > > +		hlist_for_each_entry(host, pos, chain, h_hash) {
> > >  			host->h_expires = jiffies - 1;
> > > +			rpc_killall_tasks(host->h_rpcclnt);
> > > +		}
> > >  	}
> > >  
> > >  	/* Then, perform a garbage collection pass */
> > 
> > I was doing some more testing today, and noticed that the original
> > problem that this patch is intended to fix resurfaced. I think this
> > patch just changes the timing on the race somehow, but I haven't tracked
> > it down completely yet.
> 
> Hm.  So you're getting oopses that look like the rpc code attempting to
> make calls with an rpc_client that's been freed?
> 

Right. The situation to reproduce this is a bit contrived and tricky,
but I've been able to reproduce the same panics that I was originally
seeing. The timing seems to be a bit tighter now, but I can still make
it happen.

> > There's also another problem -- it's possible for host->h_rpcclnt to be
> > NULL, and that has special meaning for rpc_killall_tasks. For now, I
> > suggest that we drop this patch until I have a chance to work on it
> > further.
> > 
> > The other related patches in this series should be OK, however.
> 
> OK!  Dropped.  Let me know what you find out.
> 

Will do, thanks!

-- 
Jeff Layton <jlayton@redhat.com>
