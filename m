Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56826 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751922AbbEHAuc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 20:50:32 -0400
From: NeilBrown <neilb@suse.de>
To: Josef Bacik <jbacik@fb.com>, Chris Mason <clm@fb.com>,
        Jan Kara <jack@suse.cz>, David Sterba <dsterba@suse.cz>,
        Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Date: Fri, 08 May 2015 10:16:23 +1000
Subject: [PATCH 2/3] NILFS2: support NFSv2 export
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-nilfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Message-ID: <20150508001623.31129.25102.stgit@notabene.brown>
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
 fs/nilfs2/namei.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nilfs2/namei.c b/fs/nilfs2/namei.c
index 22180836ec22..b65fb79d16fd 100644
--- a/fs/nilfs2/namei.c
+++ b/fs/nilfs2/namei.c
@@ -496,8 +496,8 @@ static struct dentry *nilfs_fh_to_dentry(struct super_block *sb, struct fid *fh,
 {
 	struct nilfs_fid *fid = (struct nilfs_fid *)fh;
 
-	if ((fh_len != NILFS_FID_SIZE_NON_CONNECTABLE &&
-	     fh_len != NILFS_FID_SIZE_CONNECTABLE) ||
+	if ((fh_len < NILFS_FID_SIZE_NON_CONNECTABLE &&
+	     fh_len < NILFS_FID_SIZE_CONNECTABLE) ||
 	    (fh_type != FILEID_NILFS_WITH_PARENT &&
 	     fh_type != FILEID_NILFS_WITHOUT_PARENT))
 		return NULL;
@@ -510,7 +510,7 @@ static struct dentry *nilfs_fh_to_parent(struct super_block *sb, struct fid *fh,
 {
 	struct nilfs_fid *fid = (struct nilfs_fid *)fh;
 
-	if (fh_len != NILFS_FID_SIZE_CONNECTABLE ||
+	if (fh_len < NILFS_FID_SIZE_CONNECTABLE ||
 	    fh_type != FILEID_NILFS_WITH_PARENT)
 		return NULL;
 


