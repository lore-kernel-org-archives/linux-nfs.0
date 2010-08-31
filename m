Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41154 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754572Ab0HaSIM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Aug 2010 14:08:12 -0400
Date: Tue, 31 Aug 2010 14:07:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Message-ID: <20100831180745.GA11361@fieldses.org>
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
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C7D3976.8070209@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 31, 2010 at 01:18:46PM -0400, Steve Dickson wrote:
> I really don't think we need to rip the guts out of 
> mountd and exportfs just to remove this one nfsctl() in rpc.nfsd.

I agree.

> > Dropping backwards compatibility may be a reasonable thing to do, but
> > it's something that we should be very clear about, and that we should
> > put in a patch that does that and nothing else.
> So you are talking about doing a complete rewrite of mountd and exportfs
> just to take out that one call from rpc.nfsd... I just don't see the
> justification... If we are going to do that, let just think about rewriting
> all the tools to make the more v4 friendly... something we talked about
> at the last bakeathon...

All I'm asking is that any patch which disables support for older
kernels (by ceasing to do the nfsctl) be a *separate* patch that clearly
states which kernels we're dropping support for.

Once we decide to drop such support (if we do), that might allow us to
rip out a lot of additional code.  That can be done later.

--b.
