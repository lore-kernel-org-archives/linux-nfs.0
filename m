From: andros@netapp.com
Subject: [PATCH 4/5] pnfsd: fix DLM file layout no device return
Date: Fri,  5 Feb 2010 12:10:12 -0500
Message-ID: <1265389813-6823-5-git-send-email-andros@netapp.com>
References: <1265389813-6823-1-git-send-email-andros@netapp.com>
 <1265389813-6823-2-git-send-email-andros@netapp.com>
 <1265389813-6823-3-git-send-email-andros@netapp.com>
 <1265389813-6823-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933516Ab0BERJg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 12:09:36 -0500
In-Reply-To: <1265389813-6823-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4pnfsdlm.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 8cc7c84..83c4698 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -316,7 +316,7 @@ static int dlm_ino_hash(struct inode *ino)
 	 */
 	de = nfsd4_find_pnfs_dlm_device(ino->i_sb->s_bdev->bd_disk->disk_name);
 	if (!de)
-		return -EINVAL;
+		return -1;
 	hash_mask = de->num_ds - 1;
 	return ino->i_ino & hash_mask;
 }
@@ -340,7 +340,7 @@ static int nfsd4_pnfs_dlm_layoutget(struct inode *inode,
 	dprintk("%s first stripe index %d i_ino %lu\n", __func__, index,
 		inode->i_ino);
 	if (index < 0)
-		return index;
+		return nfserr_layoutunavailable;
 
 	res->lg_seg.layout_type = LAYOUT_NFSV4_FILES;
 	/* Always give out whole file layouts */
-- 
1.6.6

