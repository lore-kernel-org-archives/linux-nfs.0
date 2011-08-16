Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58573 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522Ab1HPIGr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 04:06:47 -0400
Subject: Re: State of NFSv4 VolatileFilehandles
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Malahal Naineni <malahal@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 16 Aug 2011 04:06:44 -0400
In-Reply-To: <20110815204900.GA12542@us.ibm.com>
References: <4E37E66D.90102@linux.vnet.ibm.com>
	 <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
	 <4E38F894.4070003@linux.vnet.ibm.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778B9B@SACMVEXC2-PRD.hq.netapp.com>
	 <20110804082311.21b7e73a@notabene.brown>
	 <20110815204900.GA12542@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1313482004.7206.3.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-08-15 at 13:49 -0700, Malahal Naineni wrote: 
> NeilBrown [neilb@suse.de] wrote:
> > > POSIX allows the namespace to change at any time (rename() or unlink())
> > > and so you cannot rely on addressing files by pathname. That was the
> > > whole reason for introducing filehandles into NFSv2 in the first place.
> > > 
> > > Volatile filehandles were introduced in NFSv4 without any attempt to fix
> > > those shortcomings. There is no real prescription for how to recover in
> > > a situation where a rename or unlink has occurred prior to the
> > > filehandle expiring. Nor is there a reliable prescription for dealing
> > > with the case where a new file of the same name has replaced the
> > > original.
> > > Basically, the implication is that volatile filehandles are only really
> > > usable in a situation where the whole Filesystem is read-only on the
> > > server.
> > 
> > I substantially agree, though I think the implication can be refined a little.
> > 
> > I would say that the implication is that a VFH is only really usable when the
> > complete path leading to the file in question is read-only.   We don't need
> > to assume that other files in other parts of the hierarchy which have stable
> > file handles are read-only.
> 
> The spec recommends "change" attribute for validating data cache, name
> cache, etc.  Some client implementations use "change" attribute for
> validating VFH though! Can we use it for validating VFH?

The change attribute can only be used as a heuristic since it is not
guaranteed to be a value that is unique to one file.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

