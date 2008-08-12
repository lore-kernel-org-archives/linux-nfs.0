From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Confused about BUG_ON in rpcb_getport_async
Date: Tue, 12 Aug 2008 16:32:58 -0400
Message-ID: <1218573178.7253.31.camel@localhost>
References: <18592.62730.840231.108375@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:49642 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875AbYHLUdE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2008 16:33:04 -0400
In-Reply-To: <18592.62730.840231.108375-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-08-12 at 12:27 +1000, Neil Brown wrote:
> Hi 
>  I have a report of a the BUG_ON in rpcb_getport_clnt being
>  triggered.  This is:
> 	/* Autobind on cloned rpc clients is discouraged */
> 	BUG_ON(clnt->cl_parent != clnt);
> 
>  It looks to me that while they might be discouraged, they are not
>  prevented and so having the BUG_ON is wrong.
> 
>  When rpc_clone_client creates a clone, it sets cl_autobind to 0,
>  and gives the new client a reference to the same cl_xprt as the
>  original client.
> 
>  The only effect of cl_autobind is to prevent rpc_force_rebind from
>  clearing the BOUND flag on ->cl_xprt.
>  So while a call to rpc_force_rebind on the clone will not clear that
>  flag, a call on the original client will clear that flag.
> 
>  So a cloned client can still end up with a ->cl_xprt with the BOUND
>  flag clear.
> 
>  So call_bind (which is present in the call trace under the oops) can
>  find that !xprt_bound, even when the client is a cloned client.
> 
>  When this happens, ->rpcbind, which is rpcb_getport_clnt, goes BOOM.
> 
>  What should happen when a clone client finds that its transport is no
>  longer bound?  Should rpc_getport_async just do
>     clnt = task->tk_client->cl_parent;
>  ??

This shouldn't be a particularly urgent problem, since lockd should
normally be the only thing that needs to use the autobind functionality,
and it does not use cloned clients.

That said, I think that the answer is that cloned clients may indeed use
rpcbind as long as they share the same program number and version as the
parent.
IOW: we should probably rather BUG_ON() calls to rpc_bind_new_program()
if the parent has xprt->cl_autobind set.

Cheers
  Trond

