Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:39728 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933574AbdLRVs5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Dec 2017 16:48:57 -0500
From: Joshua Watt <jpewhacker@gmail.com>
Message-ID: <1513633731.5784.69.camel@gmail.com>
Subject: Re: [RFC v4 0/9] NFS Force Unmounting
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>, linux-api@vger.kernel.org
Date: Mon, 18 Dec 2017 15:48:51 -0600
In-Reply-To: <876099nfiw.fsf@notabene.neil.brown.name>
References: <20171117174552.18722-1-JPEWhacker@gmail.com>
         <1512398194.7031.56.camel@gmail.com>
         <87indksq9q.fsf@notabene.neil.brown.name>
         <1512565420.4048.21.camel@redhat.com>
         <87bmjaq89r.fsf@notabene.neil.brown.name>
         <1513275773.3888.20.camel@gmail.com>
         <876099nfiw.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-12-15 at 08:52 +1100, NeilBrown wrote:
> On Thu, Dec 14 2017, Joshua Watt wrote:
> 
> > On Fri, 2017-12-08 at 13:10 +1100, NeilBrown wrote:
> > > On Wed, Dec 06 2017, Jeff Layton wrote:
> > > 
> > > > On Wed, 2017-12-06 at 10:34 +1100, NeilBrown wrote:
> > > > > 
> > > > > The new semantic for MNT_DETACH|MNT_FORCE is interesting.
> > > > > As it was never possible before (from /bin/umount), it should
> > > > > be
> > > > > safe to
> > > > > add a new meaning.
> > > > > The meaning is effectively "detach the filesystem from the
> > > > > namespace and
> > > > > detach the transport from the filesystem", which sounds like
> > > > > it
> > > > > is
> > > > > useful.
> > > > > It is worth highlighting this, and maybe even cc:ing
> > > > > linux-api@vger.kernel.org ... done that.
> > > > > 
> > > > 
> > > > I'm not thrilled with the new flag combo, personally. Given
> > > > that
> > > > we're
> > > > introducing new behavior here, I think it wouldn't hurt to add
> > > > a
> > > > new
> > > > UMOUNT_* flag for this (UMOUNT_NUKE_FROM_ORBIT?).
> > > 
> > > Suppose we did... MNT_FORCE_PONIES. What would be the semantics
> > > of
> > > this
> > > flag?  Once we had it, would anyone ever want to use MNT_FORCE
> > > again?
> > > 
> > > MNT_FORCE is already fairly heavy handled.  It abort an arbitrary
> > > collections of RPC requests being sent for the given filesystem,
> > > no
> > > matter where else that filesystem might be mounted.
> > > Is it ever safe to use this flag unless you have good reason to
> > > believe
> > > that the server is not available and there is no point pretending
> > > any
> > > more?
> > > And if that is the case, why not use the new MNT_FORCE_PONIES
> > > which
> > > is
> > > at least predictable and reliable.
> > > 
> > > We've talking a lot about the one NFS filesystem being mounted in
> > > multiple containers.  MNT_FORCE is already a problem for such
> > > mounts
> > > as
> > > one contains can kill requests generated from another
> > > container.  Maybe
> > > MNT_FORCE needs to be restricted to "real" root.
> > > Once we restrict it, do we need to keep it from being too harsh?
> > > 
> > > What would be really nice is a timeout for umount, and for sync.
> > > The timeout only starts when the filesystem stops making progress
> > > for
> > > writeback.  If it eventually does timeout, then the caller can
> > > fall
> > > back
> > > to MNT_DETACH if they are in a container, or MNT_FORCE if not.
> > > (Maybe MNT_FORCE should map to MNT_DETACH in a container??? or
> > > maybe
> > > not).
> > > 
> > > There is a lot here that still isn't clear to me, but one this
> > > does
> > > seem
> > > to be becoming clear:  MNT_FORCE as it stands is nearly useless
> > > and
> > > it
> > > would serve is well to find a semantic that it actually useful,
> > > and
> > > impose that.
> > 
> > Trying to keep the discussion going... does anyone else have
> > thoughts
> > on this?
> 
> It's a challenge, isn't it ... keeping people on-task to make forward
> progress.
> If only we could all meet in the canteen at 4pm every Friday and
> discuss
> these things over drinks.  I don't suppose any of the video
> conference
> tools support timeshifting, so we can each do 4pm in our own time
> zone....

Well, you can all come to my house... it might be easier than building
a time machine. I'll provide the beer.

> 
> I would like to arrange that nothing can block indefinitely on
> ->s_umount.  This probably means that the various "flush data" calls
> made under this lock need a timeout, or to be interruptible.
> Then both umount and remount could be sure of getting ->s_umount
> without undue delay.
> Then I would like MNT_FORCE *not* to abort requests before trying to
> get
> the lock, but instead to be passed down to ->kill_sb().
> We probably cannot pass it explicitly, but could set a flag while
> ->s_umount is held.
> This flag might be handled by generic_shutdown_super(), causing
> it to purge any unwritten data, rather than call sync_filesystems().
> 
> This way, if the filesystem is mounted elsewhere, then the MNT_FORCE
> has
> no effect.  If it is a final mount, then it cleans up properly.

