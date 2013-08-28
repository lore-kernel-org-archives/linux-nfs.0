Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hqemgate15.nvidia.com ([216.228.121.64]:11596 "EHLO
	hqemgate15.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab3H1Pr7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Aug 2013 11:47:59 -0400
From: Matt Craighead <mcraighead@nvidia.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Mark Young <MYoung@nvidia.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 28 Aug 2013 08:47:57 -0700
Subject: RE: Issue found with kernel/net/sunrpc/xdr.c
Message-ID: <71D0C6F08977AC42A3EF66AA1BEB0F10A11801AE16@HQMAIL02.nvidia.com>
References: <1FC56210173BB445BD77F608D6FB8D03620A9978B5@HQMAIL03.nvidia.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA94677C96F@SACEXCMBX04-PRD.hq.netapp.com>
 <20130828143256.GA2960@fieldses.org>
 <71D0C6F08977AC42A3EF66AA1BEB0F10A11801ADF5@HQMAIL02.nvidia.com>
 <20130828154124.GC2960@fieldses.org>
In-Reply-To: <20130828154124.GC2960@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv3 over UDP.  No Kerberos or any other authentication of any sort.

There are some non-default mount options, and perhaps some other things that might be unique to this particular test environment, but I don't see anything in particular that seems likely to perturb this code's behavior very much.

-----Original Message-----
From: J. Bruce Fields [mailto:bfields@fieldses.org] 
Sent: Wednesday, August 28, 2013 10:41 AM
To: Matt Craighead
Cc: Myklebust, Trond; Mark Young; linux-nfs@vger.kernel.org
Subject: Re: Issue found with kernel/net/sunrpc/xdr.c

On Wed, Aug 28, 2013 at 08:18:10AM -0700, Matt Craighead wrote:
> > I'm curious why we haven't seen it before
> 
> I agree, it's slightly mysterious.  We're hitting the bug on a 32-bit ARM system with 1GB or 2GB of memory; surely that's not very far off the beaten path.

Yeah, it probably gets less testing, but I doubt you're the first to use 32-bit ARM with whatever minimum memory size is required to hit this.
Hm.  (Are you using krb5?  Which version of NFS?  And I guess this manifested as the client seeing corrupted file data?)

Oh well, just curiosity on my part.  The fix is simple enough.

--b.

> 
> 
> > Or maybe memmove is an architecture-specific implementation that happens to handle left-to-right overlapping copies correctly on common architectures?
> 
> It's architecture specific, e.g.: 
> http://lxr.linux.no/linux+v3.8/arch/arm/lib/memmove.S
> 
> In this particular case, it decides that the memory is non-overlapping (by comparing the virtual addresses), so it incorrectly dispatches to memcpy().  At that point all bets are off in terms of the direction, chunk size, etc. of the copy.
> 
> I guess I'd typically expect memcpy() to stride through memory forwards rather than backwards though.  And since this function mandates "from < to", it seems like this would usually fail.
> 
> 
> For x86: http://lxr.linux.no/linux+v3.8/arch/x86/lib/memcpy_32.c
> 
> In this case, it looks like it doesn't dispatch to memcpy().  It just determines forward/backwards and copies accordingly.  So it would work as long as the "from < to" property was preserved.
> 
> If I'm reading the code correctly, kmap_atomic appears to grow downward on x86:
> http://lxr.linux.no/linux+v3.8/arch/x86/mm/highmem_32.c
> http://lxr.linux.no/linux+v3.8/arch/x86/include/asm/fixmap.h
> etc.
> 
> Since xdr.c calls kmap_atomic on *pgto first, then *pgfrom, the "from < to" property will therefore be preserved.
> 
> 
> Therefore, I suspect you might be able to reproduce the bug on (32-bit) x86 by doing any of the following:
> - swapping the order of those kmap_atomic/kunmap_atomic calls
> - modifying kmap_atomic to grow in the opposite direction
> - modifying memmove() to dispatch to memcpy() when the virtual regions 
> are non-overlapping
> 
> It's still possible that there is something else funny about how memory gets allocated in our setup that makes the bug more likely, but empirically, the bug didn't seem hard to hit.  We didn't need to copy very much data/very many files over NFS before we typically got corruption, and the bug happened on a variety of specific platforms.  It was (unsurprisingly) easier to reproduce with 2GB than with 1GB though.
> 
> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Wednesday, August 28, 2013 9:33 AM
> To: Myklebust, Trond
> Cc: Mark Young; linux-nfs@vger.kernel.org; Matt Craighead
> Subject: Re: Issue found with kernel/net/sunrpc/xdr.c
> 
> On Tue, Aug 27, 2013 at 10:01:38PM +0000, Myklebust, Trond wrote:
> > > -----Original Message-----
> > > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs- 
> > > owner@vger.kernel.org] On Behalf Of Mark Young
> > > Sent: Tuesday, August 27, 2013 5:17 PM
> > > To: linux-nfs@vger.kernel.org
> > > Cc: Matt Craighead
> > > Subject: Issue found with kernel/net/sunrpc/xdr.c
> > > 
> > > I was pointed to this mailing list by Brian Fields.
> > > 
> > >  We're currently seeing NFS data corruption, which we traced back 
> > > to memory corruption that happens in the function 
> > > _shift_data_right_pages in net/sunrpc/xdr.c.
> > > 
> > >  When we see the issue, we're running a 32bit os with systems running with
> > > more than 1GB of physical memory.   The errant behavior appears to be that
> > > two calls to kmap_atomic (on 32bit systems with highmem present) 
> > > with the same physical address (on addresses within highmem)  will return two
> > > different vaddrs.    In our assessment, this confuses the memmove code into
> > > thinking that the two addresses are non-overlapping in spite of 
> > > the fact that they are overlapping in physical space.  This, in turn, results in corruption.
> > > 
> > >  A proposed solution to the problem would involve calling 
> > > kmap_atomic only once in the case that the pgfrom and pgto are 
> > > identical, and then re-using the resultant vaddr for both vto and vfrom.
> > > 
> > > Any insight on the issue or the proposed solution would be greatly 
> > > appreciated.
> > 
> > I'm fine with that solution. Mind sending a duly conformant patch w/ a signed-off-by line?
> 
> I'm curious why we haven't seen it before: the code's done this for years.  It looks to me like the two kmap_atomic()s, if they're non-trivial, should always return different addresses.  And overlapping copies are probably the normal case for this function.
> 
> Shouldn't anyone on 32 bit and high memory have seen filesystem corruption?
> 
> Or maybe memmove is an architecture-specific implementation that happens to handle left-to-right overlapping copies correctly on common architectures?
> 
> --b.
> ----------------------------------------------------------------------
> ------------- This email message is for the sole use of the intended 
> recipient(s) and may contain confidential information.  Any 
> unauthorized review, use, disclosure or distribution is prohibited.  
> If you are not the intended recipient, please contact the sender by 
> reply email and destroy all copies of the original message.
> ----------------------------------------------------------------------
> -------------
