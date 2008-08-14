From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] knfsd: allocate readahead cache in individual chunks
Date: Thu, 14 Aug 2008 15:11:26 -0400
Message-ID: <1218741086.7328.24.camel@localhost>
References: <1218679407-11364-1-git-send-email-jlayton@redhat.com>
	 <20080814180635.GC23859@fieldses.org>
	 <20080814145227.15efe087@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:48037 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753410AbYHNTLe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2008 15:11:34 -0400
In-Reply-To: <20080814145227.15efe087-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-08-14 at 14:52 -0400, Jeff Layton wrote:
> 1) do what I did here (individual kmalloc for each raparm)
> 
> 2) do an allocation of an raparms array for each hash bucket, but when
> we get to larger thread counts, these will still require multi-page
> allocations:
> 
> 8192 threads * 2 / 16 buckets * 72 bytes = 73728 byte allocation
> 
> 3) declare a separate slabcache for this and allocate each raparm
> individually from that
> 
> ...#3 might be reasonable, but we could end up wasting even more memory
> that way when we only have a few threads. Tough call...

How about
  4) Set an upper cap on the size of the raparm array

Readahead is only useful in moderation. You don't want to reach a
situation where the various threads' readahead activities start causing
thrashing...

Cheers
  Trond

