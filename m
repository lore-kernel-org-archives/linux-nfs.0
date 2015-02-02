Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f49.google.com ([209.85.215.49]:38179 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964916AbbBBU3e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 15:29:34 -0500
Received: by mail-la0-f49.google.com with SMTP id gf13so44779002lab.8
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 12:29:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
References: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
Date: Mon, 2 Feb 2015 15:29:33 -0500
Message-ID: <CAOg9mSQSW68-aCh529BdJJ-G3xeWGY3NsNoizPu5wNdrZz88vA@mail.gmail.com>
Subject: Re: [PATCH v3 00/13] locks: saner method for managing file locks
From: Mike Marshall <hubcap@omnibond.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Sasha Levin <sasha.levin@oracle.com>,
        David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I applied Jeff's patch to my orangefs-3.19-rc5 tree. Orangefs
doesn't yet support the lock callout for file_operations, but
we have been experimenting with some ideas that would allow
Orangefs to honor locks in our distributed environment: basically
posix locks for each kernel client plus meta data in our userspace
servers.

Anyhow, the lock callout in the Orangefs patch I've posted
just returns ENOSYS. I have added posix locks in a current
test, so now I have:

int pvfs2_lock(struct file *filp, int cmd, struct file_lock *fl)
{
        int rc;

        rc = posix_lock_file(filp, fl, NULL);

        return rc;
}

So... while this isn't safe for our real world distributed environment,
it makes the kernel with this version of the Orangefs kernel client
loaded on it think that locks work.

Besides observing that locks seem to work by running some programs
that need locks (like svn/sqlite) I also ran xfstest generic/131.

Without Jeff's patch, xfstest generic/131 fails:

  29:Verify that F_GETLK for F_WRLCK doesn't require that file be
     opened for write

Same with Jeff's patch.

Jeff's patch applied painlessly, and my simple tests didn't uncover
any problems with Jeff's implementation of separate lists for different
lock types, so that's good.

What surprised me, though, is that the posix lock code failed
to get all the way through xfstest generic/131... maybe you
all knew that already?

-Mike

On Thu, Jan 22, 2015 at 9:27 AM, Jeff Layton
<jeff.layton@primarydata.com> wrote:
> v3:
> - break out a ceph locking cleanup patch into a separate one earlier
>   in the series
> - switch back to using the i_lock to protect assignment of i_flctx.
>   Using cmpxchg() was subject to races that I couldn't quite get a
>   grip on. Eventually I may switch it back, but it probably doesn't
>   provide much benefit.
> - add a patch to clean up some comments that refer to i_flock
> - use list_empty_careful in lockless checks rather than list_empty
>
> v2:
> - bugfix to the flc_posix list ordering that broke the split/merge code
> - don't use i_lock to manage the i_flctx pointer. Do so locklessly
>   via cmpxchg().
> - reordering of the patches to make the set bisectable. As a result
>   the new spinlock is not introduced until near the end of the set
> - some cleanup of the lm_change operation was added, made possible
>   by the move to standard list_heads for tracking locks
> - it takes greater pains to avoid spinlocking by checking when the
>   lists are empty in addition to whether the i_flctx pointer is NULL
> - a patch was added to keep count of the number of locks, so we can
>   avoid having to do count/alloc/populate in ceph and cifs
>
> This is the third iteration of this patchset. The second was posted
> on January 8th, under the cover letter entitled:
>
>     [PATCH v2 00/10] locks: saner method for managing file locks
>
> The big change here is that it once again uses the i_lock to protect the
> i_flctx pointer assignment. In principle we should be able to use
> cmpxchg instead, but that seems leave open a race that causes
> locks_remove_file to miss recently-added locks. Given that is not a
> super latency-sensitive codepath, an extra spinlock shouldn't make much
> difference.
>
> Many thanks to Sasha Levin who helped me nail a race that would leave
> leftover locks on the i_flock list, and David Howells who convinced
> me to just go ahead back to using the i_lock to protect that field.
>
> There are some other minor changes, but overall it's pretty similar
> to the last set. I still plan to merge this for v3.20.
>
> ------------------------[snip]-------------------------
>
> We currently manage all file_locks via a singly-linked list. This is
> problematic for a number of reasons:
>
> - we have to protect all file locks with the same spinlock (or
>   equivalent). Currently that uses the i_lock, but Christoph has voiced
>   objections due to the potential for contention with other i_lock
>   users. He'd like to see us move to using a different lock.
>
> - we have to walk through irrelevant file locks in order to get to the
>   ones we're interested in. For instance, POSIX locks are at the end
>   of the list, so we have to skip over all of the flock locks and
>   leases before we can work with them.
>
> - the singly-linked list is primitive and difficult to work with. We
>   have to keep track of the "before" pointer and it's easy to get that
>   wrong.
>
> Cleaning all of this up is complicated by the fact that no one really
> wants to grow struct inode in order to do so. We have a single pointer
> in the inode now and I don't think we want to use any more.
>
> One possibility that Trond raised was to move this to an hlist, but
> that doesn't do anything about the desire for a new spinlock.
>
> This patchset takes the approach of replacing the i_flock list with a
> new struct file_lock_context that is allocated when we intend to add a
> new file lock to an inode. The file_lock_context is only freed when we
> destroy the inode.
>
> Within that, we have separate (and standard!) lists for each lock type,
> and a dedicated spinlock for managing those lists. In principle we could
> even consider adding separate locks for each, but I didn't bother with
> that for now.
>
> For now, the code is still pretty "raw" and isn't bisectable. This is
> just a RFC for the basic approach. This is probably v3.19 material at
> best.
>
> Anyone have thoughts or comments on the basic approach?
>
> Jeff Layton (13):
>   locks: add new struct list_head to struct file_lock
>   locks: have locks_release_file use flock_lock_file to release generic
>     flock locks
>   locks: add a new struct file_locking_context pointer to struct inode
>   ceph: move spinlocking into ceph_encode_locks_to_buffer and
>     ceph_count_locks
>   locks: move flock locks to file_lock_context
>   locks: convert posix locks to file_lock_context
>   locks: convert lease handling to file_lock_context
>   locks: remove i_flock field from struct inode
>   locks: add a dedicated spinlock to protect i_flctx lists
>   locks: clean up the lm_change prototype
>   locks: keep a count of locks on the flctx lists
>   locks: consolidate NULL i_flctx checks in locks_remove_file
>   locks: update comments that refer to inode->i_flock
>
>  fs/ceph/locks.c      |  64 +++---
>  fs/ceph/mds_client.c |   4 -
>  fs/cifs/file.c       |  34 +--
>  fs/inode.c           |   3 +-
>  fs/lockd/svcsubs.c   |  26 ++-
>  fs/locks.c           | 569 +++++++++++++++++++++++++++------------------------
>  fs/nfs/delegation.c  |  23 ++-
>  fs/nfs/nfs4state.c   |  70 ++++---
>  fs/nfs/pagelist.c    |   6 +-
>  fs/nfs/write.c       |  41 +++-
>  fs/nfsd/nfs4state.c  |  21 +-
>  fs/read_write.c      |   2 +-
>  include/linux/fs.h   |  52 +++--
>  13 files changed, 510 insertions(+), 405 deletions(-)
>
> --
> 2.1.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
