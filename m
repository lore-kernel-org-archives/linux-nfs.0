Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32356 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752115Ab1GGASB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2011 20:18:01 -0400
Subject: Re: [RFC] sunrpc:  Fix race between work-queue and
 rpc_killall_tasks.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Ben Greear <greearb@candelatech.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 06 Jul 2011 20:17:59 -0400
In-Reply-To: <4E14F8C4.2010508@candelatech.com>
References: <1309992581-25199-1-git-send-email-greearb@candelatech.com>
	 <1309995932.5447.6.camel@lade.trondhjem.org>
	 <4E14F8C4.2010508@candelatech.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1309997879.5447.12.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-06 at 17:07 -0700, Ben Greear wrote: 
> On 07/06/2011 04:45 PM, Trond Myklebust wrote:
> > On Wed, 2011-07-06 at 15:49 -0700, greearb@candelatech.com wrote:
> >> From: Ben Greear<greearb@candelatech.com>
> >>
> >> The rpc_killall_tasks logic is not locked against
> >> the work-queue thread, but it still directly modifies
> >> function pointers and data in the task objects.
> >>
> >> This patch changes the killall-tasks logic to set a flag
> >> that tells the work-queue thread to terminate the task
> >> instead of directly calling the terminate logic.
> >>
> >> Signed-off-by: Ben Greear<greearb@candelatech.com>
> >> ---
> >>
> >> NOTE:  This needs review, as I am still struggling to understand
> >> the rpc code, and it's quite possible this patch either doesn't
> >> fully fix the problem or actually causes other issues.  That said,
> >> my nfs stress test seems to run a bit more stable with this patch applied.
> >
> > Yes, but I don't see why you are adding a new flag, nor do I see why we
> > want to keep checking for that flag in the rpc_execute() loop.
> > rpc_killall_tasks() is not a frequent operation that we want to optimise
> > for.
> 
> I was hoping that if the killall logic never set anything that was also
> set by the work-queue thread it would be lock-safe without needing
> explicit locking.
> 
> I was a bit concerned that my flags |= KILLME logic would potentially
> over-write flags that were being simultaneously written elsewhere
> (so maybe I'd have to add a completely new variable for that KILLME flag
> to really be safe.)
> 
> >
> > How about the following instead?
> 
> I think it still races..more comments below.
> 
> >
> > 8<----------------------------------------------------------------------------------
> >  From ecb7244b661c3f9d2008ef6048733e5cea2f98ab Mon Sep 17 00:00:00 2001
> > From: Trond Myklebust<Trond.Myklebust@netapp.com>
> > Date: Wed, 6 Jul 2011 19:44:52 -0400
> > Subject: [PATCH] SUNRPC: Fix a race between work-queue and rpc_killall_tasks
> >
> > Since rpc_killall_tasks may modify the rpc_task's tk_action field
> > without any locking, we need to be careful when dereferencing it.
> 
> > +		do_action = task->tk_callback;
> > +		task->tk_callback = NULL;
> > +		if (do_action == NULL) {
> 
> I think the race still exists, though it would be harder to hit.
> What if the killall logic sets task->tk_callback right after you assign do_action, but before
> you set tk_callback to NULL?  Or after you set tk_callback to NULL for
> that matter.

What if it does? The rpc call will continue to execute until it
completes.

rpc_killall_tasks is really only useful for signalling to tasks that are
hanging on a completely unresponsive server that we want them to stop.
The only case where we really care is in rpc_shutdown_client(), where we
sleep and loop anyway.

IOW: I really don't care about 'fixing' rpc_killall_tasks to perfection.
All I care about is that it doesn't Oops.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

