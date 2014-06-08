Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35761 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754847AbaFHS7l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 8 Jun 2014 14:59:41 -0400
Date: Sun, 8 Jun 2014 14:59:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: WARN_ON_ONCE pop with tip of your nfsd-next branch
Message-ID: <20140608185940.GB437@fieldses.org>
References: <20140607215109.3cb5e368@tlielax.poochiereds.net>
 <20140608171723.GA32514@fieldses.org>
 <20140608184436.GA437@fieldses.org>
 <20140608145249.2be6b75c@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140608145249.2be6b75c@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 08, 2014 at 02:52:49PM -0400, Jeff Layton wrote:
> On Sun, 8 Jun 2014 14:44:36 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Sun, Jun 08, 2014 at 01:17:23PM -0400, J. Bruce Fields wrote:
> > > On Sat, Jun 07, 2014 at 09:51:09PM -0400, Jeff Layton wrote:
> > > > Hi Bruce,
> > > > 
> > > > Just a heads up...
> > > > 
> > > > Was doing some testing with a pile of patches (mostly v4 state-related)
> > > > on top of your nfsd-next branch, and saw this pop:
> > > 
> > > Do you know exactly was the commit id of the last commit from my branch?
> > 
> > Also, do you remember what sort of testing it was?
> > 
> > --b.
> 
> The tip was at a676de9e22b4c13c8d4a27289b1f2bcf35dce6dd.

That's kind of old and I already fixed something that I think would have
caused that WARN at that spot.  So I'd recommend not spending any more
time on it and just rebasing.

> It looks like
> maybe you rebased at some point though and now the commit IDs are
> different?

Yeah, apologies, I've been rebasing a lot.

Next time around I think I'm going to advertise separate stable/unstable
branches so at least there's warning which things I'm likely to rebase.

--b.

> To make it pop, I ran fsstress on a v4.1 mount. I think it
> was these options:
> 
>     $ fsstress -d <dir> -n 1000 -p 128
> 
> I'll see if I can make it happen again when I have some time for more
> testing.
> 
> Thanks,
> -- 
> Jeff Layton <jlayton@primarydata.com>
