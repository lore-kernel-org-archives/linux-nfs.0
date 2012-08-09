Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36575 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751064Ab2HIQum (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 12:50:42 -0400
Date: Thu, 9 Aug 2012 12:50:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Zdenek Salvet <salvet@ics.muni.cz>, Lukas Hejtmanek <xhejtman@ics.muni.cz>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 backchannel authentication
Message-ID: <20120809165035.GB8230@fieldses.org>
References: <20120806135517.GS25979@ics.muni.cz>
 <20120807154114.GA21460@fieldses.org>
 <1344355148.5781.31.camel@lade.trondhjem.org>
 <20120808075813.GW604@horn.ics.muni.cz>
 <1344431887.3423.4.camel@lade.trondhjem.org>
 <20120809080642.GE604@horn.ics.muni.cz>
 <20120809144530.GB6592@fieldses.org>
 <1344527573.25447.17.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1344527573.25447.17.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 09, 2012 at 03:53:01PM +0000, Myklebust, Trond wrote:
> On Thu, 2012-08-09 at 10:45 -0400, J. Bruce Fields wrote:
> > On Thu, Aug 09, 2012 at 10:06:42AM +0200, Zdenek Salvet wrote:
> > > On Wed, Aug 08, 2012 at 01:18:09PM +0000, Myklebust, Trond wrote:
> > > > > We don't see any hard failures because NFS protocol does
> > > > > not depend on working callback RPCs, but no delegations are granted
> > > > > (we had nfs-kernel-server package installed on clients before which masked
> > > > > the bug).
> > > > 
> > > > So your gripe that you object to us requiring you to run rpc.svcgssd in
> > > > order to obtain server features such as NFSv4 callbacks?
> > > 
> > > Absolutely not! Just thinking why we did not notice the problem earlier ...
> > 
> > I wonder if there's anything we could do to make this more automatic,
> > though: e.g., perhaps whichever scripts are launching one of the gss
> > daemons should be replaced by one that launches both, since that's
> > generally what you'll want for NFSv4.0.  (Not necessary for other
> > versions, but it doesn't hurt much.)
> > 
> > Or perhaps they could be started on demand somehow.
> 
> How is this any different to requiring that the user start rpc.statd
> before launching an NFSv3 mount? Just document the requirement if it
> isn't already clear enough, and we can move on.

That's good enough, but it's always nice if there's some configuration
we can skip.  (Not that I'm volunteering.)

> The other source of confusion here, was that the rpc.svcgssd was
> delivered through a nfs-kernel-server package, which indicates that we
> first and foremost need to educate the distro packagers.

Yes, that's a mistake.  The nfs-utils README is where we've been
documenting daemon startup--I'll work on a patch.  (And see if the man
pages could use something too.)  And somebody should ping Debian
(nfs-kernel-server sounds like a Debian thing.)

--b.
