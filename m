Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50134 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754593AbcHBVew (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 17:34:52 -0400
Date: Tue, 2 Aug 2016 16:38:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 0/4] nfsd: add CB_NOTIFY_LOCK support
Message-ID: <20160802203820.GF15324@fieldses.org>
References: <1470161731-11301-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1470161731-11301-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 02, 2016 at 02:15:27PM -0400, Jeff Layton wrote:
> A small set of patches that should add CB_NOTIFY_LOCK support for knfsd.
> The basic idea is to use FL_SLEEP to set blocks when a lock is contended,
> and then queue a callback to issue a CB_NOTIFY_LOCK in the lm_notify op.
> 
> Per the RFC, we take no steps to reserve the lock for the client. This is
> a simple notification to tell the client that it may want to poll for it
> again.
> 
> It also takes steps to clean out old, abandoned blocks when the client
> loses interest in obtaining the lock.

I had to double-check the spec language here: ok, 5661 9.6 does
explicitly say that clients can't depend on the notify, so they do need
to continue polling--so that cleanup doesn't risk leaving clients
blocking indefinitely.  Might be worth a comment referencing that
language.

Looks like you're not attempting any sort of fair queueing, so clients
that get a notify just race for the lock?  That's fine.

Thanks for looking at this!

--b.

> 
> Only lightly tested so far, but it seems to do the right thing.
> The client-side piece is the next step.
> 
> Jeff Layton (4):
>   nfsd: plumb in a CB_NOTIFY_LOCK operation
>   nfsd: have nfsd4_lock use blocking locks for v4.1+ locks
>   nfsd: add a LRU list for blocked locks
>   nfsd: set the MAY_NOTIFY_LOCK flag in OPEN replies
> 
>  fs/nfsd/netns.h           |   1 +
>  fs/nfsd/nfs4callback.c    |  57 +++++++++++++
>  fs/nfsd/nfs4state.c       | 209 ++++++++++++++++++++++++++++++++++++++++++----
>  fs/nfsd/state.h           |  21 ++++-
>  fs/nfsd/xdr4cb.h          |   9 ++
>  include/uapi/linux/nfs4.h |   5 +-
>  6 files changed, 281 insertions(+), 21 deletions(-)
> 
> -- 
> 2.7.4
