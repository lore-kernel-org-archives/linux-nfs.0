Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52557 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772Ab1KBLnS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Nov 2011 07:43:18 -0400
Date: Wed, 2 Nov 2011 07:42:57 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Tejun Heo <tj@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Steve French <sfrench@samba.org>, linux-kernel@vger.kernel.org,
        linux-pm@vger.kernel.org, linux-cifs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH] freezer: revert 27920651fe "PM / Freezer: Make
 fake_signal_wake_up() wake TASK_KILLABLE tasks too"
Message-ID: <20111102074257.7174691c@tlielax.poochiereds.net>
In-Reply-To: <20111101215710.GA13803@google.com>
References: <20111101005505.GO18855@google.com>
	<20111101041337.39077229@tlielax.poochiereds.net>
	<20111101065958.50addab5@tlielax.poochiereds.net>
	<20111101163059.GR18855@google.com>
	<20111101175953.GB5358@redhat.com>
	<20111101180601.GV18855@google.com>
	<20111101181329.GA6739@redhat.com>
	<20111101182753.GW18855@google.com>
	<20111101193923.GA9444@redhat.com>
	<20111101194601.GB9444@redhat.com>
	<20111101215710.GA13803@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 1 Nov 2011 14:57:10 -0700
Tejun Heo <tj@kernel.org> wrote:

> Hey, Oleg.
> 
> On Tue, Nov 01, 2011 at 08:46:01PM +0100, Oleg Nesterov wrote:
> > On 11/01, Oleg Nesterov wrote:
> > >
> > > Or we can add TASK_FREEZABLE (like TASK_WAKEKILL), iirc we already
> > > discussed this some time ago. And probably it makes sense to add the
> > > generic wait_event_state().
> > 
> > Forgot to mention. I think that before anything else we need
> > signal_wake_up_state(). For example, note that none of the callers
> > of signal_wake_up(resume => true) in ptrace code wants to wake up
> > the killable task.
> 
> Yeah, agreed for both wait_event_state() and signal_wake_up_state().
> For now, let's go with the count/dont_count.  Can you please write up
> a patch for that?  Jeff, does this seem okay to you?
> 

Let me make sure I understand since I don't have a great grasp of the
freezer internals...

This will set the PF_FREEZER_SKIP flag on the task, which prevents
try_to_freeze_tasks from incrementing the "todo" var for this process
and should let the suspend proceed.

So this really makes try_to_freeze_tasks set PF_FREEZING on the task,
but not get upset that it doesn't actually call try_to_freeze().

Is that sufficient for a process that's just sleeping here?

If so, guess I'll need to respin the NFS/RPC patches for this to do
something similar around the sleeps there since they don't use
wait_event_*.

> For TASK_FREEZABLE, I'm not entirely sure.  Combined with
> wait_event_state(), it can definitely reduce the number of different
> variants of wait_event_*().  Let's see.
> 

wait_event_state() sounds like a wonderful idea regardless of what we
do here.

-- 
Jeff Layton <jlayton@redhat.com>
