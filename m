From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 5/5] nfsd: just keep single lockd reference for nfsd
 (try #4)
Date: Fri, 23 Jul 2010 08:55:29 -0400
Message-ID: <20100723125528.GB20839@fieldses.org>
References: <1279718501-6834-1-git-send-email-jlayton@redhat.com>
 <20100721201437.GD28123@fieldses.org>
 <20100721232432.GA6689@fieldses.org>
 <20100722134026.62091dc2@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52113 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757709Ab0GWM4S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jul 2010 08:56:18 -0400
In-Reply-To: <20100722134026.62091dc2-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 22, 2010 at 01:40:26PM -0400, Jeff Layton wrote:
> On Wed, 21 Jul 2010 19:24:32 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Jul 21, 2010 at 04:14:37PM -0400, J. Bruce Fields wrote:
> > > (Incremental on top of your last patch, with some noise due to moving
> > > stuff around to avoid forward references.  I'll clean these up and
> > > resend.)
> > > 
> > > Then we could also get rid of some of the individual flags (nfs4_init at
> > > least), I think.
> > 
> > Here's what I'm thinking of applying.  (Lightly tested.)
> > 
> 
> I gave them some basic smoke testing and looked them over and they seem
> to be ok. Unfortunately, I don't really have an exhaustive test for
> this sort of thing, but it does seem to fix the problem that
> was originally reported to me.

I also experimented a little with bringing nfs and rpcbind up and down
and didn't see any problems.

Applied for 2.6.36.

--b.
