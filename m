Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:33980 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752361AbdLFQk7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Dec 2017 11:40:59 -0500
From: Joshua Watt <jpewhacker@gmail.com>
Message-ID: <1512578456.12038.33.camel@gmail.com>
Subject: Re: [RFC v4 0/9] NFS Force Unmounting
To: Jeff Layton <jlayton@redhat.com>, NeilBrown <neilb@suse.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>, linux-api@vger.kernel.org
Date: Wed, 06 Dec 2017 10:40:56 -0600
In-Reply-To: <1512565420.4048.21.camel@redhat.com>
References: <20171117174552.18722-1-JPEWhacker@gmail.com>
         <1512398194.7031.56.camel@gmail.com>
         <87indksq9q.fsf@notabene.neil.brown.name>
         <1512565420.4048.21.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-12-06 at 08:03 -0500, Jeff Layton wrote:
> On Wed, 2017-12-06 at 10:34 +1100, NeilBrown wrote:
> > On Mon, Dec 04 2017, Joshua Watt wrote:
> > 
> > > On Fri, 2017-11-17 at 11:45 -0600, Joshua Watt wrote:
> > > > Latest attempt at unifying the various constraints for force
> > > > umounting
> > > > NFS servers that have disappeared in a timely manner. Namely:
> > > >   * umount2(..., MNT_FORCE) should not be made stronger, unless
> > > > we
> > > > know
> > > >     this is the final umount()
> > > >   * The "failed server" state should be reversible
> > > >   * The mechanism should be able to "unstick" a sync(2) that is
> > > > stuck
> > > > on
> > > >     an unresponsive server
> > > > 
> > > > I believe the proposal satisfies all of these concerns. There
> > > > are a
> > > > few
> > > > major components to this proposal:
> > > >  1) The umount_begin superblock operation now has a
> > > > corresponding
> > > >     umount_end operation. This is invoked by umount() when
> > > > MNT_FORCE
> > > > is
> > > >     specified (like umount_begin()), but the actual unmount
> > > > failed
> > > > (i.e.
> > > >     the mount is busy).
> > > >  2) Instead of killing all the RPC queued at a single point in
> > > > time,
> > > > the
> > > >     NFS mount now kills all queue RPCs and all RPCs that get
> > > > queued
> > > >     between nfs_umount_begin() and nfs_umount_end(). I believe
> > > > this
> > > > is
> > > >     not a significant change in behavior because there were
> > > > always
> > > > races
> > > >     between queuing RPCs and killing them in
> > > > nfs_umount_begin().
> > > >  3) nfs_umount_end() is *not* called when MNT_DETACH is
> > > > specified.
> > > > This
> > > >     is the indication that the user is done with this mount and
> > > > all
> > > >     RPCs will be killed until the mount finally gets removed.
> > > >  4) The new "transient" mount option prevents sharing
> > > > nfs_clients
> > > >     between multiple superblocks. The only exception to this is
> > > > when
> > > > the
> > > >     kernel does an automatic mount to cross a device boundary
> > > > ("xdev"
> > > >     NFS mount). In this case, the existing code always shares
> > > > the
> > > >     existing nfs_client from parent superblock. The "transient"
> > > > mount
> > > >     option implies "nosharecache", as it doesn't make sense to
> > > > share
> > > >     superblocks if clients aren't shared.
> > > >  5) If the "transient" mount option is specified (and hence the
> > > >     nfs_client is not shared), MNT_FORCE kills all RPCs for the
> > > > entire
> > > >     nfs_client (and all its nfs_servers). This effectively
> > > > enables
> > > > the
> > > >     "burn down the forest" option when combined with
> > > > MNT_DETACH.
> > > > 
> > > > The choice to use MNT_FORCE as the mechanism for triggering
> > > > this
> > > > behavior stems from the desire to unstick sync(2) calls that
> > > > might be
> > > > blocked on a non-responsive NFS server. While it was previously
> > > > discussed to remount with a new mount option to enable this
> > > > behavior,
> > > > this cannot release the blocked sync(2) call because both
> > > > sync_fileystem() and do_remount() lock the struct superblock-
> > > > > s_umount
> > > > 
> > > > reader-writer lock. As such, a remount will block until the
> > > > sync(2)
> > > > finishes, which is undesirable. umount2() doesn't have this
> > > > restriction
> > > > and can unblock the sync(2) call.
> > > > 
> > > > For the most part, all existing behavior is unchanged if the
> > > > "transient"
> > > > option is not specified. umount -f continues to behave as is
> > > > has, but
> > > > umount -fl (see note below) now does a more aggressive kill to
> > > > get
> > > > everything out of there and allow unmounting in a more timely
> > > > manner.
> > > > Note that there will probably be some communication with the
> > > > server
> > > > still, as destruction of the NFS client ID and such will occur
> > > > when
> > > > the
> > > > last reference is removed. If the server is truly gone, this
> > > > can
> > > > result
> > > > in long blocks at that time.
> > > > 
> > > > If it is known at mount time that the server might be
> > > > disappearing,
> > > > it
> > > > should be mounted with "transient". Doing this will allow mount
> > > > -fl
> > > > to
> > > > do a more complete cleanup and prevent all communication with
> > > > the
> > > > server, which should allow a timely cleanup in all cases.
> > > > 
> > > > Notes:
> > > > 
> > > > Until recently, libmount did not allow a detached and lazy
> > > > mount at
> > > > the
> > > > same time. This was recently fixed (see
> > > > https://marc.info/?l=util-linux-ng&m=151000714401929&w=2). If
> > > > you
> > > > want
> > > > to test this, you may need to write a simple test program that
> > > > directly
> > > > calls umount2() with MNT_FORCE | MNT_DETACH.
> > > > 
> > > > Thank you all again for your time and comments,
> > > > Joshua Watt
> > > > 
> > > > Joshua Watt (9):
> > > >   SUNRPC: Add flag to kill new tasks
> > > >   SUNRPC: Expose kill_new_tasks in debugfs
> > > >   SUNRPC: Simplify client shutdown
> > > >   namespace: Add umount_end superblock operation
> > > >   NFS: Kill RPCs for the duration of umount
> > > >   NFS: Add debugfs for nfs_server and nfs_client
> > > >   NFS: Add transient mount option
> > > >   NFS: Don't shared transient clients
> > > >   NFS: Kill all client RPCs if transient
> > > > 
> > > >  fs/namespace.c                 |  22 ++++++-
> > > >  fs/nfs/Makefile                |   2 +-
> > > >  fs/nfs/client.c                |  96
> > > > +++++++++++++++++++++++++--
> > > >  fs/nfs/debugfs.c               | 143
> > > > +++++++++++++++++++++++++++++++++++++++++
> > > >  fs/nfs/inode.c                 |   5 ++
> > > >  fs/nfs/internal.h              |  11 ++++
> > > >  fs/nfs/nfs3client.c            |   2 +
> > > >  fs/nfs/nfs4client.c            |   5 ++
> > > >  fs/nfs/nfs4super.c             |   1 +
> > > >  fs/nfs/super.c                 |  81 ++++++++++++++++++++---
> > > >  include/linux/fs.h             |   1 +
> > > >  include/linux/nfs_fs_sb.h      |   6 ++
> > > >  include/linux/sunrpc/clnt.h    |   1 +
> > > >  include/uapi/linux/nfs_mount.h |   1 +
> > > >  net/sunrpc/clnt.c              |  13 ++--
> > > >  net/sunrpc/debugfs.c           |   5 ++
> > > >  net/sunrpc/sched.c             |   3 +
> > > >  17 files changed, 372 insertions(+), 26 deletions(-)
> > > >  create mode 100644 fs/nfs/debugfs.c
> > > > 
> > > 
> > > Anyone have any comments on this? Sorry fo the churn, it took a
> > > few
> > > tries to get this to where it would work. I also realize I should
> > > have
> > > put all my RFC patchsets in-reply-to each other instead of
> > > starting a
> > > new thread for each one.
> > 
> > The new semantic for MNT_DETACH|MNT_FORCE is interesting.
> > As it was never possible before (from /bin/umount), it should be
> > safe to
> > add a new meaning.
> > The meaning is effectively "detach the filesystem from the
> > namespace and
> > detach the transport from the filesystem", which sounds like it is
> > useful.
> > It is worth highlighting this, and maybe even cc:ing
> > linux-api@vger.kernel.org ... done that.

Full disclosure: It looks like the kernel umount2() syscall always
allowed both to be specified, it was only libmount's umount API (and by
extension the umount(8) command) that didn't allow it in userspace
(unitl I recently changed it). If fact, the umount(8) command in
busybox allows both to be specified, and IIRC there is a comment
expressing some confusion as to why util-linux didn't. 

