Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:38192 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753394AbcGGXxv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2016 19:53:51 -0400
Date: Fri, 8 Jul 2016 09:53:30 +1000
From: Dave Chinner <david@fromorbit.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Seth Forshee <seth.forshee@canonical.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: Hang due to nfs letting tasks freeze with locked inodes
Message-ID: <20160707235330.GN27480@dastard>
References: <20160706174655.GD45215@ubuntu-hedt>
 <1467842838.2908.45.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1467842838.2908.45.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 06, 2016 at 06:07:18PM -0400, Jeff Layton wrote:
> On Wed, 2016-07-06 at 12:46 -0500, Seth Forshee wrote:
> > We're seeing a hang when freezing a container with an nfs bind mount while
> > running iozone. Two iozone processes were hung with this stack trace.
> > 
> >  [] schedule+0x35/0x80
> >  [] schedule_preempt_disabled+0xe/0x10
> >  [] __mutex_lock_slowpath+0xb9/0x130
> >  [] mutex_lock+0x1f/0x30
> >  [] do_unlinkat+0x12b/0x2d0
> >  [] SyS_unlink+0x16/0x20
> >  [] entry_SYSCALL_64_fastpath+0x16/0x71
> > 
> > This seems to be due to another iozone thread frozen during unlink with
> > this stack trace:
> > 
> >  [] __refrigerator+0x7a/0x140
> >  [] nfs4_handle_exception+0x118/0x130 [nfsv4]
> >  [] nfs4_proc_remove+0x7d/0xf0 [nfsv4]
> >  [] nfs_unlink+0x149/0x350 [nfs]
> >  [] vfs_unlink+0xf1/0x1a0
> >  [] do_unlinkat+0x279/0x2d0
> >  [] SyS_unlink+0x16/0x20
> >  [] entry_SYSCALL_64_fastpath+0x16/0x71
> > 
> > Since nfs is allowing the thread to be frozen with the inode locked it's
> > preventing other threads trying to lock the same inode from freezing. It
> > seems like a bad idea for nfs to be doing this.
> > 
> 
> Yeah, known problem. Not a simple one to fix though.

Actually, it is simple to fix.

<insert broken record about suspend should be using freeze_super(),
not sys_sync(), to suspend filesystem operations>

i.e. the VFS blocks new operations from starting, and then then the
NFS client simply needs to implement ->freeze_fs to drain all it's
active operations before returning. Problem solved.

> > Can nfs do something different here to prevent this? Maybe use a
> > non-freezable sleep and let the operation complete, or else abort the
> > operation and return ERESTARTSYS?
> 
> The problem with letting the op complete is that often by the time you
> get to the point of trying to freeze processes, the network interfaces
> are already shut down. So the operation you're waiting on might never
> complete. Stuff like suspend operations on your laptop fail, leading to
> fun bug reports like: "Oh, my laptop burned to crisp inside my bag
> because the suspend never completed."

Yup, precisely the sort of problems we've had over the past 10 years
with XFS because we do lots of stuff aynchronously in the background
(just like NFS) and hence sys_sync() isn't sufficient to quiesce a
filesystem's operations.

But I'm used to being ignored on this topic (for almost 10 years,
now!). Indeed, it's been made clear in the past that I know
absolutely nothing about what is needed to be done to safely
suspend filesystem operations...  :/

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
