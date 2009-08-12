Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59705 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752008AbZHLWdw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Aug 2009 18:33:52 -0400
Date: Wed, 12 Aug 2009 18:32:58 -0400
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        nfsv4@linux-nfs.org
Subject: Re: [PATCH 0/3] Fix the Linux rpc-over-tcp server performance
Message-ID: <20090812223258.GE17782@fieldses.org>
References: <20090518214756.786.28129.stgit@heimdal.trondhjem.org> <20090812024341.GA3227@fieldses.org> <x49ab25w4ja.fsf@segfault.boston.devel.redhat.com> <20090812142041.GA12753@fieldses.org> <x491vnhvucq.fsf@segfault.boston.devel.redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <x491vnhvucq.fsf@segfault.boston.devel.redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 12, 2009 at 01:02:13PM -0400, Jeff Moyer wrote:
> "J. Bruce Fields" <bfields@fieldses.org> writes:
> 
> > On Wed, Aug 12, 2009 at 09:22:17AM -0400, Jeff Moyer wrote:
> >> "J. Bruce Fields" <bfields@fieldses.org> writes:
> >> 
> >> > On Mon, May 18, 2009 at 05:47:56PM -0400, Trond Myklebust wrote:
> >> >> I squashed the previous set of 4 incremental patches into 3. Otherwise
> >> >> there should be no differences w.r.t. the set that Jeff tested.
> >> >
> >> > Apologies for the long delay.... Unfortunately, I can't reproduce any of
> >> > this at all: I reliably get about 112MB/s regardless of what combination
> >> > of these patches I apply (including none).  This is over gigabit
> >> > ethernet to a server exporting a filesystem on raid 0 over 3 sata disks
> >> > which iozone locally reports getting just over 200MB/s reads from.
> >> >
> >> > Any suggestions?
> >> 
> >> Well, you gave me nothing to go on here, Bruce!
> >
> > Apologies for the lack of details....
> 
> No worries.  ;-)
> 
> >> I assume you're using
> >> the deadline I/O scheduler on the NFS server, is that right?  If not,
> >> you should be.
> >
> > Oops, sorry, no. Looks like it doesn't allow setting a scheduler on md0,
> > so I'm assuming I should be setting it on the component drives.
> 
> Right, set the scheduler on the component drives.  I was testing on
> hardware raid, fwiw.

Not much difference in results.  This is frustrating.

For each test, I'm booting both client and server to the given kernel,
running

	mount server:/exports/ /mnt/
	iozone -s 2000000 -r 64 -f /mnt/testfile -w -i1
	umount /mnt/

five times, then taking the average of the "read" columns.  (I could
stick to one client--not sure which you were using.  Installing new
kernels on both is just what my existing test scripts happened to do by
default.)

2.6.30-rc1:				114113
2.6.30-rc1 + revert autotuning:		114159
2.6.30-rc1 + patch 1:			114168
2.6.30-rc1 + patch 1 & 2:		114136
2.6.30-rc1 + patch 1, 2, & 3:		114149

(Where patches 1, 2, 3 are, respectively, "SUNRPC: Fix the TCP server's
send buffer accounting results", "SUNRPC: Fix the TCP write space
reservations for deferred requests", and "Fix svc_tcp_recvfrom()
results", respectively.

And the average-of-5 is pointless, really: the individual results have
very little variation.

See anything obvious I've gotten wrong here?

> Again, let me know if you need me to reproduce this.  It will give me an
> excuse to get back that really nice machine I was using for testing. ;-)

I'd be happiest if I could figure out how to reproduce this myself.

--b.
