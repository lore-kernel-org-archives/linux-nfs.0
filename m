From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: kernel NULL pointer dereference in rpcb_getport_done (2.6.29.4)
Date: Thu, 15 Oct 2009 18:52:38 -0400
Message-ID: <20091015225238.GC11896@fieldses.org>
References: <20090619225437.GA8472@hostway.ca> <1245527855.5182.33.camel@heimdal.trondhjem.org> <20090621050941.GA17059@hostway.ca> <20090622211126.GA564@hostway.ca> <20090709172739.GG13617@hostway.ca> <20090710223408.GR10700@fieldses.org> <20090810235536.GA11617@fieldses.org> <20090811171745.GA31854@hostway.ca> <20091015214638.GA26270@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
To: Simon Kirby <sim@hostway.ca>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38279 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763256AbZJOWwW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Oct 2009 18:52:22 -0400
In-Reply-To: <20091015214638.GA26270@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 15, 2009 at 02:46:38PM -0700, Simon Kirby wrote:
> On Tue, Aug 11, 2009 at 10:17:45AM -0700, Simon Kirby wrote:
> 
> > On Mon, Aug 10, 2009 at 07:55:36PM -0400, J. Bruce Fields wrote:
> > 
> > > Looking back at that commit--I'm now confused about how it was meant to
> > > work.  In the case where the woken-up thread is waiting inside of
> > > svc_recv(), ->nwaking doesn't get decremented at all until the request
> > > is processed and svc_recv() is called again--effectively limiting the
> > > number of concurrent requests to 5 per pool, so, if I read the code
> > > correctly, likely to cause problems if your workload would benefit from
> > > lots of requests being able to wait on io simultaneously (e.g. if you
> > > have a large working set and more than 5 spindles per pool).
> > 
> > Yes, this box is serving about 50 TB of storage space, so there are more
> > than 5 spindles. :)
> > 
> > I can't believe others aren't all complaining about the same problem, but
> > I guess the loads are different.
> > 
> > > I'm inclined to revert the patch and take another look at Greg's
> > > original problem.
> > 
> > I'm inclined to be totally happy with that! :)
> 
> By the way, the original commit for this,
> 59a252ff8c0f2fa32c896f69d56ae33e641ce7ad, still seems to be in the
> kernel.

Apologies, yes, this fell through the cracks.

> Would you like me to make a patch to remove this code?

That would be helpful.

And I think Greg may be back from his travels, so perhaps he'll be able
to comment on it too.

> I suspect it can't just be pulled as-is because the pool stats were
> added later which now export the "overloads-avoided" through
> /proc/fs/nfsd/pool_stats .  I suspect the header is there to make the
> format dynamic (eg: we could kill overloads-avoided) without breaking
> backwards compatibility...?

A line-based instead of column-based format probably would have made it
more likely parsers would get this right.  Hm, I thought 

	http://oss.sgi.com/projects/pcp/

had some code that parsed this?  But a quick "git grep pool_stats" on
the git repo doesn't show me anything.

We could be conservative and just set the field to zero, but it would be
better if the format were flexible--and changing the number of columns
early on might be one way to ensure people know it will be....

Of course, best would be if Greg could explain what we're
misunderstanding about the overload avoidance--perhaps there's a still
a simple bugfix that would make it work for your situation....

> I see overloads-avoided still rising even with SVC_MAX_WAKING set to
> 127 instead of 5.  It seems to happen a lot when storage gets a little
> stuck, but it is probably increasing the latency of other requests that
> could be served from cache.
> 
> Speaking of latency, I was also looking at blktrace output for the
> underlying devices, and it seems like there are cases where knfsd is
> issuing _read_ requests in a way that leave the queue plugged sometimes,
> causing the unplug timer to have to clear it.  I still need to try to
> track this down (see recent linux-btrace thread).

A quick web search failed to turn up that thread for me.--b.
