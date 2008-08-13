From: Neil Brown <neilb@suse.de>
Subject: Re: Confused about BUG_ON in rpcb_getport_async
Date: Thu, 14 Aug 2008 09:45:51 +1000
Message-ID: <18595.29231.61262.220929@notabene.brown>
References: <18592.62730.840231.108375@notabene.brown>
	<1218573178.7253.31.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43310 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754263AbYHMXp5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2008 19:45:57 -0400
In-Reply-To: message from Trond Myklebust on Tuesday August 12
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday August 12, trond.myklebust@fys.uio.no wrote:
> On Tue, 2008-08-12 at 12:27 +1000, Neil Brown wrote:
> > Hi 
> >  I have a report of a the BUG_ON in rpcb_getport_clnt being
> >  triggered.  This is:
> > 	/* Autobind on cloned rpc clients is discouraged */
> > 	BUG_ON(clnt->cl_parent != clnt);
> > 
> >  It looks to me that while they might be discouraged, they are not
> >  prevented and so having the BUG_ON is wrong.
> > 
> >  When rpc_clone_client creates a clone, it sets cl_autobind to 0,
> >  and gives the new client a reference to the same cl_xprt as the
> >  original client.
> > 
> >  The only effect of cl_autobind is to prevent rpc_force_rebind from
> >  clearing the BOUND flag on ->cl_xprt.
> >  So while a call to rpc_force_rebind on the clone will not clear that
> >  flag, a call on the original client will clear that flag.
> > 
> >  So a cloned client can still end up with a ->cl_xprt with the BOUND
> >  flag clear.
> > 
> >  So call_bind (which is present in the call trace under the oops) can
> >  find that !xprt_bound, even when the client is a cloned client.
> > 
> >  When this happens, ->rpcbind, which is rpcb_getport_clnt, goes BOOM.
> > 
> >  What should happen when a clone client finds that its transport is no
> >  longer bound?  Should rpc_getport_async just do
> >     clnt = task->tk_client->cl_parent;
> >  ??
> 
> This shouldn't be a particularly urgent problem, since lockd should
> normally be the only thing that needs to use the autobind functionality,
> and it does not use cloned clients.
> 
> That said, I think that the answer is that cloned clients may indeed use
> rpcbind as long as they share the same program number and version as the
> parent.
> IOW: we should probably rather BUG_ON() calls to rpc_bind_new_program()
> if the parent has xprt->cl_autobind set.

Just to confirm,  you are saying that the current BUG_ON is indeed
wrong, and the fact that it fires does not imply any real bug.
It should be removed.  Possibly a BUG_ON could be put somewhere else
to catch incorrect behaviour.

Is that correct?

I now have multiple people for whom this BUG_ON has fired.

Thanks,
NeilBrown
