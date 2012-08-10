Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58980 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751831Ab2HJRXd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Aug 2012 13:23:33 -0400
Date: Fri, 10 Aug 2012 13:23:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Zdenek Salvet <salvet@ics.muni.cz>,
        Lukas Hejtmanek <xhejtman@ics.muni.cz>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 backchannel authentication
Message-ID: <20120810172322.GA17404@fieldses.org>
References: <20120806135517.GS25979@ics.muni.cz>
 <20120807154114.GA21460@fieldses.org>
 <1344355148.5781.31.camel@lade.trondhjem.org>
 <20120808075813.GW604@horn.ics.muni.cz>
 <1344431887.3423.4.camel@lade.trondhjem.org>
 <20120809080642.GE604@horn.ics.muni.cz>
 <20120809144530.GB6592@fieldses.org>
 <1344527573.25447.17.camel@lade.trondhjem.org>
 <20120810152039.21eaa5a6@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120810152039.21eaa5a6@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 10, 2012 at 03:20:39PM +1000, NeilBrown wrote:
> On Thu, 9 Aug 2012 15:53:01 +0000 "Myklebust, Trond"
> <Trond.Myklebust@netapp.com> wrote:
> 
> > On Thu, 2012-08-09 at 10:45 -0400, J. Bruce Fields wrote:
> > > On Thu, Aug 09, 2012 at 10:06:42AM +0200, Zdenek Salvet wrote:
> > > > On Wed, Aug 08, 2012 at 01:18:09PM +0000, Myklebust, Trond wrote:
> > > > > > We don't see any hard failures because NFS protocol does
> > > > > > not depend on working callback RPCs, but no delegations are granted
> > > > > > (we had nfs-kernel-server package installed on clients before which masked
> > > > > > the bug).
> > > > > 
> > > > > So your gripe that you object to us requiring you to run rpc.svcgssd in
> > > > > order to obtain server features such as NFSv4 callbacks?
> > > > 
> > > > Absolutely not! Just thinking why we did not notice the problem earlier ...
> > > 
> > > I wonder if there's anything we could do to make this more automatic,
> > > though: e.g., perhaps whichever scripts are launching one of the gss
> > > daemons should be replaced by one that launches both, since that's
> > > generally what you'll want for NFSv4.0.  (Not necessary for other
> > > versions, but it doesn't hurt much.)
> > > 
> > > Or perhaps they could be started on demand somehow.
> > 
> > How is this any different to requiring that the user start rpc.statd
> > before launching an NFSv3 mount? Just document the requirement if it
> > isn't already clear enough, and we can move on.
> 
> 'mount.nfs' checks if statd is running and will start it if it isn't ....
> which will probably annoy systemd as it likes to keep daemons in their own
> little box.  I guess systemd can be configured to register as statd and
> auto-start it on the first 'are you there' request.
> 
> Could the same thing be done with rpc.svcgssd?  Get it to auto-start either
> by mount.nfs checking and running something, or by systemd pre-registering
> the RPC port or something?

I wonder how hard it would be to teach systemd to do the
socket-activation trick with the cache upcalls: so, open the channel
file, wait till its readable, then kick off svcgssd and hand off the
file descriptor to it.

--b.
