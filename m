Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:55068 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbaDPEqW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Apr 2014 00:46:22 -0400
Date: Wed, 16 Apr 2014 05:46:18 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 17/19] VFS: set PF_FSTRANS while namespace_sem is held.
Message-ID: <20140416044618.GX18016@ZenIV.linux.org.uk>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416040337.10604.86740.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140416040337.10604.86740.stgit@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 16, 2014 at 02:03:37PM +1000, NeilBrown wrote:
> namespace_sem can be taken while various i_mutex locks are held, so we
> need to avoid reclaim from blocking on an FS (particularly loop-back
> NFS).

I would really prefer to deal with that differently - by explicit change of
gfp_t arguments of allocators.

The thing is, namespace_sem is held *only* over allocations, and not a lot
of them, at that - only mnt_alloc_id(), mnt_alloc_group_id(), alloc_vfsmnt()
and new_mountpoint().  That is all that is allowed.

Again, actual work with filesystems (setup, shutdown, remount, pathname
resolution, etc.) is all done outside of namespace_sem; it's held only
for manipulations of fs/{namespace,pnode}.c data structures and the only
reason it isn't a spinlock is that we need to do some allocations.

So I'd rather slap GFP_NOFS on those few allocations...
