Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:52974 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752776AbeFAOdR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Jun 2018 10:33:17 -0400
Message-ID: <84dd9dbf7e11818cd4188b01e0834a1f04cd24ae.camel@kernel.org>
Subject: Re: [RFC PATCH] rados_cluster: add a "design" manpage
From: Jeff Layton <jlayton@kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: devel@lists.nfs-ganesha.org, sostapov@redhat.com,
        Supriti.Singh@suse.com,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Date: Fri, 01 Jun 2018 10:33:14 -0400
In-Reply-To: <20180601141725.GB10666@fieldses.org>
References: <20180523122140.8373-1-jlayton@kernel.org>
         <20180531213733.GB4654@fieldses.org>
         <fbc5ad16342dc1b4d50041bfa1274fc0197486a9.camel@kernel.org>
         <20180601141725.GB10666@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2018-06-01 at 10:17 -0400, J. Bruce Fields wrote:
> On Fri, Jun 01, 2018 at 06:42:37AM -0400, Jeff Layton wrote:
> > Thanks for having a look. Hmm...you're right.
> > 
> >         nn->nfsd4_lease = 90;   /* default lease time */                        
> >         nn->nfsd4_grace = 90;                                                   
> > 
> > nit: We should probably add a #define'd constant for that at some
> > point...but, might this be problematic?
> > 
> > In the pessimal case, you might renew your lease just before the server
> > crashes. It then comes back up quickly and starts the grace period. By
> > the time the client contacts the server again the grace period is almost
> > over and you may have very little time to actually do any reclaim.
> > 
> > ISTR that when we were working on the server at PD we had determined
> > that we needed around 2 grace periods + a small fudge factor. I don't
> > recall the details of how we determined it though.
> 
> OK, I'd be interested in any of that.
> 
> If we decide we need a larger grace/lease ratio, we may want to adjust
> default lease down at same time to avoid increasing grace period, as
> that's always an annoyance.
> 

I think we just figured that we ought to give the client a full lease
period to reclaim everything, in case it holds a lot of state. You also
need to give it a full lease period to figure out that the server has
rebooted, and then I think we added a few seconds to account for "other
factors" (transport delays and whatnot).

> > Even worse: 
> > 
> >         $ cat /proc/sys/fs/lease-break-time 
> >         45
> > 
> > Maybe we should be basing the v4 lease time on the lease-break-time
> > value? It seems like we ought to revoke delegations after two lease
> > periods rather than after half of one.
> 
> No, we ignore lease-break-time on delegations.  See the comment in
> fs/nfsd/nfs4state.c:nfsd_break_deleg_cb():
> 
> 	/*
> 	 * We don't want the locks code to timeout the lease for us;
> 	 * we'll remove it ourself if a delegation isn't returned
> 	 * in time:
> 	 */
> 	fl->fl_break_time = 0;
> 

Ahh thanks, I had forgotten that. Whew!

-- 
Jeff Layton <jlayton@kernel.org>
