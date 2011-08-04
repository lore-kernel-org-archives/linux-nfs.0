Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57803 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849Ab1HDQ1X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2011 12:27:23 -0400
Date: Thu, 4 Aug 2011 12:27:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: State of NFSv4 VolatileFilehandles
Message-ID: <20110804162721.GD12445@fieldses.org>
References: <4E37E66D.90102@linux.vnet.ibm.com>
 <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
 <4E38F894.4070003@linux.vnet.ibm.com>
 <2DD1BC2B-6113-4D00-9DD4-C5D431EA1F8A@oracle.com>
 <4E3A8225.1020309@linux.vnet.ibm.com>
 <20110804160344.GC12445@fieldses.org>
 <1312474244.5806.4.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1312474244.5806.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 04, 2011 at 12:10:44PM -0400, Trond Myklebust wrote:
> On Thu, 2011-08-04 at 12:03 -0400, J. Bruce Fields wrote: 
> > On Thu, Aug 04, 2011 at 04:27:33AM -0700, Venkateswararao Jujjuri wrote:
> > > One of the usecase is rsync between two physical filesystems; but in
> > > this particular use case the export
> > > is readonly (rootfs).  As trond mentioned Volatile FHs are fine in
> > > the case of readonly exports.
> > > Is it something we can consider for upstream? VFH only for readonly
> > > exports.?
> > 
> > The client has no way of knowing that an export is read only.  (Or that
> > the server guarantees the safety of looking up names again in the more
> > general cases Neil describes.)  Unless we decide that a server is making
> > an implicit guarantee of that just by exposing volatile filehandles at
> > all.  Doesn't sound like the existing spec really says that, though.
> 
> NFSv4.1 introduces the 'fs_status' recommended attribute (see section
> 11.11 in RFC5661), which does, in fact, allow the client to deduce that
> an export is read-only/won't ever change.

Oh, neat, I'd forgotten that; you're thinking of STATUS4_FIXED?  But I'm
not sure it does the job:

	STATUS4_FIXED, which indicates a read-only image in the sense
	that it will never change.  The possibility is allowed that, as
	a result of migration or switch to a different image, changed
	data can be accessed, but within the confines of this instance,
	no change is allowed.  The client can use this fact to cache
	aggressively.

OK, so permission to set your attribute cache timeout very high,
perhaps, but I don't see why "changed data" couldn't mean changed
paths....

--b.

> > If an examination of existing implementations and/or some sort of new
> > spec language could reassure us that servers will only ever expose
> > volatile filehandles when it's safe to do so, then maybe it would make
> > sense for the client to implement volatile filehandle recovery?
> > 
> > But if there's a chance of "unsafe" servers out there, then it would
> > seem like a trap for the unwary user....
> > 
> > Your rootfs's probably aren't terribly large--could you copy around
> > compressed block-level images instead of doing rsync?
> 
> Agreed.
