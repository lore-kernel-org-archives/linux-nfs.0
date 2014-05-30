Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44334 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525AbaE3Vz0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 May 2014 17:55:26 -0400
Date: Fri, 30 May 2014 17:55:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Live lock in silly-rename.
Message-ID: <20140530215522.GA27615@fieldses.org>
References: <20140529164521.02324559@notabene.brown>
 <CAHQdGtTtU9_zBcfzRb_wmEf7XaX9rNg-_Q85ZLX9BYax14D2Gg@mail.gmail.com>
 <20140530075135.753fb7ed@notabene.brown>
 <20140530004423.GA13746@fieldses.org>
 <20140530134442.5a8e5983@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140530134442.5a8e5983@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 30, 2014 at 01:44:42PM +1000, NeilBrown wrote:
> On Thu, 29 May 2014 20:44:23 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > Yes, it's a known server bug.
> > 
> > As a first attempt I was thinking of just sticking a timestamp in struct
> > inode to record the time of the most recent conflicting access and deny
> > delegations if the timestamp is too recent, for some definition of too
> > recent.
> > 
> 
> Hmmm... I'll have a look next week and see what I can come up with.

Thanks!

If we didn't think it was worth another struct inode field, we could
probably get away with global state.  Even just refusing to give out any
delegations for a few seconds after any delegation break would be enough
to fix this bug.

Or you could make it a little less harsh with a small hash table: "don't
give out a delegation on any inode whose inode number hashes to X for a
few seconds."

As long as the delegations can be turned down at the whim of the server,
we've got a lot of leeway.

--b.
