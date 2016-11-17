Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50310 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753223AbcKQTck (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Nov 2016 14:32:40 -0500
Date: Thu, 17 Nov 2016 14:32:39 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "tibbs@math.uh.edu" <tibbs@math.uh.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
Message-ID: <20161117193239.GD20937@fieldses.org>
References: <ufafuwhlr72.fsf@epithumia.math.uh.edu>
 <20160225195827.GC23315@fieldses.org>
 <ufaegbvdslg.fsf@epithumia.math.uh.edu>
 <20160301004844.GA11952@fieldses.org>
 <ufay4a3c938.fsf@epithumia.math.uh.edu>
 <20160301010120.GB11952@fieldses.org>
 <ufapovfc8m4.fsf@epithumia.math.uh.edu>
 <ufa1syb402e.fsf@epithumia.math.uh.edu>
 <20161117163101.GA19161@fieldses.org>
 <1479404750.33885.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1479404750.33885.1.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 17, 2016 at 05:45:52PM +0000, Trond Myklebust wrote:
> On Thu, 2016-11-17 at 11:31 -0500, J. Bruce Fields wrote:
> > On Wed, Nov 16, 2016 at 02:55:05PM -0600, Jason L Tibbitts III wrote:
> > > 
> > > I'm replying to a rather old message, but the issue has just now
> > > popped
> > > back up again.
> > > 
> > > To recap, a client stops being able to access _any_ mount on a
> > > particular server, and "NFS: nfs4_reclaim_open_state: Lock reclaim
> > > failed!" appears several hundred times per second in the kernel
> > > log.
> > > The load goes up by one for ever process attempting to access any
> > > mount
> > > from that particular server.  Mounts to other servers are fine, and
> > > other clients can mount things from that one server without
> > > problems.
> > > 
> > > When I kill every process keeping that particular mount active and
> > > then
> > > umount it, I see:
> > > 
> > > NFS: nfs4_reclaim_open_state: unhandled error -10068
> > 
> > NFS4ERR_RETRY_UNCACHED_REP.
> > 
> > So, you're using NFSv4.1 or 4.2, and the server thinks that the
> > client
> > has reused a (slot, sequence number) pair, but the server doesn't
> > have a
> > cached response to return.
> > 
> > Hard to know how that happened, and it's not shown in the below.
> > Sounds like a bug, though.
> 
> ...or a Ctrl-C....

How does that happen?

--b.
