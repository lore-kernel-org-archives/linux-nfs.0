Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54029 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbcD2H6P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Apr 2016 03:58:15 -0400
Date: Fri, 29 Apr 2016 08:58:12 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: parallel lookups on NFS
Message-ID: <20160429075812.GY25498@ZenIV.linux.org.uk>
References: <20160424023453.GK25498@ZenIV.linux.org.uk>
 <1461501975.5219.40.camel@poochiereds.net>
 <20160424191835.GL25498@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160424191835.GL25498@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 24, 2016 at 08:18:35PM +0100, Al Viro wrote:

> What we get out of that is fully parallel lookup/readdir/sillyunlink - all
> exclusion is on per-name basis (nfs_prime_dcache() vs. nfs_lookup() vs.
> nfs_do_call_unlink()).  It will require a bit of care in atomic_open(),
> though...
> 
> I'll play with that a bit and see what can be done...

OK, a bunch of atomic_open cleanups (moderately tested) +
almost untested sillyunlink patch are in vfs.git#untested.nfs.

It ought to make lookups (and readdir, and !O_CREAT case of atomic_open)
on NFS really execute in parallel.  Folks, please hit that sucker with
NFS torture tests.  In particular, the stuff mentioned in commit
565277f6 would be interesting to try.
