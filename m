From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 02/11] sunrpc: take reference to bc_xprt in sunrpc layer
Date: Wed, 10 Mar 2010 14:05:45 -0500
Message-ID: <20100310190545.GC23974@fieldses.org>
References: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu> <1268180896-30921-2-git-send-email-bfields@citi.umich.edu> <1268180896-30921-3-git-send-email-bfields@citi.umich.edu> <1268182980.9419.40.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57946 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932759Ab0CJTES (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Mar 2010 14:04:18 -0500
In-Reply-To: <1268182980.9419.40.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 09, 2010 at 08:03:00PM -0500, Trond Myklebust wrote:
> On Tue, 2010-03-09 at 19:28 -0500, J. Bruce Fields wrote: 
> > Currently we're requiring whoever holds the reference to a client set up
> > the on the backchannel to also hold a reference to the forechannel
> > transport; but this should be the responsibility of the lower level
> > code.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> >  net/sunrpc/xprtsock.c |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index a91f0a4..5adc000 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -792,6 +792,8 @@ static void xs_destroy(struct rpc_xprt *xprt)
> >  
> >  	xs_close(xprt);
> >  	xs_free_peer_addresses(xprt);
> > +	if (xprt->bc_xprt)
> > +		svc_xprt_put(xprt->bc_xprt);
> >  	kfree(xprt->slot);
> >  	kfree(xprt);
> >  	module_put(THIS_MODULE);
> > @@ -2510,6 +2512,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
> >  	 * forechannel
> >  	 */
> >  	xprt->bc_xprt = args->bc_xprt;
> > +	svc_xprt_get(xprt->bc_xprt);
> >  	bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
> >  	bc_sock->sk_bc_xprt = xprt;
> >  	transport->sock = bc_sock->sk_sock;
> > @@ -2552,6 +2555,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
> >  		return xprt;
> >  	ret = ERR_PTR(-EINVAL);
> >  out_err:
> > +	svc_xprt_put(xprt->bc_xprt);
> >  	kfree(xprt->slot);
> >  	kfree(xprt);
> >  	return ret;
> 
> OK... This makes my head spin.
> 
> Why should the back channel socket hold a reference to the svc_sock? The
> process that owns both of these things is an RPC server process. It
> already holds a reference to the svc_sock and presumably also to the
> back channel socket.

Only while it's actually processing an rpc, I assume.  

I'll take a harder look at what should be the lifetime of the server
socket that the backchannel requests use.

By the way, we also need to make sure the nfs server code gets some kind
of call when the client closes the connection, so we can set
callback-down session flags appropriately.

--b.
