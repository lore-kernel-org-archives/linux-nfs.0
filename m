From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 7/7] nfsd: nfs4xdr decode_stateid helper function
Date: Wed, 13 Aug 2008 15:35:53 -0400
Message-ID: <1218656153.9042.46.camel@localhost>
References: <48A1CB0C.4090906@panasas.com>
	 <1218563178-25480-1-git-send-email-bhalevy@panasas.com>
	 <20080812190410.GC30729@fieldses.org> <48A28DEA.5060406@panasas.com>
	 <20080813150329.GF21004@fieldses.org> <1218650349.9042.20.camel@localhost>
	 <20080813183041.GG26765@fieldses.org> <1218653992.9042.32.camel@localhost>
	 <20080813191143.GI26765@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:53289 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbYHMTgB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2008 15:36:01 -0400
In-Reply-To: <20080813191143.GI26765@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-08-13 at 15:11 -0400, J. Bruce Fields wrote:
> On Wed, Aug 13, 2008 at 02:59:52PM -0400, Trond Myklebust wrote:
> > On Wed, 2008-08-13 at 14:30 -0400, J. Bruce Fields wrote:
> > > On Wed, Aug 13, 2008 at 01:59:09PM -0400, Trond Myklebust wrote:
> > > > Which is a good reason for ditching the entire confusing typedef, and
> > > > replacing it with a packed structure instead:
> > > > 
> > > > struct stateid {
> > > > 	__be32 generation;
> > > > 	char opaque[12];
> > > > } __attribute__((packed));
> > > 
> > > So without the ((packed)), all arrays get aligned to 8-byte boundaries
> > > on 64-bit machines?  (What do I need to read to catch up here?)
> > 
> > A quick google showed up:
> > 
> > 	http://sig9.com/articles/gcc-packed-structures
> > 
> > In any case, yes, the idea behind the packed attribute is to turn off
> > the field alignment.
> 
> Yeah, I was more curious about how to decide when it's necessary.  (Why
> didn't we need it before?  Is an embedded struct always aligned as if
> the fields of the embedded struct were declared directly in the
> containing struct?  Or should we really just be using the packed
> attribute *any* time we depend on that alignment, even if it seems
> obvious the compiler wouldn't need to add padding?)

The advantage of having it packed like the above is that you can still
use WRITEMEM() to write out the whole structure in one fell swoop. If
you don't specify 'packed', then the C standard allows the compiler to
add padding between the fields in order align them. I'm not sure that
compilers will usually do that for a 'char[]' field, but they will
definitely for the integer types.


