Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:51735 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210Ab3AHVXu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2013 16:23:50 -0500
Received: by mail-qc0-f181.google.com with SMTP id x40so1109878qcp.12
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jan 2013 13:23:49 -0800 (PST)
Date: Tue, 8 Jan 2013 16:23:43 -0500
From: Chris Perl <chris.perl@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Message-ID: <20130108212343.GC30872@nyc-qws-132.nyc.delacy.com>
References: <20130107185848.GB16957@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91199197E@SACEXCMBX04-PRD.hq.netapp.com>
 <20130107202021.GC16957@nyc-qws-132.nyc.delacy.com>
 <1357590561.28341.11.camel@lade.trondhjem.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911991BE9@SACEXCMBX04-PRD.hq.netapp.com>
 <20130107220047.GA30814@nyc-qws-132.nyc.delacy.com>
 <20130108184011.GA30872@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911993608@SACEXCMBX04-PRD.hq.netapp.com>
 <20130108210106.GB30872@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911993A92@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA911993A92@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 08, 2013 at 09:13:45PM +0000, Myklebust, Trond wrote:
> On Tue, 2013-01-08 at 16:01 -0500, Chris Perl wrote:
> > > My main interest is always the upstream (Linus) kernel, however the RPC
> > > client in the CentOS 6.3 kernel does actually contain a lot of code that
> > > was recently backported from upstream. As such, it is definitely of
> > > interest to figure out corner case bugs so that we can compare to
> > > upstream...
> > 
> > Ok, great.  I will try this version of the patch as well.  However, when just
> > thinking about this, I'm concerned that the race still exists, but is just less
> > likely to manifest.
> > 
> > I imagine something like this happening.  I assume there is some reason this
> > can't happen that I'm not seeing?  These are functions from linus's current
> > git, not the CentOS 6.3 code: 
> > 
> > thread 1                                          thread 2
> > --------                                          --------
> > __rpc_execute                                     __rpc_execute
> > ...                                               ...
> > call_reserve
> > xprt_reserve
> > xprt_lock_and_alloc_slot
> > xprt_lock_write
> > xprt_reserve_xprt
> > ...
> > xprt_release_write
> >                                                   call_reserve
> > 						  xprt_reserve
> > 						  xprt_lock_and_alloc_slot
> > 						  xprt_lock_write
> > 						  xprt_reserve_xprt
> > 						  rpc_sleep_on_priority
> > 						  __rpc_sleep_on_priority
> > 						  __rpc_add_wait_queue
> > 						  __rpc_add_wait_queue_priority
> > 						  (Now on the sending wait queue)
> > xs_tcp_release_xprt
> > xprt_release_xprt
> > xprt_clear_locked
> > __xprt_lock_write_next
> > rpc_wake_up_first
> > __rpc_find_next_queued
> > __rpc_find_next_queued_priority
> > ...
> > (has now pulled thread 2 off the wait queue)
> >                                                  out_of_line_wait_on_bit
> > 						 (receive SIGKILL)
> > 						 rpc_wait_bit_killable
> > 						 rpc_exit
> > 						 rpc_exit_task
> > 						 rpc_release_task
> > 						 (doesn't release xprt b/c he isn't listed in snd_task yet)
> > 						 (returns from __rpc_execute)
> > __xprt_lock_write_func
> > (thread 2 now has the transport locked)
> > rpc_wake_up_task_queue_locked
> > __rpc_remove_wait_queue
> > __rpc_remove_wait_queue_priority
> > (continues on, potentially exiting early,
> >  potentially blocking the next time it needs the transport)
> > 
> > With the patch we're discussing, it would fix the case where thread 2 is
> > breaking out of the FSM loop after having been given the transport lock.  But
> > what about the above.  Is there something else synchronizing things?
> 
> I'm not sure I understand how the above would work. rpc_exit_task() will
> remove the rpc_task from the xprt->sending rpc_wait_queue, at which
> point __xprt_lock_write_func() can no longer find it.

I'm imagining that thread 1 pulls thread 2 off the sending wait queue
almost right after it was added, but before thread 2 has a chance to
execute rpc_exit_task.  Now that thread 1 has a reference to
thread 2, it proceeds to give it the lock on the transport, but before
it does so, thread 2 completely finishes executing and returns from
__rpc_execute.

I'm probably missing something.

> Is it really the same hang? Does 'echo 0 >/proc/sys/sunrpc/rpc_debug'
> show you a similar list of rpc tasks waiting on xprt->sending?

I'm not certain.  Its possible that its not.  I'm recompiling with your
v4 of the patch right now and will test shortly.  I didn't know about
echoing 0 out to that file, good to know! :)

