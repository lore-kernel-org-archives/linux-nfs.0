Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56832 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751922AbbEHAul (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 20:50:41 -0400
From: NeilBrown <neilb@suse.de>
To: Josef Bacik <jbacik@fb.com>, Chris Mason <clm@fb.com>,
        Jan Kara <jack@suse.cz>, David Sterba <dsterba@suse.cz>,
        Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Date: Fri, 08 May 2015 10:16:23 +1000
Subject: [PATCH 3/3] UDF: support NFSv2 export
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-nilfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Message-ID: <20150508001623.31129.24710.stgit@notabene.brown>
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
 fs/udf/namei.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/udf/namei.c b/fs/udf/namei.c
index 5c03f0dfb98b..facc2a840f7b 100644
--- a/fs/udf/namei.c
+++ b/fs/udf/namei.c
@@ -1221,7 +1221,7 @@ static struct dentry *udf_nfs_get_inode(struct super_block *sb, u32 block,
 static struct dentry *udf_fh_to_dentry(struct super_block *sb,
 				       struct fid *fid, int fh_len, int fh_type)
 {
-	if ((fh_len != 3 && fh_len != 5) ||
+	if (fh_len < 3 ||
 	    (fh_type != FILEID_UDF_WITH_PARENT &&
 	     fh_type != FILEID_UDF_WITHOUT_PARENT))
 		return NULL;
@@ -1233,7 +1233,7 @@ static struct dentry *udf_fh_to_dentry(struct super_block *sb,
 static struct dentry *udf_fh_to_parent(struct super_block *sb,
 				       struct fid *fid, int fh_len, int fh_type)
 {
-	if (fh_len != 5 || fh_type != FILEID_UDF_WITH_PARENT)
+	if (fh_len < 5 || fh_type != FILEID_UDF_WITH_PARENT)
 		return NULL;
 
 	return udf_nfs_get_inode(sb, fid->udf.parent_block,


