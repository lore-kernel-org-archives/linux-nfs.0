Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f67.google.com ([209.85.192.67]:37688 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757761AbaGALKo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 07:10:44 -0400
Received: by mail-qg0-f67.google.com with SMTP id f51so976105qge.2
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jul 2014 04:10:43 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 1 Jul 2014 07:10:41 -0400
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, Ingo Molnar <mingo@redhat.com>
Subject: Re: [PATCH v3 071/114] lockdep: add lockdep_assert_not_held
Message-ID: <20140701071041.7cc9f9fa@f20.localdomain>
In-Reply-To: <20140701110718.GT3213@twins.programming.kicks-ass.net>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
	<1404143423-24381-72-git-send-email-jlayton@primarydata.com>
	<20140701100335.GP6758@twins.programming.kicks-ass.net>
	<20140701101108.GK3588@twins.programming.kicks-ass.net>
	<20140701064111.5fe8e555@f20.localdomain>
	<20140701110718.GT3213@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 1 Jul 2014 13:07:18 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Jul 01, 2014 at 06:41:11AM -0400, Jeff Layton wrote:
> > Right -- in the case of something like atomic_dec_and_lock, we only
> > take the spinlock if we think the count might go to zero. So, we might
> > miss catching some places that could deadlock if the refcounts don't go
> > to zero in the testing we're doing.
> > 
> > might_lock may be what we need, but I don't see any callers of it, 
> 
> might_fault()
>   might_lock_read(&current->mm->mmap_sem)
> 
> I'm not sure we have others; but this is the one I remember providing
> this for.
> 
> > and
> > at a quick glance it doesn't appear to be disabled if debug_locks is
> > false.
> 
> The whole of lockdep gets killed, and that would include the
> lock_acquire/lock_release used to implement these.

Ok, good. Let's just drop this patch then and I'll plan to use
might_lock instead of this call.

Thanks!
-- 
Jeff Layton <jlayton@primarydata.com>
