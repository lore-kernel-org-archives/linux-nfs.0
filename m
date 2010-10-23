Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42393 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755568Ab0JWDcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 23:32:52 -0400
Date: Fri, 22 Oct 2010 23:32:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Cc: linux-nfs@vger.kernel.org, neilb@suse.de
Subject: Re: "xprt" reference count drops to 0
Message-ID: <20101023033250.GA24630@fieldses.org>
References: <4C7E4469.70807@duchatelet.net>
 <4CAAE046.5060209@bull.net>
 <20101021203801.GA12038@fieldses.org>
 <4CC1A722.4060907@bull.net>
 <20101022212007.GB22837@fieldses.org>
 <20101022230111.GC22837@fieldses.org>
 <20101022232133.GD22837@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101022232133.GD22837@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Oct 22, 2010 at 07:21:33PM -0400, J. Bruce Fields wrote:
> On Fri, Oct 22, 2010 at 07:01:12PM -0400, J. Bruce Fields wrote:
> > On Fri, Oct 22, 2010 at 05:20:07PM -0400, J. Bruce Fields wrote:
> > > On Fri, Oct 22, 2010 at 05:00:50PM +0200, Menyhart Zoltan wrote:
> > > > J. Bruce Fields wrote:
> > > > >On Tue, Oct 05, 2010 at 10:22:30AM +0200, Menyhart Zoltan wrote:
> > > > >>Due to some race conditions, the reference count can become 0
> > > > >>while "xprt" is still on a "pool":
> > > > >
> > > > >Apologies, your email got buried in my inbox....
> > > > >
> > > > >>
> > > > >>WARNING: at lib/kref.c:43 kref_get+0x23/0x2d()
> > > > >>  [] kref_get+0x23/0x2d
> > > > >>  [] svc_xprt_get+0x12/0x14 [sunrpc]
> > > > >>  [] svc_recv+0x2db/0x78a [sunrpc]
> > > > >
> > > > >Which kernel exactly did you see this on?  Is it reproduceable?
> > > > 
> > > > I saw it on a 2.6.32.
> > > > It has not been corrected for the 2.6.36-rc3 yet.

Doh.  Wait, when you say "has not been corrected on 2.6.36-rc3", do you
mean you've actually *seen* the problem occur on 2.6.36-rc3?

If not, it's more likely you're seeing the problem that was fixed by
1b644b6e6f6160ae35ce4b52c2ca89ed3e356e18, in 2.6.34-rc1.

--b.
