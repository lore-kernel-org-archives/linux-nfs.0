Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:32699 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751894Ab1C1FTf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2011 01:19:35 -0400
Date: Mon, 28 Mar 2011 16:19:28 +1100
From: Dave Chinner <david@fromorbit.com>
To: Ryan Mallon <ryan@bluewatersys.com>
Cc: Matthew Wilcox <matthew@wil.cx>, viro@zeniv.linux.org.uk,
        dchinner@redhat.com, Trond.Myklebust@netapp.com,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH] fs: don't use igrab() while holding i_lock (was Re: [RFC
 PATCH 1/2] Add unlocked version of igrab.)
Message-ID: <20110328051928.GB1022@dastard>
References: <1301277361-9453-1-git-send-email-ryan@bluewatersys.com>
 <1301277361-9453-2-git-send-email-ryan@bluewatersys.com>
 <20110328025423.GN13806@parisc-linux.org>
 <4D9010F1.1040909@bluewatersys.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D9010F1.1040909@bluewatersys.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 28, 2011 at 05:39:13PM +1300, Ryan Mallon wrote:
> On 03/28/2011 03:54 PM, Matthew Wilcox wrote:
> > On Mon, Mar 28, 2011 at 02:56:00PM +1300, Ryan Mallon wrote:
> >> Commit 250df6ed274d767da844a5d9f05720b804240197 "fs: protect
> >> inode->i_state with inode->i_lock" changes igrab to acquire inode->i_lock,
> >> however some callees, notably nfs_inode_add_request, already hold the lock
> >> when calling igrab.
> > 
> > I think a better solution to your problem is to notice that this is
> > called in the context of doing a write to an inode.  That means we
> > must already have a reference count on this inode, so it can't possibly
> > be in I_FREEING or I_WILL_FREE.  That means we can just call __iget()
> > instead ... except that __iget isn't exported to modules.
> 
> Ah, okay. Thanks for the hint.
> 
> A few other locations that I can see that call igrab with inode->i_lock
> held are:
> 
>   fs/ceph/snap.c::ceph_queue_cap_snap
>   fs/ceph/addr.c::ceph_set_page_dirty

I don't know how I missed these uses when auditing Nick's code - we
caught the use of the dcache_lock inside i_lock and got that fixed,
but missed these ones.

>   fs/nfs/nfs4state.c::nfs4_get_open_state

I know I fixed this one once, along with the first NFS issue you
tripped over. Somehow I lost them along the way.

> There may be some more cases where the locking is less obvious. I don't
> know enough about the filesystem code to say whether each of those can
> skip the (I_FREEING | I_WILL_FREE) check, or whether the correct
> approach is to modify the filesystems themselves so that they do not
> hold i_lock when calling igrab (i.e. rework to use a different outer lock)?
> 
> If the correct approach is to use __iget or __igrab then I can prepare a
> patch for this. In the case of __iget, should it just be marked
> EXPORT_SYMBOL and added to include/linux/fs.h?

All of them should simply be a conversion from igrab() to ihold(),
which is already exported. Patch below for all 4 you've reported.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

fs: don't use igrab() while holding i_lock

From: Dave Chinner <dchinner@redhat.com>

If we are already holding the i_lock, we have a reference to the
inode so we can safely use ihold() to gain an extra reference. This
avoids hangs due to lock recursion on the i_lock.

Reviewed-by: Dave Chinner <dchinner@redhat.com>
---
 fs/ceph/addr.c     |    2 +-
 fs/ceph/snap.c     |    4 ++--
 fs/nfs/nfs4state.c |    2 +-
 fs/nfs/write.c     |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 561438b..37368ba 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -92,7 +92,7 @@ static int ceph_set_page_dirty(struct page *page)
 		ci->i_head_snapc = ceph_get_snap_context(snapc);
 	++ci->i_wrbuffer_ref_head;
 	if (ci->i_wrbuffer_ref == 0)
-		igrab(inode);
+		ihold(inode);
 	++ci->i_wrbuffer_ref;
 	dout("%p set_page_dirty %p idx %lu head %d/%d -> %d/%d "
 	     "snapc %p seq %lld (%d snaps)\n",
diff --git a/fs/ceph/snap.c b/fs/ceph/snap.c
index f40b913..0aee66b 100644
--- a/fs/ceph/snap.c
+++ b/fs/ceph/snap.c
@@ -463,8 +463,8 @@ void ceph_queue_cap_snap(struct ceph_inode_info *ci)
 
 		dout("queue_cap_snap %p cap_snap %p queuing under %p\n", inode,
 		     capsnap, snapc);
-		igrab(inode);
-		
+		ihold(inode);
+
 		atomic_set(&capsnap->nref, 1);
 		capsnap->ci = ci;
 		INIT_LIST_HEAD(&capsnap->ci_item);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index ab1bf5b..da6e895 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -590,7 +590,7 @@ nfs4_get_open_state(struct inode *inode, struct nfs4_state_owner *owner)
 		state->owner = owner;
 		atomic_inc(&owner->so_count);
 		list_add(&state->inode_states, &nfsi->open_states);
-		state->inode = igrab(inode);
+		state->inode = ihold(inode);
 		spin_unlock(&inode->i_lock);
 		/* Note: The reclaim code dictates that we add stateless
 		 * and read-only stateids to the end of the list */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 85d7525..3236951 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -390,7 +390,7 @@ static int nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	error = radix_tree_insert(&nfsi->nfs_page_tree, req->wb_index, req);
 	BUG_ON(error);
 	if (!nfsi->npages) {
-		igrab(inode);
+		ihold(inode);
 		if (nfs_have_delegation(inode, FMODE_WRITE))
 			nfsi->change_attr++;
 	}
