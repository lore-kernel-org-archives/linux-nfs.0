Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53797 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755077Ab1BCS3A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Feb 2011 13:29:00 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/3] pnfs: avoid incorrect use of layout stateid
Date: Thu,  3 Feb 2011 13:28:50 -0500
Message-Id: <1296757732-16261-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1296757732-16261-1-git-send-email-iisaman@netapp.com>
References: <1296757732-16261-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The code could violate the following from RFC5661, section 12.5.3:
"Once a client has no more layouts on a file, the layout stateid is no
longer valid and MUST NOT be used."

This can occur when a layout already has a lseg, starts another
non-everlapping LAYOUTGET, and a CB_LAYOUTRECALL for the existing lseg
is processed before we hit pnfs_layout_process().

Solve by setting, each time the client has no more lsegs for a file, a
flag which blocks further use of the layout and triggers its removal.

This also fixes a second bug which occurs in the same instance as
above.  If we actually use pnfs_layout_process, we add the new lseg to
the layout, but the layout has been removed from the nfs_client list
by the intervening CB_LAYOUTRECALL and will not be added back.  Thus
the newly acquired lseg will not be properly returned in the event of
a subsequent CB_LAYOUTRECALL.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1b1bc1a..c8d9b21 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -255,6 +255,9 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
 			list_del_init(&lseg->pls_layout->plh_layouts);
 			spin_unlock(&clp->cl_lock);
 			clear_bit(NFS_LAYOUT_BULK_RECALL, &lseg->pls_layout->plh_flags);
+			set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
+			/* Matched by initial refcount set in alloc_init_layout_hdr */
+			put_layout_hdr_locked(lseg->pls_layout);
 		}
 		rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq);
 		list_add(&lseg->pls_list, tmp_list);
@@ -299,6 +302,11 @@ mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 
 	dprintk("%s:Begin lo %p\n", __func__, lo);
 
+	if (list_empty(&lo->plh_segs)) {
+		if (!test_and_set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags))
+			put_layout_hdr_locked(lo);
+		return 0;
+	}
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
 		if (should_free_lseg(lseg->pls_range.iomode, iomode)) {
 			dprintk("%s: freeing lseg %p iomode %d "
@@ -332,10 +340,8 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	lo = nfsi->layout;
 	if (lo) {
-		set_bit(NFS_LAYOUT_DESTROYED, &nfsi->layout->plh_flags);
+		lo->plh_block_lgets++; /* permanently block new LAYOUTGETs */
 		mark_matching_lsegs_invalid(lo, &tmp_list, IOMODE_ANY);
-		/* Matched by refcount set to 1 in alloc_init_layout_hdr */
-		put_layout_hdr_locked(lo);
 	}
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	pnfs_free_lseg_list(&tmp_list);
@@ -403,6 +409,7 @@ pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
 	    (int)(lo->plh_barrier - be32_to_cpu(stateid->stateid.seqid)) >= 0)
 		return true;
 	return lo->plh_block_lgets ||
+		test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags) ||
 		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 		(list_empty(&lo->plh_segs) &&
 		 (atomic_read(&lo->plh_outstanding) > lget));
-- 
1.7.2.1