> > 
> 
> I'm not thrilled with the new flag combo, personally. Given that
> we're
> introducing new behavior here, I think it wouldn't hurt to add a new
> UMOUNT_* flag for this (UMOUNT_NUKE_FROM_ORBIT?).
> 
> That should still give you a -EINVAL when you try to use it on
> kernels
> that don't understand it, and cleanly separates this behavior from
> the
> old flags. Userland umount program would need changes of course, but
> that's not hard.
> 
> Fundamentally, I don't really agree with all the hand-wringing about
> torpedoing other mounts that are using a client that you're going to
> kill off. This is going to be a privileged operation, and I think we
> just need to ensure that it's well-documented and that the admin can
> figure out what mounts will be affected and how.
> 
> > The new umount_end to match umount_begin seems to make sense.  It
> > can
> > replace a racy semantic with a more predictable one, and that is
> > good.
> > As you say, we cannot do anything really useful here with remount
> > as
> > sync can block it by holding ->s_umount.
> > 
> > I'm not sure about the new "transient" option.  It is probably a
> > good
> > idea but I haven't yet wrapped my mind around exactly what it does
> > so I
> > don't want to commit just yet.
> 
> I think fixing this with new mount options is a losing strategy. By
> the
> time you realize you need it, it's too late to add it. NFS has a huge
> entrenched user-base and you'll never get them all to sprinkle this
> new
> mount option in there.

