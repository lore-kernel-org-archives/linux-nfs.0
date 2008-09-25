From: "Jim Schutt" <jaschut@sandia.gov>
Subject: Re: svcrdma/xprtrdma fast memory registration questions
Date: Thu, 25 Sep 2008 15:32:31 -0600
Message-ID: <1222378352.32577.44.camel@sale659>
References: <1222357183.32577.34.camel@sale659>
 <48DBF4C6.7010008@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Tom Tucker" <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sentry.sandia.gov ([132.175.109.21]:4139 "EHLO
	sentry.sandia.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753842AbYIYVcp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2008 17:32:45 -0400
In-Reply-To: <48DBF4C6.7010008@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-09-25 at 14:29 -0600, Tom Tucker wrote:
> Jim Schutt wrote:
> > Hi,
> >
> > I've been giving the fast memory registration NFS RDMA
> > patches a spin, and I've got a couple questions.
> >
> > AFAICS the default xprtrdma memory registration model
> > is still RPCRDMA_ALLPHYSICAL; I had to
> >   "echo 6 > /proc/sys/sunrpc/rdma_memreg_strategy"
> > prior to a mount to get fast registration.  Given that fast
> > registration has better security properties for iWARP, and
> > the fallback is RPCRDMA_ALLPHYSICAL if fast registration is
> > not supported, is it more appropriate to have RPCRDMA_FASTREG
>    ???
> > be the default?
> 
> I'm not sure I parsed this right, but I think you're asking if FASTREG
> should be the default if it _is_ supported by the HW. IMO yes.

Yes, that't it.

> 
> >
> > Second, it seems that the number of pages in a client fast
> > memory registration is still limited to RPCRDMA_MAX_DATA_SEGS.
> > So on a client write, without fast registration I get
> > RPCRDMA_MAX_DATA_SEGS RDMA reads of 1 page each, whereas with
> > fast registration I get 1 RDMA read of RPCRDMA_MAX_DATA_SEGS
> > pages.
> >
> > In either case my maximum rsize, wsize for an RDMA mount
> > is still 32 KiB.
> 
> Sure, Big data was not the purpose of the patch.

OK.

> 
> >
> > My understanding is that, e.g., a Chelsio T3 with the
> > 2.6.27-rc driver can support 24 pages in a fast registration
> > request.  So, what I was hoping to see with a T3 were RPCs with
> > RPCRDMA_MAX_DATA_SEGS  chunks, each for a fast registration of
> > 24 pages each, making possible an RDMA mount with 768 KiB for
> > rsize, wsize.
> >
> > Is something like that possible?  If so, do you have any
> > work in progress along those lines?
> >
> 
> I have nothing in the works along those lines -- sorry.

OK - thanks for letting me know.

> 
> > -- Jim
> >
> >
> 
> 


