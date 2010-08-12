Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:54955 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822Ab0HLR0t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Aug 2010 13:26:49 -0400
Subject: Re: [PATCH] nfs: lookupcache coherence bugs in WCC update path
 (revised)
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "Patrick J. LoPresti" <lopresti@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <AANLkTi=WzNzq7wKf0qa+VFuOBYy4yW==0QvdKsTQ88+x@mail.gmail.com>
References: <87lj8ckb1e.fsf@patl.com> <8762zgmmer.fsf@patl.com>
	 <1281628195.2873.12.camel@heimdal.trondhjem.org>
	 <AANLkTi=WzNzq7wKf0qa+VFuOBYy4yW==0QvdKsTQ88+x@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 12 Aug 2010 13:26:44 -0400
Message-ID: <1281634004.14329.14.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-08-12 at 10:13 -0700, Patrick J. LoPresti wrote:
> On Thu, Aug 12, 2010 at 8:49 AM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> >
> > This looks less than obviously correct to me.
> 
> I just meant my patch obviously fixes a bug even if you do not believe
> it is the bug I am encountering.  I claim it is "obvious" based on:
> 
> Obvious statement #1:  It is a bug if a directory inode's mtime is
> EVER updated without invalidating the lookup cache, because that
> results in a stale cache that does not know it is stale and can
> persist indefinitely.

Wrong! Not if we _know_ that the mtime was updated due to an action we
took. We don't have to invalidate the lookup cache every time we create
a new dentry: we're quite able to add that dentry in to the cache
ourselves, and we do that.


> Obvious statement #2:  The current nfs_wcc_update_inode() code updates
> the directory inode's mtime without invalidating the lookup cache.
> 
> So the current code would be wrong even if it never created a problem
> in practice.  (Although it does create a problem in practice).

The current code is not wrong.

> > The wcc case is invoked when the ctime/mtime/.... change is known to have occurred due to a file
> > creation/unlink/... from this client. It is a weak cache consistency case.
> >
> > If your client is seeing ENOENT after it created the file itself, then
> > the problem isn't cache coherency, but a bug in the file creation code.
> 
> The client did not create the file itself.

So why is it going through the wcc case, and why does wcc think that the
client created the file?

> The sequence of operations goes like this:
> 
> 1) Client looks up non-existent file, creates negative dentry.
> 2) File is created by a process on the server.
> 3) Something causes the client to update its mtime for the directory
> without invalidating the dentry lookup cache.  (I have not figured out
> exactly what, but I have "caught it in the act"; see below).

Changing the wcc behaviour won't fix this.

> 4) Client incorrectly returns ENOENT when application next attempts to
> access file.
> 
> You may think this is the usual "multiple updates within one second"
> issue.  That is what I thought at first, anyway.  But I know it is
> not, for three reasons...
> 
> First, my server is using XFS, which supports sub-second timestamps.
> 
> Second, I instrumented nfs_update_inode() to record the inode's mtime
> and cache_change_attribute on function entry, then to log a message on
> function return if the inode is a directory whose mtime got updated
> without also updating cache_change_attribute.  Then I reproduced my
> issue.  My new log message appeared precisely in those runs where the
> issue occurred.  (I also instrumented the code to follow the actual
> sequence of events; I can see that the faulty ENOENT is being returned
> because the inode's cache_change_attribute matches the stale dentry's
> d_time.)
> 
> Third, my testing confirms that the issue disappears after I apply my
> patch.  If the problem were the usual "multiple updates in one
> second", or indeed any server-side issue whatsoever, my patch could
> not have fixed it.

Then you need to explain why. As I said, the wcc code path should not be
triggered when the client isn't creating or deleting stuff in the
directory. The WCC is there to tell you that your client and only your
client has changed stuff in the directory since it last revalidated the
mtime.

> Unfortunately, the only test case I have is my real-world application,
> which I cannot share.  It takes ~30 minutes of running to reproduce
> every time, and it only happens on maybe 2/3 of the runs, so it has
> taken me over a week to track this down.  I still do not know the
> exact sequence of operations that causes the problem; I just know it
> really is happening.
> 
> In summary, the current code is "obviously wrong" because it violates
> its own invariants by potentially updating a directory's mtime without
> invalidating its lookup cache.  And it really is happening to me in
> practice.  My patch fixes both the potential problem (which you can
> see for yourself) and the actual problem (for which you have only my
> word).

I disagree.

> Are you unwilling to fix such a bug unless I can provide you a test case?

I can't take the patch as it stands. It is obviously wrong whether or
not it fixes your test case.

I'm happy to accept that there may be a bug, but you're going to have to
investigate further what is happening, and figure out why changing the
WCC code appears to fix the situation.
My hunch is that you are seeing a server bug rather than a client bug
here...

Cheers
  Trond

