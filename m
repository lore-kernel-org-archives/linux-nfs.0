Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32011 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030205Ab3BGSDY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2013 13:03:24 -0500
Date: Thu, 7 Feb 2013 13:03:16 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 2/2] nfsd: keep a checksum of the first 256 bytes of
 request
Message-ID: <20130207130316.0cf29993@corrin.poochiereds.net>
In-Reply-To: <DF2DA489-3D72-4DBF-8C65-1B7DA9866B63@oracle.com>
References: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
	<1360248701-23963-3-git-send-email-jlayton@redhat.com>
	<DF2DA489-3D72-4DBF-8C65-1B7DA9866B63@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 7 Feb 2013 10:51:02 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Feb 7, 2013, at 9:51 AM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > Now that we're allowing more DRC entries, it becomes a lot easier to hit
> > problems with XID collisions. In order to mitigate those, calculate the
> > crc32 of up to the first 256 bytes of each request coming in and store
> > that in the cache entry, along with the total length of the request.
> 
> I'm happy to see a checksummed DRC finally become reality for the Linux NFS server.
> 
> Have you measured the CPU utilization impact and CPU cache footprint of performing a CRC computation for every incoming RPC?  I'm wondering if a simpler checksum might be just as useful but less costly to compute.
> 

No, I haven't, at least not in any sort of rigorous way. It's pretty
negligible on "normal" PC hardware, but I think most intel and amd cpus
have instructions for handling crc32. I'm ok with a different checksum,
we don't need anything cryptographically secure here. I simply chose
crc32 since it has an easily available API, and I figured it would be
fairly lightweight.

I originally had hopes of just using the checksum in the TCP/UDP
header, but that's handled in hw by some cards and so isn't available.
There are also things that change during a retransmit (like GSS sequence
numbers), so we can't just scrape those out anyway.

As far as why 256 bytes, we had had a bug opened a while back (by
Oracle, I think), that asked us to add this capability and suggested
200 bytes. I like powers of 2 so I rounded up. We could easily extend
that though by just changing RC_CSUMLEN if we think it's not enough.

-- 
Jeff Layton <jlayton@redhat.com>
