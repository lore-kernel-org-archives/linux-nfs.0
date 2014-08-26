Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f174.google.com ([209.85.212.174]:55930 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755234AbaHZOKR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 10:10:17 -0400
Received: by mail-wi0-f174.google.com with SMTP id d1so4278974wiv.1
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 07:10:15 -0700 (PDT)
Message-ID: <53FC9545.4000800@plexistor.com>
Date: Tue, 26 Aug 2014 17:10:13 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>
CC: linux-nfs@vger.kernel.org, Matt Benjamin <matt@linuxbox.com>
Subject: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
References: <1408637375-11343-1-git-send-email-hch@lst.de> <1408637375-11343-4-git-send-email-hch@lst.de> <53FA259C.9050807@gmail.com> <20140824191839.GA9717@lst.de>
In-Reply-To: <20140824191839.GA9717@lst.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Boaz Harrosh <boaz@plexistor.com>

This fixes a dead-lock in the pnfs recall processing

pnfs_layoutcommit_inode() is called through update_inode()
called from VFS. By setting set_inode_dirty during
pnfs write IO.

But the VFS will not schedule another update_inode()
If it is already inside an update_inode() or an sb-writeback

As part of writeback pnfs code might get stuck in LAYOUT_GET
with the server returning ERR_RECALL_CONFLICT because some
operation has caused the server to RECALL all layouts, including
those from our client.

So the RECALL is received, but our client is returning ERR_DELAY
because its write-segments need a LAYOUT_COMMIT, but
pnfs_layoutcommit_inode will never come because it is scheduled
behind the LAYOUT_GET which is stuck waiting for the recall to
finish

Hence the deadlock, client is stuck polling LAYOUT_GET receiving
ERR_RECALL_CONFLICT. Server is stuck polling RECALL receiving
ERR_DELAY.

With pnfs-objects the above condition can easily happen, when
a file grows beyond a group of devices. The pnfs-objects-server
will RECALL all layouts because the file-objects-map will
change and all old layouts will have stale attributes, therefor
the RECALL is initiated as part of a LAYOUT_GET, and this can
be triggered from within a single client operation.

A simple solution is to kick out a pnfs_layoutcommit_inode()
from within the recall, to free any need-to-commit segments
and let the client return success on the RECALL, so streaming
can continue.

This patch Is based on 3.17-rc1. It is completely UNTESTED.
I have tested a version of this patch at around the 3.12 Kernel
at which point the deadlock was resolved but I hit some race
conditions on pnfs state management farther on, so the actual
overall processing was not fixed. But hopefully these were fixed
by Trond and Christoph, and it should work better now.

Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 fs/nfs/callback_proc.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 41db525..8660f96 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -171,6 +171,14 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		goto out;
 
 	ino = lo->plh_inode;
+
+	spin_lock(&ino->i_lock);
+	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
+	spin_unlock(&ino->i_lock);
+
+	/* kick out any segs held by need to commit */
+	pnfs_layoutcommit_inode(ino, true);
+
 	spin_lock(&ino->i_lock);
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 	    pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
@@ -178,7 +186,6 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		rv = NFS4ERR_DELAY;
 	else
 		rv = NFS4ERR_NOMATCHING_LAYOUT;
-	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
 	pnfs_put_layout_hdr(lo);
-- 
1.9.3


