Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:36734 "EHLO
	mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755856AbcHBV1R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Aug 2016 17:27:17 -0400
Received: by mail-qt0-f175.google.com with SMTP id 52so131726245qtq.3
        for <linux-nfs@vger.kernel.org>; Tue, 02 Aug 2016 14:25:44 -0700 (PDT)
Message-ID: <1470173140.15226.16.camel@redhat.com>
Subject: Re: [RFC PATCH 0/4] nfsd: add CB_NOTIFY_LOCK support
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 02 Aug 2016 17:25:40 -0400
In-Reply-To: <20160802203820.GF15324@fieldses.org>
References: <1470161731-11301-1-git-send-email-jlayton@redhat.com>
	 <20160802203820.GF15324@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-08-02 at 16:38 -0400, J. Bruce Fields wrote:
> On Tue, Aug 02, 2016 at 02:15:27PM -0400, Jeff Layton wrote:
> > 
> > A small set of patches that should add CB_NOTIFY_LOCK support for knfsd.
> > The basic idea is to use FL_SLEEP to set blocks when a lock is contended,
> > and then queue a callback to issue a CB_NOTIFY_LOCK in the lm_notify op.
> > 
> > Per the RFC, we take no steps to reserve the lock for the client. This is
> > a simple notification to tell the client that it may want to poll for it
> > again.
> > 
> > It also takes steps to clean out old, abandoned blocks when the client
> > loses interest in obtaining the lock.
> 
> I had to double-check the spec language here: ok, 5661 9.6 does
> explicitly say that clients can't depend on the notify, so they do need
> to continue polling--so that cleanup doesn't risk leaving clients
> blocking indefinitely.  Might be worth a comment referencing that
> language.
> 

Yep, exactly. This is 100% a best-effort kind of thing. The clients
have to poll regardless of whether we send a notification.

> > Looks like you're not attempting any sort of fair queueing, so clients
> that get a notify just race for the lock?  That's fine.
> 

Yep. I don't think that we can reasonably do anything more
sophisticated. Hopefully the delay between callbacks will be enough to
prevent the herd from thundering too badly.

> > Thanks for looking at this!
> 
> --b.
> 

No problem. It has been on my to-do list for a while now...

> > 
> > 
> > Only lightly tested so far, but it seems to do the right thing.
> > The client-side piece is the next step.
> > 
> > Jeff Layton (4):
> >   nfsd: plumb in a CB_NOTIFY_LOCK operation
> >   nfsd: have nfsd4_lock use blocking locks for v4.1+ locks
> >   nfsd: add a LRU list for blocked locks
> >   nfsd: set the MAY_NOTIFY_LOCK flag in OPEN replies
> > 
> >  fs/nfsd/netns.h           |   1 +
> >  fs/nfsd/nfs4callback.c    |  57 +++++++++++++
> >  fs/nfsd/nfs4state.c       | 209 ++++++++++++++++++++++++++++++++++++++++++----
> >  fs/nfsd/state.h           |  21 ++++-
> >  fs/nfsd/xdr4cb.h          |   9 ++
> >  include/uapi/linux/nfs4.h |   5 +-
> >  6 files changed, 281 insertions(+), 21 deletions(-)
> > 
> > -- 
> > 2.7.4

-- 
Jeff Layton <jlayton@redhat.com>