My use case fortunately has the convience of knowing apriori that the
mount option is needed when the filesystem is mounted (*occasionally*,
embedded use cases do simplify things), but I obviously realize that my
use case isn't necessarily what is best for everyone.

> 
> That said, it might work if you can make it take effect on a remount.

I think it could.... the thing that blocks remount from is waiting on a
"stuck" call that is never going to finish and has the struct
superblock->s_umount reader-write lock (specifically sync(2), but maybe
others). You could actually use umount(..., MNT_FORCE) to try and
recover that like so:

 until mount -o remount,transient $MOUNT; do
     umount -f $MOUNT
 done
 umount -fl $MOUNT

I'll play a little devil's advocate to my own patch here and ask why
the above is any better than simply forgoing my patches entirely and
doing:

 until umount -f $MOUNT; do echo "Retry"; done

Technically speaking the difference between these is that the first
only races between processes calling sync(2) and the remount, which the
second races between all NFS calls that make RPC calls and the umount.
In theory a race is a race, but I would guess in practice the second is
much more likely to have to keep retrying than the first.

Honestly, if you are a system admin trying to remove a dead NFS mount,
the second option might be better in many cases. If the umount takes
too long, you can go in and kill processes, cleanup resources, or
whatever might be required to get the mount shutdown. However, there
are use cases (like mine) where having the system administrator step in
to clean up the system isn't an option. On my embedded system, I *know*
this mount can disappear on me at any time, and have decided that
keeping our system responsive is more important than trying a long
recovery processes (that's probably going to fail anyway) to try and
save the data, and we have confidence that our applications can handle
this without requiring drastic things like being killed. As such, I
mount with the "transient" option right away so that my system can
clean up in a timely manner when and if it becomes necessary. I've
effectively made that administrative decision as part of the system
design, but there is currently no mechanism in the kernel that allows
me to enforce it in a sane manner.

Thanks,
Joshua Watt

> 
> My two lumps of copper and nickel.
