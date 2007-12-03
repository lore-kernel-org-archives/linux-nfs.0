From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 7/8] rdma: makefile
Date: Mon, 3 Dec 2007 12:25:17 -0500
Message-ID: <20071203172517.GF16422@fieldses.org>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int> <20071129224513.14887.8074.stgit@dell3.ogc.int> <2F4C0A61-33B5-4D2D-9349-657EC856A8B2@oracle.com> <1196702699.5811.0.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34809 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750723AbXLCRZU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Dec 2007 12:25:20 -0500
In-Reply-To: <1196702699.5811.0.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 03, 2007 at 11:24:59AM -0600, Tom Tucker wrote:
> I don't know that it adds much, but perhaps for consistency?

It's arguably a little friendlier for someone just learning their way
around the code--the rdma files are probably clutter to them on a first
pass.

> In fact, if we were to move it, would we move it to the same directory
> as the client?

That's what the gss code does, so I guess there's precedent.

No real strong opinion from me, though.

--b.

> 
> On Mon, 2007-12-03 at 12:00 -0500, Chuck Lever wrote:
> > On Nov 29, 2007, at 5:45 PM, Tom Tucker wrote:
> > > Add the NFSD_RDMA module to the sunrpc makefile.
> > 
> > General question about how the RPC level RDMA code is organized:  The  
> > client-side RDMA service provider lives in its own subdirectory of  
> > net/sunrpc.  Should the server side provider also live in that  
> > directory?  Should these two be glued together into a single module?
> > 
> > > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > > ---
> > >
> > >  net/sunrpc/Makefile |    4 ++++
> > >  1 files changed, 4 insertions(+), 0 deletions(-)
> > >
> > > diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
> > > index 92e1dbe..6d03dbf 100644
> > > --- a/net/sunrpc/Makefile
> > > +++ b/net/sunrpc/Makefile
> > > @@ -15,3 +15,7 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o  
> > > sched.o \
> > >  	    svc_xprt.o
> > >  sunrpc-$(CONFIG_PROC_FS) += stats.o
> > >  sunrpc-$(CONFIG_SYSCTL) += sysctl.o
> > > +
> > > +obj-$(CONFIG_NFSD_RDMA) += svcrdma.o
> > > +svcrdma-y := svc_rdma.o svc_rdma_transport.o \
> > > +	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o
> > 
> > 
> > --
> > Chuck Lever
> > chuck[dot]lever[at]oracle[dot]com
> 
