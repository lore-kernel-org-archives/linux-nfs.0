From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 02/11] sunrpc: take reference to bc_xprt in sunrpc layer
Date: Thu, 18 Mar 2010 11:08:18 -0400
Message-ID: <20100318150818.GA17347@fieldses.org>
References: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu> <1268180896-30921-2-git-send-email-bfields@citi.umich.edu> <1268180896-30921-3-git-send-email-bfields@citi.umich.edu> <1268182980.9419.40.camel@localhost.localdomain> <20100310190545.GC23974@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57456 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802Ab0CRPGf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Mar 2010 11:06:35 -0400
In-Reply-To: <20100310190545.GC23974@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 10, 2010 at 02:05:45PM -0500, J. Bruce Fields wrote:
> On Tue, Mar 09, 2010 at 08:03:00PM -0500, Trond Myklebust wrote:
> > On Tue, 2010-03-09 at 19:28 -0500, J. Bruce Fields wrote: 
> > > Currently we're requiring whoever holds the reference to a client set up
> > > the on the backchannel to also hold a reference to the forechannel
> > > transport; but this should be the responsibility of the lower level
> > > code.
...
> > > @@ -2552,6 +2555,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
> > >  		return xprt;
> > >  	ret = ERR_PTR(-EINVAL);
> > >  out_err:
> > > +	svc_xprt_put(xprt->bc_xprt);
> > >  	kfree(xprt->slot);
> > >  	kfree(xprt);
> > >  	return ret;
> > 
> > OK... This makes my head spin.
> > 
> > Why should the back channel socket hold a reference to the svc_sock? The
> > process that owns both of these things is an RPC server process. It
> > already holds a reference to the svc_sock and presumably also to the
> > back channel socket.
> 
> Only while it's actually processing an rpc, I assume.  
> 
> I'll take a harder look at what should be the lifetime of the server
> socket that the backchannel requests use.
> 
> By the way, we also need to make sure the nfs server code gets some kind
> of call when the client closes the connection, so we can set
> callback-down session flags appropriately.

One way to do that would be for nfsd to register a callback to be called
from svc_delete_xprt().  Then in that callback nfsd can set those
session flags appropriately, but it can also shut down the rpc client.
That ensures the rpc client (and its xprt) go away before the svc_xprt,
so we no longer need to hold a reference.

(Actually there's nothing preventing multiple backchannels from sharing
the same connection, so we'd need a list of callbacks.)

--b.
