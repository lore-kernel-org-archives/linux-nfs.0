Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34190 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755174AbcGHMsz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 08:48:55 -0400
Received: by mail-oi0-f42.google.com with SMTP id s66so59500431oif.1
        for <linux-nfs@vger.kernel.org>; Fri, 08 Jul 2016 05:48:55 -0700 (PDT)
Date: Fri, 8 Jul 2016 07:48:53 -0500
From: Seth Forshee <seth.forshee@canonical.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: Hang due to nfs letting tasks freeze with locked inodes
Message-ID: <20160708124853.GB16921@ubuntu-hedt>
References: <20160706174655.GD45215@ubuntu-hedt>
 <1467842838.2908.45.camel@redhat.com>
 <20160707235330.GN27480@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20160707235330.GN27480@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 08, 2016 at 09:53:30AM +1000, Dave Chinner wrote:
> On Wed, Jul 06, 2016 at 06:07:18PM -0400, Jeff Layton wrote:
> > On Wed, 2016-07-06 at 12:46 -0500, Seth Forshee wrote:
> > > We're seeing a hang when freezing a container with an nfs bind mount while
> > > running iozone. Two iozone processes were hung with this stack trace.
> > > 
> > >  [] schedule+0x35/0x80
> > >  [] schedule_preempt_disabled+0xe/0x10
> > >  [] __mutex_lock_slowpath+0xb9/0x130
> > >  [] mutex_lock+0x1f/0x30
> > >  [] do_unlinkat+0x12b/0x2d0
> > >  [] SyS_unlink+0x16/0x20
> > >  [] entry_SYSCALL_64_fastpath+0x16/0x71
> > > 
> > > This seems to be due to another iozone thread frozen during unlink with
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
> > > Since nfs is allowing the thread to be frozen with the inode locked it's
> > > preventing other threads trying to lock the same inode from freezing. It
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

No, this won't solve my problem. We're not doing a full suspend, rather
using a freezer cgroup to freeze a subset of processes. We don't want to
want to fully freeze the filesystem.

Thanks,
Seth

