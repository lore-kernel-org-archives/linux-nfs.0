Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38894 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754327AbaDPEUF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2014 00:20:05 -0400
From: NeilBrown <neilb@suse.de>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 16 Apr 2014 14:03:37 +1000
Subject: [PATCH 19/19] XFS: set PF_FSTRANS while ilock is held in
 xfs_free_eofblocks
Cc: xfs@oss.sgi.com
Message-ID: <20140416040337.10604.7488.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

memory allocates can happen while the xfs ilock is held in
xfs_free_eofblocks, particularly

  [<ffffffff813e6667>] kmem_zone_alloc+0x67/0xc0
  [<ffffffff813e5945>] xfs_trans_add_item+0x25/0x50
  [<ffffffff8143d64c>] xfs_trans_ijoin+0x2c/0x60
  [<ffffffff8142275e>] xfs_itruncate_extents+0xbe/0x400
  [<ffffffff813c72f4>] xfs_free_eofblocks+0x1c4/0x240

So set PF_FSTRANS to avoid this causing a deadlock.

Care is needed here as xfs_trans_reserve() also sets PF_FSTRANS, while
xfs_trans_cancel and xfs_trans_commit will clear it.
So our extra setting must fully nest these calls.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/xfs/xfs_bmap_util.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
index f264616080ca..53761fe4fada 100644
--- a/fs/xfs/xfs_bmap_util.c
+++ b/fs/xfs/xfs_bmap_util.c
@@ -889,6 +889,7 @@ xfs_free_eofblocks(
 	xfs_filblks_t	map_len;
 	int		nimaps;
 	xfs_bmbt_irec_t	imap;
+	unsigned int pflags;
 
 	/*
 	 * Figure out if there are any blocks beyond the end
@@ -929,12 +930,14 @@ xfs_free_eofblocks(
 			}
 		}
 
+		current_set_flags_nested(&pflags, PF_FSTRANS);
 		error = xfs_trans_reserve(tp, &M_RES(mp)->tr_itruncate, 0, 0);
 		if (error) {
 			ASSERT(XFS_FORCED_SHUTDOWN(mp));
 			xfs_trans_cancel(tp, 0);
 			if (need_iolock)
 				xfs_iunlock(ip, XFS_IOLOCK_EXCL);
+			current_restore_flags_nested(&pflags, PF_FSTRANS);
 			return error;
 		}
 
@@ -964,6 +967,7 @@ xfs_free_eofblocks(
 				xfs_inode_clear_eofblocks_tag(ip);
 		}
 
+		current_restore_flags_nested(&pflags, PF_FSTRANS);
 		xfs_iunlock(ip, XFS_ILOCK_EXCL);
 		if (need_iolock)
 			xfs_iunlock(ip, XFS_IOLOCK_EXCL);


