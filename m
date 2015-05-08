Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56817 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918AbbEHAuX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 20:50:23 -0400
From: NeilBrown <neilb@suse.de>
To: Josef Bacik <jbacik@fb.com>, Chris Mason <clm@fb.com>,
        Jan Kara <jack@suse.cz>, David Sterba <dsterba@suse.cz>,
        Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Date: Fri, 08 May 2015 10:16:23 +1000
Subject: [PATCH 1/3] BTRFS: support NFSv2 export
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-nilfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Message-ID: <20150508001623.31129.91695.stgit@notabene.brown>
In-Reply-To: <20150508001142.31129.7604.stgit@notabene.brown>
References: <20150508001142.31129.7604.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The "fh_len" passed to ->fh_to_* is not guaranteed to be that same as
that returned by encode_fh - it may be larger.

With NFSv2, the filehandle is fixed length, so it may appear longer
than expected and be zero-padded.

So we must test that fh_len is at least some value, not exactly equal
to it.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/btrfs/export.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/btrfs/export.c b/fs/btrfs/export.c
index 8d052209f473..2513a7f53334 100644
--- a/fs/btrfs/export.c
+++ b/fs/btrfs/export.c
@@ -112,11 +112,11 @@ static struct dentry *btrfs_fh_to_parent(struct super_block *sb, struct fid *fh,
 	u32 generation;
 
 	if (fh_type == FILEID_BTRFS_WITH_PARENT) {
-		if (fh_len !=  BTRFS_FID_SIZE_CONNECTABLE)
+		if (fh_len <  BTRFS_FID_SIZE_CONNECTABLE)
 			return NULL;
 		root_objectid = fid->root_objectid;
 	} else if (fh_type == FILEID_BTRFS_WITH_PARENT_ROOT) {
-		if (fh_len != BTRFS_FID_SIZE_CONNECTABLE_ROOT)
+		if (fh_len < BTRFS_FID_SIZE_CONNECTABLE_ROOT)
 			return NULL;
 		root_objectid = fid->parent_root_objectid;
 	} else
@@ -136,11 +136,11 @@ static struct dentry *btrfs_fh_to_dentry(struct super_block *sb, struct fid *fh,
 	u32 generation;
 
 	if ((fh_type != FILEID_BTRFS_WITH_PARENT ||
-	     fh_len != BTRFS_FID_SIZE_CONNECTABLE) &&
+	     fh_len < BTRFS_FID_SIZE_CONNECTABLE) &&
 	    (fh_type != FILEID_BTRFS_WITH_PARENT_ROOT ||
-	     fh_len != BTRFS_FID_SIZE_CONNECTABLE_ROOT) &&
+	     fh_len < BTRFS_FID_SIZE_CONNECTABLE_ROOT) &&
 	    (fh_type != FILEID_BTRFS_WITHOUT_PARENT ||
-	     fh_len != BTRFS_FID_SIZE_NON_CONNECTABLE))
+	     fh_len < BTRFS_FID_SIZE_NON_CONNECTABLE))
 		return NULL;
 
 	objectid = fid->objectid;


