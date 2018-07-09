Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48522 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754538AbeGIOZM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Jul 2018 10:25:12 -0400
Date: Mon, 9 Jul 2018 10:25:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Manjunath Patil <manjunath.b.patil@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: return ENOSPC if unable to allocate a session
 slot
Message-ID: <20180709142512.GA17769@fieldses.org>
References: <1529598933-16506-1-git-send-email-manjunath.b.patil@oracle.com>
 <1529598933-16506-2-git-send-email-manjunath.b.patil@oracle.com>
 <20180622175416.GA7119@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180622175416.GA7119@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 22, 2018 at 01:54:16PM -0400, bfields wrote:
> On Thu, Jun 21, 2018 at 04:35:33PM +0000, Manjunath Patil wrote:
> > Presently nfserr_jukebox is being returned by nfsd for create_session
> > request if server is unable to allocate a session slot. This may be
> > treated as NFS4ERR_DELAY by the clients and which may continue to re-try
> > create_session in loop leading NFSv4.1+ mounts in hung state. nfsd
> > should return nfserr_nospc in this case as per rfc5661(section-18.36.4
> > subpoint 4. Session creation).
> 
> I don't think the spec actually gives us an error that we can use to say
> a CREATE_SESSION failed permanently for lack of resources.
> 
> Better would be to avoid the need to fail at all.  Possibilities:
> 
> 	- revive Trond's patches some time back to do dynamic slot size

By the way, I finally got around to reviewing those patches (5 years
late!).  One issue is that they seem to take the slot count requested by
the client at CREATE_SESSION as a lower bound.  And the current client
requests a lot of slots (1024, I think?--this is just from looking at
the code, I should watch a mount).  Anyway, I assume that's not a hard
requirement and that we can fix it.

Also the slot number is driven entirely by the server's guess at what
the client needs--we might also want to take into account whether we're
running out of server resources.

So that still leaves the question of how to cap the total slot memory.

I'm beginning to wonder whether that's a good idea at all.  Perhaps it'd
be better for now just to keep going till kmalloc fails.  There's no
shortage of other ways that a malicious client could DOS the server
anyway.

I'll probably forward-port and repost Trond's patches some time in the
next month.

--b.

> 	  renegotiation
> 	- make sure the systems you're testing on already have
> 	  de766e570413 and 44d8660d3bb0 applied.
> 	- further liberalise the limits here: do we need them at all, or
> 	  should we just wait till a kmalloc fails?  Or maybe take a
> 	  hybrid approach?: e.g. allow an arbitrary number of clients
> 	  and only limit slots & slotsizes.
