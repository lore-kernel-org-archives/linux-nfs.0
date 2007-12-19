From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: constrained lockd error handling semantics when lock request
	processing is deferred?
Date: Wed, 19 Dec 2007 00:45:02 -0500
Message-ID: <20071219054502.GB2836@fieldses.org>
References: <170fa0d20712182003n6819645cwc1560b35da210895@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Mike Snitzer <snitzer@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60863 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134AbXLSFpE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Dec 2007 00:45:04 -0500
In-Reply-To: <170fa0d20712182003n6819645cwc1560b35da210895-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 18, 2007 at 11:03:01PM -0500, Mike Snitzer wrote:
> I could be missing something blatantly obvious so please be kind...
> 
> I would like to understand how one _should_ implement ->lock() for a
> filesystem that can't immediately determine that the request would
> result in -EDEADLK or -ENOLCK.  Particularly for deferred SETLKW
> requests.
> 
> That is, the filesystem's ->lock() initially responds with
> -EINPROGRESS but later goes on to fail the request with -EDEADLK or
> -ENOLCK.  The filesystem's call to ->fl_grant() will be made with an
> unsupported 'result'.
> 
> Having reviewed the code in fs/lockd/svclock.c it would seem that it
> was never designed to allow EDEADLK or ENOLCK _after_ nlmsvc_lock()'s
> initial call to vfs_lock_file().
> 
> nlmsvc_grant_deferred() properly handles deferred SETLKW processing
> IFF the result is 0 (aka granted).
> nlmsvc_grant_deferred()'s SETLK processing will at least return
> failures (but they are assumed to be B_TIMED_OUT).
> In the end the real 'result' gets dropped on the floor.
> 
> Why must ->lock() immediately return error (e.g. EDEADLK), otherwise
> it is assumed the request will complete successfully (or timeout in
> the B_QUEUED/SETLK case)?  Seems overly constrained (painfully so for
> SETLKW) when you consider that the whole point of deferred processing
> (via EINPROGRESS and ->fl_grant) is to accomodate filesystems that
> can't respond to a lock request immediately.

Yeah, the assuumption was that we only needed to deal with non-blocking
requests first, under the theory that the blocking case could always be
handled with a deny followed by an eventual grant.  Which, as you point
out, may not ever be coming in the EDEALK or ENOLCK cases.  I'm inclined
to agree it's ugly.

That said, I find it hard to care about the EDEADLK case--deadlock
detection just isn't going to be reliable in the presence of nfs clients
anyway.  And are there really a lot of cases where ENOLCK has to be
returned and where the local filesystem doesn't know that immediately?

But it should probably be rethought anyway.  I'm grateful for any
suggestions (but probably won't be working on this seriously until the
new year).

--b.
