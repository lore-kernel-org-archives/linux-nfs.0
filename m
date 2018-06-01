Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58452 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752467AbeFAOqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Jun 2018 10:46:55 -0400
Date: Fri, 1 Jun 2018 10:46:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: devel@lists.nfs-ganesha.org, sostapov@redhat.com,
        Supriti.Singh@suse.com,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH] rados_cluster: add a "design" manpage
Message-ID: <20180601144655.GD10666@fieldses.org>
References: <20180523122140.8373-1-jlayton@kernel.org>
 <20180531213733.GB4654@fieldses.org>
 <fbc5ad16342dc1b4d50041bfa1274fc0197486a9.camel@kernel.org>
 <20180601141725.GB10666@fieldses.org>
 <84dd9dbf7e11818cd4188b01e0834a1f04cd24ae.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <84dd9dbf7e11818cd4188b01e0834a1f04cd24ae.camel@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 01, 2018 at 10:33:14AM -0400, Jeff Layton wrote:
> On Fri, 2018-06-01 at 10:17 -0400, J. Bruce Fields wrote:
> > On Fri, Jun 01, 2018 at 06:42:37AM -0400, Jeff Layton wrote:
> > > Thanks for having a look. Hmm...you're right.
> > > 
> > >         nn->nfsd4_lease = 90;   /* default lease time */                        
> > >         nn->nfsd4_grace = 90;                                                   
> > > 
> > > nit: We should probably add a #define'd constant for that at some
> > > point...but, might this be problematic?
> > > 
> > > In the pessimal case, you might renew your lease just before the server
> > > crashes. It then comes back up quickly and starts the grace period. By
> > > the time the client contacts the server again the grace period is almost
> > > over and you may have very little time to actually do any reclaim.
> > > 
> > > ISTR that when we were working on the server at PD we had determined
> > > that we needed around 2 grace periods + a small fudge factor. I don't
> > > recall the details of how we determined it though.
> > 
> > OK, I'd be interested in any of that.
> > 
> > If we decide we need a larger grace/lease ratio, we may want to adjust
> > default lease down at same time to avoid increasing grace period, as
> > that's always an annoyance.
> > 
> 
> I think we just figured that we ought to give the client a full lease
> period to reclaim everything, in case it holds a lot of state. You also
> need to give it a full lease period to figure out that the server has
> rebooted, and then I think we added a few seconds to account for "other
> factors" (transport delays and whatnot).

I think it would also be easy to extend it on demand.

So, for example: end the grace period when:

	(one lease period has passed *and* we've received no reclaim
	request in the last second) *or*
	two lease periods have passed

Maybe think about the exact choice of numbers a little.

--b.
