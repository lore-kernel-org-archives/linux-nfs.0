From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: kernel NULL pointer dereference in rpcb_getport_done (2.6.29.4)
Date: Mon, 10 Aug 2009 19:55:36 -0400
Message-ID: <20090810235536.GA11617@fieldses.org>
References: <20090619225437.GA8472@hostway.ca> <1245527855.5182.33.camel@heimdal.trondhjem.org> <20090621050941.GA17059@hostway.ca> <20090622211126.GA564@hostway.ca> <20090709172739.GG13617@hostway.ca> <20090710223408.GR10700@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
To: Simon Kirby <sim@hostway.ca>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55404 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799AbZHJXzf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Aug 2009 19:55:35 -0400
In-Reply-To: <20090710223408.GR10700@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 10, 2009 at 06:34:08PM -0400, bfields wrote:
> On Thu, Jul 09, 2009 at 10:27:39AM -0700, Simon Kirby wrote:
> > Hello,
> > 
> > It seems this email to Greg Banks is bouncing (no longer works at SGI),
> 
> Yes, I've cc'd his new address.  (But he's on vacation.)
> 
> > and I see git commit 59a252ff8c0f2fa32c896f69d56ae33e641ce7ad is still
> > in HEAD (and still causing problems for our load).
> > 
> > Can somebody else eyeball this, please?  I don't understand enough about
> > this particular change to fix the request latency / queue backlogging
> > that this patch seems to introduce.
> > 
> > It would seem to me that this patch is flawed because svc_xprt_enqueue()
> > is edge-triggered upon the arrival of packets, but the NFS threads
> > themselves cannot then pull another request off of the socket queue. 
> > This patch likely helps with the particular benchmark, but not in our
> > load case where there is a heavy mix of cached and uncached NFS requests.
> 
> That sounds plausible.  I'll need to take some time to look at it.

Looking back at that commit--I'm now confused about how it was meant to
work.  In the case where the woken-up thread is waiting inside of
svc_recv(), ->nwaking doesn't get decremented at all until the request
is processed and svc_recv() is called again--effectively limiting the
number of concurrent requests to 5 per pool, so, if I read the code
correctly, likely to cause problems if your workload would benefit from
lots of requests being able to wait on io simultaneously (e.g. if you
have a large working set and more than 5 spindles per pool).

The nwaking count probably also leaks in some cases (e.g. if a thread
exits?)

I'm inclined to revert the patch and take another look at Greg's
original problem.

--b.
