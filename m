Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34335 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946647Ab3BHP5H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2013 10:57:07 -0500
Date: Fri, 8 Feb 2013 10:57:01 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, rees@umich.edu
Subject: Re: [PATCH v3 2/2] nfsd: keep a checksum of the first 256 bytes of
 request
Message-ID: <20130208105701.61ca0c34@tlielax.poochiereds.net>
In-Reply-To: <F6C70BBF-1B66-4142-A2A3-BFBFAE452807@oracle.com>
References: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
	<1360248701-23963-3-git-send-email-jlayton@redhat.com>
	<DF2DA489-3D72-4DBF-8C65-1B7DA9866B63@oracle.com>
	<20130207130316.0cf29993@corrin.poochiereds.net>
	<20130208082706.614035e2@tlielax.poochiereds.net>
	<F6C70BBF-1B66-4142-A2A3-BFBFAE452807@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 8 Feb 2013 10:42:20 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Feb 8, 2013, at 8:27 AM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Thu, 7 Feb 2013 13:03:16 -0500
> > Jeff Layton <jlayton@redhat.com> wrote:
> > 
> >> On Thu, 7 Feb 2013 10:51:02 -0500
> >> Chuck Lever <chuck.lever@oracle.com> wrote:
> >> 
> >>> 
> >>> On Feb 7, 2013, at 9:51 AM, Jeff Layton <jlayton@redhat.com> wrote:
> >>> 
> >>>> Now that we're allowing more DRC entries, it becomes a lot easier to hit
> >>>> problems with XID collisions. In order to mitigate those, calculate the
> >>>> crc32 of up to the first 256 bytes of each request coming in and store
> >>>> that in the cache entry, along with the total length of the request.
> >>> 
> >>> I'm happy to see a checksummed DRC finally become reality for the Linux NFS server.
> >>> 
> >>> Have you measured the CPU utilization impact and CPU cache footprint of performing a CRC computation for every incoming RPC?  I'm wondering if a simpler checksum might be just as useful but less costly to compute.
> >>> 
> >> 
> >> No, I haven't, at least not in any sort of rigorous way. It's pretty
> >> negligible on "normal" PC hardware, but I think most intel and amd cpus
> >> have instructions for handling crc32. I'm ok with a different checksum,
> >> we don't need anything cryptographically secure here. I simply chose
> >> crc32 since it has an easily available API, and I figured it would be
> >> fairly lightweight.
> >> 
> > 
> > After an abortive attempt to measure this with ftrace, I ended up
> > hacking together a patch to just measure the latency of the
> > nfsd_cache_csum/_crc functions to get some rough numbers. On my x86_64
> > KVM guest, the avg time to calculate the crc32 is ~1750ns. Using IP
> > checksums cuts that roughly in half to ~800ns. I'm not sure how best to
> > measure the cache footprint however.
> 
> Thanks for sorting that, I feel better having a real data point.
> 

Me too -- thanks for raising the question.

> > Neither seems terribly significant, especially given the other
> > inefficiencies in this code. OTOH, I guess those latencies can add up,
> > and I don't see any need to use crc32 over the net/checksum.h routines.
> > We probably ought to go with my RFC patch from yesterday.
> > 
> > This could look very different on other arches too of course, but I
> > don't have a test rig for any other arches at the moment.
> 
> Going with the IP checksum seems perfectly adequate to me.
> 

Agreed.

> Bruce made a good point that it is difficult to know how to test the efficacy of this change.  We don't really know of any especially bad cases that defeat the current DRC, though I know the Red Hat Q/A team likes to use NFS/UDP and they seem to run into problems with some frequency.  Having a chat with Rick Macklem and/or Tom Talpey on this topic might have some value, and likewise perhaps the bug's OP might have some ideas about what test cases they prefer.
> 

It is difficult to know since XID collisions are so rare (or at least
we think so). When they do happen they're often not noticeable, but we
do have some documented cases of it happening in the field...

RH's QA team does test with NFS/UDP but I'm not aware of any problems
with XID collisions, per-se. The problems they've had are that the DRC
sometimes just plain doesn't work. Based on some testing we've done
internally, I think the problem is likely due to the fact that it's
trivial to blow out the current fixed-size DRC cache. Until I backport
this and get them to deploy it onto our test NFS servers though, it's
going to be hard to know for certain.

I decided to add in the extra checksumming for 3 main reasons:

1) I was in here anyway, and it didn't seem too tough to do

2) the potential for xid collisions will be greater with a larger DRC

3) we've had people request it in the past

Given that it seems fairly cheap to add this, we might as well do it.

-- 
Jeff Layton <jlayton@redhat.com>
