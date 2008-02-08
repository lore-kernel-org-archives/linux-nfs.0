From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs new_cache mechanism and older kernel
Date: Thu, 7 Feb 2008 22:42:22 -0500
Message-ID: <20080208034222.GB7117@fieldses.org>
References: <DDFD17CC94A9BD49A82147DDF7D545C5798775@exchange.ZeugmaSystems.local> <18347.42555.441287.802490@notabene.brown> <DDFD17CC94A9BD49A82147DDF7D545C57987CF@exchange.ZeugmaSystems.local> <18347.44054.920429.277506@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anirban Sinha <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:57504 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758075AbYBHDm3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 22:42:29 -0500
In-Reply-To: <18347.44054.920429.277506-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 08, 2008 at 12:10:46PM +1100, Neil Brown wrote:
> On Thursday February 7, ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org wrote:
> > 
> > Yeah, not sure if it would make any difference. I think one of them is
> > the wall clock time (do_gettimeofday) and the xtime is the monotonic
> > time. One can be obtained from other by adding/subtracting an offset
> > value (wall_to_monotonic or something like that) if I recall correctly.
> > Why not use the same time value for both cases (if you think it could be
> > if some remote significance).
> 
> They probably should use the same value - I wasn't previously aware
> there was a difference.... something for Bruce's todo list :-) (but
> not for Bruce to do...)

I know nothing about time.  I suppose for proc/../flush to be a
reasonable user interface the time source used should be something that
makes sense to userland?

Looks like the number nfs-utils uses in
support/nfs/cacheio.c:cache_flush() is either returned from time() or is
the mtime of /var/lib/nfs/etab.

--b.

> 
> >  
> > > 
> > > It is normal for exportfs to completely flush the in-kernel cache.
> > > Subsequent NFS requests will then cause an upcall to mountd which will
> > > add the required information to the cache.
> > 
> > I am wondering ... if it completely flushes the in-kernel cache as its
> > happening in my case, shouldn't the clients who have already mounted
> > their nfs filesystem, lose their mounts? In our case, we are mounting
> > the root fs through nfs and the moment it flushes the cache, the clients
> > become dead. If they happen to resend their mount request, will it not,
> > in that case, involve mountd? Please enlighten me. 
> 
> When an NFS request arrives and the cache doesn't contain enough
> information to accept or reject it, a message is sent to mountd (via
> /proc/net/rpc/XXX/channel) to ask that the information in the cache be
> filled in.  mountd does the appropriate checks and replies with the
> required information.
> 
> If this isn't happening for you, then something is wrong with
> mountd...
> 
> I assume you have checked that mountd is still running, so my best
> guess is that mountd was started *before* the 'nfsd' filesystem was
> mounted.  It needs to be started afterwards.
> 
> Just kill mountd, restart it, and see what happens.
> 
> NeilBrown
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
