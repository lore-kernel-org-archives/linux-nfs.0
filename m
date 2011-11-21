Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754732Ab1KUUip (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Nov 2011 15:38:45 -0500
Date: Mon, 21 Nov 2011 15:36:15 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Tejun Heo <tj@kernel.org>
Cc: rjw@sisk.pl, linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org,
        john@calva.com, trond.myklebust@netapp.com
Subject: Re: [PATCH 1/2] sunrpc: make rpc_wait_bit_killable handle freeze
 events
Message-ID: <20111121153615.7e876801@corrin.poochiereds.net>
In-Reply-To: <20111121175644.GF15314@google.com>
References: <1321897221-2278-1-git-send-email-jlayton@redhat.com>
	<1321897221-2278-2-git-send-email-jlayton@redhat.com>
	<20111121175644.GF15314@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 21 Nov 2011 09:56:44 -0800
Tejun Heo <tj@kernel.org> wrote:

> On Mon, Nov 21, 2011 at 12:40:20PM -0500, Jeff Layton wrote:
> > Allow the freezer to skip wait_on_bit_killable sleeps in the sunrpc
> > layer. This should allow suspend and hibernate events to proceed, even
> > when there are RPC's pending on the wire.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  include/linux/freezer.h |   12 ++++++++++++
> >  net/sunrpc/sched.c      |    3 ++-
> >  2 files changed, 14 insertions(+), 1 deletions(-)
> > 
> > diff --git a/include/linux/freezer.h b/include/linux/freezer.h
> > index a5386e3..8b60dd0 100644
> > --- a/include/linux/freezer.h
> > +++ b/include/linux/freezer.h
> > @@ -135,6 +135,16 @@ static inline void set_freezable_with_signal(void)
> >  }
> >  
> >  /*
> > + * Freezer-friendly macro around schedule() in the kernel.
> > + */
> > +#define freezable_schedule()						\
> > +({									\
> > +	freezer_do_not_count();						\
> > +	schedule();							\
> > +	freezer_count();						\
> 
> Don't we want try_to_freeze() here?  If the freezer thought the task
> was safe to skip, it better stay inside freezer until the freezing
> condition is lifted.
> 
> Thanks.
> 

I suppose you're suggesting something like this?

	freezer_do_not_count();
	if (!try_to_freeze())
		schedule();
	freezer_count();

Hmm, so I guess the concern is that we'd race in such a way that
freezer_count() ends up running after the freezer has already skipped
the task?

If so, that seems just as racy...nothing guarantees that the freeze
event occurs before the try_to_freeze call...

The freezer is not really my forte', but I have to say that the whole
do_not_count scheme seems "sketchy". Would we not be better off with
something closer to the original method that I proposed, along with a
new TASK_WAKEFREEZE state bit? Processes that are sleeping in
uninterruptible sleep that are able to deal with freezer events could
set that bit and fake_signal_wake_up could be changed to also wake
processes with that bit set.

-- 
Jeff Layton <jlayton@redhat.com>
