Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:59145 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543Ab1HPQAS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 12:00:18 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p7GG0Dgc025712
	for <linux-nfs@vger.kernel.org>; Tue, 16 Aug 2011 10:00:13 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7GFxmT7038246
	for <linux-nfs@vger.kernel.org>; Tue, 16 Aug 2011 09:59:59 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7GFxmg9009265
	for <linux-nfs@vger.kernel.org>; Tue, 16 Aug 2011 09:59:48 -0600
Received: from malahal (malahal.beaverton.ibm.com [9.47.25.235])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id p7GFxkn4008754
	for <linux-nfs@vger.kernel.org>; Tue, 16 Aug 2011 09:59:47 -0600
Date: Tue, 16 Aug 2011 08:59:39 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: State of NFSv4 VolatileFilehandles
Message-ID: <20110816155939.GA15566@us.ibm.com>
References: <4E37E66D.90102@linux.vnet.ibm.com>
 <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
 <4E38F894.4070003@linux.vnet.ibm.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778B9B@SACMVEXC2-PRD.hq.netapp.com>
 <20110804082311.21b7e73a@notabene.brown>
 <20110815204900.GA12542@us.ibm.com>
 <1313482004.7206.3.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1313482004.7206.3.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust [Trond.Myklebust@netapp.com] wrote:
> On Mon, 2011-08-15 at 13:49 -0700, Malahal Naineni wrote: 
> > NeilBrown [neilb@suse.de] wrote:
> > > > POSIX allows the namespace to change at any time (rename() or unlink())
> > > > and so you cannot rely on addressing files by pathname. That was the
> > > > whole reason for introducing filehandles into NFSv2 in the first place.
> > > > 
> > > > Volatile filehandles were introduced in NFSv4 without any attempt to fix
> > > > those shortcomings. There is no real prescription for how to recover in
> > > > a situation where a rename or unlink has occurred prior to the
> > > > filehandle expiring. Nor is there a reliable prescription for dealing
> > > > with the case where a new file of the same name has replaced the
> > > > original.
> > > > Basically, the implication is that volatile filehandles are only really
> > > > usable in a situation where the whole Filesystem is read-only on the
> > > > server.
> > > 
> > > I substantially agree, though I think the implication can be refined a little.
> > > 
> > > I would say that the implication is that a VFH is only really usable when the
> > > complete path leading to the file in question is read-only.   We don't need
> > > to assume that other files in other parts of the hierarchy which have stable
> > > file handles are read-only.
> > 
> > The spec recommends "change" attribute for validating data cache, name
> > cache, etc.  Some client implementations use "change" attribute for
> > validating VFH though! Can we use it for validating VFH?
> 
> The change attribute can only be used as a heuristic since it is not
> guaranteed to be a value that is unique to one file.

Agreed, it is a heuristic if we only use the file's "change id". If we
want to be very strict, we could potentially use change ids of all the
path components in the pathname... OR how about a mount option "use VFH
at your own risk"?

Thanks, Malahal.
