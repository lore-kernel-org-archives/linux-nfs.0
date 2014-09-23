Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32928 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568AbaIWTs0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 15:48:26 -0400
Date: Tue, 23 Sep 2014 15:48:25 -0400
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'Chuck Lever'" <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH V2] svcrdma: Advertise the correct max payload
Message-ID: <20140923194825.GL29932@fieldses.org>
References: <20140922200547.19909.68196.stgit@build.ogc.int>
 <465554E1-802A-4D37-8032-4E99B96B8BFB@oracle.com>
 <00a701cfd766$855044e0$8ff0cea0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <00a701cfd766$855044e0$8ff0cea0$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2014 at 02:42:34PM -0500, Steve Wise wrote:
> 
> > > diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> > > index c419498..a9cf5c3 100644
> > > --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> > > +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> > > @@ -392,4 +392,8 @@ extern struct kmem_cache *svc_rdma_ctxt_cachep;
> > > /* Workqueue created in svc_rdma.c */
> > > extern struct workqueue_struct *svc_rdma_wq;
> > >
> > > +#define RPCSVC_MAXPAYLOAD_RDMA \
> > > +	(RPCSVC_MAXPAYLOAD < (RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT) ? \
> > > +	 RPCSVC_MAXPAYLOAD : (RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT))
> > > +
> > 
> > Couldn't you use:
> > 
> > #if RPCSVC_MAXPAYLOAD < (RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT)
> > #define RPCSVC_MAXPAYLOAD_RDMA RPC_MAXPAYLOAD
> > #else
> > #define RPCSVC_MAXPAYLOAD_RDMA (RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT)
> > #endif
> > 
> > That seems more idiomatic.
> 
> Sure.  That makes it easier to read in my opinion too.
> 
> I'll send out V3 with this change.

While we're bikeshedding, why not use min()?

--b.
