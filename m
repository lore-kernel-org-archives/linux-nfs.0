Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:39142 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751584AbeFAKmk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Jun 2018 06:42:40 -0400
Message-ID: <fbc5ad16342dc1b4d50041bfa1274fc0197486a9.camel@kernel.org>
Subject: Re: [RFC PATCH] rados_cluster: add a "design" manpage
From: Jeff Layton <jlayton@kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: devel@lists.nfs-ganesha.org, sostapov@redhat.com,
        Supriti.Singh@suse.com,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Date: Fri, 01 Jun 2018 06:42:37 -0400
In-Reply-To: <20180531213733.GB4654@fieldses.org>
References: <20180523122140.8373-1-jlayton@kernel.org>
         <20180531213733.GB4654@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2018-05-31 at 17:37 -0400, J. Bruce Fields wrote:
> On Wed, May 23, 2018 at 08:21:40AM -0400, Jeff Layton wrote:
> > From: Jeff Layton <jlayton@redhat.com>
> > 
> > Bruce asked for better design documentation, so this is my attempt at
> > it. Let me know what you think. I'll probably end up squashing this into
> > one of the code patches but for now I'm sending this separately to see
> > if it helps clarify things.
> > 
> > Suggestions and feedback are welcome.
> > 
> > Change-Id: I53cc77f66b2407c2083638e5760666639ba1fd57
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  src/doc/man/ganesha-rados-cluster.rst | 227 ++++++++++++++++++++++++++
> >  1 file changed, 227 insertions(+)
> >  create mode 100644 src/doc/man/ganesha-rados-cluster.rst
> > 
> > diff --git a/src/doc/man/ganesha-rados-cluster.rst b/src/doc/man/ganesha-rados-cluster.rst
> > new file mode 100644
> > index 000000000000..1ba2d3c29093
> > --- /dev/null
> > +++ b/src/doc/man/ganesha-rados-cluster.rst
> > @@ -0,0 +1,227 @@
> > +==============================================================================
> > +ganesha-rados-cluster-design -- Clustered RADOS Recovery Backend Design
> > +==============================================================================
> > +
> > +.. program:: ganesha-rados-cluster-design
> > +
> > +This document aims to explain the theory and design behind the
> > +rados_cluster recovery backend, which coordinates grace period
> > +enforcement among multiple, independent NFS servers.
> > +
> > +In order to understand the clustered recovery backend, it's first necessary
> > +to understand how recovery works with a single server:
> > +
> > +Singleton Server Recovery
> > +-------------------------
> > +NFSv4 is a lease-based protocol. Clients set up a relationship to the
> > +server and must periodically renew their lease in order to maintain
> > +their ephemeral state (open files, locks, delegations or layouts).
> > +
> > +When a singleton NFS server is restarted, any ephemeral state is lost. When
> > +the server comes comes back online, NFS clients detect that the server has
> > +been restarted and will reclaim the ephemeral state that they held at the
> > +time of their last contact with the server.
> > +
> > +Singleton Grace Period
> > +----------------------
> > +
> > +In order to ensure that we don't end up with conflicts, clients are
> > +barred from acquiring any new state while in the Recovery phase. Only
> > +reclaim operations are allowed.
> > +
> > +This period of time is called the **grace period**. Most NFS servers
> > +have a grace period that lasts around two lease periods, however
> 
> knfsd's is one lease period, who does two?
> 
> (Still catching up on the rest.  Looks good.)
> 
> --b.

(cc'ing linux-nfs)

Thanks for having a look. Hmm...you're right.

        nn->nfsd4_lease = 90;   /* default lease time */                        
        nn->nfsd4_grace = 90;                                                   

nit: We should probably add a #define'd constant for that at some
point...but, might this be problematic?

In the pessimal case, you might renew your lease just before the server
crashes. It then comes back up quickly and starts the grace period. By
the time the client contacts the server again the grace period is almost
over and you may have very little time to actually do any reclaim.

ISTR that when we were working on the server at PD we had determined
that we needed around 2 grace periods + a small fudge factor. I don't
recall the details of how we determined it though.

Even worse: 

        $ cat /proc/sys/fs/lease-break-time 
        45

Maybe we should be basing the v4 lease time on the lease-break-time
value? It seems like we ought to revoke delegations after two lease
periods rather than after half of one.
-- 
Jeff Layton <jlayton@kernel.org>
