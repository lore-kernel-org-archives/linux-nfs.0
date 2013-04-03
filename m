Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32967 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758698Ab3DCSgT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 14:36:19 -0400
Date: Wed, 3 Apr 2013 14:36:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
Subject: Re: sunrpc/cache.c: races while updating cache entries
Message-ID: <20130403183612.GD6044@fieldses.org>
References: <61eb00$3hon1j@dgate20u.abg.fsc.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <61eb00$3hon1j@dgate20u.abg.fsc.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 21, 2013 at 05:41:35PM +0100, Bodo Stroesser wrote:
> On 21 Mar 2013 00:34:00 +0100 NeilBrown <neilb@suse.de> wrote:
> > This applies only to SLES11-SP1 (2.6.32+) right?
> > In mainline the request won't be dropped because the cache item isn't assumed
> > to still be valid.
> 
> I agree, there will be no drop in mainline.
> 
> But in mainline there will be a useless upcall. That upcall might even be
> processed by the reader, if cache_clean isn't faster then the reader.
> The answer from the reader will again replace the current cache entry
> (which is just a few microseconds old) by a new one. The new one must be
> allocated, the replaced one must later be cleaned. The single item cache
> is invalidated again.
> 
> In worst case, the unnecessary replacement also could trigger the next
> round of the game ...
> 
> So in my opinion it would be better to add the patch you suggested below
> to mainline also.
> 
> > 
> > So we need to make sure that sunrpc_cache_pipe_upcall doesn't make an upcall
> > on a cache item that has been replaced.  I'd rather not use the CACHE_CLEAN
> > bit (whether renamed or not) as it has a well defined meaning "has been
> > removed from cache" and I'd rather not blur that meaning.
> > We already have a state that means "this has been replace"- ->expiry_time is
> > 0.
> > So how about adding
> >    if (h->expiry_time == 0)
> >          return -EAGAIN;
> > to sunrpc_cache_pipe_upcall() in SLES11-SP1.
> > 
> > Does that work for you?
> 
> Yes, that looks good. My test with this fix is running successfully
> since 5 hours. I'll let it run until Monday.

Apologies, I've completely lost track of this thread: do we know what
mainline needs now?

--b.
