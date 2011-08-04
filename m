Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42537 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752829Ab1HDQsw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 12:48:52 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: State of NFSv4 VolatileFilehandles
Date: Thu, 4 Aug 2011 09:48:32 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A8AA818@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20110804162721.GD12445@fieldses.org>
References: <4E37E66D.90102@linux.vnet.ibm.com> <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com> <4E38F894.4070003@linux.vnet.ibm.com> <2DD1BC2B-6113-4D00-9DD4-C5D431EA1F8A@oracle.com> <4E3A8225.1020309@linux.vnet.ibm.com> <20110804160344.GC12445@fieldses.org> <1312474244.5806.4.camel@lade.trondhjem.org> <20110804162721.GD12445@fieldses.org>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Venkateswararao Jujjuri" <jvrao@linux.vnet.ibm.com>,
        "Chuck Lever" <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Thursday, August 04, 2011 12:27 PM
> To: Myklebust, Trond
> Cc: Venkateswararao Jujjuri; Chuck Lever; linux-nfs@vger.kernel.org
> Subject: Re: State of NFSv4 VolatileFilehandles
> 
> On Thu, Aug 04, 2011 at 12:10:44PM -0400, Trond Myklebust wrote:
> > On Thu, 2011-08-04 at 12:03 -0400, J. Bruce Fields wrote:
> > > On Thu, Aug 04, 2011 at 04:27:33AM -0700, Venkateswararao Jujjuri
> wrote:
> > > > One of the usecase is rsync between two physical filesystems;
but
> in
> > > > this particular use case the export
> > > > is readonly (rootfs).  As trond mentioned Volatile FHs are fine
> in
> > > > the case of readonly exports.
> > > > Is it something we can consider for upstream? VFH only for
> readonly
> > > > exports.?
> > >
> > > The client has no way of knowing that an export is read only.  (Or
> that
> > > the server guarantees the safety of looking up names again in the
> more
> > > general cases Neil describes.)  Unless we decide that a server is
> making
> > > an implicit guarantee of that just by exposing volatile
filehandles
> at
> > > all.  Doesn't sound like the existing spec really says that,
> though.
> >
> > NFSv4.1 introduces the 'fs_status' recommended attribute (see
section
> > 11.11 in RFC5661), which does, in fact, allow the client to deduce
> that
> > an export is read-only/won't ever change.
> 
> Oh, neat, I'd forgotten that; you're thinking of STATUS4_FIXED?  But
> I'm
> not sure it does the job:
> 
> 	STATUS4_FIXED, which indicates a read-only image in the sense
> 	that it will never change.  The possibility is allowed that, as
> 	a result of migration or switch to a different image, changed
> 	data can be accessed, but within the confines of this instance,
> 	no change is allowed.  The client can use this fact to cache
> 	aggressively.
> 
> OK, so permission to set your attribute cache timeout very high,
> perhaps, but I don't see why "changed data" couldn't mean changed
> paths....

No, but you can presumably use the FSLI4BX_CLSIMUL flag from
fs_locations_info in order to find an equivalent replica.

Cheers,
  Trond
