Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:35114 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757819Ab2FHWZw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2012 18:25:52 -0400
Date: Fri, 8 Jun 2012 15:25:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Boaz Harrosh <bharrosh@panasas.com>, Tao Ma <boyu.mt@taobao.com>,
        Nick Piggin <npiggin@kernel.dk>, "Dmitry V. Levin" <ldv@altlinux.org>,
        v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        codalist@TELEMANN.coda.cs.cmu.edu, ecryptfs@vger.kernel.org,
        osd-dev@open-osd.org, linux-ext4@vger.kernel.org,
        fuse-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        jfs-discussion@lists.sourceforge.net, logfs@logfs.org,
        linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com,
        reiserfs-devel@vger.kernel.org
Subject: Re: [RFC, PATCH, RESEND] fs: push rcu_barrier() from
 deactivate_locked_super() to filesystems
Message-Id: <20120608152550.258d6a30.akpm@linux-foundation.org>
In-Reply-To: <20120608221446.GA18250@otc-wbsnb-06>
References: <1339191663-17693-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20120608150253.e42464a6.akpm@linux-foundation.org>
	<20120608221446.GA18250@otc-wbsnb-06>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 9 Jun 2012 01:14:46 +0300
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> On Fri, Jun 08, 2012 at 03:02:53PM -0700, Andrew Morton wrote:
> > On Sat,  9 Jun 2012 00:41:03 +0300
> > "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > There's no reason to call rcu_barrier() on every deactivate_locked_super().
> > > We only need to make sure that all delayed rcu free inodes are flushed
> > > before we destroy related cache.
> > > 
> > > Removing rcu_barrier() from deactivate_locked_super() affects some
> > > fas paths. E.g. on my machine exit_group() of a last process in IPC
> > > namespace takes 0.07538s. rcu_barrier() takes 0.05188s of that time.
> > 
> > What an unpleasant patch.  Is final-process-exiting-ipc-namespace a
> > sufficiently high-frequency operation to justify the change?

This, please.

> > I don't really understand what's going on here.  Are you saying that
> > there is some filesystem against which we run deactivate_locked_super()
> > during exit_group(), and that this filesystem doesn't use rcu-freeing
> > of inodes?  The description needs this level of detail, please.

You still haven't explained where this deactivate_locked_super() call
is coming from.  Oh well.

> I think the rcu_barrier() is in wrong place. We need it to safely destroy
> inode cache. deactivate_locked_super() is part of umount() path, but all
> filesystems I've checked have inode cache for whole filesystem, not
> per-mount.

Well from a design perspective, putting the rcu_barrier() in the vfs is
the *correct* place.  Individual filesystems shouldn't be hard-coding
knowledge about vfs internal machinery.

A neater implementation might be to add a kmem_cache* argument to
unregister_filesystem().  If that is non-NULL, unregister_filesystem()
does the rcu_barrier() and destroys the cache.  That way we get to
delete (rather than add) a bunch of code from all filesystems and new
and out-of-tree filesystems cannot forget to perform the rcu_barrier().

> > The implementation would be less unpleasant if we could do the
> > rcu_barrier() in kmem_cache_destroy().  I can't see a way of doing that
> > without adding a dedicated slab flag, which would require editing all
> > the filesystems anyway.
> 
> I think rcu_barrier() for all kmem_cache_destroy() would be too expensive.

That is not what I proposed.
