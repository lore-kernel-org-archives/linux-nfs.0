Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44607 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751485Ab1HPWYa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Aug 2011 18:24:30 -0400
Date: Wed, 17 Aug 2011 08:24:17 +1000
From: NeilBrown <neilb@suse.de>
To: Malahal Naineni <malahal@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: State of NFSv4 VolatileFilehandles
Message-ID: <20110817082417.66e2758a@notabene.brown>
In-Reply-To: <20110816155939.GA15566@us.ibm.com>
References: <4E37E66D.90102@linux.vnet.ibm.com>
	<45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
	<4E38F894.4070003@linux.vnet.ibm.com>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778B9B@SACMVEXC2-PRD.hq.netapp.com>
	<20110804082311.21b7e73a@notabene.brown>
	<20110815204900.GA12542@us.ibm.com>
	<1313482004.7206.3.camel@lade.trondhjem.org>
	<20110816155939.GA15566@us.ibm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 16 Aug 2011 08:59:39 -0700 Malahal Naineni <malahal@us.ibm.com> wrote:

> Trond Myklebust [Trond.Myklebust@netapp.com] wrote:
> > On Mon, 2011-08-15 at 13:49 -0700, Malahal Naineni wrote: 
> > > NeilBrown [neilb@suse.de] wrote:
> > > > > POSIX allows the namespace to change at any time (rename() or unlink())
> > > > > and so you cannot rely on addressing files by pathname. That was the
> > > > > whole reason for introducing filehandles into NFSv2 in the first place.
> > > > > 
> > > > > Volatile filehandles were introduced in NFSv4 without any attempt to fix
> > > > > those shortcomings. There is no real prescription for how to recover in
> > > > > a situation where a rename or unlink has occurred prior to the
> > > > > filehandle expiring. Nor is there a reliable prescription for dealing
> > > > > with the case where a new file of the same name has replaced the
> > > > > original.
> > > > > Basically, the implication is that volatile filehandles are only really
> > > > > usable in a situation where the whole Filesystem is read-only on the
> > > > > server.
> > > > 
> > > > I substantially agree, though I think the implication can be refined a little.
> > > > 
> > > > I would say that the implication is that a VFH is only really usable when the
> > > > complete path leading to the file in question is read-only.   We don't need
> > > > to assume that other files in other parts of the hierarchy which have stable
> > > > file handles are read-only.
> > > 
> > > The spec recommends "change" attribute for validating data cache, name
> > > cache, etc.  Some client implementations use "change" attribute for
> > > validating VFH though! Can we use it for validating VFH?
> > 
> > The change attribute can only be used as a heuristic since it is not
> > guaranteed to be a value that is unique to one file.
> 
> Agreed, it is a heuristic if we only use the file's "change id". If we
> want to be very strict, we could potentially use change ids of all the
> path components in the pathname... OR how about a mount option "use VFH
> at your own risk"?

I don't think change-id is really useful even as an heuristic.  Not only are
they not unique, but they are not guaranteed to be stable either (after all,
something might have changed when the file handle expired).

I think the *only* credible response to FHEXPIRED is to re-lookup the same
name and as the spec doesn't make any promises about that it is *only* safe
to do it with explicit permission through a mount option.

NeilBrown
