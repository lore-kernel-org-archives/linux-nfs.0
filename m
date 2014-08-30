Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:59099 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661AbaH3Rgk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Aug 2014 13:36:40 -0400
Date: Sat, 30 Aug 2014 18:36:38 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Peng Tao <tao.peng@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: VFS regression: commit aba809cf0944 breaks MNT_SHRINKABLE
 automounted partitions
Message-ID: <20140830173638.GE7996@ZenIV.linux.org.uk>
References: <CAHQdGtT4kbPqQvD_fu7c_5_CqK8FCpA5mJsVdh=KxoE9_vXRzw@mail.gmail.com>
 <20140829205817.GB7996@ZenIV.linux.org.uk>
 <CAHQdGtRBqmsfeVVysTnTEELHuwiPwvsyTHtoRAsfSS0aSyCbfQ@mail.gmail.com>
 <20140829230147.GD7996@ZenIV.linux.org.uk>
 <CAKVebiWBU3du650yeTMfaFuLr=WLUBc2RukFGyBF6Qgxd6zA8Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiWBU3du650yeTMfaFuLr=WLUBc2RukFGyBF6Qgxd6zA8Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 30, 2014 at 08:38:56AM +0800, Peng Tao wrote:
> On Sat, Aug 30, 2014 at 7:01 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > On Fri, Aug 29, 2014 at 05:47:58PM -0400, Trond Myklebust wrote:
> >
> >> Note that the issue happens with NFSv4 or NFSv4.1 (not NFSv3).
> >
> > That's what I'd been using for testing.
> >
> >> Note that on my system, if I call 'umount' a second time after getting
> >> the 'device is busy' error, then it succeeds. It looks as if the first
> >> call to 'umount /mnt' causes the directory /mnt/export to clear,
> >> causing the second 'umount /mnt' to succeeed (unless I try to access
> >> /mnt/export again):
> Just to be clear, it is what I saw as well. I did not get permanent
> -EBUSY and I could umount /mnt if I run `umount /mnt` twice.
> 
> And I did not do git bisect. I had doubts in the code so I found the
> specific commit to revert it and it worked. But if it is some other
> commit in the middle, I could have missed it.
> 
> My theory to blame aba809cf0944 is that in
> do_umount()->shrink_submounts()->umount_tree(), it transfers parent
> mnt refcount (held by child mnt) to mnt_ex_mountpoint but that is put
> _after_ do_umount() calls propagate_mount_busy(mnt, 2). So
> propagate_mount_busy() would fail do_refcount_check(). Does it make
> sense to you?

Of course; the question is what to do with that.  The root of the problem
is in ordering constraints on fs shutdown and dput() of mountpoints.  What
we have right now solves that by holding "ghost" reference to parent vfsmount
until namespace_unlock(), where we drop them after having done that dput().

The constrants are
	* dput() of mountpoint should happen only after we'd dropped namespace
lock - we really don't want any IO under it.
	* it should happen before fs containing that mountpoint gets shut down.
	* non-lazy umount(2) should not return until all filesystems it
will shut down are, indeed, shut down

FWIW, I suspect that the simplest solution is this:
	* decrement parent's refcount when detaching a child from it in
umount_tree()
	* in namespace_unlock(), _before_ dropping the rwsem, go through the
list of victims and bump refcounts on their parents.  Note that those could
not have been shut down, let alone freed yet - either we are the ones to
take the parent out, in which case its refcount won't get to zero until
namespace_unlock() regardless of the children, or we are not.  In which case
its ->mnt_ns is non-NULL and will stay that way until rwsem is dropped (and
its refcount is also guaranteed to stay positive, not that mntput() would
bother checking that with non-NULL ->mnt_ns).

It does give a window when parent looks busy - from dropping rwsem in
namespace_unlock() to the moment when we get to the (ex-)child in the
loop there.  So what?  It doesn't affect the busy checks for that syscall -
we'd already done them all.  It doesn't affect the busy checks for anything
we do after returning from that syscall - namespace_unlock() completes before
we return to userland and all is good.  And if another process calls umount()
before ours return...  Well, it gets its EBUSY - same as it would if it got
there just as the first one has finished finding the mountpoint of child.
Two processes playing with umount(2) on the same area in the tree without
serialization should be ready to see the damn things transiently busy, simply
from another process looking at its victims...

IOW, how about this (completely untested)?  That's on top of that commit
from -next, but those two should be easy to backport to older trees
(->mnt_mp_list won't be there for those, but that's about it).

diff --git a/fs/namespace.c b/fs/namespace.c
index 3733cfb..00e5b1e 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1299,6 +1299,11 @@ static void namespace_unlock(void)
 	head.first->pprev = &head.first;
 	INIT_HLIST_HEAD(&unmounted);
 
+	/* undo decrements we'd done in umount_tree() */
+	hlist_for_each_entry(mnt, &head, mnt_hash)
+		if (mnt->mnt_ex_mountpoint.mnt)
+			mntget(mnt->mnt_ex_mountpoint.mnt);
+
 	up_write(&namespace_sem);
 
 	synchronize_rcu();
@@ -1351,6 +1356,7 @@ void umount_tree(struct mount *mnt, int how)
 		if (mnt_has_parent(p)) {
 			hlist_del_init(&p->mnt_mp_list);
 			put_mountpoint(p->mnt_mp);
+			mnt_add_count(p->mnt_parent, -1);
 			/* move the reference to mountpoint into ->mnt_ex_mountpoint */
 			p->mnt_ex_mountpoint.dentry = p->mnt_mountpoint;
 			p->mnt_ex_mountpoint.mnt = &p->mnt_parent->mnt;
