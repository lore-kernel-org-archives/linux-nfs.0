Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33308 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162203Ab3DEVIe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 17:08:34 -0400
Date: Fri, 5 Apr 2013 17:08:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
Subject: Re: sunrpc/cache.c: races while updating cache entries
Message-ID: <20130405210830.GA7079@fieldses.org>
References: <d6437a$47jkcm@dgate10u.abg.fsc.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <d6437a$47jkcm@dgate10u.abg.fsc.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 05, 2013 at 05:33:49PM +0200, Bodo Stroesser wrote:
> On 05 Apr 2013 14:40:00 +0100 J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Thu, Apr 04, 2013 at 07:59:35PM +0200, Bodo Stroesser wrote:
> > > There is no reason for apologies. The thread meanwhile seems to be a bit
> > > confusing :-)
> > > 
> > > Current state is:
> > > 
> > > - Neil Brown has created two series of patches. One for SLES11-SP1 and a
> > >   second one for -SP2
> > > 
> > > - AFAICS, the series for -SP2 will match with mainline also.
> > > 
> > > - Today I found and fixed the (hopefully) last problem in the -SP1 series.
> > >   My test using this patchset will run until Monday.
> > > 
> > > - Provided the test on SP1 succeeds, probably on Tuesday I'll start to test
> > >   the patches for SP2 (and mainline). If it runs fine, we'll have a tested
> > >   patchset not later than Mon 15th.
> > 
> > OK, great, as long as it hasn't just been forgotten!
> > 
> > I'd also be curious to understand why we aren't getting a lot of
> > complaints about this from elsewhere....  Is there something unique
> > about your setup?  Do the bugs that remain upstream take a long time to
> > reproduce?
> > 
> > --b.
> > 
> 
> It's no secret, what we are doing. So let me try to explain:

Thanks for the detailed explanation!  I'll look forward to the patches.

--b.

> 
> We build appliances for storage purposes. Each appliance mainly consists of
> a cluster of servers and a bunch of FibreChannel RAID systems. The servers
> of the appliance run SLES11.
> 
> One ore more of the servers in the cluster can act as a NFS server.
> 
> Each NFS server is connected to the RAID systems and has two 10 GBit/s Ethernet
> controllers for the link to the clients.
> 
> The appliance not only offers NFS access for clients, but also has some other
> types of interfaces to be used by the clients.
> 
> For QA of the appliances we use a special test system, that runs the entire
> appliance with all its interfaces under heavy load.
> 
> For the test of the NFS interfaces of the appliance, we connect the Ethernet
> links one by one to 10 GBit/s Ethernet controllers on a linux machine of the
> test system.
> 
> The SW on the test system for each Ethernet link uses 32 TCP connections to the
> NFS server in parallel. 
> 
> So between NFS server of the appliance and linux machine of the test system we
> have two 10 GBit/s links with 32 TCP/RPC/NFS_V3 connections each. Each link
> is running at up to 1 GByte/s throughput (per second and per link a total of
> 32k NFS3_READ or NFS3_WRITE RPCs of 32k data each.)
> 
> Normal Linux-NFS-Clients open only one single connection to a specific NFS
> server, even if there are multiple mounts. We do not use the linux builtin
> client, but create a RPC client by clnttcp_create() and do the NFS handling
> directly. Thus we can have multiple connections and we immediately can
> see if something goes wrong (e.g. if a RPC request is dropped), while the
> builtin linux client probably would do a silent retry. (But probably one
> could see single connections hang for a few minutes sporadically. Maybe
> someone hit by this would complain about the network ...)
> 
> As a side effect of this test setup all 64 connections to the NFS server
> use the same uid/gid and all 32 connections on one link come from the same
> ip address. This - as we know now - maximizes the stress for a single entry
> of the caches.
> 
> With our test setup at the beginning we had more than two dropped RPC request
> per hour and per NFS server. (Of course, this rate varied widely.) With each
> single change in cache.c the rate went down. The latest drop caused by a
> missing detail in the latest patchset for -SP1 occured after more than 2 days
> of testing!
> 
> Thus, to verify the patches I schedule a test for at least 4 days.
> 
> HTH
> Bodo
