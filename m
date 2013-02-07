Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48904 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756855Ab3BGQhK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2013 11:37:10 -0500
Date: Thu, 7 Feb 2013 11:37:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 2/2] nfsd: keep a checksum of the first 256 bytes of
 request
Message-ID: <20130207163708.GJ3222@fieldses.org>
References: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
 <1360248701-23963-3-git-send-email-jlayton@redhat.com>
 <DF2DA489-3D72-4DBF-8C65-1B7DA9866B63@oracle.com>
 <20130207160032.GF3222@fieldses.org>
 <7AE3520E-0F1E-4BDF-9977-B110180E99E3@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7AE3520E-0F1E-4BDF-9977-B110180E99E3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 07, 2013 at 11:23:17AM -0500, Chuck Lever wrote:
> 
> On Feb 7, 2013, at 11:00 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Thu, Feb 07, 2013 at 10:51:02AM -0500, Chuck Lever wrote:
> >> 
> >> On Feb 7, 2013, at 9:51 AM, Jeff Layton <jlayton@redhat.com> wrote:
> >> 
> >>> Now that we're allowing more DRC entries, it becomes a lot easier to
> >>> hit problems with XID collisions. In order to mitigate those,
> >>> calculate the crc32 of up to the first 256 bytes of each request
> >>> coming in and store that in the cache entry, along with the total
> >>> length of the request.
> >> 
> >> I'm happy to see a checksummed DRC finally become reality for the
> >> Linux NFS server.
> >> 
> >> Have you measured the CPU utilization impact and CPU cache footprint
> >> of performing a CRC computation for every incoming RPC?
> > 
> > Note this is over the first 256 bytes of the request--which we're
> > probably just about to read for xdr decoding anyway.
> 
> XDR decoding is copying and branching.  Computing a CRC involves real math, which tends to be significantly more expensive than successfully predicted branches, especially on low-power CPUs that might be found in SOHO NAS products.

OK, I wouldn't know.

(I was just responding to the "cache footprint" question--I thought you
were concerned about reading in a bunch of the request.)  Looks like the
biggest piece of the crc32 code is a 1k lookup table?

> >> I'm wondering if a simpler checksum might be just as useful but less
> >> costly to compute.
> > 
> > What would be an example of a simpler checksum?
> 
> The same one TCP uses, like a simple additive sum, or an XOR.  Is a heavyweight checksum needed because checksums generated with a simple function are more likely to collide?
> 
> Not that this should hold up merging Jeff's work!  We can easily tweak or replace the checksum algorithm after it's upstream.  It's not kABI.
> 
> But someone should assess the impact of the additional checksum computation.  CRC seems to me heavier than is needed here.

OK, sure, may be worth looking into.

> Possible tweaks:
> 
> Why 256 bytes?  Is that too much?  Or not enough for some NFSv4
> compounds that might often start with the same data?  Could we, for
> instance, use fewer bytes for NFSv2 and NFSv3?  Or even a variable
> checksum length depending on the NFS operation?  Is 256 bytes enough
> for NFSv4.1, whose compounds always start with the same operation?

NFSv4.1 has the drc turned completely off.

> If integrity or privacy is in play, can we use that information in
> place of a separate DRC checksum?

There's a gss sequence number that's incremented even on resends of the
same rpc, so this doesn't work.  (By design: you don't want an attacker
to be able to replay an old rpc.)

--b.
