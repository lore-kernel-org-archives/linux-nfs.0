Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8572 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753473Ab3BHN1Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2013 08:27:16 -0500
Date: Fri, 8 Feb 2013 08:27:06 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, rees@umich.edu
Subject: Re: [PATCH v3 2/2] nfsd: keep a checksum of the first 256 bytes of
 request
Message-ID: <20130208082706.614035e2@tlielax.poochiereds.net>
In-Reply-To: <20130207130316.0cf29993@corrin.poochiereds.net>
References: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
	<1360248701-23963-3-git-send-email-jlayton@redhat.com>
	<DF2DA489-3D72-4DBF-8C65-1B7DA9866B63@oracle.com>
	<20130207130316.0cf29993@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 7 Feb 2013 13:03:16 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Thu, 7 Feb 2013 10:51:02 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> > 
> > On Feb 7, 2013, at 9:51 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > > Now that we're allowing more DRC entries, it becomes a lot easier to hit
> > > problems with XID collisions. In order to mitigate those, calculate the
> > > crc32 of up to the first 256 bytes of each request coming in and store
> > > that in the cache entry, along with the total length of the request.
> > 
> > I'm happy to see a checksummed DRC finally become reality for the Linux NFS server.
> > 
> > Have you measured the CPU utilization impact and CPU cache footprint of performing a CRC computation for every incoming RPC?  I'm wondering if a simpler checksum might be just as useful but less costly to compute.
> > 
> 
> No, I haven't, at least not in any sort of rigorous way. It's pretty
> negligible on "normal" PC hardware, but I think most intel and amd cpus
> have instructions for handling crc32. I'm ok with a different checksum,
> we don't need anything cryptographically secure here. I simply chose
> crc32 since it has an easily available API, and I figured it would be
> fairly lightweight.
> 

After an abortive attempt to measure this with ftrace, I ended up
hacking together a patch to just measure the latency of the
nfsd_cache_csum/_crc functions to get some rough numbers. On my x86_64
KVM guest, the avg time to calculate the crc32 is ~1750ns. Using IP
checksums cuts that roughly in half to ~800ns. I'm not sure how best to
measure the cache footprint however.

Neither seems terribly significant, especially given the other
inefficiencies in this code. OTOH, I guess those latencies can add up,
and I don't see any need to use crc32 over the net/checksum.h routines.
We probably ought to go with my RFC patch from yesterday.

This could look very different on other arches too of course, but I
don't have a test rig for any other arches at the moment.

-- 
Jeff Layton <jlayton@redhat.com>
