Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40195 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752127AbaFKOVE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jun 2014 10:21:04 -0400
Date: Wed, 11 Jun 2014 10:21:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Live lock in silly-rename.
Message-ID: <20140611142102.GB19382@fieldses.org>
References: <20140529164521.02324559@notabene.brown>
 <CAHQdGtTtU9_zBcfzRb_wmEf7XaX9rNg-_Q85ZLX9BYax14D2Gg@mail.gmail.com>
 <20140530075135.753fb7ed@notabene.brown>
 <20140530004423.GA13746@fieldses.org>
 <20140530134442.5a8e5983@notabene.brown>
 <20140530215522.GA27615@fieldses.org>
 <20140531081358.62ae69b3@notabene.brown>
 <20140604173926.53918af3@notabene.brown>
 <20140604220531.GA8362@fieldses.org>
 <20140605103423.43e21569@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140605103423.43e21569@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 05, 2014 at 10:34:23AM +1000, NeilBrown wrote:
> On Wed, 4 Jun 2014 18:05:31 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Wed, Jun 04, 2014 at 05:39:26PM +1000, NeilBrown wrote:
> > > Below is my suggestion.  It seems easy enough.  It even works.
> > 
> > Woah!
> > 
> > Anyway, looks reasonable to me, and it fixes an immediate problem so I'm
> > inclined to just apply.
...
> And if you are going to apply it, you'll want:
> 
>    Signed-off-by: NeilBrown <neilb@suse.de>

Oh, gah, then I forgot to actually apply.

Anyway, it's a reasonably self-contained fix for an important bug so
I'll send it as part of a later bugfix pull request.

I thought it could also use a more explicit description of the resulting
problem, so I added:

	... so further delegations should not be handed out.

	The current code fails to do so, and the result is effectively a
	live-lock under some workloads: a client attempting a
	conflicting operation on a read-delegated file receives
	NFS4ERR_DELAY and retries the operation, but by the time it
	retries the server may already have given out another
	delegation.

--b.
