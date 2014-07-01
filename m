Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f68.google.com ([209.85.192.68]:34190 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbaGAKlO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 06:41:14 -0400
Received: by mail-qg0-f68.google.com with SMTP id q107so964646qgd.11
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jul 2014 03:41:13 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 1 Jul 2014 06:41:11 -0400
To: Peter Zijlstra <peterz@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Ingo Molnar <mingo@redhat.com>
Subject: Re: [PATCH v3 071/114] lockdep: add lockdep_assert_not_held
Message-ID: <20140701064111.5fe8e555@f20.localdomain>
In-Reply-To: <20140701101108.GK3588@twins.programming.kicks-ass.net>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
 <1404143423-24381-72-git-send-email-jlayton@primarydata.com>
 <20140701100335.GP6758@twins.programming.kicks-ass.net>
 <20140701101108.GK3588@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 1 Jul 2014 12:11:08 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Jul 01, 2014 at 12:03:35PM +0200, Peter Zijlstra wrote:
> > On Mon, Jun 30, 2014 at 11:49:40AM -0400, Jeff Layton wrote:
> > > We currently have the ability to call lockdep_assert_held to throw a
> > > warning when a spinlock isn't held in a codepath. There are also times
> > > when we'd like to throw a warning when a lock is held (i.e. when there
> > > is the potential for deadlock with atomic_dec_and_lock or similar).
> > 
> > So I'm not getting it; if there's deadlock potential, lockdep would
> > already report so, right?
> > 
> > That is, lockdep is very good a yelling when you try to acquire a lock
> > you're already holding.
> 
> Ah, I think I see what you're trying to do.
> 
> You're wanting to use might_lock() and might_lock_read(). Which are used
> to make conditional lock acquisitions unconditional, so as to more
> reliably trigger the deadlock detection.

Right -- in the case of something like atomic_dec_and_lock, we only
take the spinlock if we think the count might go to zero. So, we might
miss catching some places that could deadlock if the refcounts don't go
to zero in the testing we're doing.

might_lock may be what we need, but I don't see any callers of it, and
at a quick glance it doesn't appear to be disabled if debug_locks is
false.

-- 
Jeff Layton <jlayton@primarydata.com>
