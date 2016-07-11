Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:53230 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751406AbcGKBU5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Jul 2016 21:20:57 -0400
Date: Mon, 11 Jul 2016 11:20:51 +1000
From: Dave Chinner <david@fromorbit.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Seth Forshee <seth.forshee@canonical.com>,
        Jeff Layton <jlayton@redhat.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: Hang due to nfs letting tasks freeze with locked inodes
Message-ID: <20160711012051.GO12670@dastard>
References: <20160706174655.GD45215@ubuntu-hedt>
 <1467842838.2908.45.camel@redhat.com>
 <20160707235330.GN27480@dastard>
 <20160708124853.GB16921@ubuntu-hedt>
 <F1C12823-0C51-4FEF-BA8E-330A066B086D@primarydata.com>
 <8E320A98-4DA6-49B0-8288-E46A03A899C1@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <8E320A98-4DA6-49B0-8288-E46A03A899C1@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 08, 2016 at 01:05:40PM +0000, Trond Myklebust wrote:
> > On Jul 8, 2016, at 08:55, Trond Myklebust
> > <trondmy@primarydata.com> wrote:
> >> On Jul 8, 2016, at 08:48, Seth Forshee
> >> <seth.forshee@canonical.com> wrote: On Fri, Jul 08, 2016 at
> >> 09:53:30AM +1000, Dave Chinner wrote:
> >>> On Wed, Jul 06, 2016 at 06:07:18PM -0400, Jeff Layton wrote:
> >>>> On Wed, 2016-07-06 at 12:46 -0500, Seth Forshee wrote:
> >>>>> We're seeing a hang when freezing a container with an nfs
> >>>>> bind mount while running iozone. Two iozone processes were
> >>>>> hung with this stack trace.
> >>>>> 
> >>>>> [] schedule+0x35/0x80 [] schedule_preempt_disabled+0xe/0x10
> >>>>> [] __mutex_lock_slowpath+0xb9/0x130 [] mutex_lock+0x1f/0x30
> >>>>> [] do_unlinkat+0x12b/0x2d0 [] SyS_unlink+0x16/0x20 []
> >>>>> entry_SYSCALL_64_fastpath+0x16/0x71
> >>>>> 
> >>>>> This seems to be due to another iozone thread frozen during
> >>>>> unlink with this stack trace:
> >>>>> 
> >>>>> [] __refrigerator+0x7a/0x140 []
> >>>>> nfs4_handle_exception+0x118/0x130 [nfsv4] []
> >>>>> nfs4_proc_remove+0x7d/0xf0 [nfsv4] [] nfs_unlink+0x149/0x350
> >>>>> [nfs] [] vfs_unlink+0xf1/0x1a0 [] do_unlinkat+0x279/0x2d0 []
> >>>>> SyS_unlink+0x16/0x20 [] entry_SYSCALL_64_fastpath+0x16/0x71
> >>>>> 
> >>>>> Since nfs is allowing the thread to be frozen with the inode
> >>>>> locked it's preventing other threads trying to lock the same
> >>>>> inode from freezing. It seems like a bad idea for nfs to be
> >>>>> doing this.
> >>>>> 
> >>>> 
> >>>> Yeah, known problem. Not a simple one to fix though.
> >>> 
> >>> Actually, it is simple to fix.
> >>> 
> >>> <insert broken record about suspend should be using
> >>> freeze_super(), not sys_sync(), to suspend filesystem
> >>> operations>
> >>> 
> >>> i.e. the VFS blocks new operations from starting, and then
> >>> then the NFS client simply needs to implement ->freeze_fs to
> >>> drain all it's active operations before returning. Problem
> >>> solved.
> >> 
> >> No, this won't solve my problem. We're not doing a full
> >> suspend, rather using a freezer cgroup to freeze a subset of
> >> processes. We don't want to want to fully freeze the
> >> filesystem.
> > 
> > …and therein lies the rub. The whole cgroup freezer stuff
> > assumes that you can safely deactivate a bunch of processes that
> > may or may not hold state in the filesystem. That’s
> > definitely not OK when you hold locks etc that can affect
> > processes that lies outside the cgroup (and/or outside the NFS
> > client itself).

Not just locks, but even just reference counts are bad. e.g. just
being suspended with an active write reference to the superblock
will cause the next filesystem freeze to hang waiting for that
reference to drain. In essence, that's a filesystem-wide DOS vector
for anyone using snapshots....

> In case it wasn’t clear, I’m not just talking about VFS
> mutexes here. I’m also talking about all the other stuff, a
> lot of which the kernel has no control over, including POSIX file
> locking, share locks, leases/delegations, etc.

Yeah, freezer base process-granularity suspend just seems like a bad
idea to me...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
