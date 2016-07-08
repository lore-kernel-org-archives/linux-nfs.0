Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:36764 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754191AbcGHLdX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 07:33:23 -0400
Received: by mail-qk0-f180.google.com with SMTP id 82so36022180qko.3
        for <linux-nfs@vger.kernel.org>; Fri, 08 Jul 2016 04:33:22 -0700 (PDT)
Message-ID: <1467977599.24149.32.camel@redhat.com>
Subject: Re: Hang due to nfs letting tasks freeze with locked inodes
From: Jeff Layton <jlayton@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Seth Forshee <seth.forshee@canonical.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho.andersen@canonical.com>
Date: Fri, 08 Jul 2016 07:33:19 -0400
In-Reply-To: <20160707235330.GN27480@dastard>
References: <20160706174655.GD45215@ubuntu-hedt>
 <1467842838.2908.45.camel@redhat.com> <20160707235330.GN27480@dastard>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-07-08 at 09:53 +1000, Dave Chinner wrote:
> On Wed, Jul 06, 2016 at 06:07:18PM -0400, Jeff Layton wrote:
> > On Wed, 2016-07-06 at 12:46 -0500, Seth Forshee wrote:
> > > We're seeing a hang when freezing a container with an nfs bind
> > > mount while
> > > running iozone. Two iozone processes were hung with this stack
> > > trace.
> > > 
> > >  [] schedule+0x35/0x80
> > >  [] schedule_preempt_disabled+0xe/0x10
> > >  [] __mutex_lock_slowpath+0xb9/0x130
> > >  [] mutex_lock+0x1f/0x30
> > >  [] do_unlinkat+0x12b/0x2d0
> > >  [] SyS_unlink+0x16/0x20
> > >  [] entry_SYSCALL_64_fastpath+0x16/0x71
> > > 
> > > This seems to be due to another iozone thread frozen during
> > > unlink with
> > > this stack trace:
> > > 
> > >  [] __refrigerator+0x7a/0x140
> > >  [] nfs4_handle_exception+0x118/0x130 [nfsv4]
> > >  [] nfs4_proc_remove+0x7d/0xf0 [nfsv4]
> > >  [] nfs_unlink+0x149/0x350 [nfs]
> > >  [] vfs_unlink+0xf1/0x1a0
> > >  [] do_unlinkat+0x279/0x2d0
> > >  [] SyS_unlink+0x16/0x20
> > >  [] entry_SYSCALL_64_fastpath+0x16/0x71
> > > 
> > > Since nfs is allowing the thread to be frozen with the inode
> > > locked it's
> > > preventing other threads trying to lock the same inode from
> > > freezing. It
> > > seems like a bad idea for nfs to be doing this.
> > > 
> > 
> > Yeah, known problem. Not a simple one to fix though.
> 
> Actually, it is simple to fix.
> 
> <insert broken record about suspend should be using freeze_super(),
> not sys_sync(), to suspend filesystem operations>
> 
> i.e. the VFS blocks new operations from starting, and then then the
> NFS client simply needs to implement ->freeze_fs to drain all it's
> active operations before returning. Problem solved.
> 

Not a bad idea. In the case of NFS though, I'm not sure we'd actually
do anything different than what we're doing though. Part of the problem
is that by the time 

FWIW, we already have CONFIG_SUSPEND_SKIP_SYNC. It might be worth
experimenting with a CONFIG_SUSPEND_FREEZE_FS that does what you
suggest?

> > > Can nfs do something different here to prevent this? Maybe use a
> > > non-freezable sleep and let the operation complete, or else abort
> > > the
> > > operation and return ERESTARTSYS?
> > 
> > The problem with letting the op complete is that often by the time
> > you
> > get to the point of trying to freeze processes, the network
> > interfaces
> > are already shut down. So the operation you're waiting on might
> > never
> > complete. Stuff like suspend operations on your laptop fail,
> > leading to
> > fun bug reports like: "Oh, my laptop burned to crisp inside my bag
> > because the suspend never completed."
> 
> Yup, precisely the sort of problems we've had over the past 10 years
> with XFS because we do lots of stuff aynchronously in the background
> (just like NFS) and hence sys_sync() isn't sufficient to quiesce a
> filesystem's operations.
> 

Yeah, adding a freeze_fs operation for NFS (and using that during
suspend) sounds reasonable at first blush. I can probably trawl the
archives to better understand, but what are the arguments against doing
that? Is it just that freeze_fs is relatively new and the
suspend/resume subsystems haven't caught up?

> But I'm used to being ignored on this topic (for almost 10 years,
> now!). Indeed, it's been made clear in the past that I know
> absolutely nothing about what is needed to be done to safely
> suspend filesystem operations...  :/
> 
> Cheers,
> 
> Dave.
-- 

Jeff Layton <jlayton@redhat.com>
