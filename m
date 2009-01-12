From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH,RFC] more graceful sunrpc cache updates for HA
Date: Tue, 13 Jan 2009 08:15:11 +1100
Message-ID: <496BB2DF.4030403@melbourne.sgi.com>
References: <496B1A7E.80807@melbourne.sgi.com> <20090112155146.GA24322@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>, NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:59720 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750826AbZALVXR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2009 16:23:17 -0500
In-Reply-To: <20090112155146.GA24322@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Mon, Jan 12, 2009 at 09:25:02PM +1100, Greg Banks wrote:
>   
> So the result is just to give userspace a way to tell the kernel that it
> should start making upcalls without yet dropping the existing cache
> entries?
>   
Precisely.

Also, it's a method with a finer grain than 1 second.  One of my earlier
attempts involved adding an extra flag to the data passed in the
.../flush pseudofile to make the flushing "soft".  One of the problems
this suffered from was that all the logic was working in time_t units.
> I'd like to guarantee that nfsd behavior reflects the updated exports
> by the time exportfs returns.  
This is certainly necessary for the "exportfs -u" case so that "exportfs
-u ; umount" always works.  The patch needs improvement to ensure that. 
I'm not convinced it's strictly necessary for other changes.

> From your description, it doesn't sound
> like you're trying to meet such a guarantee?
We don't have that guarantee now except for the "exportfs -u" case.  The
only synchronisation mechanism that I can see is when exportfs writes to
the cache .../flush pseudofile, which blocks until the cache is
completely flushed.  This technique doesn't wait for new entries to be
filled in by upcalls, so if the change involved adding new exports or
changing the flags on existing exports it will not yet be in effect when
exportfs exits.

> It also might be possible to teach exportfs and/or mountd how to write
> the "diff" between the current kernel exports and the new exports into
> the export cache.
>   
Indeed.  The difficulty there is working out how to synchronise between
two exportfs instances, and how to synchronise between an exportfs
instance and calls from new clients coming in over the wire.
>   
>> a) allow large NFS calls to be deferred, up to the maximum wsize rather
>> than just a page, or
>>
>> b) change call deferral to always block the calling thread instead of
>> using a deferral record and returning -EAGAIN
>>     
>
> Any deferral method sufficient to handle reads and writes already
> requires saving a fair amount of state, so I wonder whether the extra
> overhead just to keep another thread around is worth the trouble of
> avoiding....
>   

Agreed.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

