From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [patch] sunrpc: add missing return statement
Date: Tue, 04 May 2010 09:13:35 -0400
Message-ID: <1272978815.7559.27.camel@localhost.localdomain>
References: <20100504115759.266396633@emlix.com>
	 <1272976042.7559.24.camel@localhost.localdomain>
	 <201005042203.DAJ09881.tFQOJFHSOLVOMF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: jw@emlix.com, davem@davemloft.net, batsakis@netapp.com,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <201005042203.DAJ09881.tFQOJFHSOLVOMF@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-05-04 at 22:03 +0900, Tetsuo Handa wrote: 
> Trond Myklebust wrote:
> > On Tue, 2010-05-04 at 13:59 +0200, Johannes Weiner wrote: 
> > > f300bab "nfsd41: sunrpc: add new xprt class for nfsv4.1 backchannel"
> > > introduced an error case branch that lacks an actual `return' keyword
> > > before the return value.  Add it.
> > > 
> > > Signed-off-by: Johannes Weiner <jw@emlix.com>
> > > Cc: Alexandros Batsakis <batsakis@netapp.com>
> > > ---
> > >  net/sunrpc/xprtsock.c |    2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > --- a/net/sunrpc/xprtsock.c
> > > +++ b/net/sunrpc/xprtsock.c
> > > @@ -2444,7 +2444,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(
> > >  	struct svc_sock *bc_sock;
> > >  
> > >  	if (!args->bc_xprt)
> > > -		ERR_PTR(-EINVAL);
> > > +		return ERR_PTR(-EINVAL);
> > >  
> > >  	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
> > >  	if (IS_ERR(xprt))
> > 
> > No. It should either be a BUG_ON(), or else be removed entirely.
> > Returning an error value for something that is clearly a programming bug
> > is not a particularly useful exercise...
> > 
> Removing NULL check is wrong because it will NULL pointer dereference later.

Wrong. Removing NULL check is _right_ because calling this function
without setting up a back channel first is a major BUG. Returning an
error value to the user is pointless, since the user has no control over
this. It is entirely under control of the sunrpc developers...

Trond

