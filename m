Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41674 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751755Ab0HaTC1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Aug 2010 15:02:27 -0400
Date: Tue, 31 Aug 2010 15:02:17 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Message-ID: <20100831150217.259b9bb6@tlielax.poochiereds.net>
In-Reply-To: <4C7D5117.6050407@RedHat.com>
References: <4C7CF499.5090003@RedHat.com>
	<20100831084323.02a1abf5@corrin.poochiereds.net>
	<4C7D1694.6000708@RedHat.com>
	<20100831111008.157618f4@corrin.poochiereds.net>
	<20100831151342.GA3071@fieldses.org>
	<4C7D1D3B.1030607@RedHat.com>
	<20100831155128.GB3071@fieldses.org>
	<4C7D2A20.1040806@RedHat.com>
	<20100831161547.GD3071@fieldses.org>
	<4C7D3976.8070209@RedHat.com>
	<20100831180745.GA11361@fieldses.org>
	<4C7D5117.6050407@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 31 Aug 2010 14:59:35 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 08/31/2010 02:07 PM, J. Bruce Fields wrote:
> > On Tue, Aug 31, 2010 at 01:18:46PM -0400, Steve Dickson wrote:
> >> I really don't think we need to rip the guts out of 
> >> mountd and exportfs just to remove this one nfsctl() in rpc.nfsd.
> > 
> > I agree.
> > 
> >>> Dropping backwards compatibility may be a reasonable thing to do, but
> >>> it's something that we should be very clear about, and that we should
> >>> put in a patch that does that and nothing else.
> >> So you are talking about doing a complete rewrite of mountd and exportfs
> >> just to take out that one call from rpc.nfsd... I just don't see the
> >> justification... If we are going to do that, let just think about rewriting
> >> all the tools to make the more v4 friendly... something we talked about
> >> at the last bakeathon...
> > 
> > All I'm asking is that any patch which disables support for older
> > kernels (by ceasing to do the nfsctl) be a *separate* patch that clearly
> > states which kernels we're dropping support for.
> Fine. The taking out the nfsclt() and/or the adding of the error check
> on the mount (basically causing nfsclt() to never be called) will be in 
> a separate clearly documented patch.....
> 
> > 
> > Once we decide to drop such support (if we do), that might allow us to
> > rip out a lot of additional code.  That can be done later.
> I agree... 
> 
> steved.

Sounds good -- doing this as two patches makes much more sense.

I think Steve had a good point though -- we should log a message or
something if we tried to mount up /proc/fs/nfsd and it didn't work.
That'll help clue in people that they have a problem and things might
not work as expected.

I'll respin the patch to do that and repost once I've tested it.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
