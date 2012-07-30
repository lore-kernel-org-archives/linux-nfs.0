Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34344 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754826Ab2G3XXT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 19:23:19 -0400
Date: Mon, 30 Jul 2012 19:23:16 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] SUNRPC: return negative value in case rpcbind client
 creation error
Message-ID: <20120730232316.GC21730@fieldses.org>
References: <20120720114849.23572.91010.stgit@localhost.localdomain>
 <1343689924.8362.4.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1343689924.8362.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 30, 2012 at 11:12:05PM +0000, Myklebust, Trond wrote:
> On Fri, 2012-07-20 at 15:57 +0400, Stanislav Kinsbursky wrote:
> > Without this patch kernel will panic on LockD start, because lockd_up() checks
> > lockd_up_net() result for negative value.
> > >From my pow it's better to return negative value from rpcbind routines instead
> > of replacing all such checks like in lockd_up().
> > 
> > Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> > ---
> >  net/sunrpc/rpcb_clnt.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> > index 92509ff..a70acae 100644
> > --- a/net/sunrpc/rpcb_clnt.c
> > +++ b/net/sunrpc/rpcb_clnt.c
> > @@ -251,7 +251,7 @@ static int rpcb_create_local_unix(struct net *net)
> >  	if (IS_ERR(clnt)) {
> >  		dprintk("RPC:       failed to create AF_LOCAL rpcbind "
> >  				"client (errno %ld).\n", PTR_ERR(clnt));
> > -		result = -PTR_ERR(clnt);
> > +		result = PTR_ERR(clnt);
> >  		goto out;
> >  	}
> >  
> > @@ -298,7 +298,7 @@ static int rpcb_create_local_net(struct net *net)
> >  	if (IS_ERR(clnt)) {
> >  		dprintk("RPC:       failed to create local rpcbind "
> >  				"client (errno %ld).\n", PTR_ERR(clnt));
> > -		result = -PTR_ERR(clnt);
> > +		result = PTR_ERR(clnt);
> >  		goto out;
> >  	}
> 
> Who is supposed to carry this patch? Is it Bruce or is it me?

Works either way.  Either way--it looks like the bug was introduced with

c526611dd631b2802b6b0221ffb306c5fa25c86c "SUNRPC: Use a cached RPC
client and transport for rpcbind upcalls" and
7402ab19cdd5943c7dd4f3399afe3abda8077ef5 "SUNRPC: Use AF_LOCAL for
rpcbind upcalls"

and should go to stable as well.

(Looks like I said that before but accidentally dropped everyone off the
cc.)

--b.
