From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH -next] nfs: fix ISO C90 warning
Date: Wed, 16 Dec 2009 14:47:00 -0800
Message-ID: <20091216144700.34b80b4b.randy.dunlap@oracle.com>
References: <20091215165309.58e98eea.sfr@canb.auug.org.au>
	<20091216142334.6a0ba115.randy.dunlap@oracle.com>
	<1261003219.13878.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1261003219.13878.6.camel@localhost>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Dec 2009 17:40:19 -0500 Trond Myklebust wrote:

> On Wed, 2009-12-16 at 14:23 -0800, Randy Dunlap wrote: 
> > From: Randy Dunlap <randy.dunlap@oracle.com>
> > 
> > Fix gcc ISO C90 warning:
> > 
> > fs/nfs/callback.c:356: warning: ISO C90 forbids mixed declarations and code
> > 
> > Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> > ---
> >  fs/nfs/callback.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > --- linux-next-20091215.orig/fs/nfs/callback.c
> > +++ linux-next-20091215/fs/nfs/callback.c
> > @@ -352,8 +352,8 @@ static int check_gss_callback_principal(
> >  static int nfs_callback_authenticate(struct svc_rqst *rqstp)
> >  {
> >  	struct nfs_client *clp;
> > -	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
> >  	int ret = SVC_OK;
> > +	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
> >  
> 
> What version of gcc is giving rise to this warning?

> gcc --version
gcc (GCC) 4.2.1 (SUSE Linux)

> RPC_IFDEBUG is a macro that either evaluates to its argument, or to
> nothing, depending on whether or not RPC_DEBUG is defined or not. In
> neither case should it evaluate to anything illegal under C90 rules
> afaics.

Yep.  Odd warning.


---
~Randy
