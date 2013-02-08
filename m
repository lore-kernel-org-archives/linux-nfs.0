Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:40822 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760193Ab3BHPme convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2013 10:42:34 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH v3 2/2] nfsd: keep a checksum of the first 256 bytes of request
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130208082706.614035e2@tlielax.poochiereds.net>
Date: Fri, 8 Feb 2013 10:42:20 -0500
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, rees@umich.edu
Message-Id: <F6C70BBF-1B66-4142-A2A3-BFBFAE452807@oracle.com>
References: <1360248701-23963-1-git-send-email-jlayton@redhat.com> <1360248701-23963-3-git-send-email-jlayton@redhat.com> <DF2DA489-3D72-4DBF-8C65-1B7DA9866B63@oracle.com> <20130207130316.0cf29993@corrin.poochiereds.net> <20130208082706.614035e2@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 8, 2013, at 8:27 AM, Jeff Layton <jlayton@redhat.com> wrote:

> On Thu, 7 Feb 2013 13:03:16 -0500
> Jeff Layton <jlayton@redhat.com> wrote:
> 
>> On Thu, 7 Feb 2013 10:51:02 -0500
>> Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>>> 
>>> On Feb 7, 2013, at 9:51 AM, Jeff Layton <jlayton@redhat.com> wrote:
>>> 
>>>> Now that we're allowing more DRC entries, it becomes a lot easier to hit
>>>> problems with XID collisions. In order to mitigate those, calculate the
>>>> crc32 of up to the first 256 bytes of each request coming in and store
>>>> that in the cache entry, along with the total length of the request.
>>> 
>>> I'm happy to see a checksummed DRC finally become reality for the Linux NFS server.
>>> 
>>> Have you measured the CPU utilization impact and CPU cache footprint of performing a CRC computation for every incoming RPC?  I'm wondering if a simpler checksum might be just as useful but less costly to compute.
>>> 
>> 
>> No, I haven't, at least not in any sort of rigorous way. It's pretty
>> negligible on "normal" PC hardware, but I think most intel and amd cpus
>> have instructions for handling crc32. I'm ok with a different checksum,
>> we don't need anything cryptographically secure here. I simply chose
>> crc32 since it has an easily available API, and I figured it would be
>> fairly lightweight.
>> 
> 
> After an abortive attempt to measure this with ftrace, I ended up
> hacking together a patch to just measure the latency of the
> nfsd_cache_csum/_crc functions to get some rough numbers. On my x86_64
> KVM guest, the avg time to calculate the crc32 is ~1750ns. Using IP
> checksums cuts that roughly in half to ~800ns. I'm not sure how best to
> measure the cache footprint however.

Thanks for sorting that, I feel better having a real data point.

> Neither seems terribly significant, especially given the other
> inefficiencies in this code. OTOH, I guess those latencies can add up,
> and I don't see any need to use crc32 over the net/checksum.h routines.
> We probably ought to go with my RFC patch from yesterday.
> 
> This could look very different on other arches too of course, but I
> don't have a test rig for any other arches at the moment.

Going with the IP checksum seems perfectly adequate to me.

Bruce made a good point that it is difficult to know how to test the efficacy of this change.  We don't really know of any especially bad cases that defeat the current DRC, though I know the Red Hat Q/A team likes to use NFS/UDP and they seem to run into problems with some frequency.  Having a chat with Rick Macklem and/or Tom Talpey on this topic might have some value, and likewise perhaps the bug's OP might have some ideas about what test cases they prefer.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




