Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60907 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758673Ab2HIQiv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 12:38:51 -0400
Date: Thu, 9 Aug 2012 12:38:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Lukas Hejtmanek <xhejtman@ics.muni.cz>, Zdenek Salvet <salvet@ics.muni.cz>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 backchannel authentication
Message-ID: <20120809163846.GA8230@fieldses.org>
References: <20120806135517.GS25979@ics.muni.cz>
 <20120807154114.GA21460@fieldses.org>
 <1344355148.5781.31.camel@lade.trondhjem.org>
 <20120808075813.GW604@horn.ics.muni.cz>
 <1344431887.3423.4.camel@lade.trondhjem.org>
 <20120809080642.GE604@horn.ics.muni.cz>
 <20120809144530.GB6592@fieldses.org>
 <1344527573.25447.17.camel@lade.trondhjem.org>
 <20120809162801.GM11089@ics.muni.cz>
 <1344529851.25447.33.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1344529851.25447.33.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 09, 2012 at 04:30:53PM +0000, Myklebust, Trond wrote:
> On Thu, 2012-08-09 at 18:28 +0200, Lukas Hejtmanek wrote:
> > On Thu, Aug 09, 2012 at 03:53:01PM +0000, Myklebust, Trond wrote:
> > > How is this any different to requiring that the user start rpc.statd
> > > before launching an NFSv3 mount? Just document the requirement if it
> > > isn't already clear enough, and we can move on.
> > > 
> > > The other source of confusion here, was that the rpc.svcgssd was
> > > delivered through a nfs-kernel-server package, which indicates that we
> > > first and foremost need to educate the distro packagers.
> > 
> > hmm, if both rpc.gssd and rpc.svcgssd are needed on clients and servers, isn't
> > it worth of merging them into a single process?
> 
> You don't need rpc.gssd to use rpcsec_gss with NFSv3, nor do you need it
		 ^^^^^^^^

You meant rpc.svcgssd, unless you were thinking about the nfsd side.

> if you're not intending on using delegations with NFSv4.

Though the default should be to support delegations.

--b.
