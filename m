Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57696 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836Ab1HDRVe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 13:21:34 -0400
Subject: Re: State of NFSv4 VolatileFilehandles
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Date: Thu, 04 Aug 2011 13:21:32 -0400
In-Reply-To: <20110804170313.GH12445@fieldses.org>
References: <4E37E66D.90102@linux.vnet.ibm.com>
	 <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
	 <4E38F894.4070003@linux.vnet.ibm.com>
	 <2DD1BC2B-6113-4D00-9DD4-C5D431EA1F8A@oracle.com>
	 <4E3A8225.1020309@linux.vnet.ibm.com> <20110804160344.GC12445@fieldses.org>
	 <1312474244.5806.4.camel@lade.trondhjem.org>
	 <20110804162721.GD12445@fieldses.org>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A8AA818@SACMVEXC2-PRD.hq.netapp.com>
	 <20110804170313.GH12445@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312478492.8919.14.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-08-04 at 13:03 -0400, J. Bruce Fields wrote: 
> On Thu, Aug 04, 2011 at 09:48:32AM -0700, Myklebust, Trond wrote:
> > > -----Original Message-----
> > > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > > Oh, neat, I'd forgotten that; you're thinking of STATUS4_FIXED?  But
> > > I'm
> > > not sure it does the job:
> > > 
> > > 	STATUS4_FIXED, which indicates a read-only image in the sense
> > > 	that it will never change.  The possibility is allowed that, as
> > > 	a result of migration or switch to a different image, changed
> > > 	data can be accessed, but within the confines of this instance,
> > > 	no change is allowed.  The client can use this fact to cache
> > > 	aggressively.
> > > 
> > > OK, so permission to set your attribute cache timeout very high,
> > > perhaps, but I don't see why "changed data" couldn't mean changed
> > > paths....
> > 
> > No, but you can presumably use the FSLI4BX_CLSIMUL flag from
> > fs_locations_info in order to find an equivalent replica.
> 
> I lost you.
> 
> Actually my real problem is that I don't understand the description of
> STATUS4_FIXED.  What does "or switch to a different image" mean?  Not
> "migration", or the sentence would have ended before the "or".
> 
> I read it as allowing a server admin to replace the filesystem image in
> place, in which case from the client's point of view this allows the
> filesystem to change at any time.  Which makes the whole thing not
> terribly useful, except (as the last sentence says) as a caching hint.

If the server admin replaces one filesystem, with a different
filesystem, then nothing is going to work anyway. I don't see how that
is relevant. That's a case of 'doctor it hurts...'

The bit that _is_ relevant is the 'migration' part, but since the
fs_locations_info FSLI4BX_CLSIMUL flag allows you to conclude that
replica is an exact replica at all times (i.e. contents are guaranteed
to be the same even if filehandles, directory cookies, etc are not) then
the STATUS4_FIXED flag does allow you to assume that paths have not
changed.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

