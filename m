Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44806 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504Ab3H1OdE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Aug 2013 10:33:04 -0400
Date: Wed, 28 Aug 2013 10:32:56 -0400
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Mark Young <MYoung@nvidia.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Matt Craighead <mcraighead@nvidia.com>
Subject: Re: Issue found with kernel/net/sunrpc/xdr.c
Message-ID: <20130828143256.GA2960@fieldses.org>
References: <1FC56210173BB445BD77F608D6FB8D03620A9978B5@HQMAIL03.nvidia.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA94677C96F@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA94677C96F@SACEXCMBX04-PRD.hq.netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 27, 2013 at 10:01:38PM +0000, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of Mark Young
> > Sent: Tuesday, August 27, 2013 5:17 PM
> > To: linux-nfs@vger.kernel.org
> > Cc: Matt Craighead
> > Subject: Issue found with kernel/net/sunrpc/xdr.c
> > 
> > I was pointed to this mailing list by Brian Fields.
> > 
> >  We're currently seeing NFS data corruption, which we traced back to
> > memory corruption that happens in the function _shift_data_right_pages in
> > net/sunrpc/xdr.c.
> > 
> >  When we see the issue, we're running a 32bit os with systems running with
> > more than 1GB of physical memory.   The errant behavior appears to be that
> > two calls to kmap_atomic (on 32bit systems with highmem present) with the
> > same physical address (on addresses within highmem)  will return two
> > different vaddrs.    In our assessment, this confuses the memmove code into
> > thinking that the two addresses are non-overlapping in spite of the fact that
> > they are overlapping in physical space.  This, in turn, results in corruption.
> > 
> >  A proposed solution to the problem would involve calling kmap_atomic only
> > once in the case that the pgfrom and pgto are identical, and then re-using
> > the resultant vaddr for both vto and vfrom.
> > 
> > Any insight on the issue or the proposed solution would be greatly
> > appreciated.
> 
> I'm fine with that solution. Mind sending a duly conformant patch w/ a signed-off-by line?

I'm curious why we haven't seen it before: the code's done this for
years.  It looks to me like the two kmap_atomic()s, if they're
non-trivial, should always return different addresses.  And overlapping
copies are probably the normal case for this function.

Shouldn't anyone on 32 bit and high memory have seen filesystem
corruption?

Or maybe memmove is an architecture-specific implementation that happens
to handle left-to-right overlapping copies correctly on common
architectures?

--b.
