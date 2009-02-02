From: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Tue, 03 Feb 2009 08:11:58 +1030
Message-ID: <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au>
	 <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 60-242-66-41.static.tpgi.com.au ([60.242.66.41]:38713 "EHLO
	sibyl.beware.dropbear.id.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759492AbZBBVmI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2009 16:42:08 -0500
In-Reply-To: <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-02-02 at 12:00 -0500, Chuck Lever wrote:
> On Jan 31, 2009, at 10:45 PM, Ian Dall wrote:
> > The following patch is relative to 2.6.29-rc3. The crux of the  
> > matter is
> > that sock_addr structures can't be reliably compared using memcmp()
> > because there are padding bytes in the structure which can't be
> > guaranteed to be the same even when the sock_addr structures refer to
> > the same thing.
> >
> > There have been significant changes to the way address comparison is
> > done in client.c since my original patch (Kernel Bug Tracker #11061,
> > comment 19). In particular ipv4 addresses are now mapped to ipv6
> > addresses for comparison (but only if the kernel is configured for
> > IPV6). The conditional compilation blocks were quite big and contained
> > duplication. Adding my changes in their original style would have only
> > made matters worse. So I have taken to opportunity to clean up. By
> > inverting the logic, I was able to reduce the depth of nested ifs,
> > reduce the number of trivial helper functions and reduce the size of  
> > the
> > conditional compilation blocks. This is a mater of opinion of course,
> > but I think the result is cleaner and easier to read and maintain.
> >
> > This has been tested with kernels configured with and without IPV6.
> 
> As far as I can tell, this is only an issue in nfs_match_client(), so  
> there isn't any need to rewrite the other pieces.

True. and I can do it that way easily enough if that is more acceptable.
However I felt it better to keep all the address comparison code with
the switches on sa_family and compilation conditional on CONFIG_IPV6 etc
together. That way it is less likely that something gets fixed in one
place and not another and easier to add more network address types,
should that be necessary at some time down the track. Also, there would
be a lack of symmetry in that nfs_match_client would then need to "know"
about the details of a sock_addr, whereas nfs_find_client and
nfs_find_client_next can treat the sockaddr as an opaque object. Small
points perhaps.


-- 
Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

