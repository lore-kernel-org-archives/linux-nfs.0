Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:37339 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751638AbaIWTxZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 15:53:25 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'J. Bruce Fields'" <bfields@fieldses.org>
Cc: "'Chuck Lever'" <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>
References: <20140922200547.19909.68196.stgit@build.ogc.int> <465554E1-802A-4D37-8032-4E99B96B8BFB@oracle.com> <00a701cfd766$855044e0$8ff0cea0$@opengridcomputing.com> <20140923194825.GL29932@fieldses.org>
In-Reply-To: <20140923194825.GL29932@fieldses.org>
Subject: RE: [PATCH V2] svcrdma: Advertise the correct max payload
Date: Tue, 23 Sep 2014 14:53:28 -0500
Message-ID: <00af01cfd768$0b2d1bf0$218753d0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: 'J. Bruce Fields' [mailto:bfields@fieldses.org]
> Sent: Tuesday, September 23, 2014 2:48 PM
> To: Steve Wise
> Cc: 'Chuck Lever'; linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org
> Subject: Re: [PATCH V2] svcrdma: Advertise the correct max payload
> 
> On Tue, Sep 23, 2014 at 02:42:34PM -0500, Steve Wise wrote:
> >
> > > > diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> > > > index c419498..a9cf5c3 100644
> > > > --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> > > > +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> > > > @@ -392,4 +392,8 @@ extern struct kmem_cache *svc_rdma_ctxt_cachep;
> > > > /* Workqueue created in svc_rdma.c */
> > > > extern struct workqueue_struct *svc_rdma_wq;
> > > >
> > > > +#define RPCSVC_MAXPAYLOAD_RDMA \
> > > > +	(RPCSVC_MAXPAYLOAD < (RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT) ? \
> > > > +	 RPCSVC_MAXPAYLOAD : (RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT))
> > > > +
> > >
> > > Couldn't you use:
> > >
> > > #if RPCSVC_MAXPAYLOAD < (RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT)
> > > #define RPCSVC_MAXPAYLOAD_RDMA RPC_MAXPAYLOAD
> > > #else
> > > #define RPCSVC_MAXPAYLOAD_RDMA (RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT)
> > > #endif
> > >
> > > That seems more idiomatic.
> >
> > Sure.  That makes it easier to read in my opinion too.
> >
> > I'll send out V3 with this change.
> 
> While we're bikeshedding, why not use min()?
> 
> --b.

I tried that initially.  But min() and min_t() don't work because of the way we use the #define.  With it defined thusly:

#define RPCSVC_MAXPAYLOAD_RDMA min(RPC_MAXPAYLOAD, RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT)

I see this error:

  CC [M]  net/sunrpc/xprtrdma/svc_rdma_transport.o
net/sunrpc/xprtrdma/svc_rdma_transport.c:94: error: braced-group within expression allowed only inside a function
make[3]: *** [net/sunrpc/xprtrdma/svc_rdma_transport.o] Error 1
make[2]: *** [net/sunrpc/xprtrdma] Error 2
make[1]: *** [net/sunrpc] Error 2
make: *** [net] Error 2

min() looks like this:

#define min(x, y) ({                            \
        typeof(x) _min1 = (x);                  \
        typeof(y) _min2 = (y);                  \
        (void) (&_min1 == &_min2);              \
        _min1 < _min2 ? _min1 : _min2; })

