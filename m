From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v2 02/12] nfsd41: sunrpc: Added rpc server-side backchannel
 handling
Date: Thu, 10 Sep 2009 15:33:45 +0300
Message-ID: <4AA8F229.2060404@panasas.com>
References: <4AA8C597.8080809@panasas.com>	 <1252574717-30074-1-git-send-email-bhalevy@panasas.com> <1252583366.8722.121.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Rahul Iyer <iyer@netapp.com>,
	Mike Sager <sager@netapp.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Andy Adamson <andros@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:31543 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752950AbZIJMdQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2009 08:33:16 -0400
In-Reply-To: <1252583366.8722.121.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep. 10, 2009, 14:49 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > > index f412a85..f577e5a 100644
> > > --- a/net/sunrpc/xprt.c
> > > +++ b/net/sunrpc/xprt.c
> > > @@ -832,6 +832,11 @@ static void xprt_timer(struct rpc_task *task)
> > >  	spin_unlock_bh(&xprt->transport_lock);
> > >  }
> > >  
> > > +static inline int xprt_has_timer(struct rpc_xprt *xprt)
> > > +{
> > > +	return xprt->idle_timeout != (~0);
> > > +}
> 
> Why did this change again?
> 
> It's a disconnect timer, and the idle_timeout sets the timeout period. A
> test for whether or not that period is 0 therefore makes sense (a zero
> timeout being a nonsense value for a timer).
> 
> Testing for arbitrary non-zero values is more dubious, and forces the
> backchannel to explicitly set a non-zero value. What value does that
> add?
> 

Good question. I agree with your direction.

Alexandros, why was this != 0 in PATCH 3/3 v2:
http://linux-nfs.org/pipermail/pnfs/2009-September/009057.html
but changed back to ~0 in PATCH 3/3 v2.1?
http://linux-nfs.org/pipermail/pnfs/2009-September/009059.html

With this in mind, xs_setup_bc_tcp can simply initialize idle_timeout
to zero, right?
 	xprt->bind_timeout = 0;
 	xprt->connect_timeout = 0;
 	xprt->reestablish_timeout = 0;
-	xprt->idle_timeout = (~0);
+	xprt->idle_timeout = 0;
 
 	/*
 	 * The backchannel uses the same socket connection as the

Benny

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
