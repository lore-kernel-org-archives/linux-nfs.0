From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/2] NLM: tear down RPC clients in nlm_shutdown_hosts
Date: Mon, 28 Jan 2008 19:04:24 -0500
Message-ID: <20080128190424.7415e4b9@tleilax.poochiereds.net>
References: <1201548551-23592-1-git-send-email-jlayton@redhat.com>
	<1201548551-23592-2-git-send-email-jlayton@redhat.com>
	<20080128231826.GU16785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39124 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751196AbYA2AE2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 19:04:28 -0500
In-Reply-To: <20080128231826.GU16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 28 Jan 2008 18:18:26 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jan 28, 2008 at 02:29:10PM -0500, Jeff Layton wrote:
> > It's possible for a RPC to outlive the lockd daemon that created
> > it, so we need to make sure that all RPC's are killed when lockd is
> > coming down. When nlm_shutdown_hosts is called, kill off all RPC
> > tasks associated with the host. Since we need to wait until they
> > have all gone away, we might as well just shut down the RPC client
> > altogether.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/lockd/host.c |    7 ++++++-
> >  1 files changed, 6 insertions(+), 1 deletions(-)
> > 
> > diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> > index ebec009..ca6b16f 100644
> > --- a/fs/lockd/host.c
> > +++ b/fs/lockd/host.c
> > @@ -379,8 +379,13 @@ nlm_shutdown_hosts(void)
> >  	/* First, make all hosts eligible for gc */
> >  	dprintk("lockd: nuking all hosts...\n");
> >  	for (chain = nlm_hosts; chain < nlm_hosts +
> > NLM_HOST_NRHASH; ++chain) {
> > -		hlist_for_each_entry(host, pos, chain, h_hash)
> > +		hlist_for_each_entry(host, pos, chain, h_hash) {
> >  			host->h_expires = jiffies - 1;
> > +			if (host->h_rpcclnt) {
> 
> So the only difference from the previous patch is this test and the
> following assignment?  OK.
> 
> --b.
> 

No, the old patch used rpc_killall_tasks and this one uses
rpc_shutdown_client. I don't believe rpc_killall_tasks gives any
guarantee about when the tasks actually complete, and we need to know
that they're gone before we allow lockd to exit.

> > +
> > rpc_shutdown_client(host->h_rpcclnt);
> > +				host->h_rpcclnt = NULL;
> > +			}
> > +		}
> >  	}
> >  
> >  	/* Then, perform a garbage collection pass */
> > -- 
> > 1.5.3.7
> > 


-- 
Jeff Layton <jlayton@redhat.com>
