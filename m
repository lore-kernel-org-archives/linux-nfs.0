Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43893 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755992Ab1HDCMz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2011 22:12:55 -0400
Subject: Re: State of NFSv4 VolatileFilehandles
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Malahal Naineni <malahal@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 03 Aug 2011 22:12:39 -0400
In-Reply-To: <20110804011611.GA24568@us.ibm.com>
References: <4E37E66D.90102@linux.vnet.ibm.com>
	 <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
	 <4E38F894.4070003@linux.vnet.ibm.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778B9B@SACMVEXC2-PRD.hq.netapp.com>
	 <20110804082311.21b7e73a@notabene.brown>
	 <20110804011611.GA24568@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312423959.2304.10.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-08-03 at 18:16 -0700, Malahal Naineni wrote: 
> NeilBrown [neilb@suse.de] wrote:
> > 
> > I substantially agree, though I think the implication can be refined a
> > little.
> > 
> > I would say that the implication is that a VFH is only really usable
> > when the complete path leading to the file in question is read-only.
> > We don't need to assume that other files in other parts of the
> > hierarchy which have stable file handles are read-only.
> > 
> > So if the server presents us with a VFH, it seems reasonable to assume
> > that we can use a repeated lookup of the same name to refresh the
> > filehandle simply because there is no other credible way to respond to
> > a FHEXPIRED.
> 
> The spec seems to imply that repeated lookup of the same name to refresh
> the file handle is OK as long as the file is OPEN! It doesn't seem to imply
> anything for files that are not opened.

I see no such implication for a migration situation, unless you also
migrate the open state.

Even if you do, then you still have to somehow recover directory
filehandles for the current directory and any other RPC call that
happened to be in progress when the original server was migrated.

> "RFC 3530, 4.2.3. Volatile Filehandle" states:
> 
> "Servers which provide volatile filehandles that may expire while open
> (i.e., if FH4_VOL_MIGRATION or FH4_VOL_RENAME is set or if
> FH4_VOLATILE_ANY is set and FH4_NOEXPIRE_WITH_OPEN not set), should deny
> a RENAME or REMOVE that would affect an OPEN file of any of the
> components leading to the OPEN file.  In addition, the server should
> deny all RENAME or REMOVE requests during the grace period upon server
> restart."
> 
> On the other hand, if FH4_NOEXPIRE_WITH_OPEN is set, then the file can
> be allowed to be renamed or removed by the server.

Which completely violates the expectations of POSIX applications on the
client. Any idea how you would work around the above?

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

