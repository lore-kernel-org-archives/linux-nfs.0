Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47773 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089Ab0HLRsi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Aug 2010 13:48:38 -0400
In-Reply-To: <1281634004.14329.14.camel@heimdal.trondhjem.org>
References: <87lj8ckb1e.fsf@patl.com>
	<8762zgmmer.fsf@patl.com>
	<1281628195.2873.12.camel@heimdal.trondhjem.org>
	<AANLkTi=WzNzq7wKf0qa+VFuOBYy4yW==0QvdKsTQ88+x@mail.gmail.com>
	<1281634004.14329.14.camel@heimdal.trondhjem.org>
Date: Thu, 12 Aug 2010 10:48:35 -0700
Message-ID: <AANLkTiktMP5ceibYN3fuCw5FGdh0indDssGoQ1SWL6QE@mail.gmail.com>
Subject: Re: [PATCH] nfs: lookupcache coherence bugs in WCC update path (revised)
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 12, 2010 at 10:26 AM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
>
> Wrong! Not if we _know_ that the mtime was updated due to an action we
> took. We don't have to invalidate the lookup cache every time we create
> a new dentry: we're quite able to add that dentry in to the cache
> ourselves, and we do that.

OK, now I see.  That is the purpose of the "atomic update" checks;
i.e., seeing whether the ctime/mtime on the inode equals the
pre_ctime/pre_mtime in the fattr.

> I'm happy to accept that there may be a bug, but you're going to have to
> investigate further what is happening, and figure out why changing the
> WCC code appears to fix the situation.

Well, I know why my change fixes it:  Because that code path is
updating the mtime in the inode to a value that matches the mtime on
the server even though the dentry lookup cache is actually out of
date.

However, it could have become out of date much earlier...  And then
subsequent operations from the client "know" they are the ones
updating the mtime, thus preserving the stale cache indefinitely.

In other words, once my lookup cache gets into this bad state, it will
stay that way until some other client (or the server) updates the
directory.  My patch flushes the cache even for operations that
originate on the client itself, thus working around the bug without
fixing it.

> My hunch is that you are seeing a server bug rather than a client bug
> here...

Yeah, assuming the "atomic action" logic is correct, I agree.

This also explains why the problem is so hard to reproduce.  In my
application, the client checks for the existence of the file at almost
exactly the same time it is being created on the server.  This may
well be triggering a race in the server that violates the atomicity
guarantees of NFS WCC.  And once the cache becomes stale on my client,
it stays that way in spite of additional client-side directory
modifications.

Thank you for the quick replies.  Obviously I need to investigate further.

 - Pat
