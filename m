Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:34239 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbcGGK3j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2016 06:29:39 -0400
Received: by mail-qk0-f178.google.com with SMTP id t127so10329879qkf.1
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jul 2016 03:29:38 -0700 (PDT)
Message-ID: <1467887375.3195.12.camel@redhat.com>
Subject: Re: Hang due to nfs letting tasks freeze with locked inodes
From: Jeff Layton <jlayton@redhat.com>
To: Seth Forshee <seth.forshee@canonical.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho.andersen@canonical.com>
Date: Thu, 07 Jul 2016 06:29:35 -0400
In-Reply-To: <20160707035534.GF45215@ubuntu-hedt>
References: <20160706174655.GD45215@ubuntu-hedt>
	 <1467842838.2908.45.camel@redhat.com> <20160707035534.GF45215@ubuntu-hedt>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-07-06 at 22:55 -0500, Seth Forshee wrote:
> On Wed, Jul 06, 2016 at 06:07:18PM -0400, Jeff Layton wrote:
> > 
> > On Wed, 2016-07-06 at 12:46 -0500, Seth Forshee wrote:
> > > 
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
> > Yeah, known problem. Not a simple one to fix though.
> > 
> > > 
> > > Can nfs do something different here to prevent this? Maybe use a
> > > non-freezable sleep and let the operation complete, or else abort the
> > > operation and return ERESTARTSYS?
> > The problem with letting the op complete is that often by the time you
> > get to the point of trying to freeze processes, the network interfaces
> > are already shut down. So the operation you're waiting on might never
> > complete. Stuff like suspend operations on your laptop fail, leading to
> > fun bug reports like: "Oh, my laptop burned to crisp inside my bag
> > because the suspend never completed."
> > 
> > You could (in principle) return something like -ERESTARTSYS iff the
> > call has not yet been transmitted. If it has already been transmitted,
> > then you might end up sending the call a second time (but not as an RPC
> > retransmission of course). If that call was non-idempotent then you end
> > up with all of _those_ sorts of problems.
> > 
> > Also, -ERESTARTSYS is not quite right as it doesn't always cause the
> > call to be restarted. It depends on the syscall. I think this would
> > probably need some other sort of syscall-restart machinery plumbed in.
> I don't really know much at all about how NFS works, so I hope you don't
> mind indulging me in some questions.
> 
> What happens then if you suspend waiting for an op to complete and then
> resume an hour later? Will it actually succeed or end up returning some
> sort of "timed out" error?
> 

Well, the RPC would likely time out. The RPC engine would then likely
end up retransmitting it. What happens at that point depends on a lot
of different factors -- what sort of call it was and how the server
behaves, whether it's NFSv3 or v4, etc...

If it was an idempotent call or the server still has the reply in its
duplicate reply cache, then everything "just works". If it's non-
idempotent or relies on some now-expired state, then you might get an
error because the same call ended up getting retransmitted or the state
that it relies on is now gone.

> If it's going to be an error (or even likely to be one) could the op
> just be aborted immediately with an error code? It just seems like there
> must be something better than potentially deadlocking the kernel.
> 

Not without breaking "hard" retry semantics. We had discussed at one
point adding a 3rd alternative to hard vs. soft mount options
(squishy?) that would do more or less what you suggest: allow syscalls
to return an error when the task is being frozen. You'd only really
want to do that though if you've already transmitted the call, waited
for a while (several seconds) and didn't get a reply. If the call
hasn't been transmitted yet, then you'd either want to restart the call
from scratch after unfreezing (a'la something like ERESTARTSYS).

-- 
Jeff Layton <jlayton@redhat.com>
