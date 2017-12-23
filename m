Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:41046 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750810AbdLWNQ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 23 Dec 2017 08:16:57 -0500
Message-ID: <1514035013.3425.8.camel@kernel.org>
Subject: Re: [PATCH/RFC] NFS: add nostatflush mount option.
From: Jeff Layton <jlayton@kernel.org>
To: NeilBrown <neilb@suse.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Cc: "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Date: Sat, 23 Dec 2017 08:16:53 -0500
In-Reply-To: <87efnnkda2.fsf@notabene.neil.brown.name>
References: <87k1xgkct1.fsf@notabene.neil.brown.name>
         <4B4DA4D4-8068-4C10-92BE-F03632522C75@oracle.com>
         <1513871689.11836.3.camel@primarydata.com>
         <87efnnkda2.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-12-22 at 07:59 +1100, NeilBrown wrote:
> On Thu, Dec 21 2017, Trond Myklebust wrote:
> 
> > On Thu, 2017-12-21 at 10:39 -0500, Chuck Lever wrote:
> > > Hi Neil-
> > > 
> > > 
> > > > On Dec 20, 2017, at 9:57 PM, NeilBrown <neilb@suse.com> wrote:
> > > > 
> > > > 
> > > > When an i_op->getattr() call is made on an NFS file
> > > > (typically from a 'stat' family system call), NFS
> > > > will first flush any dirty data to the server.
> > > > 
> > > > This ensures that the mtime reported is correct and stable,
> > > > but has a performance penalty.  'stat' is normally thought
> > > > to be a quick operation, and imposing this cost can be
> > > > surprising.
> > > 
> > > To be clear, this behavior is a POSIX requirement.
> > > 
> > > 
> > > > I have seen problems when one process is writing a large
> > > > file and another process performs "ls -l" on the containing
> > > > directory and is blocked for as long as it take to flush
> > > > all the dirty data to the server, which can be minutes.
> > > 
> > > Yes, a well-known annoyance that cannot be addressed
> > > even with a write delegation.
> > > 
> > > 
> > > > I have also seen a legacy application which frequently calls
> > > > "fstat" on a file that it is writing to.  On a local
> > > > filesystem (and in the Solaris implementation of NFS) this
> > > > fstat call is cheap.  On Linux/NFS, the causes a noticeable
> > > > decrease in throughput.
> > > 
> > > If the preceding write is small, Linux could be using
> > > a FILE_SYNC write, but Solaris could be using UNSTABLE.
> > > 
> > > 
> > > > The only circumstances where an application calling 'stat()'
> > > > might get an mtime which is not stable are times when some
> > > > other process is writing to the file and the two processes
> > > > are not using locking to ensure consistency, or when the one
> > > > process is both writing and stating.  In neither of these
> > > > cases is it reasonable to expect the mtime to be stable.
> > > 
> > > I'm not convinced this is a strong enough rationale
> > > for claiming it is safe to disable the existing
> > > behavior.
> > > 
> > > You've explained cases where the new behavior is
> > > reasonable, but do you have any examples where the
> > > new behavior would be a problem? There must be a
> > > reason why POSIX explicitly requires an up-to-date
> > > mtime.
> > > 
> > > What guidance would nfs(5) give on when it is safe
> > > to specify the new mount option?
> > > 
> > > 
> > > > In the most common cases where mtime is important
> > > > (e.g. make), no other process has the file open, so there
> > > > will be no dirty data and the mtime will be stable.
> > > 
> > > Isn't it also the case that make is a multi-process
> > > workload where one process modifies a file, then
> > > closes it (which triggers a flush), and then another
> > > process stats the file? The new mount option does
> > > not change the behavior of close(2), does it?
> > > 
> > > 
> > > > Rather than unilaterally changing this behavior of 'stat',
> > > > this patch adds a "nosyncflush" mount option to allow
> > > > sysadmins to have applications which are hurt by the current
> > > > behavior to disable it.
> > > 
> > > IMO a mount option is at the wrong granularity. A
> > > mount point will be shared between applications that
> > > can tolerate the non-POSIX behavior and those that
> > > cannot, for instance.
> > 
> > Agreed. 
> > 
> > The other thing to note here is that we now have an embryonic statx()
> > system call, which allows the application itself to decide whether or
> > not it needs up to date values for the atime/ctime/mtime. While we
> > haven't yet plumbed in the NFS side, the intention was always to use
> > that information to turn off the writeback flushing when possible.
> 
> Yes, if statx() were actually working, we could change the application
> to avoid the flush.  But then if changing the application were an
> option, I suspect that - for my current customer issue - we could just
> remove the fstat() calls.  I doubt they are really necessary.
> I think programmers often think of stat() (and particularly fstat()) as
> fairly cheap and so they use it whenever convenient.  Only NFS violates
> this expectation.
> 
> Also statx() is only a real solution if/when it gets widely used.  Will
> "ls -l" default to AT_STATX_DONT_SYNC ??
> 

Maybe. Eventually, I could see glibc converting normal stat/fstat/etc.
to use a statx() syscall under the hood (similar to how stat syscalls on
32-bit arches will use stat64 in most cases).

With that, we could look at any number of ways to sneak a "don't flush"
flag into the call. Maybe an environment variable that causes the stat
syscall wrapper to add it? I think there are possibilities there that
don't necessarily require recompiling applications.

> Apart from the Posix requirement (which only requires that the
> timestamps be updated, not that the data be flushed), do you know of any
> value gained from flushing data before stat()?
> 
-- 
Jeff Layton <jlayton@kernel.org>