> Your need to cause writes to start failing would be achieved by
> performing a remount, either just setting "soft,retrans=0,timeo=1",
> or
> by setting some special-purpose mount option.

Hmm... If I have a mount option that does what I want and remount
doesn't block, what do I need MNT_FORCE for at all? All I would need
from userspace is:

 mount /mnt/nfs -o remount,serverdead
 umount -l /mnt/nfs

I does seem nice to know that this is the last place the superblock is
mounted in ->kill_sb()... But it seems like we replace MNT_FORCE having
consequences on a shared superblock with some mount options that
probably(?) have consequences on a shared superblock (and in the
process, makes MNT_FORCE less useful?). 

> In order for s_umount not to be held indefinite, the generic things
> that
> need to be fixed include:
>  __writeback_inodes_wb() calls writeback_sb_inodes() under the lock.
>     This needs to be interruptible
>  Same for try_to_writeback_inodes_sb() -> __writeback_inodes_sb_nr()
>  sync_sync and do_sync_work call iterate_supers() with various
> handlers, and these need
>  to be interruptible.
> 
> and do_remount_sb needs to not block.
> 
> Finding a way to interrupt those writeback calls would be tricky,
> especially as we need to trigger the interrupt without holding
> s_umount.

I'll look into it more, but I don't think it would be terribly tricky.
AFAIK, rpc_killall_tasks() covers a lot of these cases.

> 
> I really like the idea that an umount attempt would interrupt a
> sync().
> Currently sync() can block indefinitely, which is occasionally
> inconvenient.
> If "umount" (or "umount -f" at least) on a filesystem would abort the
> sync of that filesystem, take the lock and clean up more forcefully,
> that would make for fairly clean shutdown processing.
> 1/ call sync() in a separate thread.
> 2/ wait until Dirty in /proc/meminfo stops changing
> 3/ umount -f every remaining filesystem.  Even if the
>    umount fails, the sync will abort.

Isn't that pretty close to the current behavior? I'm having a bit of
trouble reconciling this with "Then I would like MNT_FORCE *not* to
abort requests before trying to get the lock"... it sort of sounds like
here you *do* want umount (or maybe umount + MNT_FORCE) to abort a
sync()? Or are you trying to say that sync() should *only* be
interrupted in kill_sb()? Would you mind clarifying?

> 
> 
> Part of this effort would require making sure that SIGKILL really
> kills
> processes blocked on filesystem IO.

I get that making sure processes can be killed when blocked on I/O is a
really good thing, but I don't understand why it keeps getting rolled
into what I'm trying to do.... it seems like an orthagonal concern? You
can certianly do "better" force unmounting without having to SIGKILL
processes, and someone could surely make SIGKILL work for all I/O
without having to implement a full force unmount scheme?

I guess more directly.... SIGKILLing a processes isn't necessary (or
really acceptable) for my use case. If I don't do that portion, is that
going to result in rejection of my patches, or am I missing something
important? 

> 
> So:
>  1/ make sure all filesystem IO waits are TASK_KILLABLE
>  2/ find a way to interrupt any write-back wait when there is a
> pending
>     remount or umount.  Possibly the write-back thing would need to
>     retry after the umount/remount, I'm not sure.
>  3/ Cause MNT_FORCE to set a superblock flag, and have
>     generic_shutdown_super() and/or ->kill_sb() interpret this flag
> to
>     be very forceful
>  4/ Possibly introduce new NFS mount option which causes all requests
>     to fail
>  5/ Teach NFS to support remount of this option, and of soft,
> retrans,
>     timeo.
> 
> How does that sound?

All right, let me reiterate where I think you are going with this:

Currently, MNT_FORCE is not particularly useful for actually force
unmounting, since it only cancels RPCs at a single point in time.
However, this would be a useful behavior to have during remount.
Specifically, do_remount_sb() should get this behavior so that any
"stuck" sync() calls that would block it from getting ->s_umount can be
cleaned up in a timely manner. If a sync() was canceled for this
reason, it might need to be restarted after the remount?

Once remount can be done without undue blocking, some combination of
mount options can be used to mark the server as "dead", thereby
preventing long blocking API calls going forward.

Finally, MNT_FORCE can be reworked. Instead of trying to clean things
up so that a mount *might* be able to be unmounted, wait until we
*know* the mount is getting removed (->kill_sb()) and then be agressive
with cleaning up.



I'm not sure if this is really any different than MNT_FORCE_PONIES. Not
that I prefer one mechanism over the other... it just sort of seems
like they are all pretty similar. 

So far we have:

 1) umount with MNT_FORCE_PONIES - Only *real* root can do this, and it
destroys everything

 2) Remount (which won't block) with some "server dead" flag(s), then
umount with MNT_DETACH 

 3) Mount with a flag that optionally makes MNT_FORCE act like
MNT_FORCE_PONIES (e.g. my original proposal with the "transient" mount
flag).

Am I missing any? In all of these mechanism, a superblock mounted in
multiple namespaces get affected in some way. The real difference is
what that change looks like in the other namespaces. In all cases, the
admin doing these actions is going to have to be aware of how these
action affect other namespaces... I don't know if we can save them from
that.

Thanks,
Joshua

> 
> NeilBrown
